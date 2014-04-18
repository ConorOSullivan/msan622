library(shiny)

shinyUI(
  # We will create a page with a sidebar for input.
  pageWithSidebar(  
    # Add title panel.
    headerPanel("Lord of the Rings Text Analysis"),
    sidebarPanel(
      conditionalPanel(
        condition = "input.tabs1 == 'Word Frequency Bar Plot'",
        selectInput(
          "which_book",
          "Book Choice",
          choices = c("Fellowship of the Ring", "The Two Towers", "Return of the King")
          )

      ),
      conditionalPanel(
        condition = "input.tabs1 == 'Word Cloud'",
        sliderInput(
          "numWords",
          "Number of words: ",
          min = 5,
          max = 100,
          value = 50
          )
        ) 
    ),
    mainPanel(
      tabsetPanel(id = 'tabs1',
                  # Add a tab for displaying the bubble plot.
                  tabPanel("Word Cloud", plotOutput("word_cloud")),          
                  
                  # Add a tab for displaying the parallel coordinates plot
                  tabPanel("Word Frequency Bar Plot", plotOutput("bar_plot"))
      )
    )
  )
)