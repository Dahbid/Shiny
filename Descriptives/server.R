shinyServer(function(input, output, session) {
  ########################################### Install missing packages #######################################
  # instelling om grotere bestanden in te kunnen lezen
  options(shiny.maxRequestSize = 50 * 1024^2)
  options(warn = -1)
  options(scipen = 999) # no scientific notations
  # checken of alle benodigde packages geïnstalleerd zijn
  lijst_packages <- c("dplyr", "data.table", "devtools", "ggplot2", "gridExtra", "lubridate", "openxlsx", "plyr", "Rcpp", "readxl",
                      "Rserve", "tidyr", "XLConnect", "xlsx", "plotly", "Metrics", "magrittr", "reshape2", "psych", "cellranger",
                      "DT", "shinycssloaders", "shinythemes", "shinyjs", "shinydashboard")
  nieuw_packages <- lijst_packages[!(lijst_packages %in% installed.packages()[,"Package"])]
  if(length(nieuw_packages)) install.packages(pkgs = nieuw_packages, repos = "https://lib.ugent.be/CRAN")
  source("./global.R")
  ########################################### Input ##########################################################


  ## inlezen data
  script <- reactive({
    req(input$knop_input)
    bestand <- input$knop_input
    
    type <- tools::file_ext(bestand$datapath)
    
    if (type == "csv") {
      req(input$skip_row)
      a <- input$skip_row
      datatable <- fread(bestand$datapath, stringsAsFactors = FALSE, check.names = FALSE, skip = a)
    } else if (type == "rds") {
      datatable <- as.data.table(readRDS(bestand$datapath))
    } else if (type == "xls" || type == "xlsx") {
      req(input$skip_row, input$select_sheet)
      a <- input$skip_row
      b <- input$select_sheet
      aantal_sheets <- length(readxl::excel_sheets(bestand$datapath))
      
      if (b <= aantal_sheets) {
        datatable <- as.data.table(readxl::read_excel(bestand$datapath, sheet = b, trim_ws = TRUE, skip = a))
      } else {
        return(NULL)
      }
    }
    # output data
    rownumber <- nrow(datatable)
    colnumber <- ncol(datatable)
    bestandsnaam <- bestand$name
    return(list(datatable, bestandsnaam, colnumber, rownumber))
  })
  
  output$contents1 <- DT::renderDataTable(DT::datatable(script()[[1]][1:25], selection = 'none',
                                          options = list(pageLength = 25, scrollX = TRUE, searching = FALSE, lengthChange = FALSE)
                                                         ))

  ## dynamische infoboxen
  output$rijen <- shinydashboard::renderInfoBox({
    req(script())
    shinydashboard::infoBox("", subtitle = "Rows", value = prettyNum(script()[[4]], big.mark = ".", decimal.mark = ","), color = 'blue', 
            icon = icon('arrows-v'))
  })
  
  output$kolommen <- shinydashboard::renderInfoBox({
    req(script())
    shinydashboard::infoBox("", subtitle = "Columns", value = script()[[3]], color = 'blue', icon = icon('arrows-h'))
  })
  
  output$bestandsnaam <- shinydashboard::renderInfoBox({
    req(script())
    shinydashboard::infoBox(title = "", value = script()[[2]], color = 'blue', icon = icon('file'))
  })
  
  ## Input resetten als je een nieuwe dataset invoert
  # skip row en select sheet apart zodat skip row op 0 springt wanneer knop_input verandert maar ook als select sheet verandert
  output$reset <- renderUI({
    reset <- input$knop_input
    reset2 <- input$select_sheet
    list(numericInput("skip_row", label = "Skip row", value = 0, min = 0))
  })
  output$reset2 <- renderUI({
    reset <- input$knop_input
    list(numericInput("select_sheet", label = "Select sheet", value = 1, min = 1))
  })
  
  ########################################### Text ###########################################################
  ## functions
  text_missings <- reactive({
    DT <- fun_missings(script()[[1]])
    return(DT)
  })
  
  text_numerics <- reactive({
    DT <- fun_numeric_summary(copy(script()[[1]]))
    return(DT)
  })
  
  ## outputs
  output$contentsx <- DT::renderDataTable({   
    DT::datatable(text_missings(), selection = "none",
              options = list(pageLength = 50, searching = FALSE, lengthChange = FALSE, autoWidth = TRUE, scrollX = TRUE)) %>%
      DT::formatPercentage(columns = c('Perc. Missing', 'Perc. Zero', 'Perc. Empty', 'Perc. Infinite'), digits = 1)
  })
  
  output$contents_numeric <- DT::renderDataTable({
    DT::datatable(text_numerics(), selection = "none",
              options = list(pageLength = 50, searching = FALSE, lengthChange = FALSE, autoWidth = FALSE, scrollX = FALSE)) %>%
      DT::formatRound(columns = c("Minimum", "First quartile", "Median", "Mean", "Third quartile", "Maximum"))
  })
  
  ########################################### Plots ##########################################################
  
  output$raster <- renderPlot(fun_plot_missings(copy(script()[[1]] )))
  output$distribution <- renderPlot(fun_plot_distributions(copy(script()[[1]] )))
  
  output$correlation <- renderPlot(fun_plot_correlation(copy(script()[[1]] )))

  ########################################### Close session ##################################################
  session$onSessionEnded(function() {
    stopApp()
  })
})
