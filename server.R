
library(shiny)
library(babynames)
library(ggplot2)
library(dplyr)
data(babynames)

shinyServer(function(input, output) {
        
        output$myPlot <- renderPlot({
                if (input$sex == "female") babysex <- "F"
                else if (input$sex == "male") babysex <- "M"
                pickaname <- babynames %>% filter(sex == babysex, name == input$chosenname)
                goalprop <- as.numeric(pickaname[pickaname$year == input$firstyear, 'prop'])
                subsetfitname <- pickaname %>% 
                        filter(year %in% seq(input$firstyear-5,input$firstyear+5))
                myfit <- lm(prop ~ year, subsetfitname)
                goalslope <- myfit$coefficients[2]
                findmatches <- babynames %>% filter(sex == babysex, 
                                                    year == input$goalyear, 
                                                    prop < goalprop*1.1 & prop > goalprop*0.9) %>%
                        mutate(slope = 0.00)
                for (i in seq_along(findmatches$name)) {
                        matchfitname <- babynames %>% filter(sex == babysex, 
                                                             name == as.character(findmatches[i,'name']))
                        matchfitname <- matchfitname %>% 
                                filter(year %in% seq(input$goalyear-5,input$goalyear+5))
                        matchfit <- lm(prop ~ year, matchfitname)
                        findmatches[i,'slope'] <- matchfit$coefficients[2]
                }
                if (goalslope >= 0.00005) {
                        matchnames <- findmatches %>% filter(slope >= 0.00005) %>% select(name)
                } else if (goalslope <= -0.00005) {
                        matchnames <- findmatches %>% filter(slope <= -0.00005) %>% select(name)
                } else {
                        matchnames <- findmatches %>% 
                                filter(slope > -0.00005 & slope < 0.00005) %>% select(name) 
                }
                
                matchnames <- babynames %>% filter(sex == babysex, name %in% matchnames$name)
                plotname <- rbind(pickaname, matchnames)
                ggplot(plotname, aes(x = year, y = prop, color = name)) + 
                        geom_line(size = 1.1) + 
                        annotate("text", x = input$firstyear, y = goalprop*1.4, label = input$firstyear) +
                        annotate("point", x = input$firstyear, y = goalprop,
                                 color = "blue", size = 4.5, alpha = .8) +
                        annotate("text", x = input$goalyear, y = goalprop*1.4, label = input$goalyear) +
                        annotate("point", x = input$goalyear, y = goalprop,
                                 color = "blue", size = 4.5, alpha = .8) +
                        theme(legend.title=element_blank()) + 
                        ylab("Proportion of total applicants for year") + xlab("Year")
  })
  
  output$errorText <- renderText({
          
  })        
  
})
