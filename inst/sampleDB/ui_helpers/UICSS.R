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
        
        /* Navbar customization */
        @media (min-width: 992px) {
            .navbar-expand-lg, .navbar:not(.navbar-expand):not(.navbar-expand-sm):not(.navbar-expand-md):not(.navbar-expand-lg):not(.navbar-expand-xl) {
                flex-wrap: nowrap;
                -webkit-flex-wrap: nowrap;
                justify-content: flex-start;
                -webkit-justify-content: flex-start;
            }
        }
        
        .navbar {
            --bslib-navbar-light-bg: #212529 !important;
            --bs-navbar-bg: #212529 !important;
            --bs-navbar-color: #ffffff !important;
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
        .navbar-nav > .active > a,
        .navbar-nav > .active > a:focus,
        .navbar-nav > .active > a:hover {
            color: #FFA500 !important;
            background-color: transparent !important;
        }
        
        .navbar .nav-link:hover,
        .navbar .nav-item > .nav-link:hover,
        .navbar-nav > li > a:hover {
            color: #FFA500 !important;
        }
      ")
    )
  )
}