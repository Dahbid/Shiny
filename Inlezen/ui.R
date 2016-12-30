shinyUI(pageWithSidebar(
  headerPanel("R data inlezen"),
  
  sidebarPanel(fileInput("uploadFile", "SC"),
               downloadButton('downloadData', "Download")),
  
  mainPanel(tableOutput('contents'))
))
