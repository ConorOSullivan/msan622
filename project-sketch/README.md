Project: Sketch
==============================

| **Name**  | Conor O'Sullivan  |
|----------:|:-------------|
| **Email** | ccosullivan@dons.usfca.edu |

## Discussion ##

Before I graph anything, I will extract the following variables from my dataset:
median age, population growth, poverty index, continent of country, GDP, area, population, country name, mean life expectancy at birth, mean years of schooling, gross income per capita, gender inequality index rank, adolescent fertility rate, majority religion. This will be done via R.

##Technique 1: Bubble Plot

###Tools: RCharts, shiny, RColorBrewer

I want to exhibit the negative correlation between age and population growth. I also will size these bubbles by poverty index. These bubbles will be colored by continent or religion (depending on the user's input) and allow filtering by selecting a single continent or religion. A tooltip with the country's name will pop up when the mouse hovers over the bubble.

##Technique 2: World map with tool tips

###Tools: d3

I'll make a world map with d3 by using a Mike Bostock example I found online. The colors will again be colored by religion or continent, depending on the user's input, and a tooltip with country information will appear when the mouse hovers over a country. The information displayed at the mouse's hover will be population, GDP, and area. This plot will support a zooming feature. I plan on including this in the shiny app, or if that is too difficult, to host it on gist.

##Technique 3: Parallel Coordinates plot

###Tools: d3 or Rcharts

This parallel coordinates plot will use the following variables: mean life expectancy at birth, mean years of schooling, gross income per capita, gender inequality index rank, and adolescent fertility rate. These will be colored by majority religion or continent, and allow brushing by selecting a single continent or religion. A tooltip will pop up with the country's name with a mouse hover.

##Technique 4: Star Plot

###Tools: d3

I'll select a subset of the countries (15 or so) to make a star plot with. It will use the same variables as the parallel coordinates plot. The coloring will be by religion or continent and will support the same brushing as mentioned before.




