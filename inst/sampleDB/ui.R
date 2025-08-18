# Load required libraries
library(dplyr)
library(sampleDB)
library(shiny)
library(DT)
library(bslib)

# Load helper files - make sure these files actually exist and are correct
for(ui_helper in list.files(path = "ui_helpers", full.names = T, recursive = T)){
  source(ui_helper, local = TRUE)
}

# Ensure the environment variable is correctly set
database <- Sys.getenv("SDB_PATH")
if(database == "") {
  stop("SDB_PATH environment variable not set.")
}

#' Get the path to a markdown file
get_markdown_path <- function(filename, package_name = "sampleDB") {
  filepath <- system.file("app/www", filename, package = package_name)
  
  if (file.exists(filepath)) {
    return(filepath)
  } else {
    stop(paste("Markdown file", filename, "not found in package", package_name))
  }
}

my_theme <- bs_theme(
  version = 5,
  bootswatch = "darkly"  # Use EPPIcenter's exact dark theme
)

# Main Shiny App UI
ui <- page_navbar(
  title = tags$strong("SampleDB"),
  header = UICSS(),
  id = "navBar", # add an ID for better JS/CSS customization
  theme = my_theme,
  nav_panel(title = "Upload New Specimens", UIUploadSamples()),
  nav_panel(title = "Search, Delete & Archive", UISearchDelArchSamples()),
  nav_panel(title = "Move Specimens",  UIMoveSamples()),
  nav_panel(title = "Modify Containers", UIMoveContainerOfSamples()),
  nav_menu(title = "Update References",
             nav_panel(title = "Freezers", UIFreezerReference()),
             nav_panel(title = "Specimen Types", UISpecimenTypeReference()),
             nav_panel(title = "Studies", UIStudiesReference()),
             nav_panel(title = "Controls", UIControlsReference())
  ),
  nav_panel("Preferences", UIPreferences()),
  nav_spacer(),
  nav_item(tags$a("EPPIcenter", href = "https://eppicenter.ucsf.edu/")),
  nav_item(tags$a("User Guide", href = "https://eppicenter.github.io/sampleDB-rpackage/"))
)

