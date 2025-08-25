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
            border-color: #FFF6D0 !important;
        }
        button:hover, .btn:hover {
            background-color: #FFAC45;
            color: black;
            border-color: #FFAC45 !important;
        }
        .dropdown-menu {
            padding: 0;
        }
        
        /* Force dark navbar styling */
        .navbar {
            background-color: #212529 !important;
            color: #ffffff !important;
        }
        
        /* Force no underlines on navbar links - using more specific selectors */
        .navbar .nav-link,
        .navbar .nav-item > .nav-link,
        .navbar-nav > li > a,
        .navbar-nav .nav-link,
        .navbar-nav .nav-item .nav-link,
        .navbar-nav .nav-item > .nav-link,
        .navbar .navbar-nav .nav-link,
        .navbar .navbar-nav .nav-item .nav-link {
            color: #ffffff !important;
            text-decoration: none !important;
            border-bottom: none !important;
            box-shadow: none !important;
        }
        
        .navbar .nav-link.active,
        .navbar .nav-item.active > .nav-link,
        .navbar-nav > .active > a,
        .navbar-nav .nav-link.active,
        .navbar-nav .nav-item.active .nav-link,
        .navbar .navbar-nav .nav-link.active,
        .navbar .navbar-nav .nav-item.active .nav-link {
            color: #FF4B4B !important;
            background-color: transparent !important;
            text-decoration: none !important;
            border-bottom: none !important;
            box-shadow: none !important;
        }
        
        .navbar .nav-link:hover,
        .navbar .nav-item > .nav-link:hover,
        .navbar-nav > li > a:hover,
        .navbar-nav .nav-link:hover,
        .navbar-nav .nav-item .nav-link:hover,
        .navbar .navbar-nav .nav-link:hover,
        .navbar .navbar-nav .nav-item .nav-link:hover {
            color: #FF4B4B !important;
            text-decoration: none !important;
            border-bottom: none !important;
            box-shadow: none !important;
        }
        
        /* EPPIcenter-style main content areas */
        body {
            background-color: #f8f9fa !important;  /* Light gray background */
            color: #333333 !important;
        }
        
        /* Main content panel - subtle background */
        .main-panel,
        .content-panel {
            background-color: transparent !important;  /* Remove white background */
            color: #333333 !important;
            border-radius: 6px;
            margin: 10px;
            padding: 20px;
        }
        .rt-text-content {
            overflow: visible !important;
            white-space: nowrap !important;
            text-overflow: ellipsis !important;
        }
        
        /* Target all reactable cells */
        .Reactable .rt-text-content {
            overflow: visible !important;
            white-space: nowrap !important;
            text-overflow: ellipsis !important;
        }

        /* Or target specific table by ID */
        #DelArchSearchResultsTable .rt-text-content {
            overflow: visible !important;
            white-space: nowrap !important;
            text-overflow: ellipsis !important;
        }
        
        /* Sidebar panel - subtle background */
        .sidebar-panel {
            background-color: transparent !important;  /* Remove white background */
            color: #333333 !important;
            border-right: 1px solid #dee2e6;
        }
        
        /* Form elements - subtle styling without harsh white backgrounds */
        .form-group,
        .form-control,
        .panel,
        .well {
            background-color: transparent !important;  /* Remove white background */
            color: #333333 !important;
            
            border-radius: 4px;
        }
        
        /* Buttons - Updated to use red primary color */
        .btn-primary {
            background-color: #FFF6D0 !important;  /* Red rgb(255, 75, 75) */
            border-color: #FFF6D0 !important;
        }
        
        .btn-primary:hover {
            background-color: #FFAC45 !important;  /* Darker red on hover */
            border-color: #FFAC45 !important;
        }
        
        /* Preserve sidebar handles - don't override their styling */
        .sidebar-handle,
        .sidebar-handle-bottom {
            /* Keep existing sidebar handle styling */
        }
        
      ")
    )
  )
}