library(ggplot2)
library(shiny)
library(scales)

loadData <- function() {
  data("movies", package = "ggplot2")
  genre <- rep(NA, nrow(movies))
  count <- rowSums(movies[, 18:24])
  genre[which(count > 1)] = "Mixed"
  genre[which(count < 1)] = "None"
  genre[which(count == 1 & movies$Action == 1)] = "Action"
  genre[which(count == 1 & movies$Animation == 1)] = "Animation"
  genre[which(count == 1 & movies$Comedy == 1)] = "Comedy"
  genre[which(count == 1 & movies$Drama == 1)] = "Drama"
  genre[which(count == 1 & movies$Documentary == 1)] = "Documentary"
  genre[which(count == 1 & movies$Romance == 1)] = "Romance"
  genre[which(count == 1 & movies$Short == 1)] = "Short"
  movies$genre<-genre
  m<-subset(movies,budget>0)
  m<-m[m$mpaa!="",]
  return(m)
}

globalData <- loadData()
logspace <- function( d1, d2, n) exp(log(10)*seq(d1, d2, length.out=n))

getPlot <- function(localFrame, colorChoice, dotSize, dotAlpha, selectGenre, showRating, logAxis) {
  # Create base plot.
  support <- logspace(0,8,9)
  localPlot<-ggplot(localFrame,aes(x=budget, y=rating))+
             ggtitle("Scatterplot of  Movie Rating vs. Movie Budget")+
             xlab("Movie Budget")+
             ylab("Movie Rating")+
             theme_grey()+
             theme(text = element_text(size=20))+
             geom_point(aes(color=mpaa), size=dotSize, alpha=dotAlpha)+
             scale_y_continuous(breaks=0:10, expand=c(0,0), limits=c(0,10.5))+
             theme(legend.key = element_rect(fill = "white"))+
             theme(panel.background = element_blank(), panel.grid = element_blank())+
             theme(line = element_line(colour = 'gray'), axis.line = element_line(colour = 'gray'))+
             theme(legend.direction = "horizontal")+
             theme(legend.justification = c(0, 0))+
             theme(legend.position = c(0, 0))+
             theme(panel.grid.minor = element_line(colour = "gray90"))
     
     
  
  all<-c("NC-17", "PG", "PG-13", "R")
  
  if (showRating == "All") res<-c(TRUE,TRUE,TRUE,TRUE)
  else res<-all %in% showRating
  
  if (colorChoice == "Default"){
    thepal<-c("#F8766D", "#7CAE00", "#00BFC4", "#C77CFF")[res]
    localPlot<-localPlot + scale_color_manual(values=thepal, name="Rating")
  }
  if (colorChoice != "Default"){
    thepal<-brewer_pal(palette = colorChoice)(4)[res]
    localPlot<-localPlot + scale_color_manual(values=thepal, name="Rating")
  }
  if (logAxis) {
    localPlot<-localPlot+
      scale_x_log10(breaks=support,
                    labels=paste0(dollar(support/1000), 'k'),
                    limits=c(min(globalData$budget, na.rm = T),
                             max(globalData$budget, na.rm = T)))
  }
  else {
    localPlot<-localPlot+scale_x_continuous(label=dollar, limits=c(0,max(globalData$budget)))
  }
  
  return(localPlot)
}

shinyServer(function(input, output) {
  localFrame <- globalData
  changeFrame <- reactive({
    #Subset by rating
    if (input$showRating != "All") {
      localFrame<-subset(localFrame, mpaa==input$showRating)
    }
    #Subset by genre
    if (length(input$selectGenre) %in% c(1:7)) {
      localFrame<-localFrame[localFrame$genre %in% input$selectGenre,]
    }
    localFrame<-localFrame[localFrame$length >= input$movieLength[1] & localFrame$length <= input$movieLength[2],]
    return(localFrame)
  })

  
  output$scatterPlot <- renderPlot(
    {
      # Use our function to generate the plot.
      scatterPlot <- getPlot(
        changeFrame(),
        input$colorChoice,
        input$dotSize,
        input$dotAlpha,
        input$selectGenre,
        input$showRating,
        input$logAxis
      )
      # Output the plot
      print(scatterPlot)
    }
  )
  
  sortOrder <- reactive(
    {
      return(
        order(
          localFrame[,tolower(paste(input$sortColumn))],
          decreasing = input$sortDecreasing
        )
      )
    }
  )
  
  output$table <- renderTable(
    {
        localFrame<-localFrame[sortOrder(),c("title", "year", "length", "budget", "rating", "mpaa", "genre")]
        return(localFrame[localFrame$length >= input$movieLength[1] & localFrame$length <= input$movieLength[2],])
    },
      include.rownames = FALSE
  )
  
  
})




