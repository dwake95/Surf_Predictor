
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Surf Height Predictor"),

  sidebarLayout(
    sidebarPanel(
#            dateRangeInput("trn", 
#                      label = h3("Train Data Date Range"),
#                      format = "yyyymmdd"
#                      ),
            
#            dateRangeInput("test", 
#                      label = h3("Test Data Date Range"), 
#                      format = "yyyymmdd"
#                      ),
            
        numericInput("Height", 
                     label = h3("Enter Swell Height (cm)"),
                     value = 100,
                     min = 10,
                     max = 1000,
                     step = 10),
        
        numericInput("Period",
                     label = h3("Enter Period of Waves (seconds)"),
                    min = 4,
                    max = 24,
                    step = 2,
                    value = 8),
        
        sliderInput("Direction",
                  label = "Enter Direction
                  of Swell Arrival 
                  (degrees 000-360)",
                  min = 0,
                  max = 360,
                  value = 270),
        
        submitButton("Submit")
        ),
    mainPanel(
            textOutput("text1"),
            textOutput("text2"),
            textOutput("text3"),
            textOutput("prediction")
    )
    )
  )
)
