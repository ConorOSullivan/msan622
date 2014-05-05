shinyUI(pageWithSidebar(
  headerPanel("UK Seatbelt Data"),
  
  sidebarPanel(
    radioButtons(
      "colorSelection",
      "Select Coloring:",
      choices = c("Region", "Religion")
      )
    
    ),
  
  mainPanel(
    tabsetPanel(
      tabPanel("World Map",
        plotOutput(
          outputId = "worldMap", 
          width = "100%", 
          height = "400px"
        )    
      ),
      tabPanel("Bubble Plot",
               plotOutput(
                 outputId = "bubblePlot", 
                 width = "100%", 
                 height = "600px"
               )
      ),
      tabPanel("Parallel Coordinates Plot",
               plotOutput(
                 outputId = "parallelCoords",
                 width = "100%", 
                 height = "500px"
               )
               
      ),
      tabPanel("Star Plot",
               plotOutput(
                 outputId = "starPlot"
               )
      )
      
    )
  )
))