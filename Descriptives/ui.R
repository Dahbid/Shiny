shinyUI(
  shinydashboard::dashboardPage(
    shinydashboard::dashboardHeader(title = "Shiny Descriptives"),
    shinydashboard::dashboardSidebar(
      shinydashboard::sidebarMenu(
        shinydashboard::menuItem("Input", tabName = "input_data", icon = icon('gears')),
        shinydashboard::menuItem("Text", tabName = "output_texts", icon = icon('sticky-note-o')),
        shinydashboard::menuItem("Plot", tabName = "output_plots", icon = icon('line-chart'))
      )
    ),
    shinydashboard::dashboardBody(
      shinydashboard::tabItems(
        shinydashboard::tabItem(
          tabName = "input_data",
          fluidRow(
            shinydashboard::box(
              div(id = "myDiv", fileInput("knop_input", multiple = FALSE, label = NULL)),
              uiOutput('reset'),
              uiOutput('reset2'),
              height = '250px', width = 3, status = 'primary'),
            shinydashboard::box(
              p(strong("TODO:")),
              p("- plot dynamisch groter maken op basis van ncol"),
              p("- shiny dwingen direct plots te renderen na uploaden data zodra asynchrone taken mogelijk zijn"),
              p("- distributieplot stijl aanpassen"),
              p("- file limit exceeded na uploaden aantal bestanden"),
              status = 'primary'),
            shinydashboard::box(
              checkboxInput('interactief', label = strong('Interactieve plots'), value = FALSE), 
              width = 3, status = 'primary')
          ),
          fluidRow(
            shinydashboard::valueBoxOutput('rijen'),
            shinydashboard::valueBoxOutput('kolommen'),
            shinydashboard::infoBoxOutput('bestandsnaam')),
          fluidRow(
            tags$head(tags$style("#contents1 {white-space: nowrap; overflow: hidden; text-overflow: ellipsis;}")),
            # tags$head(tags$style("#contents1 {text-overflow: ellipsis;}")),
            
            div(DT::dataTableOutput('contents1') %>% shinycssloaders::withSpinner(type = 8, size = 0.5), 
                style = "font-size: 80%; width: 100%"))
        ),
        shinydashboard::tabItem(
          tabName = "output_texts",
          fluidRow(
            shinydashboard::box(title = "Descriptives", collapsible = TRUE, status = 'primary', solidHeader = TRUE,
                                DT::dataTableOutput('contentsx') %>% shinycssloaders::withSpinner(type = 8, size = 0.5), width = 12)
          ),
          fluidRow(
            shinydashboard::box(title = "Numeric variables", collapsible = TRUE, status = 'primary', solidHeader = TRUE,
                                DT::dataTableOutput('contents_numeric') %>% shinycssloaders::withSpinner(type = 8, size = 0.5), width = 12))
        ),
        shinydashboard::tabItem(
          tabName = "output_plots",
          fluidRow(
            tags$head(tags$style(".shiny-plot-output{height:60vh !important;}")),  # css om de box en de plot langer te maken
            # uiOutput('plots')#,
            shinydashboard::box(title = "Missing values by row/column",  collapsible = TRUE, status = 'primary', solidHeader = TRUE,
                                plotOutput('raster') %>% shinycssloaders::withSpinner(type = 8, size = 0.5), width = 12),
            shinydashboard::box(title = "Variable distributions", collapsible = TRUE, status = 'primary', solidHeader = TRUE,
                                plotOutput('distribution') %>% shinycssloaders::withSpinner(type = 8, size = 0.5), width = 12),
            shinydashboard::box(title = "Correlation matrix", collapsible = TRUE, status = 'primary', solidHeader = TRUE,
                                plotOutput('correlation') %>% shinycssloaders::withSpinner(type = 8, size = 0.5), width = 12)
          )
        )
      )
    )
  )
)
