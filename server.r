library(shiny)
library(leaflet)
library(readr)
library(rjson)
library(ggplot2)
library(rgdal)


s<-read.csv("dataset.csv")

data=rjson::fromJSON(file="https://api.covid19india.org/data.json")
for( j in 1:34){
  for(i in 1:38){
    if(data$statewise[[i]]$state==s$State[j]){
      s$Total[j]=as.numeric(data$statewise[[i]]$confirmed)
      s$Infected[j]=as.numeric(data$statewise[[i]]$active)
      s$Recovered[j]=as.numeric(data$statewise[[i]]$recovered)
      s$Deaths[j]=as.numeric(data$statewise[[i]]$deaths)
      break
    }
    if(data$statewise[[i]]$state=="Andaman and Nicobar Islands"){
      s$Total[31]=as.numeric(data$statewise[[i]]$confirmed)
      s$Infected[31]=as.numeric(data$statewise[[i]]$active)
      s$Recovered[31]=as.numeric(data$statewise[[i]]$recovered)
      s$Deaths[31]=as.numeric(data$statewise[[i]]$deaths)
    }
    if(data$statewise[[i]]$state=="Jammu and Kashmir"){
      s$Total[12]=as.numeric(data$statewise[[i]]$confirmed)
      s$Infected[12]=as.numeric(data$statewise[[i]]$active)
      s$Recovered[12]=as.numeric(data$statewise[[i]]$recovered)
      s$Deaths[12]=as.numeric(data$statewise[[i]]$deaths)
    }
    if(data$statewise[[i]]$state=="Arunachal Pradesh"){
      s$Total[2]=as.numeric(data$statewise[[i]]$confirmed)
      s$Infected[2]=as.numeric(data$statewise[[i]]$active)
      s$Recovered[2]=as.numeric(data$statewise[[i]]$recovered)
      s$Deaths[2]=as.numeric(data$statewise[[i]]$deaths)
    }
  }
}

sb<- readOGR(dsn = getwd(),layer = "Indian_States")


sb$rec=s$Recovered[match(sb$st_nm,s$State)]
sb$dec=s$Deaths[match(sb$st_nm,s$State)]
sb$aec=s$Infected[match(sb$st_nm,s$State)]
sb$tot=s$Total[match(sb$st_nm,s$State)]

s$ac_range=cut(s$Infected,
               breaks = c(0,10000,100000,max(s$Infected)+10),right=FALSE,
               labels=c("less than 10000","less than 100000","more than 100000"))
s$re_range=cut(s$Recovered,
               breaks = c(0,50000,150000,max(s$Recovered)+10),right=FALSE,
               labels=c("less than 50000","less than 150000","more than 150000"))
s$de_range=cut(s$Deaths,
               breaks = c(0,10000,50000,max(s$Deaths)+10),right=FALSE,
               labels=c("less than 10000","less than 50000","more than 50000"))


p<- s[order(-s$Total),]


pal= colorFactor(palette=c("yellow","orange","red"),domain = s$ac_range)
pl= colorFactor(palette=c("dark green","forest green","green"),domain = s$re_range)
pa= colorFactor(palette=c("chocolate"," brown","black"),domain = s$de_range)



basemap = leaflet(data = s)%>%
  addTiles()%>%
  setView(lat = 20.5937,lng = 78.9629,zoom=5)%>%
  addPolygons(data = sb,group="ALL",
              highlightOptions = highlightOptions(weight = 5,color = "red",fillColor = "orange",fillOpacity = "0.4",bringToFront = TRUE),
              label = sprintf("<strong>%s</strong><br/>Cases: %d<br/>Active cases: %d<br/>Recovered: %d <br/>Deaths: %d", sb$st_nm,sb$tot,sb$aec,sb$rec,sb$dec ) %>%
                   lapply(htmltools::HTML), 
                   labelOptions = labelOptions(
                     style = list("font-weight" = "normal", padding = "3px 8px","color"="black"),
                        textsize = "15px", direction = "auto"))%>%
  addCircleMarkers(group="DEATHS",lat = ~Latitude,lng = ~Longitude,color = ~pa(de_range),radius = ~(Deaths)^(1/2),
                   label=sprintf("<strong>%s</strong><br/>Deaths: %d ", s$State,s$Deaths )%>% lapply(htmltools::HTML), 
                   labelOptions = labelOptions(
                     style = list("font-weight" = "normal", padding = "3px 8px","color"="#045a8d"),
                     textsize = "15px", direction = "auto"))%>%
  addCircleMarkers(group="RECOVERED",lat = ~Latitude,lng = ~Longitude,color = ~pl(re_range),radius = ~(Recovered)^(1/4),
                   label=sprintf("<strong>%s</strong><br/>Recovered: %d ", s$State,s$Recovered )%>% lapply(htmltools::HTML), 
                   labelOptions = labelOptions(
                     style = list("font-weight" = "normal", padding = "3px 8px","color"="#4d004b"),
                     textsize = "15px", direction = "auto"))%>%
  addCircleMarkers(group="ACTIVE",lat = ~Latitude,lng = ~Longitude,color = ~pal(ac_range),radius = ~(Infected)^(1/3),
                   label = sprintf("<strong>%s</strong><br/>Active cases: %d ", s$State,s$Infected )%>% lapply(htmltools::HTML), 
                   labelOptions = labelOptions(
                     style = list("font-weight" = "normal", padding = "3px 8px","color"="#016c59"),
                     textsize = "15px", direction = "auto"))%>%
  addLayersControl( 
    position = "bottomright",
    baseGroups = c("ALL","ACTIVE", "RECOVERED", "DEATHS"),
    options = layersControlOptions(collapsed = FALSE)) %>% 
     hideGroup(c("ACTIVE","RECOVERED", "DEATHS")) %>%
  addLegend(group ="DEATHS",position = "bottomright",pal = pa,values = ~de_range,title = "DEATHS",
            opacity = 0.6)%>%
  addLegend(group ="RECOVERED",position = "bottomright",pal = pl,values = ~re_range,title = "RECOVERED",
          opacity = 0.6)%>%
  addLegend(group ="ACTIVE",position = "bottomright",pal = pal,values = ~ac_range,title = "ACTIVE",
          opacity = 0.6)

  

shinyServer(
  function(input,output){
    output$case_count <- renderText({
      paste0(prettyNum(sum(s$Total), big.mark=","), " Confirmed ")
    })
    
    output$death_count <- renderText({
      paste0(prettyNum(sum(s$Deaths), big.mark=","), " Deaths  ")
    })
    
    output$recovered_count <- renderText({
      paste0(prettyNum(sum(s$Recovered), big.mark=","), " Recovered  ")
    })
    output$active_count <- renderText({
      paste0(prettyNum(sum(s$Infected), big.mark=","), " Active  ")
    })
    output$mymap <- renderLeaflet(basemap)
    
    output$plot <- renderPlot({
       ggplot(head(p,5), aes(x =State, y =Total,fill =Deaths )) + 
        geom_bar(stat = "identity")+ylab("Total Cases")+xlab(" ")
    })
    output$dea <- renderText({
      paste0("  Death rate : ",signif((sum(s$Deaths)/sum(s$Total))*100,digits = 4)," %" )
    })
    output$rec <- renderText({
      paste0("Recovery rate : ",signif((sum(s$Recovered)/sum(s$Total))*100,digits = 4), " % ")
    })
  observe({
    df=s[s$State==input$sl,]
    lt=df$Latitude
    lg=df$Longitude
    
       output$sdea <- renderText({
      paste0("  Death rate : ",signif((df$Deaths/df$Total)*100,digits = 4)," %" )
       })
      output$srec <- renderText({
      paste0("Recovery rate : ",signif((df$Recovered/df$Total)*100,digits = 4), " % ")
      })
      if(input$sl!="None")
      leafletProxy("mymap",data = s)%>%
        clearMarkers()%>%
        addMarkers(lat = lt,lng = lg)%>%
        addCircleMarkers(group="DEATHS",lat = ~Latitude,lng = ~Longitude,color = ~pa(de_range),radius = ~(Deaths)^(1/3),
                         label=sprintf("<strong>%s</strong><br/>Deaths: %d ", s$State,s$Deaths )%>% lapply(htmltools::HTML), 
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px","color"="#045a8d"),
                           textsize = "15px", direction = "auto"))%>%
        addCircleMarkers(group="RECOVERED",lat = ~Latitude,lng = ~Longitude,color = ~pl(re_range),radius = ~(Recovered)^(1/4),
                         label=sprintf("<strong>%s</strong><br/>Recovered: %d ", s$State,s$Recovered )%>% lapply(htmltools::HTML), 
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px","color"="#4d004b"),
                           textsize = "15px", direction = "auto"))%>%
        addCircleMarkers(group="ACTIVE",lat = ~Latitude,lng = ~Longitude,color = ~pal(ac_range),radius = ~(Infected)^(1/3),
                         label = sprintf("<strong>%s</strong><br/>Active cases: %d ", s$State,s$Infected )%>% lapply(htmltools::HTML), 
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px","color"="#016c59"),
                           textsize = "15px", direction = "auto"))
        
       else
       leafletProxy("mymap",data = s)%>%
        clearMarkers()%>%
        addCircleMarkers(group="DEATHS",lat = ~Latitude,lng = ~Longitude,color = ~pa(de_range),radius = ~(Deaths)^(1/3),
                         label=sprintf("<strong>%s</strong><br/>Deaths: %d ", s$State,s$Deaths )%>% lapply(htmltools::HTML), 
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px","color"="#045a8d"),
                           textsize = "15px", direction = "auto"))%>%
        addCircleMarkers(group="RECOVERED",lat = ~Latitude,lng = ~Longitude,color = ~pl(re_range),radius = ~(Recovered)^(1/4),
                         label=sprintf("<strong>%s</strong><br/>Recovered: %d ", s$State,s$Recovered )%>% lapply(htmltools::HTML), 
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px","color"="#4d004b"),
                           textsize = "15px", direction = "auto"))%>%
        addCircleMarkers(group="ACTIVE",lat = ~Latitude,lng = ~Longitude,color = ~pal(ac_range),radius = ~(Infected)^(1/3),
                         label = sprintf("<strong>%s</strong><br/>Active cases: %d ", s$State,s$Infected )%>% lapply(htmltools::HTML), 
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px","color"="#016c59"),
                           textsize = "15px", direction = "auto"))
        
    })
})
