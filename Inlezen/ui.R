library(shiny)
library(shinythemes)
shinyUI(
  navbarPage("Shiny test", theme = shinytheme("darkly"), 
  tabPanel("Urendashboard updater", 
   # shinythemes::themeSelector(), 
    headerPanel("Urendashboard updater"),
    sidebarLayout(position = "left",
      sidebarPanel(fileInput("uploadFile", "Open het SC urenbestand"), 
                   fileInput("uploadFile2", "Open het VX urenbestand")),
      mainPanel(tableOutput('contents3'))
    )
  ),
  
  tabPanel("Zenith updater",
    headerPanel("Zenith updater"),
    sidebarLayout(position = "left",
      sidebarPanel(fileInput("uploadFile5", "Open het ZO urenbestand")),
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
