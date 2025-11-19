# qPCR Download Functionality Implementation Documentation

## Overview

This document describes the implementation of dual qPCR template download functionality for SampleDB, allowing users to export plate data in both **QuantStudio** and **BioRad** formats. The feature enables researchers to generate standardized qPCR template files directly from the SampleDB interface for use with their respective thermocycler platforms.

---

## What Was Implemented

### 1. Dual Format Support
- **QuantStudio Format**: Tab-delimited `.txt` file compatible with Applied Biosystems QuantStudio thermocyclers
- **BioRad Format**: Tab-delimited `.txt` file compatible with BioRad CFX thermocyclers

### 2. User Interface Enhancements
- Added dropdown menu with two download options in the Search, Delete & Archive page
- Integrated download buttons that trigger validation and data processing workflows
- Visual plate layout preview modal before download

### 3. Data Processing Pipeline
- Comprehensive plate validation (96-well plate structure)
- Control sample recognition and positioning
- Automatic filling of missing wells with blanks/NTC
- Density validation with user warnings
- Standard control position enforcement

---

## Code Changes and Implementation Details

### File: `inst/sampleDB/ui_helpers/UISearchDelArchSamples.R`

#### UI Component Addition (Lines 150-160)

**What Changed:**
- Replaced single download button with a Bootstrap dropdown menu containing two options

**Code Added:**
```r
tags$button(
  class = "btn btn-primary dropdown-toggle",
  type = "button",
  `data-bs-toggle` = "dropdown",
  `aria-expanded` = "false"
),
tags$ul(
  class = "dropdown-menu",
  tags$li(actionButton("download_qpcr_quantstudio", "Download qPCR Format (QuantStudio)", class = "dropdown-item")),
  tags$li(actionButton("download_qpcr_biorad", "Download qPCR Format (BioRad)", class = "dropdown-item"))
)
```

**How It Works:**
- Creates a dropdown button that expands to show two action buttons
- Each button triggers a different download workflow (`download_qpcr_quantstudio` or `download_qpcr_biorad`)
- Uses Bootstrap classes for styling and dropdown functionality

---

### File: `inst/sampleDB/server_helpers/AppSearchDelArchSamples.R`

## 1. Download Handlers (Lines 1216-1291)

### QuantStudio Download Handler

**Location:** Lines 1217-1253

**Code:**
```r
observe({
  output$download_qpcr_csv <- downloadHandler(
    filename = function() {
      plate_name <- qpcr_final_data()$PlateName
      paste0("qPCR_QuantStudio_", plate_name, "_", Sys.Date(), ".txt")
    },
    content = function(file) {
      output_header <- matrix(c("[Sample Setup]"), byrow = TRUE)
      qpcr_names <- matrix(colnames(qpcr_final_data()$FinalData), byrow = FALSE, nrow = 1)
      final_data <- qpcr_final_data()$FinalData
      colnames(final_data) <- NULL
      
      # Combine header, column names, and data into single matrix
      final_matrix <- matrix(NA, nrow = nrow(output_header_tbl) + nrow(qpcr_names) + nrow(final_data_tbl), ncol = max_cols)
      final_matrix[1:nrow(output_header_tbl), 1:ncol(output_header_tbl)] <- output_header_tbl
      final_matrix[(nrow(output_header_tbl) + 1):(nrow(output_header_tbl) + nrow(qpcr_names)), 1:ncol(qpcr_names)] <- qpcr_names
      final_matrix[(nrow(output_header_tbl) + nrow(qpcr_names) + 1):nrow(final_matrix), 1:ncol(final_data_tbl)] <- final_data_tbl
      
      # Write tab-delimited file
      write.table(final_matrix, file=file, row.names=FALSE, col.names=FALSE, na = "", quote = FALSE, sep = "\t")
    }
  )
})
```

**How It Works:**
1. **Filename Generation**: Creates filename with pattern `qPCR_QuantStudio_[PlateName]_[Date].txt`
2. **Header Creation**: Adds `[Sample Setup]` header required by QuantStudio
3. **Data Formatting**: 
   - Extracts column names as first data row
   - Removes column names from data matrix
   - Combines header, column names, and data into single matrix
4. **File Writing**: Writes tab-delimited text file with no row names, no quotes, and empty strings for NA values

### BioRad Download Handler

**Location:** Lines 1256-1291

**Code:**
```r
output$download_qpcr_biorad_csv <- downloadHandler(
  filename = function() {
    plate_name <- qpcr_final_data()$PlateName
    paste0("qPCR_BioRad_", plate_name, "_", Sys.Date(), ".txt")
  },
  content = function(file) {
    # Same structure as QuantStudio but with BioRad-specific filename
    # ... (identical content processing)
  }
)
```

**How It Works:**
- Identical data processing to QuantStudio
- Only difference is filename pattern: `qPCR_BioRad_[PlateName]_[Date].txt`
- Both formats use the same tab-delimited structure with `[Sample Setup]` header

---

## 2. Standard Values Definition (Lines 1294-1300)

**Code:**
```r
standard_values <- reactive({
  data.frame(
    Position = c(paste0(rep(LETTERS[1:8], each = 2), sprintf("%02d", rep(11:12, times = 8)))),
    Density = c("10000", "10000", "1000", "1000", "100", "100",
                "10", "10", "1", "1", "0.1", "0.1", "0", "0", "NTC", "NTC")
  )
})
```

**What It Does:**
- Defines standard control positions in columns 11-12 (last two columns of 96-well plate)
- Maps expected densities: A11-A12 (10000), B11-B12 (1000), C11-C12 (100), D11-D12 (10), E11-E12 (1), F11-F12 (0.1), G11-G12 (0), H11-H12 (NTC)
- Used for validation and automatic control recognition

---

## 3. QuantStudio Download Logic (Lines 1308-1369)

### Main Event Handler

**Code:**
```r
observeEvent(input$download_qpcr_quantstudio, ignoreInit = TRUE, {
  message(sprintf("Starting qPCR template download process (QuantStudio)..."))
  showNotification("Fetching data for qPCR template...", id = "qPCRNotification", type = "message", duration = 5, closeButton = FALSE)
  
  user.filtered.rows <- filtered_data()
  user.selected.rows <- if (length(selected() > 0)) user.filtered.rows[selected(), ] else user.filtered.rows
  
  unique_plates <- unique(user.selected.rows$`Plate Name`)
  num_unique_plates <- length(unique_plates)
  
  if (num_unique_plates > 1) {
    showModal(modalDialog(
      title = "Too many plates selected!",
      sprintf("Only one plate is allowed at a time! There were %d plates found in the search table.", num_unique_plates),
      easyClose = TRUE,
      footer = modalButton("OK")
    ))
    return(NULL)
  }
  
  required_wells <- paste0(rep(LETTERS[1:8], each = 10), sprintf("%02d", rep(1:10, times = 8)))
  user_wells <- unique(user.selected.rows$Position)
  missing_wells <- setdiff(required_wells, user_wells)
  
  if (length(missing_wells) > 0) {
    showModal(modalDialog(
      title = "Missing Wells Detected",
      paste("The following wells are missing samples:", paste(missing_wells, collapse = ", ")),
      paste("Is this okay?"),
      easyClose = TRUE,
      footer = tagList(
        actionButton("qpcr_check_conflicts", "Yes, continue!"),
        modalButton("qpcr_exit")
      )
    ))
  } else {
    check_conflicts(user.selected.rows, standard_values(), output)
  }
})
```

**How It Works:**
1. **User Selection**: Gets filtered and selected rows from search results
2. **Plate Validation**: Ensures only one plate is selected (throws error if multiple)
3. **Well Validation**: 
   - For QuantStudio: Requires wells A1-H10 (80 wells)
   - Checks for missing wells and prompts user if found
4. **Conflict Checking**: Calls `check_conflicts()` function to validate plate layout

**Key Differences:**
- QuantStudio requires **80 wells** (A1-H10, columns 1-10)
- BioRad requires **96 wells** (A1-H12, all columns)

---

## 4. BioRad Download Logic (Lines 1372-1440)

**Code:**
```r
observeEvent(input$download_qpcr_biorad, ignoreInit = TRUE, {
  message("=== BioRad qPCR Download Process Started ===")
  message(sprintf("Starting qPCR template download process (BioRad)..."))
  showNotification("Fetching data for qPCR template (BioRad)...", id = "qPCRNotification", type = "message", duration = 5, closeButton = FALSE)
  
  user.filtered.rows <- filtered_data()
  user.selected.rows <- if (length(selected() > 0)) user.filtered.rows[selected(), ] else user.filtered.rows
  
  unique_plates <- unique(user.selected.rows$`Plate Name`)
  num_unique_plates <- length(unique_plates)
  
  if (num_unique_plates > 1) {
    showModal(modalDialog(
      title = "Too many plates selected!",
      sprintf("Only one plate is allowed at a time! There were %d plates found in the search table.", num_unique_plates),
      easyClose = TRUE,
      footer = modalButton("OK")
    ))
    return(NULL)
  }
  
  # Both QuantStudio and BioRad use 96-well plates
  required_wells <- paste0(rep(LETTERS[1:8], each = 12), sprintf("%02d", rep(1:12, times = 8)))
  user_wells <- unique(user.selected.rows$Position)
  missing_wells <- setdiff(required_wells, user_wells)
  
  if (length(missing_wells) > 0) {
    showModal(modalDialog(
      title = "Missing Wells Detected",
      paste("The following wells are missing samples:", paste(missing_wells, collapse = ", ")),
      paste("Is this okay?"),
      easyClose = TRUE,
      footer = tagList(
        actionButton("biorad_check_conflicts", "Yes, continue!"),
        modalButton("biorad_exit")
      )
    ))
  } else {
    check_conflicts(user.selected.rows, standard_values(), output)
  }
})
```

**Key Differences from QuantStudio:**
- Requires **all 96 wells** (A1-H12)
- Uses separate button IDs (`biorad_check_conflicts` vs `qpcr_check_conflicts`)
- Includes extensive debug logging for troubleshooting

---

## 5. Conflict Checking Function (Lines 1465-1687)

### Overview
The `check_conflicts()` function is the core validation and data processing engine that:
1. Validates plate structure
2. Recognizes control samples
3. Fills missing positions
4. Validates control positions and densities
5. Generates final export data

### Step-by-Step Process

#### Step 1: Database Connection and Data Joining (Lines 1468-1486)

```r
con <- init_and_copy_to_db(database, user_selected_rows)
on.exit(dbDisconnect(con), add = TRUE)

specimen_tbl <- con %>% tbl("specimen") %>% dplyr::rename(specimen_id = id)
study_subject_tbl <- con %>% tbl("study_subject") %>% dplyr::rename(study_subject_id = id)
malaria_blood_control_tbl <- con %>% tbl("malaria_blood_control") %>%
  dplyr::rename(malaria_blood_control_id = id)

linked_samples_data <- tbl(con, "user_data") %>%
  inner_join(con %>% tbl("storage_container"), by = c("Sample ID" = "id")) %>%
  inner_join(specimen_tbl, by = "specimen_id") %>%
  inner_join(study_subject_tbl, by = "study_subject_id") %>%
  left_join(malaria_blood_control_tbl, by = "study_subject_id") %>%
  mutate(IsControl = !is.na(malaria_blood_control_id)) %>%
  select(Position, `Sample ID`, Barcode, density, IsControl, `Specimen Type`, Comment) %>%
  collect() %>%
  mutate(`Sample ID` = as.integer(`Sample ID`))
```

**What It Does:**
- Creates temporary database connection with user-selected data
- Joins multiple tables to get complete sample information
- Identifies controls by checking for `malaria_blood_control_id`
- Extracts relevant columns for qPCR template

#### Step 2: Position-Based Control Recognition (Lines 1488-1506)

```r
linked_samples_data <- linked_samples_data %>%
  mutate(
    IsControl = ifelse(
      Position %in% standard_values_data$Position, 
      TRUE, 
      IsControl
    )
  )
```

**What It Does:**
- Marks samples in standard control positions (columns 11-12) as controls
- Ensures controls are recognized even if not in malaria_blood_control table
- Provides dual recognition: database-based and position-based

#### Step 3: Fill Missing Positions (Lines 1508-1525)

```r
all_positions <- paste0(rep(LETTERS[1:8], each = 12), sprintf("%02d", rep(1:12, times = 8)))
missing_positions <- setdiff(all_positions, linked_samples_data$Position)

if (length(missing_positions) > 0) {
  blanks <- data.frame(
    Position = missing_positions,
    Barcode = ifelse(missing_positions %in% standard_values_data$Position[standard_values_data$Density == "NTC"], "NTC", NA),
    density = NA,
    IsControl = ifelse(missing_positions %in% standard_values_data$Position[standard_values_data$Density == "NTC"], TRUE, FALSE),
    stringsAsFactors = FALSE
  ) %>%
  mutate(`Sample ID` = NA, `Specimen Type` = NA)
  
  linked_samples_data <- bind_rows(linked_samples_data, blanks) %>%
    arrange(Position)
}
```

**What It Does:**
- Generates all 96 well positions (A01-H12)
- Identifies missing positions
- Creates blank entries for missing positions
- Sets H11-H12 as "NTC" (Negative Template Control) if empty
- Ensures complete 96-well plate structure

#### Step 4: Control Position Processing (Lines 1527-1569)

**Row H Processing (Lines 1531-1534):**
```r
linked_samples_data <- linked_samples_data %>%
  mutate(IsControl = ifelse(grepl("^H(11|12)$", Position), TRUE, IsControl)) %>%
  filter(!(grepl("^H(11|12)$", Position) & !is.na(`Sample ID`)))
```
- Ensures row H, columns 11-12 are reserved for NTC
- Removes any existing samples from these positions

**Column 12 Control Copying (Lines 1541-1561):**
```r
if (nrow(controls_in_col_11) > 0 & nrow(empty_in_col_12) > 0) {
  linked_samples_data <- linked_samples_data %>%
    mutate(
      `Sample ID` = ifelse(grepl("12$", Position) & lag(IsControl) == TRUE & is.na(`Sample ID`), lag(`Sample ID`), `Sample ID`),
      density = ifelse(grepl("12$", Position) & lag(IsControl) == TRUE & !is.na(`Sample ID`), lag(density), density),
      Barcode = ifelse(grepl("12$", Position) & lag(IsControl) == TRUE & !is.na(`Sample ID`), lag(Barcode), Barcode),
      # ... (similar for other fields)
    )
}
```
- Copies controls from column 11 to column 12 if column 12 is empty
- Creates biological replicates automatically
- Maintains control metadata across both columns

#### Step 5: Validation Logic (Lines 1574-1645)

**Non-Control Conflict Detection (Lines 1601-1612):**
```r
non_control_conflicts <- linked_samples_data %>%
  filter(!IsControl & Position %in% standard_values_data$Position & !is.na(`Sample ID`) & !grepl("^(G|F)", Position)) %>%
  select(RowNumber, Barcode, Position)

if (nrow(non_control_conflicts) > 0) {
  error_data <- ErrorData$new(
    description = "Non-control in a standard position.",
    data_frame = non_control_conflicts
  )
  validation_errors$add_error(error_data)
}
```
- Checks for regular samples in standard control positions
- Allows flexibility in rows G and F
- Generates validation errors if conflicts found

**Empty Well Validation (Lines 1624-1635):**
```r
empty_standard_wells <- linked_samples_data %>%
  filter(grepl("11$", Position)) %>%
  filter(Position %in% standard_values_data$Position & is.na(`Sample ID`) & ExpectedDensity != "NTC" & !grepl("^(G|H|F)", Position)) %>%
  select(RowNumber, Position)
```
- Ensures standard control positions (A11-E11) are not empty
- Allows empty wells in rows G, H, and F
- Validates only column 11 (column 12 is a copy)

#### Step 6: Density Mismatch Warning (Lines 1647-1674)

```r
control_conflicts <- linked_samples_data %>%
  filter(grepl("11$", Position) & IsControl & !is.na(ActualDensity) & ExpectedDensity != "0" & ActualDensity != ExpectedDensity) %>%
  select(RowNumber, Position, `Sample ID`, ExpectedDensity, ActualDensity)

if (nrow(control_conflicts) > 0) {
  showModal(modalDialog(
    title = "Density Mismatch Detected",
    paste("The following wells have a density mismatch:", paste(control_conflicts$Position, collapse = ", ")),
    paste("Is this okay?"),
    easyClose = TRUE,
    footer = tagList(
      actionButton("qpcr_proceed_with_warning", "Yes, continue!"),
      modalButton("qpcr_exit")
    )
  ))
  return(NULL)
}
```
- Compares actual control densities with expected values
- Shows warning modal if mismatches detected
- Allows user to proceed or cancel
- Non-blocking: user can choose to continue despite mismatch

---

## 6. Data Combination Function (Lines 2148-2237)

### Overview
The `combine_data()` function transforms validated plate data into the final export format required by qPCR instruments.

### Process Flow

#### Step 1: Data Merging (Lines 2151-2168)

```r
combined_data <- linked_samples %>%
  left_join(user_data, by = join_by(Position, `Sample ID`, Barcode, `Specimen Type`, Comment)) %>%
  arrange(Position)

all_positions <- paste0(rep(LETTERS[1:8], each = 12), sprintf("%02d", rep(1:12, times = 8)))
missing_positions <- setdiff(all_positions, combined_data$Position)

if (length(missing_positions) > 0) {
  blanks <- data.frame(
    Position = missing_positions,
    Barcode = ifelse(missing_positions %in% standard_values$Position[standard_values$Density == "NTC"], "NTC", "Blank"),
    ActualDensity = NA,
    IsControl = FALSE
  )
  combined_data <- bind_rows(combined_data, blanks) %>%
    arrange(Position)
}
```
- Merges linked sample data with user-selected data
- Ensures all 96 positions are present
- Fills missing positions with "Blank" or "NTC"

#### Step 2: Layout Preview Generation (Lines 2170-2185)

```r
showModal(modalDialog(
  title = "qPCR Plate Layout",
  size = "xl",
  div(
    style = "display: flex; margin-bottom: 10px;",
    tags$div(tags$span(style = "background-color: #f5f5f5; padding: 5px 15px; margin-right: 10px;", "Blank")),
    tags$div(tags$span(style = "background-color: #fff9c4; padding: 5px 15px; margin-right: 10px;", "Samples")),
    tags$div(tags$span(style = "background-color: #c8e6c9; padding: 5px 15px;", "Standards"))
  ),
  reactableOutput("qpcr_layout_table"),
  footer = tagList(
    downloadButton("download_qpcr_csv", "Download qPCR CSV"),
    modalButton("Close")
  )
))

generate_layout(combined_data, output)
```
- Shows visual plate layout in modal dialog
- Color-coded: Grey (Blank), Yellow (Samples), Green (Standards)
- Includes download button in modal footer
- Allows user to review before downloading

#### Step 3: Export Data Transformation (Lines 2190-2230)

```r
export_data <- combined_data %>%
  mutate(
    # Target Name is fixed as "varATS"
    `Target Name` = ifelse(is.na(Barcode), NA_character_, "VarATS"),
    
    # Task is assigned NTC, STANDARD or UNKNOWN
    Task = ifelse(
      is.na(Barcode), NA_character_, ifelse(
        Position %in% standard_values$Position & IsControl, ifelse(
          Barcode == "NTC", "NTC", "STANDARD"),
      "UNKNOWN")
    ),
    
    # Sample Name uses the Barcode for sample identification
    `Sample Name` = ifelse(is.na(Barcode), NA_character_, Barcode),
    
    Reporter = ifelse(!is.na(Barcode),"FAM", NA_character_),
    Quencher = ifelse(!is.na(Barcode),"NFQ-MGB", NA_character_),
    
    `Biogroup Name` = ifelse(!is.na(Barcode) & Position %in% standard_values$Position & IsControl,
      ifelse(Barcode == "NTC", "NTC", as.character(density)), `Study Subject`),
    
    `Biogroup Color` = NA_character_,
    Row = substr(Position, 1, 1),
    Column = as.numeric(substr(Position, 2, 3)),
    `Well Position` = sprintf("%s%d", Row, Column),
    Well = as.character(row_number()),
    Quantity = ifelse(Task == "STANDARD", sprintf("\"%s\"", trimws(format(density, big.mark = ",",  nsmall = 2))), NA_character_)
  ) %>%
  select(
    Well,
    `Well Position`,
    `Sample Name`,
    `Biogroup Name`,
    `Biogroup Color`,
    `Target Name`,
    `Task`,
    Reporter,
    Quencher,
    Quantity,
    Comments = Comment
  )
```

**Column Mapping:**
- **Well**: Sequential well number (1-96)
- **Well Position**: Human-readable position (A1, A2, etc.)
- **Sample Name**: Barcode or sample identifier
- **Biogroup Name**: Study subject for samples, density for standards, "NTC" for negative controls
- **Target Name**: Fixed as "VarATS" (variant gene target)
- **Task**: "STANDARD" (controls), "NTC" (negative controls), "UNKNOWN" (samples)
- **Reporter**: Fixed as "FAM" (fluorescent dye)
- **Quencher**: Fixed as "NFQ-MGB" (quencher type)
- **Quantity**: Density value for standards (formatted with commas)
- **Comments**: User comments from database

---

## 7. Layout Generation Function (Lines 2239-2318)

### Overview
Creates visual representation of plate layout for user preview.

### Implementation

```r
generate_layout <- function(data, output) {
  # Create empty matrix for 8 rows (A-H) and 12 columns (1-12)
  layout_matrix <- matrix(NA, nrow = 8, ncol = 12, dimnames = list(LETTERS[1:8], sprintf("%02d", 1:12)))
  
  # Populate matrix with data
  for (i in seq_len(nrow(data))) {
    pos <- data$Position[i]
    row <- substr(pos, 1, 1)
    col <- substr(pos, 2, 3)
    
    if (!is.na(data$Barcode[i]) && data$Barcode[i] != "Blank") {
      layout_matrix[row, col] <- paste(
        data$Barcode[i],
        data$`Specimen Type`[i],
        ifelse(!is.na(data$IsControl[i]) && data$IsControl[i] == 1, 
               sprintf("%s", data$ActualDensity[i]), ""),
        sep = "\n"
      )
    } else {
      layout_matrix[row, col] <- ""
    }
  }
  
  # Cell color function
  cell_color <- function(position) {
    info <- data %>% filter(Position == position)
    if (is.na(info$Barcode) || info$Barcode == "Blank" || nrow(info) == 0) {
      return("#f5f5f5")  # Grey for blank
    } else if (!is.na(info$IsControl) && info$IsControl == 1) {
      return("#c8e6c9")  # Light green for Controls
    } else {
      return("#fff9c4")  # Light yellow for Samples
    }
  }
  
  # Render reactable table
  output$qpcr_layout_table <- renderReactable({
    reactable(
      layout_df,
      columns = setNames(
        lapply(names(layout_df), function(col_name) {
          colDef(
            align = "center", minWidth = 150, headerStyle = list(fontWeight = "bold"),
            style = function(value, index) {
              row_letter <- LETTERS[index]
              col_num <- sprintf("%02d", as.numeric(col_name))
              position <- paste0(row_letter, col_num)
              list(backgroundColor = cell_color(position))
            },
            # ... (additional styling)
          )
        }),
        names(layout_df)
      )
    )
  })
}
```

**What It Does:**
- Creates 8x12 matrix representing plate layout
- Populates cells with barcode, specimen type, and density (for controls)
- Color-codes cells: Grey (blank), Yellow (samples), Green (controls)
- Renders interactive table using `reactable` package

---

## Expected Output

### File Format

Both QuantStudio and BioRad formats produce **tab-delimited text files** with the following structure:

```
[Sample Setup]
Well	Well Position	Sample Name	Biogroup Name	Biogroup Color	Target Name	Task	Reporter	Quencher	Quantity	Comments
1	A1	4064909862	B855		VarATS	UNKNOWN	FAM	NFQ-MGB		Sample comment
2	A2	4064909487	B856		VarATS	UNKNOWN	FAM	NFQ-MGB		Another comment
...
11	A11	CTRL001	10000		VarATS	STANDARD	FAM	NFQ-MGB	"10,000.00"	
12	A12	CTRL001	10000		VarATS	STANDARD	FAM	NFQ-MGB	"10,000.00"	
...
96	H12	NTC	NTC		VarATS	NTC	FAM	NFQ-MGB		
```

### File Naming Convention

- **QuantStudio**: `qPCR_QuantStudio_[PlateName]_[YYYY-MM-DD].txt`
- **BioRad**: `qPCR_BioRad_[PlateName]_[YYYY-MM-DD].txt`

**Example:**
- `qPCR_QuantStudio_IM-26-036_2025-11-19.txt`
- `qPCR_BioRad_IM-26-036_2025-11-19.txt`

### Data Structure

#### Required Columns (in order):
1. **Well**: Sequential number (1-96)
2. **Well Position**: Alphanumeric position (A1, A2, ..., H12)
3. **Sample Name**: Barcode or identifier
4. **Biogroup Name**: Study subject (samples) or density (standards) or "NTC"
5. **Biogroup Color**: Empty (reserved for future use)
6. **Target Name**: "VarATS" (fixed)
7. **Task**: "STANDARD", "NTC", or "UNKNOWN"
8. **Reporter**: "FAM" (fixed)
9. **Quencher**: "NFQ-MGB" (fixed)
10. **Quantity**: Density value for standards (formatted with quotes and commas)
11. **Comments**: User comments from database

### Plate Layout Requirements

#### QuantStudio:
- **Required Wells**: A1-H10 (80 wells, columns 1-10)
- **Control Positions**: A11-E11 (standard controls), H11-H12 (NTC)
- **Optional**: F11-F12, G11-G12 can contain samples or be empty

#### BioRad:
- **Required Wells**: A1-H12 (all 96 wells)
- **Control Positions**: A11-E11 (standard controls), H11-H12 (NTC)
- **Column 12**: Automatically populated with replicates from column 11

### Control Standards

Standard control positions and expected densities:
- **A11-A12**: 10,000 p/uL
- **B11-B12**: 1,000 p/uL
- **C11-C12**: 100 p/uL
- **D11-D12**: 10 p/uL
- **E11-E12**: 1 p/uL
- **F11-F12**: 0.1 p/uL (optional)
- **G11-G12**: 0 p/uL (optional)
- **H11-H12**: NTC (Negative Template Control)

---

## User Workflow

### Step-by-Step Process

1. **Search for Plate**
   - Navigate to "Search, Delete & Archive" tab
   - Filter/search for desired plate
   - Select samples (or use all filtered results)

2. **Initiate Download**
   - Click "Download" dropdown button
   - Select "Download qPCR Format (QuantStudio)" or "Download qPCR Format (BioRad)"

3. **Validation Process**
   - System validates plate structure
   - Checks for missing wells
   - Validates control positions
   - Checks density mismatches

4. **User Confirmations**
   - If missing wells: Confirm to proceed
   - If density mismatch: Confirm to proceed with warning
   - If validation errors: Review and fix issues

5. **Preview Layout**
   - Visual plate layout displayed in modal
   - Color-coded: Grey (blank), Yellow (samples), Green (controls)
   - Review sample positions and controls

6. **Download File**
   - Click "Download qPCR CSV" button in modal
   - File downloads with appropriate filename
   - File is ready for import into thermocycler software

---

## Technical Implementation Details

### Reactive Values

```r
qpcr_final_data <- reactiveVal()  # Stores final processed data
linked_samples <- reactiveVal(NULL)  # Stores linked sample data
conflict_wells <- reactiveVal()  # Stores conflict information
```

### Event Handlers

1. **Primary Triggers:**
   - `input$download_qpcr_quantstudio` - QuantStudio download initiation
   - `input$download_qpcr_biorad` - BioRad download initiation

2. **User Confirmations:**
   - `input$qpcr_check_conflicts` - Proceed with missing wells (QuantStudio)
   - `input$biorad_check_conflicts` - Proceed with missing wells (BioRad)
   - `input$qpcr_proceed_with_warning` - Proceed with density mismatch

3. **Download Handlers:**
   - `output$download_qpcr_csv` - QuantStudio file download
   - `output$download_qpcr_biorad_csv` - BioRad file download

### Error Handling

1. **Multiple Plates**: Modal error if more than one plate selected
2. **Missing Wells**: User confirmation modal
3. **Validation Errors**: Detailed error modal with conflict information
4. **Density Mismatches**: Warning modal (non-blocking)

### Database Operations

- **Temporary Database**: Creates in-memory SQLite database for processing
- **Table Joins**: Joins `storage_container`, `specimen`, `study_subject`, `malaria_blood_control`
- **Data Extraction**: Extracts position, barcode, density, control status, specimen type, comments

### Performance Considerations

- **Reactive Caching**: Uses `reactiveVal()` to cache processed data
- **Lazy Evaluation**: Data processing only occurs when download is initiated
- **Efficient Joins**: Uses `dplyr` and `dbplyr` for optimized database queries
- **Modal Management**: Closes modals automatically after data processing

---

## Differences Between QuantStudio and BioRad Formats

| Feature | QuantStudio | BioRad |
|---------|-------------|--------|
| **Required Wells** | A1-H10 (80 wells) | A1-H12 (96 wells) |
| **File Format** | Tab-delimited `.txt` | Tab-delimited `.txt` |
| **Header** | `[Sample Setup]` | `[Sample Setup]` |
| **Filename Pattern** | `qPCR_QuantStudio_[Plate]_[Date].txt` | `qPCR_BioRad_[Plate]_[Date].txt` |
| **Data Structure** | Identical | Identical |
| **Control Handling** | Same validation | Same validation |

**Note**: The only functional difference is the number of required wells. Both formats use identical data structures and file formats.

---

## Debugging and Logging

### Debug Messages

The implementation includes extensive debug logging:

```r
message("=== BioRad qPCR Download Process Started ===")
message("BioRad Debug - User filtered rows:")
message("  Number of rows: ", nrow(user.filtered.rows))
message("  Columns: ", paste(names(user.filtered.rows), collapse = ", "))
message("BioRad Debug - User selected rows:")
message("  Number of rows: ", nrow(user.selected.rows))
message("  Selected positions: ", paste(user.selected.rows$Position, collapse = ", "))
```

### Key Debug Sections

1. **Position-Based Control Recognition**: Logs before/after IsControl values
2. **Validation Debug**: Logs validation checks and conflicts
3. **Density Mismatch Check**: Logs detected mismatches
4. **Control Creation**: Logs control sample creation process
5. **Final Verification**: Logs final sample counts and structure

### Log Locations

- Console output (R console)
- Server logs (if running on Shiny Server)
- Browser console (for client-side errors)

---

## Testing and Validation

### Test Scenarios

1. **Single Plate Selection**
   - ✅ Should proceed normally
   - ❌ Should error if multiple plates selected

2. **Missing Wells**
   - ✅ Should prompt user for confirmation
   - ✅ Should fill missing wells with blanks/NTC

3. **Control Validation**
   - ✅ Should recognize controls in standard positions
   - ✅ Should error if non-controls in standard positions
   - ✅ Should allow flexibility in rows G, F, H

4. **Density Mismatch**
   - ✅ Should warn but allow continuation
   - ✅ Should show affected positions

5. **File Generation**
   - ✅ Should generate correct filename
   - ✅ Should include all required columns
   - ✅ Should format data correctly

---

## Future Enhancements

### Potential Improvements

1. **Additional Formats**: Support for other thermocycler formats (Roche LightCycler, etc.)
2. **Custom Targets**: Allow user to specify target name instead of fixed "VarATS"
3. **Batch Processing**: Support multiple plates in single download
4. **Template Customization**: Allow users to customize column mappings
5. **Export Options**: CSV, Excel, JSON formats
6. **Validation Rules**: Configurable validation rules per protocol
7. **Control Library**: Pre-defined control libraries for different protocols

---

## Conclusion

The qPCR download functionality provides a comprehensive solution for exporting plate data from SampleDB to qPCR thermocycler platforms. The implementation includes:

- **Dual format support** (QuantStudio and BioRad)
- **Comprehensive validation** (plate structure, controls, densities)
- **User-friendly interface** (visual preview, clear error messages)
- **Robust error handling** (validation errors, warnings, confirmations)
- **Flexible control handling** (automatic recognition, position-based, database-based)
- **Professional file output** (standardized format, proper naming)

The feature seamlessly integrates with the existing SampleDB workflow and provides researchers with a streamlined process for preparing qPCR experiments.

