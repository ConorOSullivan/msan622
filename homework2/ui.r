library(shiny)

shinyUI(
  # We will create a page with a sidebar for input.
  pageWithSidebar(  
    # Add title panel.
    headerPanel("Movie Data"),
    sidebarPanel(
      radioButtons(
        # This will be the variable we access later.
        "showRating", 
        # This will be the control title.
        "MPAA Rating:", 
        # This will be the control choices.
        choices = c("All", "NC-17", "PG", "PG-13", "R")
        ),
      checkboxGroupInput(
        "selectGenre",
        "Movie Genres",
        choices = c("Action", "Animation", "Comedy", "Documentary", "Drama", "Mixed", "Romance", "Short")
        ),
      br(),
      selectInput(
        "colorChoice",
        "Color Scheme",
        choices = c("Default","Accent", "Set1", "Set2", "Set3", "Dark2", "Pastel1","Pastel2"),
        "Set1"
        ),
      sliderInput(
        "dotSize",
        "Dot Size",
        min=1,
        max=10,
        value=3,
        step = 1
        ),
      sliderInput(
        "dotAlpha",
        "Dot Alpha",
        min=0.1,
        max=1,
        value=0.8,
        step = 0.1
        ),
      sliderInput(
        "movieLength", 
        "Movie Length:",   
        min = 7, 
        max = 251, 
        value = c(7,251)
        ),
      checkboxInput(
        "logAxis", 
        "Use log axis",   
        value = FALSE
      ),
      selectInput(
        # This will be the variable we access later.
        "sortColumn", 
        # This will be the control title.
        "Sort By:", 
        # This will be the control choices.
        choices = c("Genre", "Budget", "Year", "Rating", "Length")
      ),
      checkboxInput(
        "sortDecreasing", 
        "Decreasing", 
        FALSE
      )
      ),
      # Setup main panel.
      mainPanel(
        #plotOutput("scatterPlot"), width = 10
        
        tabsetPanel(
          # Add a tab for displaying the histogram.
          tabPanel("Scatter Plot", plotOutput("scatterPlot")),
          
          # Add a tab for displaying the table (will be sorted).
          tabPanel("Table", tableOutput("table"))
        )
      )

  )
)






