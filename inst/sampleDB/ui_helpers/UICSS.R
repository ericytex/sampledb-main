UICSS <- function(){
  tags$head(
    tags$style(
      HTML("
        .shiny-file-input-progress {
            display: none
        }
        .progress-bar {
            color: transparent!important
        }
        h5 {
            line-height: 150%;
        }
        ::-webkit-input-placeholder {
            font-style: italic;
        }
        :-moz-placeholder {
            font-style: italic;
        }
        ::-moz-placeholder {
            font-style: italic;
        }
        :-ms-input-placeholder {  
          font-style: italic; 
        }
        .shiny-output-error-validation {
              color: #c4244c; font-weight: normal;
        }
        .no-select {
          -webkit-touch-callout: none; /* iOS Safari */
          -webkit-user-select: none;   /* Chrome/Safari/Opera */
          -khtml-user-select: none;    /* Konqueror */
          -moz-user-select: none;      /* Firefox */
          -ms-user-select: none;       /* Internet Explorer/Edge */
          user-select: none;
        }
        /* Your custom_css rules below */
        .custom-dropdown, .dropdown-menu .dropdown-item {
            width: 100%;
        }
        button, .btn {
            background-color: #FFF6D0;
            color: black;
        }
        button:hover, .btn:hover {
            background-color: #FFAC45;
            color: black;
        }
        .dropdown-menu {
            padding: 0;
        }
        
        /* Force dark navbar styling */
        .navbar {
            background-color: #212529 !important;
            color: #ffffff !important;
        }
        
        .navbar .nav-link,
        .navbar .nav-item > .nav-link,
        .navbar-nav > li > a {
            color: #ffffff !important;
        }
        
        .navbar .nav-link.active,
        .navbar .nav-item.active > .nav-link,
        .navbar-nav > .active > a {
            color: #ffffff !important;
            background-color: transparent !important;
        }
        
        .navbar .nav-link:hover,
        .navbar .nav-item > .nav-link:hover,
        .navbar-nav > li > a:hover {
            color: #ffffff !important;
        }
        
        /* Force white main content areas */
        body {
            background-color: #ffffff !important;
            color: #333333 !important;
        }
        
        .main-panel,
        .content-panel,
        .sidebar-panel {
            background-color: #ffffff !important;
            color: #333333 !important;
        }
        
        /* Ensure form areas are white */
        .form-group,
        .form-control,
        .panel,
        .well {
            background-color: #ffffff !important;
            color: #333333 !important;
        }
      ")
    )
  )
}