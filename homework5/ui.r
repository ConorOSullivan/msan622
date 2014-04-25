shinyUI(pageWithSidebar(
  headerPanel("UK Seatbelt Data"),
  
  sidebarPanel(
    sliderInput(
      "num", 
      "Years:", 
      min = 1969, 
      max = 1985,
      value = c(1976, 1980),
      format = "####"
    ),
    
#     sliderInput(
#       "start", 
#       "Starting Point:",
#       min = 1974, 
#       max = 1980,
#       value = 1974, 
#       step = 1 / 12,
#       round = FALSE, 
#       ticks = TRUE,
#       format = "####.##",
#       animate = animationOptions(
#         interval = 800, 
#         loop = TRUE
#       )
#     ),
    
    width = 3
  ),
  
  mainPanel(
    tabsetPanel(
      tabPanel("Area Plot",
        plotOutput(
          outputId = "mainPlot", 
          width = "100%", 
          height = "400px"
        ),
       plotOutput(
         outputId = "overviewPlot",
         width = "100%",
         height = "200px"
       )    
      ),
      tabPanel("Heatmap",
               plotOutput(
                 outputId = "heatmap", 
                 width = "100%", 
                 height = "600px"
               )
      )
      
      #width = 9
    )
  )
))