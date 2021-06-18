library(shiny)
library(leaflet)
library(ggplot2)
shinyUI( bootstrapPage(
  navbarPage( collapsible = FALSE,inverse = TRUE ,position = "static-top",
             "COVID-19 ", 
             tabPanel("Mapper",
                      div(class="outer",
                          leafletOutput("mymap",height = 740),
                          absolutePanel(class = "panel panel-default",
                            top=70,left = 1335, width = 250,fixed = TRUE,
                                        span(tags$i(h3("------Stats of State------"),align="center"),style="color:purple"),
                                        selectInput("sl","Select state",c("None",
                                          "Andhra Pradesh"        ,     "Arunanchal Pradesh"  ,     "Assam"           ,         "Bihar"          ,          "Chandigarh"              
                                         ,  "Chhattisgarh"        ,      "Delhi"              ,     "Goa"             ,        "Gujarat"          ,        "Haryana"                 
                                          , "Himachal Pradesh"    ,     "Jammu & Kashmir"     ,    "Jharkhand"        ,       "Karnataka"          ,      "Kerala"                  
                                          ,"Ladakh"               ,   "Madhya Pradesh"        ,  "Maharashtra"        ,     "Manipur"               ,   "Meghalaya"               
                                          , "Mizoram"             ,    "Odisha"               ,   "Punjab"            ,      "Rajasthan"             ,   "Tamil Nadu"              
                                          , "Telangana"           ,    "Tripura"              ,   "Uttar Pradesh"     ,       "Uttarakhand"           ,   "West Bengal"             
                                          , "Andaman & Nicobar Island" ,"Lakshadweep"          ,   "Sikkim"             ,      "Nagaland" 
                                        )),
                                        span(h4(textOutput("srec"), align = "left"),style="color:#22bb22"),
                                        span(h4(textOutput("sdea"), align = "left"),style="color:#FF0000"),
                                        ),
                          absolutePanel( class = "panel panel-default",
                           top = 145, left = 15, width = 425, fixed=TRUE,
                          draggable = FALSE, height = "auto",
                                        span(tags$i(h5("Reported cases are subject to significant variation in testing policy and capacity of India.")),
                                        style="color:#045a8d"),
                                        span(h3(textOutput("case_count"), align = "center"),style="color:red"),
                                        span(h4(textOutput("active_count"), align = "center"), style="color:blue"),
                                        span(h4(textOutput("recovered_count"), align = "center"), style="color:#006d2c"),
                                        span(h4(textOutput("death_count"), align = "center"),style="color:#4d004b"),
                                        span(tags$i(h3("---------Statistics---------"),align="center"),style="color:purple"),
                                        span(h4(textOutput("rec"), align = "center"),style="color:#22bb22"),
                                        span(h4(textOutput("dea"), align = "center"),style="color:#FF0000"),
                                        span(tags$i(h3(" ----------Most Suffered----------"),align="center"),style="color:purple"),
                                        plotOutput("plot", height="200px", width="100%"))
                          )
                        )
                       )
                     )
                    )
             
  
  
  