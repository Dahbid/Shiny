library(shiny)
library(shinythemes)

shinyUI(
  navbarPage("Shiny", theme = shinytheme("lumen"), collapsible = TRUE, 
             tabPanel("Test",  
                      #shinythemes::themeSelector(),
                      headerPanel("Test"),
                      sidebarLayout(position = "left",
                                    sidebarPanel(strong("Open ..."), br(),
                                                 actionButton("knop_sc", "Browse...", width = '200px', style="color: #fff; background-color: #158cba; border-color: #158cba"), br(), br(), br()
                                    ),
                                    mainPanel(dataTableOutput('contents1'))
                      )
             )
  )
)
