
library(shiny)
require(dplyr)
require(lubridate)
require(caret)


# Set ground work to ingest data from user interface in the future.  Currently 
# hard coded, but eventually could use a map interface to select a deep
# and shallow water points.

cdip.data.url = "http://cdip.ucsd.edu/data_access/justdar.cdip?"
deep.stn = "100"
shallow.stn = "73"
trn.start = "20110101"
trn.end = "20141231"
test.start = "20150101"
test.end = "20150731"

train.dd.url = paste(paste(cdip.data.url,deep.stn, sep = ""), "dd", trn.start, trn.end, sep ="+")
train.de.url = paste(paste(cdip.data.url,deep.stn, sep = ""), "de", trn.start, trn.end, sep ="+")
train.y.data.url = paste(paste(cdip.data.url,shallow.stn, sep = ""), "de", trn.start, trn.end, sep = "+")


# modify column headers  

new.dd = c('dtg', 'Dp', 'D22+', 'D22-18', 'D18-16', 'D16-14', 'D14-12', 'D12-10', 'D10-8', 'D8-6', 'D6-2')
new.de = c('dtg1', 'Hs', 'Tp', 'E22+', 'E22-18', 'E18-16', 'E16-14', 'E14-12', 'E12-10', 'E10-8', 'E8-6', 'E6-2')

# Download the Directional (dd) dataset for the selected dates for the deep water point.

training.dd.cdip <- read.csv2(train.dd.url, skip = 5, header = TRUE, sep="")
colnames(training.dd.cdip) = new.dd

# Download the Energy (de) dataset for the selected dates for the deep water point.

training.de.cdip <- read.csv2(train.de.url, skip = 2, header = TRUE, sep="")
colnames(training.de.cdip) = new.de

# Combine the energy and direction data sets together, and subset out predictors.

training.cdip = merge(training.dd.cdip,training.de.cdip, by.x = "dtg", by.y = "dtg1")
training.cdip = filter(training.cdip, dtg!="</pre>")

training.cdip = select(training.cdip, dtg, Hs, Dp, Tp)

# Modify the dtg variable into a POSIX format
training.cdip$dtg = as.character(training.cdip$dtg)
training.cdip$dtg <- strptime(training.cdip$dtg, format = "%Y%m%d%H")
training.cdip$dtg <- as.POSIXct(training.cdip$dtg)

# Clean up old objects
rm(training.dd.cdip, training.de.cdip)

#Download the nearshore data
training.scripps.cdip <- read.csv2(train.y.data.url, skip = 2, header = TRUE, sep="")
colnames(training.scripps.cdip) = new.de
training.scripps.cdip = filter(training.scripps.cdip, dtg1!="</pre>")
training.scripps.cdip$dtg1 <- strptime(training.scripps.cdip$dtg1, format = "%Y%m%d%H")
training.scripps.cdip$dtg1 <- as.POSIXct(training.scripps.cdip$dtg1)
training.y = select(training.scripps.cdip, dtg1, Hs)
rm(training.scripps.cdip)

# Combine data into  a single data frame. 
colnames(training.y)= c("dtg", "surf_Hs")
training.all = merge(training.cdip, training.y)
training.all$Tp = as.integer(training.all$Tp)

# Build regression model with training data
require(caret)
modfit = train(surf_Hs~Hs+Tp+Dp, data=training.all, method = "glm")

shinyServer(function(input, output) {
       
        output$text1 <- renderText({
                
                paste("You have selected Height:", input$Height, "centimeters")
                
        })
        
        output$text2 <- renderText({
                
                paste("You have selected Period:" , input$Period, "seconds")
                
        })
       
        output$text3 <- renderText({
                
                paste("You have selected Direction:", input$Direction, "degrees")
                
        })
        
        output$prediction <- renderText({
                
                paste("Predicted Significant Wave Height is", 
                     round(predict(modfit, 
                                 newdata = data_frame("Hs" = input$Height, 
                                                      "Tp" = input$Period, 
                                                      "Dp" = input$Direction)
                                 ), digits = 2
                         ),
                      "centimeters")
        })
}
)

        
        




