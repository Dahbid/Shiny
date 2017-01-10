library(shiny)
library(shinythemes)
shinyUI(
  navbarPage("", theme = shinytheme("darkly"), collapsible = TRUE,
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
      sidebarPanel(textInput("text_platform", "Voer het platform waar de data vandaan komt in (Optioneel)", "Facebook"), br(), br(),
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
                   actionButton("knop_dma2", "Browse...", width = '200px')),
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

  navbarMenu("Extra",
    tabPanel("test"),
    tabPanel("test2"))
)
)
