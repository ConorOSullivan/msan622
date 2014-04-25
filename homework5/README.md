Homework 4: Text Data Visualization
==============================

| **Name**  | Conor O'Sullivan  |
|----------:|:-------------|
| **Email** | ccosullivan@dons.usfca.edu |

## Instructions ##

The following packages must be installed prior to running this code:

- `ggplot2`
- `shiny`
- `grid`
- `scales`


To run this code, please enter the following commands in R:

```
library(shiny)
shiny::runGitHub('msan622', 'conorosullivan', subdir='homework5')
```

This will start the `shiny` app. See below for details on how to interact with the visualization.

## Discussion ##

![IMAGE](AreaPlot.png)

### Technique 1: Area Plot

I chose to create an area plot because I wanted to show the massive drop in monthly deaths that took place when the seatbelt law was enacted. I also decided to add more information by using the data's separation of driver, front seat passenger, and rear seat passenger deaths. The plot below the area plot is a line graph that gives context to what the area plot is currently showing. 

Interactivity:
The user can choose what span of years are being shown in the area graph, as well as which years are shaded in the context line graph, by using the slider on the left sidebar.

Customization:
- Made changes to the theme like legend position/justification, deleting grid marks and tick marks
- If the user selects the same year as the start and end point, a warning message is displayed
- Used RColorBrewer to set the color palette
- Added a line segment, text, and arrow on both graphs to show when the seatbelt law was enacted

Data-ink ratio: This plot has a moderately high data-ink ratio, since I've removed extraneous gridmarks and tick marks. However, there is some text written on the plots themselves that I've kept in order to explain certain pieces of information that I felt were worth explaining.  
Lie factor: Lie factor on this is 1 since the numbers are not distorted.  
Data density: This plot has a moderate data density. The area plot itself takes up a lot of space, and while it shows three different classes of auto passenger as well as when the law was enacted, it is still clear that this is not the densest visualization.

![IMAGE](heatmap.png)

### Technique 2: Heatmap

I chose a heatmap in order to better show the seasonality of the data.

Interactivity:
The same year preferences the user selected on the area plot tab apply here.

Customization:
- Shortened and formatted month names
- Used color brewer to choose color scale

Data-ink ratio: This plot has a lower data-ink ratio than the area plot. It however shows the year-on-year seasonality that certain months have better than the area plot. For instance, by looking at the intensity of the color green in each year, we can see that there are more deaths in the colder months.
Lie factor: There is a lie factor of 1 in this plot. No misrepresenation of the numbers here.
Data density: This plot is also moderately data-dense. Here we can only see total deaths, but the months are easier to distinguish than the area plot before, so we get some explanatory power out of that fact.

I had very tough time selecting colors for this plot. On one hand, it seems like the color should just be a gradient going from white at 0, to a single intense color at our max value of 4500. This however made it hard to distinguish between the months, as most of the months see about ~2000 deaths. I decided to stick with a two color shift, with the white color centered at our halfway point, 2000.