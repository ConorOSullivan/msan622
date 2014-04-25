library(shiny)
library(grid)
library(reshape2)
library(ggplot2)
library(scales)
data(Seatbelts)
data(UKDriverDeaths)

seat<-data.frame(Seatbelts)
times <- time(Seatbelts)
years <- floor(times)
years <- factor(years, ordered = TRUE)
months <- factor(
  month.abb[cycle(times)],
  levels = month.abb,
  ordered = TRUE
)

seat$year<-years
seat$month<-months
seat$time<-as.numeric(times)
seat$totdeaths<-seat$drivers+seat$front+seat$rear

molten <- melt(
  seat,
  id = c("year", "month", "time")
)


theme_guide <- function() {
  options = list(size = 2)
  
  return(
    guides(
      colour = guide_legend(
        "year", 
        override.aes = options
      )
    )
  )
}

# scale_year <- function() {
#   return(
#     scale_x_continuous(
#       name = "Year",
#       limits = c(1969, 1984.917),
#       expand = c(0, 0),
#       breaks = c(seq(1969, 1985, 4), 1984.917),
#       labels = function(x) {ceiling(x)}
#     )
#   )
# }

theme_legend <- function() {
  return(
    theme(
      legend.direction = "horizontal",
      legend.position = c(1, 1),
      legend.justification = c(1, 1),
      legend.title = element_blank(),
      legend.background = element_blank(),
      legend.key = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      panel.background = element_blank(),
      axis.ticks = element_blank()
    )
  )
}
scale_months <- function() {
  return(
    scale_x_discrete(
      name = "Month",
      expand = c(0, 0),
      # this is for faceting,
      # can be removed otherwise
      labels = fancy_label
    )
  )
}
count <- 1
fancy_label <- function(x) {
  count <<- count + 1
  if (count %% 2 == 0) { return(x) }
  else { return(c("", x[2:12])) }
}
plotArea <- function(start=1969,end=1985){
  if (start != end) {
    p <- ggplot(molten[molten$variable %in% c("drivers","front"),], aes(x = time, y = value))
    p <- p + geom_area(
      data = subset(molten, variable %in% c("drivers","front","rear")),
      aes(
        group = variable,
        fill = variable,
        order = -as.numeric(variable)
      )
    )
    #   start = 1976
    #   end = 1983
    scale_year <- function() {
      return(
        scale_x_continuous(
          name = "Year",
          # using 1980 will result in gap
          limits = c(start, end - .083),
          expand = c(0, 0),
          # still want 1980 at end of scale
          breaks = c(seq(start, 1985, 1), end - .083),
          labels = function(x) {ceiling(x)}
        )
      )
    }
    
    
    p <- p + xlim(start,end)
    p <- p + scale_year()
    p <- p + theme_legend()
    p <- p + scale_fill_brewer(type="qual",palette=1,labels=c("Drivers","Front Seat","Rear"))
    p <- p + ylab("Number Killed or Injured")
    p <- p + ggtitle("Monthly Totals of Travelers Killed in the UK")
    textlevel <- 3300
    p <- p + geom_text(data = NULL, x = 1981, y = textlevel, label = "seatbelt law enacted")
    p <- p + geom_segment(data = NULL, x = 1981.8, y = textlevel, xend = 1983, yend = textlevel, arrow = arrow(length = unit(0.3,"cm")))
    p <- p + geom_segment(data = NULL, x = 1983, y = 4500, xend = 1983, yend = 0)
  }
  else {
    p<-ggplot()+geom_text(data=NULL, aes(x=1975, y=3000), label="Must choose at least one year to display")+
      theme(axis.line=element_blank(),axis.text.x=element_blank(),
            axis.text.y=element_blank(),axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),legend.position="none",
            panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
            panel.grid.minor=element_blank(),plot.background=element_blank())
  }
  show(p)
}
#plotArea()
col <- "#dddddd"

#plotOverview <- function(start = 1969, num = 12) {
plotOverview <- function(start = 1969, end = 1985) {
  xmin <- start
  #xmax <- start + (num / 12)
  xmax <- end
  
  ymin <- 3000
  ymin <- min(seat$totdeaths)
  ymax <- 6500
  ymax <- max(seat$totdeaths)
  
  p <- ggplot(seat, aes(x = time, y = totdeaths))
  
#   p <- p + geom_rect(
#     xmin = 1983, xmax = 1984.917,
#     ymin = ymin, ymax = ymax,
#     fill = "#00FFFF")
  
  p <- p + geom_rect(
    xmin = xmin, xmax = xmax,
    ymin = ymin, ymax = ymax,
    fill = col)
  
  p <- p + geom_line()
  
  p <- p + scale_x_continuous(
    name = "Year",
    limits = c(1969, 1984.917),
    expand = c(0, 0),
    breaks = c(seq(1969, 1985, 1), 1984.917),
    labels = function(x) {ceiling(x)}
  )
  
  p <- p + scale_y_continuous(
    limits = c(ymin, ymax),
    #     breaks = seq(ymin, ymax, length.out = 3)),
    expand = c(0,0)
  )
  
  p <- p + theme(panel.border = element_rect(
    fill = NA, colour = col))
  
  p <- p + theme(axis.title = element_blank())
  p <- p + theme(panel.grid = element_blank())
  p <- p + theme(panel.background = element_blank())
  p <- p + geom_text(data = NULL, x = 1976, y = 2000, label = "plot above is zoomed on gray shaded area")
  p <- p + geom_text(data = NULL, x = 1981, y = 4000, label = "seatbelt law enacted")
  p <- p + geom_segment(data = NULL, x = 1982.2, y = 4000, xend = 1983, yend = 4000, arrow = arrow(length = unit(0.3,"cm")))
  p <- p + geom_segment(data = NULL, x = 1983, y = ymax, xend = 1983, yend = ymin)
  p <- p + ggtitle('Total Deaths and Injuries of Drivers, Front Seat Passengers, and Rear Seat Passengers')
  #return(p)
  show(p)
}

# plotOverview()

# plotGrid<-function(start=1969, end=1985){
#   if (end == 1985) end = 1984
#   molten2<-molten[molten$year >= start & molten$year <= end,]
#   scale_prgn <- function() {
#     return(
#       scale_fill_gradientn(
#         colours = brewer_pal(
#           type = "div", 
#           palette = "PRGn")(5),
#         name = "Deaths",
#         limits = c(0, 4500),
#         #breaks = c(0, 2000, 4000)
#         breaks = c(0, 2250, 4500)
#       )
#       #       scale_fill_gradient(low = "white", high = "blue",
#       #                           limits = c(0, 4500),
#       #                           breaks = c(0, 2250, 4500)) 
#     )
#   }
#   
#   theme_heatmap <- function() {
#     return (
#       theme(
#         axis.text.y = element_text(
#           angle = 90,
#           hjust = 0.5),
#         axis.ticks = element_blank(),
#         axis.title = element_blank(),
#         legend.direction = "horizontal",
#         legend.position = "top",
#         panel.background = element_blank()
#       )
#     )
#   }
#   
#   
#   p <- ggplot(
#     subset(molten2, variable == "totdeaths"), 
#     aes(x = month, y = year)
#   )
#   
#   p <- p + geom_tile(
#     aes(fill = value), 
#     colour = "white"
#   )
#   
#   p <- p + scale_prgn()
#   p <- p + scale_months()
#   p <- p + scale_y_discrete(expand = c(0, 0))
#   p <- p + theme_heatmap()
#   
#   # p <- p + coord_polar()
#   p <- p + coord_fixed(ratio = 1)
#   p <- p + ggtitle('Heatmap of Total Vehicle Injuries and Deaths in the UK')
# #   p <- p + geom_text(data=NULL, x = )
#   
#   show(p)
# }

# plotMulti<-function(start=1969, end=1977){
#   
#   if (end - start <= 8) {
#     ys <- c(1969:1984)
#     palette <- rep("grey85",16)
#     palette[which(ys >= start & ys <= end)]<-brewer_pal(type = "qual", palette = "Set1")(9)
#     
#     p <- ggplot(
#       subset(molten, variable == "totdeaths"), 
#       aes(
#         x = month, 
#         y = value, 
#         group = year, 
#         color = year
#       )
#     )
#     
#     # CREATE MULTI-LINE PLOT ##############
#     p <- p + geom_line(alpha = 0.8)
#     #     p <- p + scale_colour_brewer(palette = "Set1")
#     p <- p + scale_color_manual(limits=levels(seat$year), values=palette)
#     
#     # make it pretty
#     p <- p + scale_months()
#     #p <- p + scale_deaths()
#     p <- p + theme_legend()
#     p <- p + theme_guide()
#     p <- p + ggtitle('Multi-Line Plot of Total Injuries and Deaths vs Month')
#     p <- p + ylab('Total Injuries and Deaths')
#     
#     # squarify grid (1 month to 1000 deaths)
#     # p <- p + coord_fixed(ratio = 1 / 1000)
#     
#     # CREATE FACET PLOT ###################
#     # p <- p + facet_wrap(~ year, ncol = 2)
#     # p <- p + theme(legend.position = "none")
#     
#     # CREATE STAR-LIKE PLOT ###############
#     # p <- p + coord_polar()
#   }
#   else {
#     p<-ggplot()+geom_text(data=NULL, aes(x=1975, y=3000), label="Choose fewer years. Max years this plot can display is 9.")+
#       theme(axis.line=element_blank(),axis.text.x=element_blank(),
#             axis.text.y=element_blank(),axis.ticks=element_blank(),
#             axis.title.x=element_blank(),
#             axis.title.y=element_blank(),legend.position="none",
#             panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
#             panel.grid.minor=element_blank(),plot.background=element_blank())
#   }
#   
#   show(p) 
#   
# }

plotMulti<-function(start=1969, end=1972){
  
  #   if (end - start <= 8) {
  ys <- c(1969:1984)
  #     palette <- rep("grey85",16)
  ps <- gg_color_hue(16)
  #     palette[which(ys >= start & ys <= end)]<-brewer_pal(type = "qual", palette = "Set1")(9)
  ps[which(ys < start | ys > end)]<-"grey85"
  #     print(which(ys < start | ys > end))
  #     print(ps)
  p <- ggplot(
    subset(molten, variable == "totdeaths"), 
    aes(
      x = month, 
      y = value, 
      group = year, 
      color = year
    )
  )
  
  # CREATE MULTI-LINE PLOT ##############
  p <- p + geom_line(alpha = 0.8)
  #     p <- p + scale_colour_brewer(palette = "Set1")
  p <- p + scale_color_manual(limits=levels(seat$year), values=ps)
  
  # make it pretty
  p <- p + scale_months()
  #p <- p + scale_deaths()
  p <- p + theme_legend()
  p <- p + theme_guide()
  p <- p + ggtitle('Multi-Line Plot of Total Injuries and Deaths vs Month')
  p <- p + ylab('Total Injuries and Deaths')
  
  # squarify grid (1 month to 1000 deaths)
  # p <- p + coord_fixed(ratio = 1 / 1000)
  
  # CREATE FACET PLOT ###################
  # p <- p + facet_wrap(~ year, ncol = 2)
  # p <- p + theme(legend.position = "none")
  
  # CREATE STAR-LIKE PLOT ###############
  # p <- p + coord_polar()
  #   }
  #   else {
  #     p<-ggplot()+geom_text(data=NULL, aes(x=1975, y=3000), label="Choose fewer years. Max years this plot can display is 9.")+
  #       theme(axis.line=element_blank(),axis.text.x=element_blank(),
  #             axis.text.y=element_blank(),axis.ticks=element_blank(),
  #             axis.title.x=element_blank(),
  #             axis.title.y=element_blank(),legend.position="none",
  #             panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
  #             panel.grid.minor=element_blank(),plot.background=element_blank())
  #   }
  
  show(p) 
  
}



shinyServer(function(input, output) {
  output$mainPlot <- renderPlot({
    print(plotArea(input$num[1], input$num[2])) 
  })
  
  output$overviewPlot <- renderPlot({
    print(plotOverview(input$num[1], input$num[2]))
  })
  
#   output$heatmap <- renderPlot({
#     print(plotGrid(input$num[1], input$num[2]))
#   })
  
  output$multiline <- renderPlot({
    print(plotMulti(input$num[1], input$num[2]))
  })
  
})



