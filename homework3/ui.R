library(shiny)

shinyUI(
  # We will create a page with a sidebar for input.
  pageWithSidebar(  
    # Add title panel.
    headerPanel("Movie Data"),
    sidebarPanel(
      selectInput(
        "colorBy",
        "Color By",
        choices = c("Division", "Region")
        ),
      checkboxGroupInput(
        "selectRegions",
        "Regions",
        choices = c("Northeast", "North Central", "South", "West")
        ),
      checkboxGroupInput(
        "selectDivisions",
        "Divisions",
        choices = c("East North Central", "East South Central", "Middle Atlantic", "Mountain", "New England", "Pacific", "West North Central", "West South Central")
        ),
      conditionalPanel(
        condition = "input.tabs1 == 'Parallel Coordinates Plot'",
        selectInput(
          # This will be the variable we access later.
          "variableOrder", 
          # This will be the control title.
          "Axis order:", 
          # This will be the control choices.
          choices = c("Default", "Clumpy", "Outlying")
          ),
        checkboxGroupInput(
          "selectVars",
          "Variables to Plot",
          choices = c("Population","Income","Illiteracy","Life.Exp","Murder","HS.Grad","Frost","Area"),
          selecte = c("Illiteracy", "Murder", "HS.Grad", "Income")
          )
        )
      ),
    mainPanel(
      tabsetPanel(id = 'tabs1',
        # Add a tab for displaying the bubble plot.
        tabPanel("Bubble Plot", plotOutput("bubblePlot")),          
        
        # Add a tab for displaying the parallel coordinates plot
        tabPanel("Parallel Coordinates Plot", plotOutput("parallelCoordsPlot")),

        # Add a tab for the scatterplot matrix
        tabPanel("Small Multiples", plotOutput("smallMultiples"))
      )
    )
  )
)