shinyServer(function(input, output, session) {
  # instelling om grotere bestanden in te kunnen lezen
  options(shiny.maxRequestSize=50*1024^2)
  
  ########################################### Urenupdater ########################################################
  starcom <- eventReactive(input$knop_sc, {choose.files(caption = "Open de meest recente SC uren", 
                                                        default = "S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Data\\SC")})
  vivaki <- eventReactive(input$knop_vx, {choose.files(caption = "Open de meest recente SC uren", 
                                                       default = "S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Data\\SC")})
  # a;lsdkfja;lksdjf;laksjdfl;kjl
  urendashboard <- reactive({
      x <- system.time({
      vec_sc <- starcom()
      vec_vx <- vivaki()
      
      vec_types <- c("text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                     "numeric", "numeric", "numeric", "numeric", "text", "numeric", "text", "text", "text",
                     "date", "date", "date", "date", "date", "text", "text", "text", "text", "text", "text", "text",
                     "text", "text", "text", "text", "text", "text", "text")
      
      # data inlezen altair
      SC <- readxl::read_excel(path = vec_sc, col_types = vec_types)
      VX <- readxl::read_excel(path = vec_vx, col_types = vec_types)
      
      SC$PTalent_ID[SC$PTalent_ID=="94385"] <- "101710"  # Esther Buis heeft twee nummers
      SC$PTalent_ID <- as.numeric(SC$PTalent_ID)
      VX$PTalent_ID <- as.numeric(VX$PTalent_ID)
      SC$CO_Document_Number <- as.numeric(SC$CO_Document_Number)
      VX$CO_Document_Number <- as.numeric(VX$CO_Document_Number)
      SC$Hour_Status_code <- as.numeric(SC$Hour_Status_code)
      VX$Hour_Status_code <- as.numeric(VX$Hour_Status_code)
      
      # overige data inlezen
      bron_uurtarief <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 2)
      bron_lcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 3)
      bron_ptalentcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 4)
      bron_xtra <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie.xlsx", sheet = 5)
      
      # SC voorbereiden
      output <- dplyr::select(SC, 1:9)
      output <- dplyr::left_join(output, bron_ptalentcodes, by = c("PTalent_ID" = "P-Talent Code"))
      
      output$Work_Code <- SC$Work_Code
      output <- dplyr::left_join(output, bron_lcodes, by = c("Work_Code" = "Wcode Ref"))
      output <- cbind(output, SC[,11:28])
      
      # dan VX
      output2 <- dplyr::select(VX, 1:9)
      output2 <- dplyr::left_join(output2, bron_ptalentcodes, by = c("PTalent_ID" = "P-Talent Code"))
      
      output2$Work_Code <- VX$Work_Code
      output2 <- dplyr::left_join(output2, bron_lcodes, by = c("Work_Code" = "Wcode Ref"))
      output2 <- cbind(output2, VX[,11:28])
      
      # samenvoegen
      output <- rbind(output, output2)
      
      # electronic arts filter toepassen
      output <- dplyr::mutate(output, `Client Description` = replace(`Client Description`, WBS_Element_Description == "SC-EA - Electronic Arts", "Electronic Arts"),
                              `Brand Descripton` = replace(`Brand Descripton`, WBS_Element_Description == "SC-EA - Electronic Arts", "Electronic Arts"))
      
      # SC- naar SC - Algemene uren 2016
      output <- dplyr::mutate(output, WBS_Element_Description = replace(WBS_Element_Description, WBS_Element_Description == "SC-", "SC - Algemene uren 2016"))
      
      # nieuwe werknemers eraan plakken
      colnames(output) <- colnames(bron_xtra)
      output <- dplyr::bind_rows(output, bron_xtra)
      output[ , 23:27] <- lapply(output[,23:27], as.Date)
      output$PTalent_ID[output$PTalent_ID==94385] <- 101710
      
      # overplaatsen in een list voor de export
      output_list <- list("Starcom Uren 2016" = output, "Uurtarief " = bron_uurtarief, "L-Codes" = bron_lcodes,
                          "P-Talentcodes" = bron_ptalentcodes, "xtra uren nieuwe WKNRS" = bron_xtra)
      
      # exporteren naar excel
      Sys.setenv(R_ZIPCMD= "S:\\Insights\\5 - Business & Data Solutions\\14. R\\Shiny\\zip.exe")
      openxlsx::write.xlsx(output_list, "S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Bronbestand Urendashboard werkversie test - shiny.xlsx")
    })
    return(paste(round(x[3],2), "seconden.") )
  })
  
  output$contents1 <- renderTable(urendashboard())
  
  ########################################### Zenith #############################################################
  zenith <- eventReactive(input$knop_zo, {choose.files(caption = "Open de meest recente ZO uren", 
                                                        default = "S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Zenith\\Data\\ZO")})
  
  zenith_input <- reactive({
    x <- system.time({
    vec_zo <- zenith()
    
    vec_types <- c("text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                   "numeric", "numeric", "numeric", "numeric", "text", "numeric", "text", "text", "text",
                   "date", "date", "date", "date", "date", "text", "text", "text", "text", "text", "text", "text",
                   "text", "text", "text", "text", "text", "text", "text")
    
    # data inlezen altair
    ZO <- readxl::read_excel(path = vec_zo, col_types = vec_types)
    ZO$PTalent_ID <- as.numeric(ZO$PTalent_ID)
    ZO$CO_Document_Number <- as.numeric(ZO$CO_Document_Number)
    ZO$Hour_Status_code <- as.numeric(ZO$Hour_Status_code)
    
    # overige data inlezen
    # bron_uurtarief <- read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Zenith\\Urendashboard Zenith Werkversie.xlsx", sheet = 2)
    bron_lcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Zenith\\Urendashboard Zenith Werkversie.xlsx", sheet = 3)
    bron_ptalentcodes <- readxl::read_excel("S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Zenith\\Urendashboard Zenith Werkversie.xlsx", sheet = 2)
    bron_ptalentcodes <- dplyr::distinct(bron_ptalentcodes)
    
    # Excel formules vervangen
    output <- dplyr::select(ZO, 1:9)
    output <- dplyr::left_join(output, bron_ptalentcodes, by = c("PTalent_ID" = "P-Talent Code"))
    
    output$Work_Code <- ZO$Work_Code
    output <- dplyr::left_join(output, bron_lcodes, by = c("Work_Code" = "Wcode Ref"))
    output <- cbind(output, ZO[,11:28])
    
    # Posixct omzetten in date
    output[ , 23:27] <- lapply(output[,23:27], as.Date)
    
    # overplaatsen in een list voor de export
    output_list <- list("Uren Zenith" = output, "P-Talent" = bron_ptalentcodes, "L-Codes" = bron_lcodes)
    # exporteren naar excel
    Sys.setenv(R_ZIPCMD= "S:\\Insights\\5 - Business & Data Solutions\\14. R\\Shiny\\zip.exe")
    openxlsx::write.xlsx(output_list, "S:\\Insights\\5 - Business & Data Solutions\\10. Starcom Tableau Server DB\\Uren Dashboard\\Zenith\\Urendashboard Zenith Werkversie test.xlsx")
    })
    return(paste(round(x[3],2), "seconden.") )
  })

  output$contents2 <- renderTable(zenith_input())
  
  ########################################### Smartcontent #######################################################
  smartruw <- eventReactive(input$knop_ru, {choose.files(default = "S:\\Insights\\5 - Business & Data Solutions\\1. Data Visualisatie\\SmartContent\\Rapportages 2016\\ruw",
                                                         caption = "Selecteer de bestanden die je wilt bewerken")})
  
  smartcontent_input1 <- reactive({
    x <- system.time({
    vec_input <- smartruw()
    
    if (grepl(x = vec_input[1], pattern = "met doelgroep") == TRUE) {
      vec_ruw_doel <- vec_input[1]
      vec_ruw <- vec_input[2]
    } else {
      vec_ruw_doel <- vec_input[2]
      vec_ruw <- vec_input[1]
    }
    
    #(ruw)
    smart1 <- readxl::read_excel(path = vec_ruw, sheet = 1)
    smart1$Starts <- as.Date(smart1$Starts)
    
    # eerste 2 kolommen verwijderen + Results Type (Result indicator)
    smart1 <- dplyr::select(smart1, -1, -2, -5)
    
    # na Campaign drie kolommen toevoegen: Platform, Ad type en Brand
    smart1$Platform <- input$text_platform
    smart1$`Ad type` <- ""
    smart1$Brand <- ""
    smart1 <- smart1[, c(1, 43:45, 2:42)]
    
    # Ad type opvullen met informatie uit de Campaign variabele
    smart1 <- tidyr::separate(smart1, Campaign, into = c("Campaign1", "Campaign2", "Campaign3"), sep = "-", extra = "merge")
    smart1$`Ad type` <- trimws(smart1$Campaign2)
    smart1 <- tidyr::unite(smart1, Campaign, 1:3, sep = "-")
    
    # brandnaam toevoegen aan Brand
    brandnaam <- sub(" -.*", "", gsub(pattern = "Januari|Februari|Maart|April|Mei|Juni|Juli|Augustus|September|Oktober|November|December",
                                      x = basename(vec_ruw), "-", ignore.case = T))
    smart1$Brand <- brandnaam
    
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
    
    #(ruw met doelgroep)
    smart2 <- readxl::read_excel(path = vec_ruw_doel, sheet = 1)
    smart2$Starts <- as.Date(smart2$Starts)
    smart2 <- dplyr::select(smart2, -1, -2, -dplyr::ends_with("indicator"))
    smart2$Platform <- input$text_platform
    smart2$`Ad type` <- ""
    smart2$Brand <- ""
    smart2 <- smart2[, c(1, 45:47, 2:44)]

    
    smart2 <- tidyr::separate(smart2, Campaign, into = c("Campaign1", "Campaign2", "Campaign3"), sep = "-", extra = "merge")
    smart2$`Ad type` <- trimws(smart2$Campaign2)
    smart2 <- tidyr::unite(smart2, Campaign, 1:3, sep = "-")
    brandnaam2 <- sub(" -.*", "", gsub(pattern = "Januari|Februari|Maart|April|Mei|Juni|Juli|Augustus|September|Oktober|November|December", 
                                       x = basename(vec_ruw_doel), "-", ignore.case = T))
    smart2$Brand <- brandnaam2
    
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
    
    #Exporteren
    #outputmap pad creëren
    outputmap <- gsub(x=dirname(dirname(vec_ruw) ),"\\/", "\\\\")
    
    #vec_ruw
    outputnaam1 <- paste0(outputmap, sep = "\\", gsub(" \\(Ruw\\)", "", basename(vec_ruw), ignore.case = T))
    #vec_ruw_doel
    outputnaam2 <- paste0(outputmap, sep = "\\", gsub("Ruw ", "", basename(vec_ruw_doel), ignore.case = T))
    
    # wegschrijven
    Sys.setenv(R_ZIPCMD= "S:\\Insights\\5 - Business & Data Solutions\\14. R\\Shiny\\zip.exe")
    openxlsx::write.xlsx(x = as.data.frame(smart1), file = outputnaam1, row.names = F)
    openxlsx::write.xlsx(x = as.data.frame(smart2), file = outputnaam2, row.names = F)
    })
    return(paste(round(x[3],2), "seconden.") )
  })

  output$contents3 <- renderTable(smartcontent_input1())
  
  ########################################### DMA ################################################################
  dma_bestand <- eventReactive(input$knop_dma1, {choose.files(caption = "Open het ruwe channel url report",
                                                              default = "S:\\Insights\\5 - Business & Data Solutions\\2. DMA\\Tableau\\Dashboard\\Data\\Channel URL\\Ruw\\ruw")})
  dma_map <- eventReactive(input$knop_dma2, {choose.dir(caption = "Kies de opslagmap",
                                                        default = "S:\\Insights\\5 - Business & Data Solutions\\2. DMA\\Tableau\\Dashboard\\Data\\Channel URL")})
  
  dma_input <- reactive({
    x <- system.time({
    vec_ruw <- dma_bestand()
    vec_export <- dma_map()
    
    var_types <- c("text", "text", "text", "text", "text", "text", "text", "numeric", "numeric", "numeric", "numeric", "numeric",
                   "numeric", "numeric")
    resultaat <- list()
    resultaat2 <- vector()
    for (i in vec_ruw) {
      dma <- list()
      dma$document <- readxl::read_excel(path = i, sheet = 1, skip = 1, col_names = F)           # sheet 1
      dma$document <- tidyr::separate(dma$document, X4, c("X4a", "X4"), sep = " - ", fill = "left")   # brand en campagne scheiden
      dma$document <- dma$document[, apply(dma$document, 2, function(x) !any(is.na(x)))]       # lege kolom die ontstaat wegdoen
      dma$channel <- readxl::read_excel(path = i, sheet = 3, skip = 2, col_types = var_types)           # sheet 2
      dma$channel <- dma$channel[,3:ncol(dma$channel)]
      
      #bewerken
      # variabelen Klant en Campaign toevoegen
      pattern <- paste0(dma$document[1,4], collapse = "|") 
      if (pmatch(pattern, dma$document[2,2], nomatch = 0) > 0) {
        dma$document[2,2] <- trimws(gsub(pattern = pattern, "", dma$document[2,2]))
      }
      dma$channel <- cbind(a=dma$document[1,4], b=dma$document[2,2], dma$channel)
      names(dma$channel)[1] <- "Klant"
      names(dma$channel)[2] <- "Campaign"
      
      # Filteren op Format en kolommen met 3s of 10s verwijderen
      dma$channel <- dma$channel[!is.na(dma$channel$Format),]
      namen <- c("Klant", "Campaign", "Network", "Placement", "Target", "Domain", "Format", "Impressions", "Measured",
                 "Avg ToP", "Avg TiV", "> 5s", "> 1s")
      dma$channel <- dplyr::select(dma$channel, dplyr::one_of(namen))
      
      # start date en end date toevoegen (mutate voegt het aan het eind toe)
      dma$datum <- data.frame(dma$document[3,4])
      dma$datum <- tidyr::separate(dma$datum, X6, into = c("Start date", "End date"), sep = " - ")
      dma$channel <- dplyr::mutate(dma$channel, `Start date` = dma$datum$`Start date`, `End date` = dma$datum$`End date`)
      
      # omzetten in datum variabelen en het format aanpassen in dd-mm-jjjj
      dma$channel$`Start date` <- as.Date(dma$channel$`Start date`)
      dma$channel$`End date` <- as.Date(dma$channel$`End date`)
      # dma$channel$`Start date` <- strptime(as.character(dma$channel$`Start date`), format = "%Y-%m-%d")
      # dma$channel$`Start date` <- format(dma$channel$`Start date`, "%d-%m-%Y")
      # dma$channel$`End date` <- strptime(as.character(dma$channel$`End date`), format = "%Y-%m-%d")
      # dma$channel$`End date` <- format(dma$channel$`End date`, "%d-%m-%Y")
      
      # #ehhh... ja
      # dma$channel[8:13] <- lapply( dma$channel[8:13], function(col) as.numeric(gsub("-$|\\,", "", col)))
      # # eeeennnnnn streepjes terug
      # dma$channel[, 8:13][is.na(dma$channel[, 8:13])] <- "-"
      # # wat als ik alle punten met komma's verwissel?
      # dma$channel[8:13] <- lapply( dma$channel[8:13], function(col) gsub(".", ",", col, fixed = T))
      resultaat[[length(resultaat)+1]] <- dma
      
      # output naam en map creëren
      output_naam <- gsub(" \\(Ruw\\)", "", basename(i), ignore.case = T)
      
      resultaat2 <- append(resultaat2, output_naam)
    }
    Sys.setenv(R_ZIPCMD= "S:\\Insights\\5 - Business & Data Solutions\\14. R\\Shiny\\zip.exe")
    # samenvoegen en exporteren
    for (j in 1:length(vec_ruw)) {
      openxlsx::write.xlsx(x = resultaat[[j]]$channel, file = paste0(vec_export, sep = "\\", resultaat2[j], "x"), row.names = F)
    }
    })
    return(paste(round(x[3],2), "seconden.") )
  })
  
  output$contents4 <- renderTable(dma_input())
  
  ########################################### App updater ########################################################
  shiny_update <- reactive({
    
     from <- "S:\\Insights\\5 - Business & Data Solutions\\14. R\\Shiny\\ui.R"
     from2 <- "S:\\Insights\\5 - Business & Data Solutions\\14. R\\Shiny\\server.R"
     to <- paste0(getwd())
     observeEvent(input$knop_update, {file.copy(from = from, to = to, overwrite = TRUE)
                                      file.copy(from = from2, to = to, overwrite = TRUE)})
    return(getwd())
  })
  output$contents99 <- renderTable(shiny_update())
  
  ########################################### Sessie afsluiten ###################################################
  session$onSessionEnded(function() {
    stopApp()
  })
})

