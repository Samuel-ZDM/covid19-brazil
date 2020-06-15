#install.packages('shiny')
library(shiny)
#install.packages('shinydashboard')
library(shinydashboard)


#install.packages('shinythemes')
library(shinythemes)

#install.packages('tidyverse')
library(tidyverse)
theme_set(theme_bw())

#install.packages('ggrepel')
library (ggrepel)

#install.packages('DT')
library(DT)

# Para trabalhar com datas 
#install.packages('lubridate')
library(lubridate)

# Para produzir gráficos interativos
library(ggplot2)

library(plotly)


library(rgdal) 
library(leaflet)

# Mapa do Brasil
#install.packages('brazilmaps')
#library(brazilmaps)

#install.packages('rsconnect')
#library(rsconnect)
#rsconnect::deployApp("C:/viproject/coronaBrazil")





options(shiny.sanitize.errors = FALSE)

############################
### preparacao dos dados ###
############################

# dados obtidos partir do site brasil.io:
# 
# https://brasil.io/dataset/covid19/caso

corona <- read.csv(file="https://brasil.io/dataset/covid19/caso?format=csv")
corona <- as_tibble(corona)

# transformar coluna `date` em data
corona <- corona %>% 
    mutate(date = ymd(date))

# transformar a coluna `is_last` em logical
corona <- corona %>% 
    mutate(is_last = ifelse(is_last == "True", TRUE, FALSE))

# remover as linhas com totais por cidade
corona <- corona %>% 
    dplyr::filter(place_type == "state")


arquivo = "./shapes"
shape_br <- readOGR(arquivo, "estados", GDAL1_integer64_policy = TRUE)

shinyServer(function(input, output) {
    output$hourlyPlot <- renderPlotly({
        
        g<-corona %>%
            dplyr::filter(state %in% c("SP", "RJ", "CE", "PA", "MA", "AM", "PE", "BA",  "PB", "ES", "DF", "AL", "MG", "AP", "RS", "RN", "SC", "SE", "RO", "PI", "AC", "PR", "GO", "TO", "RR", "MT", "MS")) %>%
            group_by(date) %>%
            #top_n(1, confirmed) %>%
            #ggplot(mtcars, aes(wt, mpg)) %>%
            ggplot(., aes(x = date, y = confirmed, group = state, colour = state)) +
            labs(x = "Data", y = "Casos Confirmados", colour = "Estado") +
            scale_colour_hue()  +
            geom_line() +
            theme_bw() 

        ggplotly() 
        
    })
    
    output$confirPlot <- renderPlotly({
      if(input$graph=="conf")
      {
        confi<-corona %>%
            group_by(date) %>%
            summarise(confirm = sum(confirmed))
        
        a<-NROW(confi)
        #confi$confirm[a]
        if((confi$confirm[a]) < confi$confirm[a-2] )
        {
            confirmedDe<-corona %>%
                group_by(date) %>%
                dplyr::filter(date!=(confi$date[a])) %>%
                summarise(confirm = sum(confirmed)) %>%
                ggplot(., aes(x = date, y = confirm), colour = "blue") +
                geom_line() +
                labs(x = "Data", y = "Total de Casos Confirmados", colour = "blue") +
                scale_colour_viridis_d() +
                theme_bw() 
            
            ggplotly()
            
        }else{ 
            confirmedDe<-corona %>%
                group_by(date) %>%
                summarise(confirm = sum(confirmed)) %>%
                ggplot(., aes(x = date, y = confirm), colour = "blue") +
                geom_line() +
                labs(x = "Data", y = "Total de Casos Confirmados", colour = "blue") +
                scale_colour_viridis_d() +
                theme_bw() 
            
            ggplotly()
        }
        
      }else if (input$graph=="dea"){
        
        confi<-corona %>%
          group_by(date) %>%
          summarise(confirm = sum(deaths))
        
        a<-NROW(confi)
        #confi$confirm[a]
        
        if((confi$confirm[a]) < confi$confirm[a-2] )
        {
          confirmedDe<-corona %>%
            group_by(date) %>%
            dplyr::filter(date!=(confi$date[a])) %>%
            summarise(confirm = sum(deaths)) %>%
            ggplot(., aes(x = date, y = confirm), colour = "blue") +
            geom_line() +
            labs(x = "Data", y = "Total de Mortos", colour = "blue") +
            scale_colour_viridis_d() +
            theme_bw() 
          
          ggplotly()
          
        }else{ 
          confirmedDe<-corona %>%
            group_by(date) %>%
            summarise(confirm = sum(deaths)) %>%
            ggplot(., aes(x = date, y = confirm), colour = "blue") +
            geom_line() +
            labs(x = "Data", y = "Total de Mortos", colour = "blue") +
            scale_colour_viridis_d() +
            theme_bw() 
          
          ggplotly()
        }
      }
      
    })
    
    output$employTable <- renderDT({
        
        hoje <- ymd(input$Date)
        h<- corona %>%
            dplyr::filter(date == hoje) %>%
            arrange(desc(confirmed)) %>%
            select(date, state, confirmed, deaths, death_rate, confirmed_per_100k_inhabitants) 
        
        datatable(h, options = list(pageLenght = 5)
        ) 
    })
    
    output$map <- renderLeaflet({
      hoje <- ymd(input$Date)
      
     # if(corona$date == hoje)
      #{
     #   hoje <-hoje
      #}else{
       # hoje <-hoje -1
      #}
      
      if(input$variable == "con100"){
        h<-corona %>%
          dplyr::filter(date==hoje) %>%
          select(confirmed_per_100k_inhabitants, state)
       
        pal <- colorNumeric(
          palette = "Paired",
          domain = h$confirmed_per_100k_inhabitants)
      
        mapa <- leaflet(h) %>% addTiles()
        mapa %>% addPolygons(data=shape_br,weight=1,col = ~pal(h$confirmed_per_100k_inhabitants),
                      highlightOptions = highlightOptions(color = "blue", weight = 3, bringToFront = TRUE),
                      label = ~paste(h$state, h$confirmed_per_100k_inhabitants)) %>%
  
                 addLegend("bottomright", pal = pal, values = h$confirmed_per_100k_inhabitants,
                            title = "Infec. 100k",
                            #labFormat = labelFormat(prefix = "$"),
                            opacity = 1)

      }
      else if(input$variable == "dea"){
        
        hoje <- ymd(input$Date)
        h<-corona %>%
          filter(date==hoje) %>%
          select(deaths,state)
        
        pal <- colorNumeric(
          palette = "Accent",
          domain = h$deaths
        )
        
        mapa <- leaflet(h) %>% addTiles()
        mapa %>%
          addPolygons(data=shape_br,weight=1,col = ~pal(h$deaths),
                      highlightOptions = highlightOptions(color = "blue", weight = 3, bringToFront = TRUE),
                      label = ~paste(h$state, h$deaths)) %>%
          
          addLegend("bottomright", pal = pal, values = h$deaths,
                    title = "Mortes",
                    #labFormat = labelFormat(prefix = "$"),
                    opacity = 1)
        
        
      }else if(input$variable == "conf")
      {
        hoje <- ymd(input$Date)
        h<-corona %>%
          filter(date==hoje) %>%
          select(confirmed,state)
        
        pal <- colorNumeric(
          palette = "Accent",
          domain = h$confirmed
        )
        
        mapa <- leaflet(h) %>% addTiles()
        mapa %>%
          addPolygons(data=shape_br,weight=1,col = ~pal(h$confirmed),
                      highlightOptions = highlightOptions(color = "blue", weight = 3,
                                                          bringToFront = TRUE),
                      label = ~paste(h$state, h$confirmed)) %>%
          
          addLegend("bottomright", pal = pal, values = h$confirmed,
                    title = "Confirmados",
                    #labFormat = labelFormat(prefix = "$"),
                    opacity = 1)
        
      }
    })
    
    output$progressBox <- renderValueBox({
        hoje <- ymd(input$Date)
        confirmedDay<-corona %>%
            dplyr::filter(date == hoje) %>%
            summarise(confirm = sum(deaths))
        
        valueBox(
            paste0(confirmedDay), "Mortes Confirmadas", 
            color = "purple"
        )
    })
    
    output$approvalBox <- renderValueBox({
        hoje <- ymd(input$Date)
        confirmedDay<-corona %>%
            dplyr::filter(date == hoje) %>%
            summarise(confirm = sum(deaths))
        
        confirmedDay_yes<-corona %>%
            dplyr::filter(date == (hoje-1)) %>%
            summarise(confirm = sum(deaths))
        if((confirmedDay - confirmedDay_yes)<0)
        {
           valueBox(
                paste0("Ind"), "Mortes/dia",
                color = "blue"
            )
        }else{
            valueBox(
                paste0(confirmedDay - confirmedDay_yes), "Mortes/dia", 
                color = "blue"
            )
        }
    })
    
    output$confirmed <- renderValueBox({
        hoje <- ymd(input$Date)
        confirmed<-corona %>%
            dplyr::filter(date == hoje) %>%
            summarise(confirm = sum(confirmed))
        
        valueBox(
            paste0(confirmed), "Casos Confirmados",
            color = "red"
        )
    })
    
    output$warnmsg <- renderPrint({
      hoje <- ymd(input$Date)
      confirmed<-corona %>%
        dplyr::filter(date == hoje)
      
      a<-NROW(confirmed)
      
      if(a<27){
        print("WARNING MESSAGE - Dados impletos! Verifique a tabela!", col = "red")
      }
      
    })
    
    output$war <- renderPrint({
      hoje <- ymd(input$Date)
      confirmed<-corona %>%
        dplyr::filter(date == hoje)
      
      a<-NROW(confirmed)
      
      if(a<27){
        print("WARNING MESSAGE - Dados imcompletos do dia! Verifique o dia anterior.", col = "red")
      }
      
    })

})
