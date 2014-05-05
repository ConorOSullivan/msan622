library(GGally)
library(scales)

# df<-read.csv('/Users/conorosullivan/Documents/FourthModule/visualization/final_project/app/country_data.csv')
df<-read.csv('country_data.csv')
dfsmall<-df[,c("LifeExpectancyAtBirth",
               "MeanYearsSchooling", 
               "GrossNationalIncomePerCapita", 
               "GenderInequalityIndex",
               "AdolescentFertilityRate", 
               "continent",
               "religion")]
dfsmall[,"GrossNationalIncomePerCapita"]<- -1*dfsmall[,"GrossNationalIncomePerCapita"]
dfsmall[,"MeanYearsSchooling"]<--1*dfsmall[,"MeanYearsSchooling"]
dfsmall[,"LifeExpectancyAtBirth"]<--1*dfsmall[,"LifeExpectancyAtBirth"]
# print(head(dfsmall))
plotPar <- function(dat, al, colorBy) {
  if (colorBy == 'Region') colorBy <- 'continent'
  else colorBy <- 'religion'
  #print(colorBy)
  p <- ggparcoord(data = dat,                 
                  columns = 1:5,                 
                  #groupColumn = colorBy,
                  groupColumn = colorBy,
                  showPoints = FALSE,                
                  alphaLines = al,                
                  shadeBox = NULL,                
                  scale = "uniminmax"
  )+theme_minimal()+
    theme(axis.ticks.x = element_blank())+
    theme(legend.position = 'top')+
    xlab('')+ylab('Proportion of Maximum Feature Value')+
    scale_x_discrete(expand=c(0,0))
  if (colorBy == "religion") p <- p + scale_color_brewer("Religion",palette="Set1")
  else p <- p + scale_color_brewer("Region",palette="Paired")
  p
}
plotPar(dfsmall, .4, "continent")

shinyServer(function(input, output) {
#   output$smallMultiples <- renderPlot(
# {
#   # Use our function to generate the plot.
#   smallMultiples <- plotSmall(
#     changeFrame(),
#     input$colorBy
#   )
#   # Output the plot
#   print(smallMultiples)
# }
#   )
  
  output$parallelCoords <- renderPlot({
    parallelCoords <- plotPar(
        dfsmall,
        .4,
        input$colorSelection
      )
    print(parallelCoords)
    })
  
})





