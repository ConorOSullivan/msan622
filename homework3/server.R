library(ggplot2)
library(shiny)
library(scales)

df <- data.frame(state.x77,
                 State = state.name,
                 Abbrev = state.abb,
                 Region = state.region,
                 Division = state.division
)

plotBub2 <- function(df2, colorBy) {
  if (nrow(df2) == 0) {
    p <- ggplot(df2) + 
      geom_text(aes(x=1.5, y=8), label="No data to display")+
      theme(axis.line=element_blank(),axis.text.x=element_blank(),
            axis.text.y=element_blank(),axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),legend.position="none",
            panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
            panel.grid.minor=element_blank(),plot.background=element_blank())
  }
  else {
    p <- ggplot() + 
      geom_point(data=df, aes(x=Illiteracy, y=Murder, size=HS.Grad), colour="grey90") +
      theme_minimal()+
      xlab('Illiteracy Rate')+
      ylab('Murders Per 100k People')+
      scale_size_continuous(name="High School Grad Rate", breaks=c(40,45,50,55,60))+
      ggtitle('Bubble Plot of Murders Per 100k People vs Illiteracy Rate in 1977')+
      guides(size=guide_legend(order=1))
    if (colorBy == "Region") {
      p <- p + geom_point(data=df2, aes(x=Illiteracy, y=Murder, size=HS.Grad, colour=Region))+
        scale_color_brewer(limits=levels(df$Region), palette="Dark2")
    }
    else {
      getPalette = colorRampPalette(brewer.pal(9, "Dark2"))
      p <- p + geom_point(data=df2, aes(x=Illiteracy, y=Murder, size=HS.Grad, colour=Division))+
        scale_color_manual(name=colorBy, limits=levels(df[,paste(colorBy)]), values=getPalette(nlevels(df[,paste(colorBy)])))
    }
  }
  show(p)
}

plotPar <- function(dat, order, al, colorBy) {
  p <- ggparcoord(data = dat,                 
                  # Which columns to use in the plot
                  columns = 1:4,                 
                  groupColumn = colorBy, 
                  order = order,                
                  showPoints = FALSE,                
                  alphaLines = al,                
                  shadeBox = NULL,                
                  # Will normalize each column's values to [0, 1]
                  scale = "globalminmax" # try "std" also
  )+theme_minimal()+theme(axis.ticks.x = element_blank())+
    xlab('Feature')+ylab('Proportion of Maximum Feature Value')# + scale_color_discrete(limits=levels(df$Region))
  show(p)
}

plotPar2 <- function(dat, order, al, colorBy, selectRegion, selectDivision, selectVars) {
  if (colorBy == "Region") {
    palette <- brewer_pal(type = "qual", palette = "Set1")(nlevels(df$Region))
    if (length(selectRegion) %in% c(1:3)) {
        allLevels <- levels(df[,colorBy])
        palette[which(!allLevels %in% selectRegion)] <- "grey85"
      }
  }
  if (colorBy == "Division") {
    palette <- brewer_pal(type = "qual", palette = "Set1")(nlevels(df$Division))
    if (length(selectDivision) %in% c(1:7)) {
        allLevels <- levels(df[,colorBy])
        palette[which(!allLevels %in% selectDivision)] <- "grey85"
      }
  }
  #if (length(selectVars) == 0)
  selectDf<-df[,c(selectVars,"Region","Division")] 
  if (order == "Default") {
    p <- ggparcoord(data = selectDf,                 
                    columns = 1:length(selectVars), 
                    groupColumn = colorBy, 
                    order = c(1:length(selectVars)),                
                    showPoints = FALSE,                
                    alphaLines = al,                
                    shadeBox = NULL,                
                    scale = "uniminmax")
  }
  if (order %in% c("Clumpy", "anyClass", "skewness", "Outlying")) {
    p <- ggparcoord(data = selectDf,                 
                    columns = 1:length(selectVars), 
                    groupColumn = colorBy, 
                    order = order,                
                    showPoints = FALSE,                
                    alphaLines = al,                
                    shadeBox = NULL,                
                    scale = "uniminmax")
  }
    p<-p+theme_minimal()+theme(axis.ticks.x = element_blank())+theme(legend.position = "bottom")+
    xlab('')+ylab('Proportion of Maximum Feature Value') + 
    scale_color_manual(limits=levels(df[,colorBy]), values=palette)+
    scale_x_discrete(expand=c(0,0))+ggtitle("Parallel Coordinates Plot")
  show(p)
}

percent_formatter <- function(x) {
  #label <- round(x / 1000)
  return(sprintf(paste("%d","%%",sep=""), round(x)))
}


plotSmall <- function(df2, colorBy) {
  p <- ggplot(data=df2, aes(x=Income, y=HS.Grad, size=Illiteracy)) + 
    xlab('Income')+
    ylab('High School Graduation Rate')+
    #scale_y_continuous(label=percent_formatter)+
    scale_x_continuous(label=dollar)+
    ggtitle('High School Graduation Rate vs Income with Bubble Size as Illiteracy')+
    theme(text = element_text(size=14))+#+theme(legend.position="none")
    scale_size(name="Illiteracy Rate")+
    guides(size=guide_legend(order=1))
    
  if (colorBy == "Region") {
    p <- p + geom_point(aes(color=Region)) + facet_wrap( ~ Region, ncol=2) +
      scale_color_brewer(limits=levels(df2$Region), palette="Dark2")
  }
  if (colorBy == "Division") {
    getPalette = colorRampPalette(brewer.pal(9, "Dark2"))
    p <- p + geom_point(aes(color=Division)) + facet_wrap( ~ Division, ncol=3) +
      scale_color_manual(limits=levels(df[,paste(colorBy)]), values=getPalette(nlevels(df[,paste(colorBy)])))
  }
  show(p)
}

divbymax<-function(x){
  x/(max(x))
}

shinyServer(function(input, output) {
  df2<-df
  df3<-cbind(apply(df[,c(1:8)],2,divbymax),df[,c(9:ncol(df))])
  
  changeFrame <- reactive({
    #Subset by Region
    if (length(input$selectRegions) %in% c(1:3)) {
      df2<-df2[df2$Region %in% input$selectRegions,]
      df2$Region<-as.factor(df2$Region)
    }
    if (length(input$selectDivisions) %in% c(1:7)) {
      df2<-df2[df2$Division %in% input$selectDivisions,]
      df2$Division<-as.factor(df2$Division)
    }
    return(df2)
  })
  
  changeFrame2 <- reactive({
    #Subset by Region
    if (length(input$selectRegions) %in% c(1:3)) {
      df3<-df3[df3$Region %in% input$selectRegions,]
      df3$Region<-as.factor(df3$Region)
    }
    if (length(input$selectDivisions) %in% c(1:7)) {
      df3<-df3[df3$Division %in% input$selectDivisions,]
      df3$Division<-as.factor(df3$Division)
    }
    return(df3)
  })
  
  
  
  output$bubblePlot <- renderPlot(
    {
      # Use our function to generate the plot.
      bubblePlot <- plotBub2(
        changeFrame(),
        input$colorBy
        )
      # Output the plot
      print(bubblePlot)
    }
  )
  
  output$parallelCoordsPlot <- renderPlot(
    {
      # Use our function to generate the plot.
      parallelCoordsPlot <- plotPar2(
        changeFrame2(),
        input$variableOrder,
        .8,
        input$colorBy,
        input$selectRegions,
        input$selectDivisions,
        input$selectVars
      )
      # Output the plot
      print(parallelCoordsPlot)
    }
  )
  
  output$smallMultiples <- renderPlot(
    {
      # Use our function to generate the plot.
      smallMultiples <- plotSmall(
        changeFrame(),
        input$colorBy
      )
      # Output the plot
      print(smallMultiples)
    }
  )
  
  
})