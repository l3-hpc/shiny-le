#Lake Erie: Modeled vs Measured
#for EPA ORD, Center for Computational Toxicology & Exposure (CCTE), 
#             Great Lakes Toxicology & Ecology Division
#R Shiny App: L.L. Lowe, 2023
#Model outputs from FVCOM Lake Erie, TP and LEEM
#Measured data from [Wilson]

#ui.R is User Interface
#Libraries:
#The dashboard version of Shiny
library(shinydashboard)
#Leaflet is for the interactive map
library(leaflet)
#The error messages are usually due to time zone warnings.
#Comment out when debugging
options( warn = -1 )

source("labels.R")


#Begin entire displayed webpage
dashboardPage(

  #Header is title of the page  
  dashboardHeader(title = shiny_title),   

  #A sidebar is default, need to disable for single page
  dashboardSidebar(disable = TRUE),

  
  #The Dashboard is contained in the Page
  dashboardBody(
    #Makes the map and plot take 65% and 60% vertical height of browser window
    tags$style(type = "text/css", "#map {height: calc(65vh) !important;}"),
    tags$style(type = "text/css", "#plotVar1 {height: calc(30vh) !important;}"),
    tags$style(type = "text/css", "#plotVar2 {height: calc(30vh) !important;}"),    

    #Main row - entire window
    fluidRow(
      #Map fills the left half of the window, in a box
      #'primary' is code for blue color
      column(width=6,
        box(width=NULL, solidHeader=TRUE,status="primary",
                                    leafletOutput("map")),
      #Below map, row of plot options
      fluidRow(
        #Show coordinates (lat/lon and X/Y) of chosen point
        column(width=3,
          strong("Model Output"),
          htmlOutput("plotlatlon"),
          htmlOutput("plotxy"),
          br()),
        #Color map circles, choose which variable                 
        column(width=3,
          radioButtons("var", "Color by which variable?",
                       #choices defined in labels.R
                       colorby_choices
                       )),
        #Color map circles, choose surface or bottom mean of chosen variable 
        column(width=3,
          radioButtons("colorby", "Color by surface or bottom?",
                        choices = list("Surface(mean)" = "Surface", "Bottom(mean)" = "Bottom"),
                        selected = "Surface"))
          ),), #end row of plot options, end left half of page
      #Plot and plot options fill right half of window
        column(width=6,
          #First row, first plot
          fluidRow(
            column(width=12,
                   box(width=NULL,solidHeader=TRUE,status="primary",
                   plotOutput("plotVar1")))),
          #Second row, second plot
          fluidRow(
            column(width=12,
                   box(width=NULL,solidHeader=TRUE,status="primary",
                   plotOutput("plotVar2")))),
           #Third row is plot options
           fluidRow(
             #Choose to display station or no, default is TRUE
             column(width=3,
               strong("Station Data"),
               checkboxInput("checkbox", "Uncheck to remove station data.", value = TRUE)),
             #Plot limits
             column(width=3,
                    radioButtons("radio", "Plot Limits",
                                  choices = list("Both model's min/max" = 1, "Each model's min/max" = 2 ),
                                  selected = 1)),
             #Add the slider, modify times as needed
               column(width=6,
                      sliderInput("timeRange", label = "Time range",
                      timeFormat="%F",
                      min = as.POSIXct("2013-03-02",tz = 'UTC'),
                      max = as.POSIXct("2013-10-31",tz = 'UTC'),
                      value = c(as.POSIXct("2013-03-02",tz = 'UTC'),
                      as.POSIXct("2013-10-31",tz = 'UTC'))))
           )#end row of plot options
      )#--End right-half window column
    )#--End Main Row
    
  )#-- End dashboard Body
)#-- End dashboard Page

