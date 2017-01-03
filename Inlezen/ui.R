library(shiny)
library(shinythemes)
shinyUI(
  navbarPage("Shiny test", theme = shinytheme("darkly"), 
  tabPanel("Urendashboard updater", 
    #shinythemes::themeSelector(), 
    headerPanel("Urendashboard updater"),
    sidebarLayout(position = "left",
      sidebarPanel(strong("Open het SC urenbestand"),
                   actionButton("knop_sc", "Browse", width = '200px'), br(), br(), br(),
                   strong("Open het VX urenbestand"),
                   actionButton("knop_vx", "Browse", width = '200px')),
      mainPanel(tableOutput('contents3'))
    )
  ),
  
  tabPanel("Zenith updater",
    headerPanel("Zenith updater"),
    sidebarLayout(position = "left",
      sidebarPanel(strong("Open het ZO urenbestand"),
                   actionButton("knop_zo", "Browse", width = '200px')),
      mainPanel(tableOutput('contents6'))
    )
  ),
  
  tabPanel("SmartContent updater",
    headerPanel("SmartContent updater"),
    sidebarLayout(position = "left",
      sidebarPanel(fileInput("uploadFile3", "Ruw"),
                   fileInput("uploadFile4", "Ruw met doelgroep"),
                   textInput("text", "Voer het platform waar de data vandaan komt in", "Facebook")),
      mainPanel(tableOutput('contents5'))
    )
  )
  
  ))
