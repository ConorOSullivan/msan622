library(GGally)
library(scales)
library(ggplot2)
library(rworldmap)
library(randomForest)
library(reshape)

trainmodel <- function(pred = "HumanDevelopmentIndex", start=170, end=190, cvs = 5){
  p<-ggplot()+geom_text(data=NULL, aes(x=1975, y=3000), label="Models being created. Can take up to 30 seconds.")+
    theme(axis.line=element_blank(),axis.text.x=element_blank(),
          axis.text.y=element_blank(),axis.ticks=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),legend.position="none",
          panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
          panel.grid.minor=element_blank(),plot.background=element_blank())
  show(p)
  
  lmrmses <- rep(1,190)
  rfrmses <- rep(1,190)
  for (j in start:end) {
    lmcvmses <- rep(1,cvs)
    rfcvmses <- rep(1,cvs)
    for (i in 1:cvs) {
      samp <- sample(c(1:nrow(df)),size=j)
      train<-df[samp,]
      test<-df[-samp,]
      trainn<-train[,c(2,3,4,5,6,7,8,9,10,11,12)]#,14,15)]
      testn<-test[,c(2,3,4,5,6,7,8,9,10,11,12)]#,14,15)]
      mod1<-lm(as.formula(paste(paste(pred),"~ .")), trainn)
      rtrain <- na.omit(trainn)
      rtest <- na.omit(testn)
      mod3<-randomForest(x=rtrain[,-c(which(colnames(rtrain) == pred))], 
                         y=rtrain[,which(colnames(rtrain) == pred)], 
                         xtest=rtest[,-c(which(colnames(rtest) == pred))],
                         ytest=rtest[,which(colnames(rtest) == pred)])
      pframe <- data.frame(actual=testn[,c(pred)],predicted=predict(mod1,testn))
      numpredicted <- length(is.na((testn[,c(pred)] - predict(mod1,testn))^2)) - sum(is.na((testn[,c(pred)] - predict(mod1,testn))^2))
      rmse<-sum((testn[,c(pred)] - predict(mod1,testn))^2,na.rm=T)/numpredicted
      
      lmcvmses[i] <- rmse
      rfcvmses[i] <- sqrt(mean(mod3$mse))
    }
    lmrmses[j] <- mean(lmcvmses)
    rfrmses[j] <- mean(rfcvmses)
  }
  rmsesf<-data.frame(LinearModel=lmrmses,RandomForest=rfrmses,sampsize=c(1:190))
  rmsesf<-rmsesf[start:end,]
  melted_rmsesf<-melt(rmsesf,id='sampsize')
  pp <- ggplot(melted_rmsesf) + 
    geom_line(aes(x=sampsize,y=value,group=variable,color=variable)) +
    ggtitle(paste('RMSE vs Sample Size for Models Predicting',pred)) + 
    theme_minimal() +
    ylab('Root-Mean-Square Error') +
    xlab('Sample Size') +
    scale_color_discrete('Model Type')
  show(pp)
}

getvarimp <- function(pred,max=190,order='Alphabetically') {
  samp <- sample(c(1:nrow(df)),size=max)
  train<-df[samp,]
  test<-df[-samp,]
  trainn<-train[,c(2,3,4,5,6,7,8,9,10,11,12)]#,14,15)]
  testn<-test[,c(2,3,4,5,6,7,8,9,10,11,12)]#,14,15)]
  mod1<-lm(as.formula(paste(paste(pred),"~ .")), trainn)
  rtrain <- na.omit(trainn)
  rtest <- na.omit(testn)
  mod3<-randomForest(x=rtrain[,-c(which(colnames(rtrain) == pred))], 
                     y=rtrain[,which(colnames(rtrain) == pred)], 
                     xtest=rtest[,-c(which(colnames(rtest) == pred))],
                     ytest=rtest[,which(colnames(rtest) == pred)])
  #   varImpPlot(mod3,main='')
  #   title(paste('Variable Importance for Predicting',pred))
  
  a <- varImpPlot(mod3)
  #   impdf <- data.frame(variables=rownames(a)[order(a,decreasing=T)],values=a[order(a,decreasing=T)])
  adf <- data.frame(variables=rownames(a)[order(a,decreasing=T)],values=a[order(a,decreasing=T)])
  #   if (order != 'Alphabetically') {
  adf$variables <- factor(adf$variables, levels = adf$variables)
  #   }
  p <- ggplot(adf)+
    geom_bar(aes(x=variables,y=values),fill="#00BFC4",stat='identity')+
    theme_minimal()+
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.ticks.x = element_blank())+
    scale_y_continuous(expand=c(0,0))+
    xlab('')+
    ylab('Increase in Node Purity')+
    ggtitle('Variable Importance Plot')
  show(p)
}
# df<-read.csv('/Users/conorosullivan/Documents/FourthModule/visualization/final_project/app/country_data.csv')
# df<-read.csv('country_data.csv')
df<-read.csv('countries_with_HDI2.csv')
dfsmall<-df[,c("LifeExpectancyAtBirth",
               "MeanYearsSchooling", 
               "GrossNationalIncomePerCapita", 
               "GenderInequalityIndex",
               "AdolescentFertilityRate", 
               "continent",
               "religion",
               'HumanDevelopmentIndex')]
dfsmall[,"GrossNationalIncomePerCapita"]<- -1*dfsmall[,"GrossNationalIncomePerCapita"]
dfsmall[,"MeanYearsSchooling"]<--1*dfsmall[,"MeanYearsSchooling"]
dfsmall[,"LifeExpectancyAtBirth"]<--1*dfsmall[,"LifeExpectancyAtBirth"]
# plotPar <- function(dat, al, colorBy) {
#   if (colorBy == 'Region') colorBy <- 'continent'
#   else colorBy <- 'religion'
#   p <- ggparcoord(data = dat,                 
#                   columns = 1:5,                 
#                   #groupColumn = colorBy,
#                   groupColumn = colorBy,
#                   showPoints = FALSE,                
#                   alphaLines = al,                
#                   shadeBox = NULL,                
#                   scale = "uniminmax"
#   )+theme_minimal()+
#     theme(axis.ticks.x = element_blank())+
#     theme(legend.position = 'top')+
#     xlab('')+ylab('Proportion of Maximum Feature Value')+
#     scale_x_discrete(expand=c(0,0))
#   if (colorBy == "religion") p <- p + scale_color_brewer("Religion",palette="Set1") + guides(colour = guide_legend(override.aes = list(size = 4)))
#   else p <- p + scale_color_brewer("Region",palette="Dark2") + guides(colour = guide_legend(override.aes = list(size = 4)))
#   p
# }
#plotPar(dfsmall, .4, "continent")


plotPar <- function(dat, al, colorBy, selectRegion, selectReligion) {
  acolorBy <- colorBy
  if (colorBy == "Region") {
    acolorBy <- 'continent'
    palette <- brewer_pal(type = "qual", palette = "Dark2")(nlevels(dfsmall$continent))
    if (length(selectRegion) %in% c(1:5)) {
      allLevels <- levels(df[,acolorBy])
      palette[which(!allLevels %in% selectRegion)] <- "grey85"
    }
  }
  if (colorBy == "Religion") {
    acolorBy <- 'religion'
    palette <- brewer_pal(type = "qual", palette = "Set1")(nlevels(dfsmall$religion))
    if (length(selectReligion) %in% c(1:4)) {
      allLevels <- levels(df[,acolorBy])
      palette[which(!allLevels %in% selectReligion)] <- "grey85"
    }
  }
#   print(palette)
  p <- ggparcoord(data = dat,                 
                  columns = 1:5,                 
                  #groupColumn = colorBy,
                  groupColumn = acolorBy,
                  showPoints = FALSE,                
                  alphaLines = al,                
                  shadeBox = NULL,                
                  scale = "uniminmax"
  )+theme_minimal()+
    theme(axis.ticks.x = element_blank())+
    theme(legend.position = 'top',
          legend.text = element_text(size=16,angle=0),
          legend.title = element_text(size=18,angle=0))+
    xlab('')+ylab('Proportion of Maximum Feature Value')+
    scale_x_discrete(expand=c(0,0))
  if (acolorBy %in% c('continent','religion')) {
    p <- p + scale_color_manual(paste(colorBy),limits=levels(dfsmall[,acolorBy]), values=palette)+
      guides(colour = guide_legend(override.aes = list(size = 4), nrow = 2))
  }
  show(p)
}



boxdf<-df[,c("LifeExpectancyAtBirth","MeanYearsSchooling","GrossNationalIncomePerCapita","AdolescentFertilityRate")]
divbymax<-function(x){
  x<-x/max(x,na.rm=T)
  x
}
boxdf<-apply(boxdf,2,FUN=divbymax)
boxdf<-data.frame(boxdf)
boxdf$continent<-df$continent
boxdf$religion<-df$religion
boxdf<-boxdf[! boxdf$religion %in% c('Buddhism','Judaism'),]#,'Hinduism'),]
boxdfm<-melt(boxdf,id=c('continent','religion'))
levels(boxdfm$variable) <- c('LifeExpectancyAtBirth: Max = 83.6','MeanYearsSchooling: Max = 13.3','G.N.I. PerCapita: Max = $87,478','AdolescentFertilityRate: Max = 193.6')

plotBox<-function(colorBy){
  actualColorBy <- colorBy
  if (colorBy == 'Region') colorBy <- 'continent'
  else colorBy <- 'religion'
  xx<-boxdfm[,paste(colorBy)]
  boxdfm$xx <- xx
  p<-ggplot(boxdfm)+
    geom_boxplot(aes(x=xx,y=value,fill=xx,group=xx))+
    facet_wrap(~ variable)+#,scales='free')+
    ylab("Percent of Maximum Value")+
    xlab("")+
    scale_y_continuous(labels = percent)+
    theme(axis.ticks.y=element_blank(), 
          #axis.text.y = element_blank(),
          legend.position = "top",
          legend.text = element_text(size = 14, angle=0),
          axis.ticks.x = element_blank(),
          axis.text.x = element_blank(),
          strip.text.x = element_text(size = 16, angle = 0),
          panel.background = element_rect(fill = 'white', colour = 'white'),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.title = element_text(vjust=-50))+
    labs(fill = paste(actualColorBy,':',sep=""))+
    guides(fill = guide_legend(title.theme = element_text(size=20,angle=0), override.aes = list(shape = 15),nrow=2))
  if (colorBy == 'religion') p <- p + scale_fill_brewer(palette="Set1") + ggtitle('Judaism and Buddhism removed due to lack of suffient data for a boxplot')
  else p <- p + scale_fill_brewer(palette="Dark2")
  show(p)
}

dfi<-df
dfi<-dfi[order(dfi$Name),]
dfi$Name <- as.character(dfi$Name)
dfi$Name[21] <- 'Bolivia'
dfi$Name[42] <- 'Ivory Coast'
dfi$Name[143] <- 'USSR'
dfi$Name[40] <- 'Zaire'
dfi$Name[191] <- 'Venezuela'
dfi$Name[79] <- 'Iran'
dfi$Name[46] <- "Czechoslovakia"
dfi$Name[172] <- 'Tanzania'
dfi$Name[187] <- 'USA'

dfi<-df
dfi$Name<-as.character(dfi$Name)
dfi$Name[df$Name=='Congo (Democratic Republic of the)'] <- 'Congo (Kinshasa)'
dfi$Name[df$Name=='Tanzania (United Republic of)'] <- 'Tanzania'
aad<-joinCountryData2Map(dF=dfi,joinCode='NAME',nameJoinColumn='Name')
plotM <- function(plotvariable) {
  pp<-mapCountryData(aad,nameColumnToPlot=plotvariable, colourPalette='white2Black')
}

plotMap <- function(fillChoice){
  dfi$region <- dfi$Name
  countries <- map_data("world")
  choro <- merge(countries, dfi, sort = FALSE, by = "region")
  choro <- choro[order(choro$order), ]
  fChoice <- dfi[,paste(fillChoice)]
  if (fillChoice == 'LifeExpectancyAtBirth') {
    p <- qplot(long, lat, data = choro, group = group, fill = LifeExpectancyAtBirth,
               geom = "polygon")
  }
  if (fillChoice == 'AnnualPopulationGrowth') {
    p <- qplot(long, lat, data = choro, group = group, fill = AnnualPopulationGrowth,
               geom = "polygon")
  }
  if (fillChoice == 'GrossNationalIncomePerCapita') {
    p <- qplot(long, lat, data = choro, group = group, fill = GrossNationalIncomePerCapita,
               geom = "polygon")
  }
  if (fillChoice == 'MeanYearsSchooling') {
    p <- qplot(long, lat, data = choro, group = group, fill = MeanYearsSchooling,
               geom = "polygon")
  }
  if (fillChoice == 'AdolescentFertilityRate') {
    p <- qplot(long, lat, data = choro, group = group, fill = AdolescentFertilityRate,
               geom = "polygon")
  }
  p <- p + theme_bw()
  p <- p + theme(axis.text = element_blank(),
                 axis.title = element_blank())
  p <- p + theme(axis.ticks = element_blank(),
                 legend.position = 'bottom',
                 legend.title = element_text(size=20, angle=0),
                 panel.grid.major = element_blank(),
                 panel.grid.minor = element_blank()
#                  legend.key.width=unit(3,"cm"),
                 )
  p <- p + scale_x_continuous(expand = c(0, 0),formatter = comma)  
  p <- p + scale_y_continuous(expand = c(0, 0))
  p <- p + guides(fill=guide_colourbar(barwidth=30))#,label.position="bottom"))
  p
}

plotBub <- function(choice, colorBy) {
  if (choice == 'Population Growth') {
    #   print(paste(third))
    if (colorBy == 'Region') colorBy <- 'continent'
    else if (colorBy == 'Religion') colorBy <- 'religion'
    #     thirdlabel <- paste('Size:',third)
    #     df$sizelabel <- rep(third, nrow(df))
    df$labelposx <- rep(2, nrow(df))
    df$labelposy <- rep(35, nrow(df))
    #     labelposxx <- max(df[,first],na.rm=T)
    #     labelposyy <- max(df[,second],na.rm=T)
    #     yy <- df[,first]
    #     xx <- df[,second]
    p<-ggplot(df)+
      geom_point(aes_string(y='MedianAge', 
                            x='AnnualPopulationGrowth', 
                            size='AdolescentFertilityRate',
                            color=colorBy),alpha=.4)+
      theme_minimal()+
      theme(legend.position = 'top',
            legend.text = element_text(size=16,angle=0),
            legend.title = element_text(size=18,angle=0),
            axis.title.x = element_text(size=16,angle=0),
            axis.title.y = element_text(size=16,angle=90))+
      scale_size(guide = 'none', range = c(4, 15))#+annotate("text", x=labelposxx*.4, y=labelposyy*.4, label = thirdlabel, hjust = 0)
    if (colorBy == "religion") p <- p + scale_color_brewer("Religion",palette="Set1")
    else if (colorBy == 'continent') p <- p + scale_color_brewer("Region",palette="Dark2")
    #   else p <- p + scale_color_brewer("Region",palette="Dark2")
    p <- p + guides(colour = guide_legend(nrow=2, override.aes=list(size=4))) 
    p <- p + annotate("text",label="Size by AdolescentFertilityRate",x=2.5,y=41,size=6)
    show(p)
  }
  if (choice == 'Economics') {
    #   print(paste(third))
    if (colorBy == 'Region') colorBy <- 'continent'
    else if (colorBy == 'Religion') colorBy <- 'religion'
    #     thirdlabel <- paste('Size:',third)
    #     df$sizelabel <- rep(third, nrow(df))
    df$labelposx <- rep(2, nrow(df))
    df$labelposy <- rep(35, nrow(df))
    #     labelposxx <- max(df[,first],na.rm=T)
    #     labelposyy <- max(df[,second],na.rm=T)
    #     yy <- df[,first]
    #     xx <- df[,second]
    p<-ggplot(df)+
      geom_point(aes_string(y='GrossNationalIncomePerCapita', 
                            x='MeanYearsSchooling', 
                            size='GDP',
                            color=colorBy),alpha=.4)+
      theme_minimal()+
      theme(legend.position = 'top',
            legend.text = element_text(size=16,angle=0),
            legend.title = element_text(size=18,angle=0),
            axis.title.x = element_text(size=16,angle=0),
            axis.title.y = element_text(size=16,angle=90))+
      scale_y_continuous(label=dollar)+
      scale_size(guide = 'none', range = c(4, 15))#+annotate("text", x=labelposxx*.4, y=labelposyy*.4, label = thirdlabel, hjust = 0)
    if (colorBy == "religion") p <- p + scale_color_brewer("Religion",palette="Set1")
    else if (colorBy == 'continent') p <- p + scale_color_brewer("Region",palette="Dark2")
    #   else p <- p + scale_color_brewer("Region",palette="Dark2")
    p <- p + guides(colour = guide_legend(nrow=2, override.aes=list(size=4))) 
    p <- p + annotate("text",label="Size by GDP",x=10,y=74000,size=6)
    show(p)
  }
}
# plotBub <- function(first, second, third, colorBy) {
#   #   print(paste(third))
#   if (colorBy == 'Region') colorBy <- 'continent'
#   else if (colorBy == 'Religion') colorBy <- 'religion'
#   thirdlabel <- paste('Size:',third)
#   df$sizelabel <- rep(third, nrow(df))
#   df$labelposx <- rep(2, nrow(df))
#   df$labelposy <- rep(35, nrow(df))
#   labelposxx <- max(df[,first],na.rm=T)
#   labelposyy <- max(df[,second],na.rm=T)
#   yy <- df[,first]
#   xx <- df[,second]
#   p<-ggplot(df)+
#     geom_point(aes_string(y=first, 
#                           x=second, 
#                           size=third,
#                           color=colorBy),alpha=.4)+
#     theme_minimal()+
#     theme(legend.position = 'top',
#           legend.text = element_text(size=16,angle=0),
#           legend.title = element_text(size=18,angle=0),
#           axis.title.x = element_text(size=16,angle=0),
#           axis.title.y = element_text(size=16,angle=90))+
#     scale_size(guide = 'none', range = c(4, 15))#+annotate("text", x=labelposxx*.4, y=labelposyy*.4, label = thirdlabel, hjust = 0)
#   if (colorBy == "religion") p <- p + scale_color_brewer("Religion",palette="Set1")
#   else if (colorBy == 'continent') p <- p + scale_color_brewer("Region",palette="Dark2")
#   #   else p <- p + scale_color_brewer("Region",palette="Dark2")
#   p <- p + guides(colour = guide_legend(nrow=2, override.aes=list(size=4))) 
#   p <- p + annotate("text",label="Size by AdolescentFertilityRate",x=2.5,y=41,size=6)
#   show(p)
# }


shinyServer(function(input, output) {
  
#   output$parallelCoords <- renderPlot({
#     parallelCoords <- plotPar(
#         dfsmall,
#         .4,
#         input$colorSelection,
#         input$selectRegion,
#         input$selectReligion
#       )
#     print(parallelCoords)
#     })
  
  output$boxPlot <- renderPlot({
    boxPlot <- plotBox(
      input$boxcolorSelection)
    print(boxPlot)
  })
  
  output$worldMap <- renderPlot({
    worldMap <- plotM(
      input$mapVariable)
    print(worldMap)
  })
  
  output$bubblePlot <- renderPlot({
    bubblePlot <- plotBub(
      input$graphChoice,input$colorSelection)
    print(bubblePlot)
  })
  
  output$predictionPlot <- renderPlot({
    predictionPlot <- trainmodel(
      pred=input$predVar,cvs=2,start=input$trainsize[1],end=input$trainsize[2])
  })
  
  output$variableImportance <- renderPlot({
    variableImportance <- getvarimp(
      pred=input$predVar)
  })
#   output$bubblePlot <- renderPlot({
#     bubblePlot <- plotBub(
#       'MedianAge',"AnnualPopulationGrowth",'AdolescentFertilityRate',input$colorSelection)
#     print(bubblePlot)
#   })
  
})





