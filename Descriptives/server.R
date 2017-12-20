shinyServer(function(input, output, session) {
  
  ########################################### Install missing packages #######################################
  # instelling om grotere bestanden in te kunnen lezen
  options(shiny.maxRequestSize = 50 * 1024^2)
  options(warn = -1)
  # checken of alle benodigde packages geïnstalleerd zijn
  lijst_packages <- c("dplyr", "data.table", "devtools", "ggplot2", "gridExtra", "lubridate", "openxlsx", "plyr", "Rcpp", "readxl",
                      "Rserve", "tidyr", "XLConnect", "xlsx", "plotly", "Metrics", "magrittr", "reshape2", "psych", "cellranger",
                      "DT", "shinycssloaders")
  nieuw_packages <- lijst_packages[!(lijst_packages %in% installed.packages()[,"Package"])]
  if(length(nieuw_packages)) install.packages(pkgs = nieuw_packages, repos = "https://lib.ugent.be/CRAN")
  
  
  ########################################### Input ##########################################################
  test <- eventReactive(input$knop_df, {req(choose.files())})
  
  ## Input resetten als je een nieuwe dataset invoert
  output$reset <- renderUI({
    reset <- input$knop_df
    list(numericInput("skip_row", label = "Skip row", value = 0, min = 0),
         numericInput("select_sheet", label = "Select sheet", value = 1, min = 1))
  })
  
  wut <- reactive({a <- input$skip_row
  return(a)})
  script <- reactive({
    req(input$knop_df)
    
    type <- tools::file_ext(test())
    if(type == "xls" || type == "xlsx") {
      req(input$skip_row, input$select_sheet)
      a <- input$skip_row
      b <- input$select_sheet
      datatable <- as.data.table(readxl::read_excel(test(), skip = a, sheet = b, trim_ws = FALSE))
    } else if (type == "rds") {
      datatable <- as.data.table(readRDS(test()))
    }

    rownumber <- nrow(datatable)
    colnumber <- ncol(datatable)
    bestandsnaam <- basename(test())

    return(list(datatable,
                bestandsnaam,
                colnumber,
                rownumber))
  })
  
  output$contents1 <- DT::renderDataTable(script()[[1]][1:25], options = list(pageLength = 25,
                                                                              scrollX = TRUE,
                                                                              searching = FALSE
                                                                              # autoWidth = TRUE,
                                                                              ))

  ## dynamische infoboxen
  output$rijen <- renderInfoBox({
    infoBox("Rows", value = script()[[4]], color = 'blue')
    # infoBox("Rows", value = wut(), color = 'blue')
  })
  
  output$kolommen <- renderInfoBox({
    infoBox("Columns", value = script()[[3]], color = 'blue')
  })
  
  output$bestandsnaam <- renderInfoBox({
    infoBox("File name", value = script()[[2]], color = 'blue')
  })
  ########################################### Text ###########################################################
  text_missings <- reactive({
    DT <- script()[[1]]
    
    namen <- names(DT)[sapply(DT, class) %in% c("character", "numeric", "integer", "factor")]
    wut <- DT[, .(Variable = namen, 
                  `Empty Cells` = sapply(.SD, function(x) sum(x == "", na.rm = TRUE))), .SDcols = namen]
    
    
    resultaat <- DT[, .(Variable = names(DT), 
                        Rows = .N, 
                        Missing = sapply(.SD, function(x) sum(is.na(x))),
                        Zeroes = sapply(.SD, function(x) sum(x == 0, na.rm = T)),
                        `Infinite Values` = sapply(.SD, function(x) sum(is.infinite(x))),
                        `Distinct Values` = sapply(.SD, function(x) length(unique(x))),
                        Type = sapply(.SD, function(x) class(x)[[1]]))][, ':=' (`Perc. Missing` = round(Missing / Rows, 2),
                                                                                `Perc. Zero` = round(Zeroes / Rows, 2),
                                                                                `Perc. Infinite` = round(`Infinite Values` / Rows, 2))]
    
    huh <- merge(resultaat, wut, by = "Variable", all.x = TRUE, sort = FALSE)
    huh[is.na(`Empty Cells`), `Empty Cells` := 0][, `Perc. Empty` := `Empty Cells` / Rows]
    
    
    setcolorder(huh, c("Variable", "Rows", "Missing", "Perc. Missing", "Zeroes", "Perc. Zero", "Empty Cells", "Perc. Empty", 
                       "Infinite Values", "Perc. Infinite", "Distinct Values", "Type"))
    
    return(huh)
  })
  output$contentsx <- DT::renderDataTable(
    DT::formatPercentage(DT::datatable(text_missings(), selection = "none", options = list(pageLength = 50, searching = FALSE, lengthChange = FALSE,
                                                                                           autoWidth = TRUE, scrollX = TRUE))
                         , columns = c('Perc. Missing', 'Perc. Zero', 'Perc. Empty', 'Perc. Infinite'), digits = 1)) 
  # output$contentsx <- DT::renderDataTable(text_missings(), options = list(pageLength = 50,
  #                                                                         searching = FALSE)) %>% DT::formatPercentage('Proportioneel', 2)
  
  test_numerics <- reactive({
    DT <- copy(script()[[1]])
    
    # select numerical variables
    DT <- DT[, .SD, .SDcols = sapply(DT, is.numeric)]
    
    DT2 <- DT[, lapply(.SD, quantile, na.rm = TRUE)]
    DT2[, A := c("Minimum", "First quartile", "Median", "Third quartile", "Maximum")]
    
    DT2 <- dcast(melt(DT2, id.var = "A", variable.factor = FALSE), variable ~ A)
    DT3 <- melt(DT[, lapply(.SD, mean, na.rm = TRUE)], measure.vars = names(DT), variable.factor = FALSE)
    
    DT2 <- merge(DT2, DT3, by = "variable", sort = FALSE)
    setnames(DT2, c("variable", "value"), c("Variable", "Mean"))
    DT2[, lapply(.SD, round, 2), .SDcols = c("Minimum", "First quartile", "Median", "Mean", "Third quartile", "Maximum")]
    setcolorder(DT2, c("Variable", "Minimum", "First quartile", "Median", "Mean", "Third quartile", "Maximum"))
    
    return(DT2)
  })
  
  output$contents_numeric <- DT::renderDataTable(
    DT::formatRound(DT::datatable(test_numerics(), options = list(pageLength = 50, searching = FALSE, lengthChange = FALSE, autoWidth = FALSE,
                                                                  scrollX = FALSE), selection = "none")
                    , columns = c("Minimum", "First quartile", "Median", "Mean", "Third quartile", "Maximum"))
  )
  ########################################### Plots ##########################################################
  plot_missings <- reactive({
    DT <- copy(script()[[1]])
    vars <- names(DT)
    
    if (any(duplicated(colnames(DT)))) {
      setnames(DT, make.names(names(DT), unique = TRUE))
      warning("Dataset contains duplicated column names.")
    }
    vars <- copy(names(DT)) # if you don't use copy() id_xyz automagically get added to vars after that variable is created
    
    # convert cells to either the class() or NA
    DT[, (vars) := lapply(.SD, function(x) ifelse(!is.na(x), paste(class(x), collapse = '\\n'), NA))]
    DT[, id_xyz := .I]
    
    # melt data.table (gives warning that not all measure vars are of the same type)
    slag <- suppressWarnings(melt(DT, id.vars = "id_xyz", measure.vars = vars) )
    
    # plot raster
    p <- ggplot2::ggplot(data = slag, ggplot2::aes(x = variable, y = id_xyz, text = value)) +
      ggplot2::geom_raster(ggplot2::aes(fill = value)) +
      ggplot2::theme_minimal() +
      ggplot2::labs(x = "", y = "Rows") +
      ggplot2::guides(fill = ggplot2::guide_legend(title = "Type")) +
      ggplot2::theme( legend.position = "top") +
      ggplot2::coord_flip() 

    # axis.text.x = ggplot2::element_text(angle = 45, vjust = 1, hjust = 1, size = 14),
    return(p)
  })
  
  plot_distribution <- reactive({
    DT <- copy(script()[[1]])
    
    # select only numeric variables
    DT <- DT[, .SD, .SDcols = sapply(DT, is.numeric)]
    
    # melt data
    DT <- melt(DT, measure.vars = names(DT))
    
    # plot facets
    p <- ggplot2::ggplot(data = DT) +
      ggplot2::facet_wrap(~ variable, scales = 'free') +
      ggplot2::geom_histogram(ggplot2::aes(value)) +
      ggplot2::geom_density( ggplot2::aes(value)) +
      ggplot2::scale_x_continuous(labels = scales::comma) +
      ggplot2::scale_y_continuous(labels = scales::comma)
    
    return(p)
  })

  output$raster <- renderPlot(plot_missings())
  output$distribution <- renderPlot(plot_distribution())

  ########################################### Close session ##################################################
  session$onSessionEnded(function() {
    stopApp()
  })
})
