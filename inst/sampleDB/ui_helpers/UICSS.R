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
        
        /* EPPIcenter-style main content areas */
        body {
            background-color: #f8f9fa !important;
            color: #333333 !important;
        }
        
        /* Main content panel - clean white */
        .main-panel,
        .content-panel {
            background-color: #ffffff !important;
            color: #333333 !important;
            border-radius: 6px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin: 10px;
            padding: 20px;
        }
        
        /* Sidebar panel - light gray background */
        .sidebar-panel {
            background-color: #f8f9fa !important;
            color: #333333 !important;
            border-right: 1px solid #dee2e6;
        }
        
        /* Form elements - clean white with subtle borders */
        .form-group,
        .form-control,
        .panel,
        .well {
            background-color: #ffffff !important;
            color: #333333 !important;
            border: 1px solid #dee2e6;
            border-radius: 4px;
        }
        
        /* Buttons - EPPIcenter style */
        .btn-primary {
            background-color: #18bc9c !important;
            border-color: #18bc9c !important;
        }
        
        .btn-primary:hover {
            background-color: #15a085 !important;
            border-color: #15a085 !important;
        }
      ")
    )
  )
}