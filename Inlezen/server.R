shinyServer(function(input, output, session) {
  # instelling om grotere bestanden in te kunnen lezen
  options(shiny.maxRequestSize=50*1024^2)
  
  # inlezen en bewerken van het SC bestand
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
    
    #okay <- choose.files(caption = "Open de meest recente SC uren", default = "S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Data\\SC")
    SC$PTalent_ID[SC$PTalent_ID=="94385"] <- "101710"  # Esther Buis heeft twee nummers
    SC$PTalent_ID <- as.numeric(SC$PTalent_ID)
    SC$CO_Document_Number <- as.numeric(SC$CO_Document_Number)
    SC$Hour_Status_code <- as.numeric(SC$Hour_Status_code)
    
    # overige data inlezen
    bron_lcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 3)
    bron_ptalentcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 4)

    # SC voorbereiden
    output <- dplyr::select(SC, 1:9)
    output <- dplyr::left_join(output, bron_ptalentcodes, by = c("PTalent_ID" = "P-Talent Code"))
    
    output$Work_Code <- SC$Work_Code
    output <- dplyr::left_join(output, bron_lcodes, by = c("Work_Code" = "Wcode Ref"))
    output <- cbind(output, SC[,11:28])
    
    return(output)
  })
  # renderen van SC data in het eerste tabblad
#  output$contents <- renderTable(datasetInput())
  
  # inlezen en bewerken van het VX bestand
  datasetInput2 <- reactive({
    inFile2 <- input$uploadFile2
    
    if (is.null(inFile2))
      return(NULL)
    
    file.rename(inFile2$datapath,
                paste(inFile2$datapath, ".xlsx", sep=""))
    vec_types <- c("text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                   "numeric", "numeric", "numeric", "numeric", "text", "numeric", "text", "text", "text",
                   "text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                   "text", "text", "text", "text", "text", "text", "text")
    VX <- readxl::read_excel(path = paste(inFile2$datapath, ".xlsx", sep=""), sheet = 1, col_types = vec_types)
    
    VX$PTalent_ID <- as.numeric(VX$PTalent_ID)
    VX$CO_Document_Number <- as.numeric(VX$CO_Document_Number)
    VX$Hour_Status_code <- as.numeric(VX$Hour_Status_code)
    
    # overige data inlezen
    bron_lcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 3)
    bron_ptalentcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 4)
    
    output2 <- dplyr::select(VX, 1:9)
    output2 <- dplyr::left_join(output2, bron_ptalentcodes, by = c("PTalent_ID" = "P-Talent Code"))
    
    output2$Work_Code <- VX$Work_Code
    output2 <- dplyr::left_join(output2, bron_lcodes, by = c("Work_Code" = "Wcode Ref"))
    output2 <- cbind(output2, VX[,11:28])
    
    return(output2)
 
  })
  # renderen van VX data in het tweede tabblad
  output$contents2 <- renderTable(datasetInput2())

  
  datasetInput3 <- reactive({
    SC <- datasetInput()
    VX <- datasetInput2()
    
    if (is.null(SC))
      return(NULL)
    bron_uurtarief <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 2)
    bron_xtra <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 5)
    bron_lcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 3)
    bron_ptalentcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 4)
    
    output <- rbind(SC, VX)
    
    # electronic arts filter toepassen
    output <- dplyr::mutate(output, `Client Description` = replace(`Client Description`, WBS_Element_Description == "SC-EA - Electronic Arts", "Electronic Arts"),
                            `Brand Descripton` = replace(`Brand Descripton`, WBS_Element_Description == "SC-EA - Electronic Arts", "Electronic Arts"))
    
    # SC- naar SC - Algemene uren 2016
    output <- dplyr::mutate(output, WBS_Element_Description = replace(WBS_Element_Description, WBS_Element_Description == "SC-", "SC - Algemene uren 2016"))
    
    # nieuwe werknemers eraan plakken
    colnames(output) <- colnames(bron_xtra)
    output <- dplyr::bind_rows(output, bron_xtra)
    #output[ , 23:27] <- lapply(output[,23:27], as.Date)
    output$PTalent_ID[output$PTalent_ID==94385] <- 101710
    
    # overplaatsen in een list voor de export
    output_list <- list("Starcom Uren 2016" = output, "Uurtarief " = bron_uurtarief, "L-Codes" = bron_lcodes,
                        "P-Talentcodes" = bron_ptalentcodes, "xtra uren nieuwe WKNRS" = bron_xtra)
    
    Sys.setenv(R_ZIPCMD= "S:\\Insights\\5 - Business & Data Solutions\\14. R\\Shiny\\zip.exe")
    # exporteren naar excel

    openxlsx::write.xlsx(output_list, "S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie test - shiny.xlsx")

    return("Klaar")
  })
  
  output$contents3 <- renderTable(datasetInput3())
  
  
  
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
