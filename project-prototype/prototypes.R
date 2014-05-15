library(ggplot)
library(rCharts)
library(GGally)
setwd('/Users/conorosullivan/Documents/FourthModule/visualization/final_project/app')

df<-read.csv('country_data.csv')


### BUBBLE PLOT IN RCHARTS ###

hh<-hPlot(x = "MedianAge", 
          y = "AnnualPopulationGrowth", 
          data = df, 
          type = "point", 
          size="AdolescentFertilityRate", 
          group = "continent")      
h1$title(text='Median Age vs Annual Population Growth in 2010')
# h1$tooltip("Potato")
h1

### BUBBLE PLOT IN GGPLOT ###
plotBub <- function(first, second, third, colorBy) {
  #   print(paste(third))
  if (colorBy == 'Region') colorBy <- 'continent'
  else if (colorBy == 'Religion') colorBy <- 'religion'
  thirdlabel <- paste('Size:',third)
  df$sizelabel <- rep(third, nrow(df))
  df$labelposx <- rep(2, nrow(df))
  df$labelposy <- rep(35, nrow(df))
  labelposxx <- max(df[,first],na.rm=T)
  labelposyy <- max(df[,second],na.rm=T)
  yy <- df[,first]
  xx <- df[,second]
  p<-ggplot(df)+
    geom_point(aes_string(y=first, 
                          x=second, 
                          size=third,
                          color=colorBy),alpha=.4)+
    theme_minimal()+
    theme(legend.position = 'top',
          legend.text = element_text(size=16,angle=0),
          legend.title = element_text(size=18,angle=0),
          axis.title.x = element_text(size=16,angle=0),
          axis.title.y = element_text(size=16,angle=90))+
    scale_size(guide = 'none', range = c(4, 15))#+annotate("text", x=labelposxx*.4, y=labelposyy*.4, label = thirdlabel, hjust = 0)
  if (colorBy == "religion") p <- p + scale_color_brewer("Religion",palette="Set1")
  else if (colorBy == 'region') p <- p + scale_color_brewer("Region",palette="Dark2")
#   else p <- p + scale_color_brewer("Region",palette="Dark2")
  p <- p + guides(colour = guide_legend(nrow=2, override.aes=list(size=4)))
  show(p)
}
plotBub('MedianAge',"AnnualPopulationGrowth",'AdolescentFertilityRate','Region')
plotBub('MedianAge',"AnnualPopulationGrowth",'AdolescentFertilityRate','HumanDevelopmentIndex')

### PARALLEL COORDINATES PLOT ###
library(GGally)
library(scales)
dfsmall<-df[,c("LifeExpectancyAtBirth",
               "MeanYearsSchooling", 
               "GrossNationalIncomePerCapita", 
               "GenderInequalityIndex",
               "AdolescentFertilityRate", 
               "continent",
               "religion",
               "HumanDevelopmentIndex")]
dfsmall[,"GrossNationalIncomePerCapita"]<- -1*dfsmall[,"GrossNationalIncomePerCapita"]
dfsmall[,"MeanYearsSchooling"]<--1*dfsmall[,"MeanYearsSchooling"]
dfsmall[,"LifeExpectancyAtBirth"]<--1*dfsmall[,"LifeExpectancyAtBirth"]
plotPar <- function(dat, al, colorBy) {
  p <- ggparcoord(data = dat,                 
                  columns = 1:5,                 
                  groupColumn = colorBy, 
                  showPoints = FALSE,                
                  alphaLines = al,                
                  shadeBox = NULL,                
                  scale = "uniminmax"
  )+theme_minimal()+
    theme(axis.ticks.x = element_blank())+
    xlab('Feature')+ylab('Proportion of Maximum Feature Value')+
    scale_x_discrete(expand=c(0,0))
  if (colorBy == "religion") p <- p + scale_color_brewer("Religion",palette="Set2")
  else if (colorBy == 'region') p <- p + scale_color_brewer("Region",palette="Dark2")
  show(p)
}
plotPar(dfsmall, .4, "HumanDevelopmentIndex")
plotPar(dfsmall, .4, "Region")


plotPar <- function(dat, al, colorBy, selectRegion, selectReligion) {
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
  print(palette)
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
    scale_x_discrete(expand=c(0,0))+
    scale_color_manual(paste(colorBy),limits=levels(dfsmall[,acolorBy]), values=palette)+
    guides(colour = guide_legend(override.aes = list(size = 4), nrow = 2))
  show(p)
}
plotPar(dfsmall, .4, "HumanDevelopmentIndex",c("Arab States"),c("Islam"))








### BAR PLOT ###
ags<-aggregate(list(df$LifeExpectancyAtBirth, df$MeanYearsSchooling, df$GrossNationalIncomePerCapita, df$AdolescentFertilityRate), by=list(df$continent), FUN=mean, na.rm=T)
colnames(ags)<-c("Region",
                 "LifeExpectancyAtBirth",
                 "MeanYearsSchooling", 
                 "GrossNationalIncomePerCapita", 
                 "AdolescentFertilityRate")
normalize<-function(x){
  x<-(x-min(x))/(max(x) - min(x))
  x[which(x==min(x))]<-x[which(x==min(x))]+.05
  x
}
ags2<-cbind(ags[,c("Region")],data.frame(apply(ags[,2:ncol(ags)],2,FUN=normalize)))
colnames(ags2)[1]<-"Region"
library(reshape)
mags<-melt(ags2, id="Region")

p<-ggplot(mags)+geom_bar(aes(x=variable,y=value, group=Region,fill=Region),stat="identity",position="dodge")
p


plotPar <- function(dat, al, colorBy) {
  if (colorBy == 'Region') colorBy <- 'continent'
  else colorBy <- 'religion'
  print(colorBy)
  p <- ggparcoord(data = dat,                 
                  columns = 1:5,                 
                  groupColumn = colorBy, 
                  showPoints = FALSE,                
                  alphaLines = al,                
                  shadeBox = NULL,                
                  scale = "uniminmax"
  )+theme_minimal()+
    theme(axis.ticks.x = element_blank())+
    xlab('Feature')+ylab('Proportion of Maximum Feature Value')+
    scale_x_discrete(expand=c(0,0))
  if (colorBy == "religion") p <- p + scale_color_brewer("Religion",palette="Paired")
  else p <- p + scale_color_brewer("Region",palette="Paired")
  show(p)
}
plotPar(dfsmall, .4, "continent")

boxdf<-dfsmall[,c("LifeExpectancyAtBirth","MeanYearsSchooling","GrossNationalIncomePerCapita","AdolescentFertilityRate","continent")]
boxdf<-dfsmall[,c("LifeExpectancyAtBirth","MeanYearsSchooling","GrossNationalIncomePerCapita","AdolescentFertilityRate")]
divbymax<-function(x){
  x<-x/max(x,na.rm=T)
  x
}
boxdf<-apply(boxdf,2,FUN=divbymax)
boxdf<-data.frame(boxdf)
boxdf$continent<-df$continent
boxdf$religion<-df$religion
boxdfm<-melt(boxdf,id=c('continent','religion'))


plotBox<-function(colorBy){
  actualColorBy <- colorBy
  if (colorBy == 'Region') colorBy <- 'continent'
  else colorBy <- 'religion'
  print(colorBy)
  xx<-boxdfm[,paste(colorBy)]
  boxdfm$xx <- xx
  print(head(xx))
  p<-ggplot(boxdfm)+
    #geom_boxplot(aes(x=continent,y=value,fill=continent))+
    geom_boxplot(aes(x=xx,y=value,fill=xx))+
    facet_grid(. ~ variable)+
    ylab("")+
    xlab("")+
    theme(axis.ticks.y=element_blank(), 
          axis.text.y = element_blank(),
          legend.position = "top",
          legend.text = element_text(size = 14, angle=0),
          axis.ticks.x = element_blank(),
          axis.text.x = element_blank(),
          strip.text.x = element_text(size = 16, angle = 0),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank())+
    scale_fill_brewer(palette="Dark2")+
    labs(fill = paste(actualColorBy,':',sep=""))+
    guides(fill = guide_legend(title.theme = element_text(size=20,angle=0), override.aes = list(shape = 15)))
  show(p)
}
plotBox('Religion')



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
                 panel.grid.major = element_blank(),
                 panel.grid.minor = element_blank())
  p <- p + scale_x_continuous(expand = c(0, 0))  
  p <- p + scale_y_continuous(expand = c(0, 0))
  p
}
plotMap('LifeExpectancyAtBirth')
plotMap('AnnualPopulationGrowth')
plotMap('GrossNationalIncomePerCapita')
plotMap('MeanYearsSchooling')
plotMap('AdolescentFertilityRate')






