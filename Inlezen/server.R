shinyServer(function(input, output, session) {
  # instelling om grotere bestanden in te kunnen lezen
  options(shiny.maxRequestSize=50*1024^2)
  
  ########################################### Urenupdater ########################################################
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
  
  
  datasetInput3 <- reactive({
    SC <- datasetInput()
    VX <- datasetInput2()
    
    if (is.null(SC))
      return(NULL)
    
    x <- system.time({
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
    })
    return(paste(round(x[3],2), "seconden.")  )
  })
  
  output$contents3 <- renderTable(datasetInput3())
  
  ########################################### Zenith #############################################################
  zenith_input1 <- reactive({
    inFile5 <- input$uploadFile5
    
    if (is.null(inFile5))
      return(NULL)
    
    file.rename(inFile5$datapath,
                paste(inFile5$datapath, ".xlsx", sep = ""))
    
    vec_types <- c("text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                   "numeric", "numeric", "numeric", "numeric", "text", "numeric", "text", "text", "text",
                   "text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                   "text", "text", "text", "text", "text", "text", "text")
    ZO <- readxl::read_excel(path = paste(inFile5$datapath, ".xlsx", sep=""), sheet = 1, col_types = vec_types)
    
    ZO$PTalent_ID <- as.numeric(ZO$PTalent_ID)
    ZO$CO_Document_Number <- as.numeric(ZO$CO_Document_Number)
    ZO$Hour_Status_code <- as.numeric(ZO$Hour_Status_code)
    
    # overige data inlezen
    bron_lcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Zenith\\Urendashboard Zenith Werkversie.xlsx", sheet = 3)
    bron_ptalentcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Zenith\\Urendashboard Zenith Werkversie.xlsx", sheet = 2)
    bron_ptalentcodes <- dplyr::distinct(bron_ptalentcodes)
    
    # SC voorbereiden
    output <- dplyr::select(ZO, 1:9)
    output <- dplyr::left_join(output, bron_ptalentcodes, by = c("PTalent_ID" = "P-Talent Code"))
    
    output$Work_Code <- ZO$Work_Code
    output <- dplyr::left_join(output, bron_lcodes, by = c("Work_Code" = "Wcode Ref"))
    output <- cbind(output, ZO[,11:28])
    
    # overplaatsen in een list voor de export
    output_list <- list("Uren Zenith" = output, "P-Talent" = bron_ptalentcodes, "L-Codes" = bron_lcodes)
    
    Sys.setenv(R_ZIPCMD= "S:\\Insights\\5 - Business & Data Solutions\\14. R\\Shiny\\zip.exe")
    openxlsx::write.xlsx(output_list, "C:\\Users\\davgies\\Documents\\R\\Projecten\\Urendashboard\\Urendashboard Zenith Werkversie.xlsx")
    
    return("Klaar")
  })
 
   output$contents6 <- renderTable(zenith_input1())
  
  ########################################### Smartcontent #######################################################
  smartcontent_input1 <- reactive({
    inFile3 <- input$uploadFile3
    
    if (is.null(inFile3))
      return(NULL)
  
    file.rename(inFile3$datapath,
                paste(inFile3$datapath, ".xlsx", sep=""))
    #(ruw)
    smart1 <- readxl::read_excel(path = paste(inFile3$datapath, ".xlsx", sep=""), sheet = 1)

#    smart1$Starts <- as.Date(smart1$Starts)
    
    # eerste 2 kolommen verwijderen + Results Type (Result indicator)
    smart1 <- dplyr::select(smart1, -1, -2, -5)
    
    # na Campaign drie kolommen toevoegen: Platform, Ad type en Brand
    smart1$Platform <- ""
    smart1$`Ad type` <- ""
    smart1$Brand <- ""
    smart1 <- smart1[, c(1, 43:45, 2:42)]
    
    # Ad type opvullen met informatie uit de Campaign variabele
    smart1 <- tidyr::separate(smart1, Campaign, into = c("Campaign1", "Campaign2", "Campaign3"), sep = "-", extra = "merge")
    smart1$`Ad type` <- trimws(smart1$Campaign2)
    smart1 <- tidyr::unite(smart1, Campaign, 1:3, sep = "-")
    
    # brandnaam toevoegen aan Brand
    # brandnaam <- sub(" -.*", "", gsub(pattern = "Januari|Februari|Maart|April|Mei|Juni|Juli|Augustus|September|Oktober|November|December", 
    #                                   x = basename(vec_ruw), "-", ignore.case = T))
    smart1$Brand <- "brandnaam"
    
    # extra dashboard variabelen berekenen en variabelennamen aanpassen aan dashboard document
    smart1 <- dplyr::mutate(smart1, 
                            `Conversation Rate` = `Post comments`/Reach,
                            `Amplification Rate` = `Post shares`/Reach,
                            `Applause Rate` = `Post Reactions`/Reach,
                            `Key Engagements` = (`Post comments`+`Post shares`+`Post Reactions`)/Reach)
    var_namen <- c("Campaign Name",	"Platform",	"Ad Type",	"Brand",	"Results",	"Reach",	"Amount Spent (EUR)",	"Clicks (All)",	
                   "Cost per Unique Click (All) (EUR)",	"CPC (All) (EUR)",	"CPM (Cost per 1,000 Impressions) (EUR)",
                   "Cost per 1,000 People Reached (EUR)",	"CTR (All)",	"Frequency",	"Impressions",	"Objective",	"Social Impressions",	
                   "Social Reach", "Page Likes",	"Page Engagement",	"Photo Views",	"Post Shares",	"Post Comments",	"Post Engagement",	
                   "Post Likes", "Clicks to Play Video",	"Video Views",	"Cost per Page Like (EUR)",	"Cost per Photo View (EUR)",	
                   "Cost per Post Share (EUR)", "Cost per Post Comment (EUR)",	"Cost per Post Engagement (EUR)",	"Cost per Post Like (EUR)",	
                   "Cost per Clicks to Play Video (EUR)", "Cost per Video View (EUR)",	"Avg. % of Video Viewed",	"Video Views to 100%", 
                   "Video Views to 25%",	"Video Views to 50%", "Video Views to 75%",	"Video Views to 95%",	"Starts",	"CPC (Link)",	"CTR (Link)",	
                   "Link Clicks",	"Conversation Rate", "Amplifcation Rate",	"Applause Rate", "Key Engagements")
    colnames(smart1) <- var_namen
    return(smart1) 
  })
  
  smartcontent_input2 <- reactive({
    inFile4 <- input$uploadFile4
    
    if (is.null(inFile4))
      return(NULL)
    
    file.rename(inFile4$datapath,
                 paste(inFile4$datapath, ".xlsx", sep=""))
    
    #(ruw met doelgroep)
    smart2 <- readxl::read_excel(path = paste(inFile4$datapath, ".xlsx", sep=""), sheet = 1)    
    # smart2$Starts <- as.Date(smart2$Starts)
    smart2 <- dplyr::select(smart2, -1, -2, -dplyr::ends_with("indicator"))
    smart2$Platform <- ""
    smart2$`Ad type` <- ""
    smart2$Brand <- ""
    smart2 <- smart2[, c(1, 45:47, 2:44)]
    
    smart2 <- tidyr::separate(smart2, Campaign, into = c("Campaign1", "Campaign2", "Campaign3"), sep = "-", extra = "merge")
    smart2$`Ad type` <- trimws(smart2$Campaign2)
    smart2 <- tidyr::unite(smart2, Campaign, 1:3, sep = "-")
    # brandnaam2 <- sub(" -.*", "", gsub(pattern = "Januari|Februari|Maart|April|Mei|Juni|Juli|Augustus|September|Oktober|November|December", 
    #                                    x = basename(vec_ruw_doel), "-", ignore.case = T))
    smart2$Brand <- "brandnaam2"
    
    smart2 <- dplyr::mutate(smart2,
                            `Conversation Rate` = `Post comments`/Reach,
                            `Amplification Rate` = `Post shares`/Reach,
                            `Applause Rate` = `Post Reactions`/Reach,
                            `Key Engagements` = (`Post comments`+`Post shares`+`Post Reactions`)/Reach)
    var_namen2 <- c("Campaign Name",	"Platform", 	"Ad Type",	"Brand",	"Age",	"Gender",	"Results",	"Reach",	
                    "Amount Spent (EUR)",	"Clicks (All)",	"Cost per Unique Click (All) (EUR)",	"CPC (All) (EUR)",
                    "CPM (Cost per 1,000 Impressions) (EUR)",	"Cost per 1,000 People Reached (EUR)",	"CTR (All)",	
                    "Frequency",	"Impressions",	"Objective",	"Social Impressions",	"Social Reach",	"Page Likes",
                    "Page Engagement",	"Photo Views",	"Post Shares",	"Post Comments",	"Post Engagement",	"Post Likes",	
                    "Clicks to Play Video",	"Video Views",	"Cost per Page Like (EUR)",	"Cost per Photo View (EUR)",	
                    "Cost per Post Share (EUR)",	"Cost per Post Comment (EUR)",	"Cost per Post Engagement (EUR)",	
                    "Cost per Post Like (EUR)",	"Cost per Clicks to Play Video (EUR)",	"Cost per Video View (EUR)",	
                    "Avg. % of Video Viewed",	"Video Views to 100%",	"Video Views to 25%",	"Video Views to 50%",	
                    "Video Views to 75%",	"Video Views to 95%",	"Datum Post",	"CPC (Link)",	"CTR (Link)",	"Link Clicks",
                    "Conversation Rate",	"Amplifcation Rate",	"Applause Rate",	"Key Engagements")
    colnames(smart2) <- var_namen2
    return(smart2)
  })
  output$contents4 <- renderTable(smartcontent_input1())
  output$contents5 <- renderTable(smartcontent_input2())
  
  ########################################### Sessie afsluiten ###################################################
  session$onSessionEnded(function() {
    stopApp()
  })
})
