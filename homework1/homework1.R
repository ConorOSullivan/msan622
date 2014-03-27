library(ggplot2) 
library(scales)
data(movies) 
data(EuStockMarkets)
setwd("/Users/conorosullivan/Documents/FourthModule/visualization/1_hw")
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
m<-movies
m<-subset(movies,budget>0)

eu <- transform(data.frame(EuStockMarkets), time = time(EuStockMarkets))

## Plot 1: Scatterplot

t<-ggplot(m,aes(x=budget, y=rating,color=genre))+
    geom_point()+
    ggtitle("Scatterplot of  Movie Rating vs. Movie Budget for 5,000 Movies from IMDb")+
    xlab("Movie Budget in US Dollars")+
    ylab("Movie Rating")+
    theme_grey()+
    theme(text = element_text(size=20))+
    scale_x_continuous(labels=dollar_format())+
    scale_y_continuous(breaks=c(0:10))+
    #scale_color_manual(values=c("red","#8EAE69","green",'orange','brown','blue','turquoise','yellow','black'),name="Genre")+
    scale_color_manual(values=c("brown3","lavenderblush2","lemonchiffon4",'lightblue','lightpink','cyan4','paleturquoise3','burlywood3','chartreuse3'),name="Genre")+
    theme(legend.background = element_rect(fill="gray99", size=.5, linetype="dotted"))+
    theme(panel.grid.minor = element_line(colour = "gray90"))
#show(t)
ggsave("hw1-scatter.png",height=8,width=13)

## Plot 2: Bar Chart

m$genre<-as.factor(m$genre)
n <- within(m, genre<-factor(genre, levels=names(sort(table(genre), decreasing=TRUE))))

p<-ggplot(n,aes(genre))+
    geom_bar(aes(fill=genre))+
    xlab("Genre")+
    ylab("Count")+
    scale_fill_manual(values=c("lightblue3","lightblue3","lightblue3","lightblue3","lightblue3","lightblue3","lightblue3","lightblue3","lightblue3"))+
    theme(legend.position="none")+
    ggtitle("Bar Chart of Movie Counts by Genre")+
    theme(legend.background = element_rect(fill="gray90", size=.5, linetype="dotted"))+
    theme(panel.grid.minor = element_line(colour = "gray90"))
#show(p)
ggsave("hw1-bar.png",height=8,width=11)

## Plot 3: Small Multiples
e<-m
q<-ggplot(e,aes(x=budget/1000000, y=rating,color=genre))+
  geom_point()+
  ggtitle("Small Multiples of  Movie Rating vs. Movie Budget for 5,000 Movies from IMDb")+
  xlab("Movie Budget in Millions of US Dollars")+
  ylab("Movie Rating")+
  theme_grey()+
  theme(text = element_text(size=20))+
  scale_y_continuous(breaks=c(0:10))+
  #scale_color_manual(values=c("red","#8EAE69","green",'orange','brown','blue','turquoise','yellow','black'),name="Genre")+
  scale_color_manual(values=c("brown3","lavenderblush4","lemonchiffon4",'lightblue','lightpink','cyan4','paleturquoise3','burlywood3','chartreuse3'),name="Genre")+
  theme(legend.background = element_rect(fill="gray90", size=.5, linetype="dotted"))+
  theme(panel.grid.minor = element_line(colour = "gray90"))+
  theme(legend.position="none")+
  facet_wrap( ~ genre, ncol=3)
ggsave("hw1-multiples.png",height=8,width=13)

## Plot 4: Multi-Line Chart

library(reshape)
library(plyr)

eu1<-eu
eu1$time<-unclass(eu1$time)
eu1m<-melt(eu1,id="time")
eu1m$time<-ts(eu1m$time)


y<-ggplot(eu1m,aes(x=time, y=value,color=variable))+
  geom_line()+
  scale_y_continuous(labels=comma)+
  scale_color_discrete(name="Index")+
  xlab("Time")+
  ylab("Price in Euro")+
  ggtitle('Multi-Line Chart of Stock Price vs Time')#+
  
ggsave("hw1-multiline.png",height=8,width=11)





