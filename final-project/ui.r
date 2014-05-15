shinyUI(pageWithSidebar(
  headerPanel("UN Human Development Reports"),
  
  sidebarPanel(
    tags$head(
      tags$style(type="text/css", "select { max-width: 200px; }"),
      tags$style(type="text/css", "textarea { max-width: 185px; }"),
      tags$style(type="text/css", ".jslider { max-width: 200px; }"),
      tags$style(type='text/css', ".well { max-width: 270px; }"),
      tags$style(type='text/css', ".span4 { max-width: 270px; }")
    ),
#     conditionalPanel(
#       condition = "input.tabs1 == 'Bubble Plot' | input.tabs1 == 'Parallel Coordinates Plot' | input.tabs1 == 'Box Plot'",
#       radioButtons(  
#         "colorSelection",
#         "Select Coloring:",
#         choices = c("Region","Religion")
#         )
#       ),
    conditionalPanel(
      condition = "input.tabs1 == 'Bubble Plot' | input.tabs1 == 'Parallel Coordinates Plot'",
      radioButtons(  
        "colorSelection",
        "Select Coloring:",
        choices = c("Region","Religion",'HumanDevelopmentIndex')
      )
    ),
    conditionalPanel(
      condition = "input.tabs1 == 'Bubble Plot'",
      selectInput(  
        "graphChoice",
        "Select Plot:",
        choices = c("Population Growth","Economics")
      )
    ),
    conditionalPanel(
      condition = "input.tabs1 == 'Box Plot'",
      radioButtons(  
        "boxcolorSelection",
        "Select Coloring:",
        choices = c("Region","Religion")
      )
    ),
#     conditionalPanel(
#       condition = "input.tabs1 == 'Parallel Coordinates Plot'",
#       checkboxGroupInput(  
#         "selectRegion",
#         "Select Regions:",
#         choices = c("Arab States","East Asia and the Pacific","Europe and Central Asia","Latin America and the Caribbean","North America","Sub-Saharan Africa"),
#         selected = c("Arab States","East Asia and the Pacific")
#       )
#     ),
    conditionalPanel(
      condition = "input.tabs1 == 'Variable Prediction'",
      radioButtons(  
        "predVar",
        "Select Variable to Predict:",
        choices = c("MedianAge","MedianAge2000","Population","AnnualPopulationGrowth","GenderInequalityIndex","AdolescentFertilityRate","GrossNationalIncomePerCapita","MeanYearsSchooling","LifeExpectancyAtBirth","GDP","HumanDevelopmentIndex"),
        selected = c("AnnualPopulationGrowth")
      ),
      sliderInput(
        'trainsize',
        'Number of samples in training set to test: ',
        min = 100,
        max = 190,
        value = c(170,190)
        )
    ),
    conditionalPanel(
      condition = "input.tabs1 == 'World Map'",
      selectInput(
        "mapVariable",
        "Variable to plot: ",
        choices = c('LifeExpectancyAtBirth',
                    'AnnualPopulationGrowth',
                    'GrossNationalIncomePerCapita',
                    'MeanYearsSchooling',
                    'AdolescentFertilityRate')
      )
    )
    
  ),
  mainPanel(
    tabsetPanel(id = 'tabs1',  
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
                 height = "500px"
#                  height = "100%"
               )
      ),
#       tabPanel("Parallel Coordinates Plot",
#                plotOutput(
#                  outputId = "parallelCoords",
#                  width = "100%", 
#                  height = "500px"
#                )
#       ),
      tabPanel("Variable Prediction",
               div(class='span10',plotOutput(
                 outputId = "predictionPlot",
                 width = "100%", 
                 height = "500px"
               )),
               div(class='span10',plotOutput(
                 outputId = "variableImportance",
                 width = "100%", 
                 height = "500px"
               ))
      ),
      tabPanel("Box Plot",
               plotOutput(
                 outputId = "boxPlot",
                 width = "100%"
               )
      )
    )
  )
))