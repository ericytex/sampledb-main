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
  bootswatch = "flatly",  # EPPIcenter's clean flatly theme
  # Force dark navbar colors
  "navbar-bg" = "#212529",
  "navbar-color" = "#ffffff",
  "navbar-hover-color" = "#FF4B4B",
  "navbar-active-color" = "#FF4B4B",
  "navbar-link-decoration" = "none",        # ← Removes underline
  "navbar-link-hover-decoration" = "none",  # ← Removes underline on hover
  # Use subtle backgrounds for main content
  "body-bg" = "#f8f9fa",  # Light gray background
  "body-color" = "#333333",
  "light" = "#f8f9fa",  # Light gray instead of white
  "dark" = "#212529",
  "primary" = "#FF4B4B",  # Red rgb(255, 75, 75)
  "secondary" = "#95a5a6",
  "success" = "#27ae60",
  "info" = "#3498db",
  "warning" = "#f39c12",
  "danger" = "#e74c3c"
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

