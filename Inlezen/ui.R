library(shiny)
library(shinythemes)
shinyUI(
  navbarPage("Shiny test", theme = shinytheme("darkly"), 
  tabPanel("Urendashboard updater", 
   # shinythemes::themeSelector(), 
    headerPanel("Urendashboard updater"),
    sidebarPanel(fileInput("uploadFile", "Open het SC urenbestand"), 
                 fileInput("uploadFile2", "Open het VX urenbestand"),
    downloadButton('downloadData', "Download")
    )
    
    ),
  
  tabPanel("test1",
    headerPanel("Poep"),

    mainPanel(tableOutput('contents2'))),
  
  tabPanel("test2",
    headerPanel("Huh"),
    sidebarPanel(),
    mainPanel(tableOutput('contents3'))),
  
  tabPanel("Smartcontent updater",
    headerPanel("Smartcontent updater"),
    sidebarPanel(),
    mainPanel(tableOutput('iris')))
  ))
