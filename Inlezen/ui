#

library(shiny)

fluidPage(
  titlePanel("Uploaden"),
  sidebarLayout(
    sidebarPanel(
      fileInput("uploadFile", "SC file"
      ),
      fileInput("uploadFile2", "VX file")
    ),
    mainPanel(
      tabsetPanel(
      tabPanel("SC",tableOutput('contents')),
      tabPanel("VX",tableOutput('contents2'))
    )
    )
  )
)
