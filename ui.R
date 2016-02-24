
library(shiny)

shinyUI(fluidPage(
        titlePanel("What Would Your Name Be If You Were Born in a Different Year?"),

        sidebarLayout(
                sidebarPanel(selectInput("sex", label = "Let's find some names similar in popularity to a", choices = list("male", "female"),
                                         selected = "female"),
                             numericInput("firstyear", label = "child born in the year", min = 1885, max = 2009, step = 1, value = 1995),
                textInput("chosenname", label = "with the name", value = "Julia"), 
                br(),
                br(),
                numericInput("goalyear", label = "Let's compare to children born in the year", min = 1885, max = 2009, step =1, value = 1975),
                br(),
                br(),
                "Names are compared based on the proportion of total names 
                reported to the Social Security Administration, and how that 
                proportion was changing (the slope). Read more about this app at ",
                a("my blog.",
                  href = "http://juliasilge.com/blog/")
                ),
    
    mainPanel(
       plotOutput("myPlot"),
       br(),
       textOutput("errorText")
    )
  )
))
