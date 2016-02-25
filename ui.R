
library(shiny)

shinyUI(fluidPage(
        titlePanel("What Would Your Name Be If You Were Born in a Different Year?"),

        sidebarLayout(
                sidebarPanel(selectInput("sex", label = "Let's find some names similar in popularity to a", choices = list("male", "female"),
                                         selected = "female"),
                             numericInput("firstyear", label = "child born in the year", 
                                          min = 1885, max = 2009, step = 1, value = 1995),
                textInput("chosenname", label = "with the name", value = "Julia"), 
                br(),
                numericInput("goalyear", label = "Let's compare to children born in the year", 
                             min = 1885, max = 2009, step = 1, value = 1925),
                br(),
                "Names are compared based on the proportion of total names 
                reported to the Social Security Administration, and how that 
                proportion was changing (the slope).",
                br(),
                br(),
                "All names with at least 5 uses are included; the app will 
                return an error if you enter a name that did not meet this 
                criteria. Be patient with the app for rare names. Read more 
                about this app at ",
                a("my blog.",
                  href = "http://juliasilge.com/blog/")
                ),
    
    mainPanel(
       plotOutput("myPlot")
    )
  )
))
