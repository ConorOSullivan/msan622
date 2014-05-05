library(ggplot)
library(rCharts)
library(GGally)
df<-read.csv('countryData.csv')


### BUBBLE PLOT IN RCHARTS ###

h1<-hPlot(x = "MedianAge", 
          y = "AnnualPopulationGrowth", 
          data = df, 
          type = "bubble", 
          size="AdolescentFertilityRate", 
          group = "continent")      
h1$title(text='Median Age vs Annual Population Growth in 2010')
h1$tooltip("Potato")
h1

### BUBBLE PLOT IN GGPLOT ###

p<-ggplot(df)+
  geom_point(aes(y=MedianAge, 
                 x=AnnualPopulationGrowth, 
                 size=AdolescentFertilityRate,
                 color=continent))+
  scale_color_discrete("Region")+
  theme_minimal()+
  scale_size("Births per 1k Women aged 15-19")
p

### PARALLEL COORDINATES PLOT ###
library(GGally)
dfsmall<-df[,c("LifeExpectancyAtBirth",
               "MeanYearsSchooling", 
               "GrossNationalIncomePerCapita", 
               "GenderInequalityIndex",
               "AdolescentFertilityRate", 
               "continent")]
dfsmall[,"GrossNationalIncomePerCapita"]<- -1*dfsmall[,"GrossNationalIncomePerCapita"]
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
    scale_x_discrete(expand=c(0,0))+
    scale_color_discrete("Region")
  show(p)
}
plotPar(dfsmall, .4, "continent")

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





