library(shiny)
library(shinythemes)
shinyUI(
  navbarPage(strong("Coole titel"), theme = shinytheme("darkly"), collapsible = TRUE, 
  tabPanel("Urendashboard updater",  
    #shinythemes::themeSelector(), 
    headerPanel("Urendashboard updater"),
    sidebarLayout(position = "left",
      sidebarPanel(strong("Open het SC urenbestand"), br(),
                   actionButton("knop_sc", "Browse...", width = '200px'), br(), br(), br(),
                   strong("Open het VX urenbestand"), br(),
                   actionButton("knop_vx", "Browse...", width = '200px')),
      mainPanel(tableOutput('contents1'))
    )
  ),
  
  tabPanel("Zenith updater",
    headerPanel("Zenith updater"),
    sidebarLayout(position = "left",
      sidebarPanel(strong("Open het ZO urenbestand"), br(),
                   actionButton("knop_zo", "Browse...", width = '200px')),
      mainPanel(tableOutput('contents2'))
    )
  ),
  
  tabPanel("SmartContent updater",
    headerPanel("SmartContent updater"),
    sidebarLayout(position = "left",
      sidebarPanel(textInput("text_platform", "Voer het platform waar de data vandaan komt in (Optioneel)", ""), br(), br(),
                   strong("Selecteer de twee exportbestanden."), br(),
                   actionButton("knop_ru", "Browse...", width = '200px')
                   ),
      mainPanel(tableOutput('contents3'))
    )
  ),
  
  tabPanel("DMA updater",
    headerPanel("DMA updater"),
    sidebarLayout(position = "left",
      sidebarPanel(strong("Selecteer de ruwe DMA output bestanden"), br(),
                   actionButton("knop_dma1", "Browse...", width = '200px'), br(), br(), br(),
                   strong("Selecteer de map waar je de verwerkte bestanden wilt opslaan"), br(),
                   actionButton("knop_dma2", "Opslag kiezen...", width = '200px')),
      mainPanel(tableOutput('contents4'))
    )
  ),

  tabPanel("App updater",
    headerPanel("App updater "),
    sidebarLayout(position = "left",
      sidebarPanel(actionButton("knop_update", "Update!", width = '200px')),
      mainPanel(tableOutput('contents99')) 
    )
  ),
  
  tabPanel("Handleiding",
    headerPanel("Handleiding"),
      navlistPanel(
                   tabPanel("Urendashboard Starcom en Zenith", icon = icon("wheelchair-alt"),
                            mainPanel(width = '800px', 
                                      p("Open de meest recente SC en VX urenbestanden (en in het geval van Zenith: ZO) door op de Browse knoppen 
                                        te drukken. Zodra de twee bestanden zijn ingeladen begint de app alle bewerkingen uit te voeren. 
                                        Wanneer deze voltooid zijn verschijnt er in het scherm een melding met hoe lang de bewerkingen hebben 
                                        geduurd en waar de output is opgeslagen."), 
                                      p("Hierna kun je verder gaan in Tableau.")
                                      )
                            ),
                   
                   tabPanel("SmartContent", icon = icon("fighter-jet"),
                            mainPanel(width = '800px',
                                      p("Met de Browse knop kun je een 'ruw' en een 'ruw met doelgroep' bestand van één brand openen.
                                        Zodra de bestanden zijn ingeladen begint de app alle bewerkingen uit te voeren. Wanneer deze 
                                        voltooid zijn verschijnt er in het scherm een melding met hoe lang de bewerkingen hebben geduurd
                                        en waar de output is opgeslagen. In het geval van SmartContent wordt de output opgeslagen in de 
                                        map die direct boven de map ligt waar de inputbestanden in staan."),
                                      p("Dus als de input bestanden bijvoorbeeld komen uit:"),
                                      strong("\\padnaam\\November\\Ruw"), br(), br(),
                                      p("Dan worden de outputbestanden opgeslagen in:"),
                                      strong("\\padnaam\\November"), br(), br(),
                                      p("Optioneel kun je invoeren van welk platform de data afkomstig is (bijv. Facebook of Facebook and
                                        Instagram). Wat je hier invoert zal in de kolom Brand in het excelbestand worden geplaatst.")
                                      )
                            ),
                   
                   tabPanel("DMA", icon = icon("paw"),
                            mainPanel(width = '800px',
                                      p("Met de Browse knop kun je een ongelimiteerd aantal bestanden kiezen om te laten bewerken. Na
                                        selectie dien je ook te kiezen waar je de Excel outputbestanden wil opslaan. Zodra beiden zijn
                                        ingevoerd worden alle bestanden ingeladen en begint de app alle bewerkingen uit te voeren.
                                        Wanneer deze voltooid zijn verschijnt er in het scherm een melding met hoe lang de bewerkingen
                                        hebben geduurd en waar de output is opgeslagen."),
                                      p("Je hoeft verder niets te doen.")
                                      )
                            ),
                   
                   tabPanel("App updaten", icon = icon("glass"),
                            mainPanel(width = '800px',
                                      p("Klik op de knop Update! om de app te updaten. Start daarna de app opnieuw op.")))
                                )),
  

  
  
  navbarMenu("Extra",
    tabPanel("Interpolatie",
      headerPanel("Interpolatie"),
      sidebarLayout(position = "left",
        sidebarPanel(actionButton("knop_ip", "Boem!", width = '200px')),
        mainPanel(plotOutput('contents5')))
    ),
    tabPanel("test2",
             mainPanel(img(src='starcom.png', height = '300px', width = '300px', align = 'right'))))
)
)

# df <- read.csv("./Testapp/shiny/ding/train.csv", header = T)
#### TODO #####
