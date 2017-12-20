library(shiny)
library(shinythemes)
library(data.table)
library(magrittr)
library(shinycssloaders)
library(shinydashboard)
# library(plotly)

shinyUI(
  dashboardPage(
    dashboardHeader(title = "Shiny Descriptives"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Input", tabName = "input_data", icon = icon('gears')),
        menuItem("Text", tabName = "output_texts", icon = icon('sticky-note-o')),
        menuItem("Plot", tabName = "output_plots", icon = icon('line-chart'))
      )
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName = "input_data",
                fluidRow(
                  box(
                    actionButton("knop_df", width = "100%", label = strong("Input dataset")),
                    uiOutput('reset'),
                    height = '200px', width = 3, status = 'primary'),
                  box(
                    p(strong("TODO:")), 
                    p("- lijnen tussen variabelen aanbrengen in rasterplot"),
                    p("- plotly rasterplot maken"),
                    p("- iconen aanpassen"),
                    p("- meer plots"), 
                    status = 'primary'),
                  box(
                    checkboxInput('interactief', label = strong('Interactieve plots')), 
                    width = 3, status = 'primary')
                ),
                fluidRow(
                  infoBoxOutput('rijen'),
                  infoBoxOutput('kolommen'),
                  infoBoxOutput('bestandsnaam')),
                fluidRow(
                  tags$head(tags$style("#contents1 {white-space: nowrap; overflow: hidden; text-overflow: ellipsis;}")),
                  # tags$head(tags$style("#contents1 {text-overflow: ellipsis;}")),
                  
                  div(DT::dataTableOutput('contents1') %>% withSpinner(type = 8, size = 0.5), style = "font-size: 80%; width: 100%"))
        ),
        tabItem(tabName = "output_texts",
                fluidRow(
                  box(title = "Descriptives", collapsible = TRUE, status = 'primary',
                      DT::dataTableOutput('contentsx') %>% withSpinner(type = 8, size = 0.5), width = 12)
                ),
                fluidRow(
                  box(title = "Numeric variables", collapsible = TRUE, status = 'primary',
                      DT::dataTableOutput('contents_numeric') %>% withSpinner(type = 8, size = 0.5), width = 12))
        ),
        tabItem(tabName = "output_plots",
                fluidRow(
                  tags$head(tags$style(".shiny-plot-output{height:60vh !important;}")),  # css om de box en de plot langer te maken
                  box(title = "Missing values by row/column",  collapsible = TRUE, status = 'primary',
                      plotOutput('raster') %>% withSpinner(type = 8, size = 0.5), width = 12),
                  box(title = "Variable distributions", collapsible = TRUE, status = 'primary',
                      plotOutput('distribution') %>% withSpinner(type = 8, size = 0.5), width = 12)
                )
        )
      )
    )
  )
)
