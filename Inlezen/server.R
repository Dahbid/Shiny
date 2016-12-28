#

library(shiny)
function(input, output) {
  options(shiny.maxRequestSize=30*1024^2)
  output$contents <- renderTable({

    
    inFile <- input$uploadFile 
    
    if (is.null(inFile))
      return(NULL)
    file.rename(inFile$datapath,
                paste(inFile$datapath, ".xlsx", sep=""))

    vec_types <- c("text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                   "numeric", "numeric", "numeric", "numeric", "text", "numeric", "text", "text", "text",
                   "numeric", "numeric", "numeric", "numeric", "numeric", "text", "text", "text", "text", "text", "text", "text",
                   "text", "text", "text", "text", "text", "text", "text")
    LD <- readxl::read_excel(path = paste(inFile$datapath, ".xlsx", sep=""), sheet = 1, col_types = vec_types)
 #   LD$Work_Date <- as.Date(LD$Work_Date, origin = "1899-12-30")
    # df <- list()
    # df$VX <- openxlsx::read.xlsx(inFile$datapath, 1)
    # df$VX <- dplyr::select(df$VX, 3)
    

    
  })
  output$contents2 <- renderTable({

    inFile2 <- input$uploadFile2
    if (is.null(inFile2))
      return(NULL)
    file.rename(inFile2$datapath,
                paste(inFile2$datapath, ".xlsx", sep=""))
    
    vec_types <- c("text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                   "numeric", "numeric", "numeric", "numeric", "text", "numeric", "text", "text", "text",
                   "text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                   "text", "text", "text", "text", "text", "text", "text")
    LO <- readxl::read_excel(path = paste(inFile2$datapath, ".xlsx", sep=""), sheet = 1, col_types = vec_types)
    LO$Created_Date <- as.Date(as.character(as.vector(unlist(LO$Created_Date))), origin = "1899-12-30")
    #LO$Created_Date <- as.Date(LO$Created_Date, origin="1899-12-30")
    #not_outlier_dates[,2]<-as.Date(as.numeric(as.vector(unlist(not_outlier_dates[,2]))))
    
  })
}
