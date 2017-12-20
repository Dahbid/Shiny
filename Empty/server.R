shinyServer(function(input, output, session) {
  
  ########################################### Install missing packages #######################################
  # instelling om grotere bestanden in te kunnen lezen
  options(shiny.maxRequestSize = 50 * 1024^2)
  options(warn = -1)
  # checken of alle benodigde packages geïnstalleerd zijn
  lijst_packages <- c("dplyr", "data.table", "devtools", "ggplot2", "gridExtra", "lubridate", "openxlsx", "plyr", "Rcpp", "readxl",
                      "Rserve", "tidyr", "XLConnect", "xlsx", "plotly", "Metrics", "magrittr", "reshape2", "psych", "cellranger",
                      "DT")
  nieuw_packages <- lijst_packages[!(lijst_packages %in% installed.packages()[,"Package"])]
  if(length(nieuw_packages)) install.packages(pkgs = nieuw_packages, repos = "https://lib.ugent.be/CRAN")
  
  
  ########################################### First script ###################################################
  test <- eventReactive(input$knop_sc, {choose.files(caption = "Open de meest recente SC uren", 
                                                        default = "S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Data\\SC")})
  
  script <- reactive({
    
  })
  
  output$contents1 <- renderDataTable(iris)
  
  ########################################### Close session ##################################################
  session$onSessionEnded(function() {
    stopApp()
  })
})
