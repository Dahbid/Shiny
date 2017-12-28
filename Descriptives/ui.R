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
                    fileInput("knop_input", multiple = FALSE, label = NULL),
                    uiOutput('reset'),
                    height = '250px', width = 3, status = 'primary'),
                  box(
                    p(strong("TODO:")),
                    p("- plot dynamisch groter maken op basis van ncol"),
                    p("- shiny dwingen direct plots te renderen na uploaden data zodra asynchrone taken mogelijk zijn"),
                    p("- een echte file input knop gebruiken gezien pad niet belangrijk is"),
                    status = 'primary'),
                  box(
                    checkboxInput('interactief', label = strong('Interactieve plots')), 
                    width = 3, status = 'primary')
                ),
                fluidRow(
                  valueBoxOutput('rijen'),
                  valueBoxOutput('kolommen'),
                  infoBoxOutput('bestandsnaam')),
                fluidRow(
                  tags$head(tags$style("#contents1 {white-space: nowrap; overflow: hidden; text-overflow: ellipsis;}")),
                  # tags$head(tags$style("#contents1 {text-overflow: ellipsis;}")),
                  
                  div(DT::dataTableOutput('contents1') %>% withSpinner(type = 8, size = 0.5), style = "font-size: 80%; width: 100%"))
        ),
        tabItem(tabName = "output_texts",
                fluidRow(
                  box(title = "Descriptives", collapsible = TRUE, status = 'primary', solidHeader = TRUE,
                      DT::dataTableOutput('contentsx') %>% withSpinner(type = 8, size = 0.5), width = 12)
                ),
                fluidRow(
                  box(title = "Numeric variables", collapsible = TRUE, status = 'primary', solidHeader = TRUE,
                      DT::dataTableOutput('contents_numeric') %>% withSpinner(type = 8, size = 0.5), width = 12))
        ),
        tabItem(tabName = "output_plots",
                fluidRow(
                  tags$head(tags$style(".shiny-plot-output{height:60vh !important;}")),  # css om de box en de plot langer te maken
                  box(title = "Missing values by row/column",  collapsible = TRUE, status = 'primary', solidHeader = TRUE,
                      plotOutput('raster') %>% withSpinner(type = 8, size = 0.5), width = 12),
                  box(title = "Variable distributions", collapsible = TRUE, status = 'primary', solidHeader = TRUE,
                      plotOutput('distribution') %>% withSpinner(type = 8, size = 0.5), width = 12),
                  box(title = "Correlation matrix", collapsible = TRUE, status = 'primary', solidHeader = TRUE,
                      plotOutput('correlation') %>% withSpinner(type = 8, size = 0.5), width = 12)
                )
        )
      )
    )
  )
)
