
library(shiny)
library(babynames)
library(ggplot2)
library(dplyr)
data(babynames)

shinyServer(function(input, output) {
        
        output$myPlot <- renderPlot({
                if (input$sex == "female") babysex <- "F"
                else if (input$sex == "male") babysex <- "M"

                # fix capitalization of name
                ourname <- paste0(toupper(substring(tolower(input$chosenname), 1, 1)), 
                                  substring(tolower(input$chosenname), 2))
                pickaname <- babynames %>% filter(sex == babysex, name == ourname)

                # what is the proportion of the original name that we want to match?                
                goalprop <- as.numeric(pickaname[pickaname$year == input$firstyear, 'prop'])
                subsetfitname <- pickaname %>% 
                        filter(year %in% seq(input$firstyear-5,input$firstyear+5))

                # fit to just 10 years around first year to find slope of original name
                myfit <- lm(prop ~ year, subsetfitname)
                goalslope <- myfit$coefficients[2]
                
                # what names match the original name in proportion at the goal year?
                findmatches <- babynames %>% filter(sex == babysex, 
                                                    year == input$goalyear, 
                                                    prop < goalprop*1.1 & prop > goalprop*0.9) %>%
                        mutate(slope = 0.00)
                
                # if there are a lot matches, sort the matches and only keep the first 60
                if (dim(findmatches)[1] > 60) {
                        findmatches <- findmatches[order(abs(goalprop - findmatches$prop)),]
                        findmatches <- findmatches[1:60,]
                }
                
                # for each matching name, calculate the slope at the goal year
                for (i in seq_along(findmatches$name)) {
                        matchfitname <- babynames %>% filter(sex == babysex, 
                                                             name == as.character(findmatches[i,'name']))
                        matchfitname <- matchfitname %>% 
                                filter(year %in% seq(input$goalyear-5,input$goalyear+5))
                        matchfit <- lm(prop ~ year, matchfitname)
                        findmatches[i,'slope'] <- matchfit$coefficients[2]
                }
                
                # which of the matching names match the original name in slope?
                if (goalslope >= 0.00005) {
                        matchnames <- findmatches %>% filter(slope >= 0.00005) %>% select(name)
                } else if (goalslope <= -0.00005) {
                        matchnames <- findmatches %>% filter(slope <= -0.00005) %>% select(name)
                } else {
                        matchnames <- findmatches %>% 
                                filter(slope > -0.00005 & slope < 0.00005) %>% select(name) 
                }
                
                # THE MATCHES!
                matchnames <- babynames %>% filter(sex == babysex, name %in% matchnames$name)
                plotname <- rbind(pickaname, matchnames)
                ggplot(plotname, aes(x = year, y = prop, color = name)) + 
                        geom_line(size = 1.1) + 
                        annotate("point", x = input$firstyear, y = goalprop,
                                 color = "blue", size = 4.5, alpha = .7) +
                        annotate("text", x = input$firstyear, y = 1.2*goalprop + 5e-7/goalprop, 
                                 label = input$firstyear, color = "black") +
                        annotate("point", x = input$goalyear, y = goalprop,
                                 color = "blue", size = 4.5, alpha = .7) +
                        annotate("text", x = input$goalyear, y = 1.2*goalprop + 5e-7/goalprop,
                                 label = input$goalyear, color = "black") +
                        theme_grey(base_size = 16) + theme(legend.title=element_blank()) +
                        ylab("Proportion of total applicants for year") + xlab("Year")
  })

})
