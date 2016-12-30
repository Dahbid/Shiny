library(shiny)
shinyServer(function(input, output, session) {
  # instelling om grotere bestanden in te kunnen lezen
  options(shiny.maxRequestSize=30*1024^2)
  
  # de data wordt hier in het mainPanel getoond
  datasetInput <- reactive({
    inFile <- input$uploadFile
    
    if (is.null(inFile))
      return(NULL)
    
    file.rename(inFile$datapath,
                paste(inFile$datapath, ".xlsx", sep=""))
    
    vec_types <- c("text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                   "numeric", "numeric", "numeric", "numeric", "text", "numeric", "text", "text", "text",
                   "text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                   "text", "text", "text", "text", "text", "text", "text")
    SC <- readxl::read_excel(path = paste(inFile$datapath, ".xlsx", sep=""), sheet = 1, col_types = vec_types)
  })
  output$contents <- renderTable(datasetInput())
  
  output$downloadData <- downloadHandler(
    filename = function() { 
      paste("werkbestand", '.csv', sep='')
    },
    content = function(file) {
      write.csv(datasetInput(), file = file)   # file moet file blijven
    }
  )
      session$onSessionEnded(function() {
        stopApp()
    })
})
