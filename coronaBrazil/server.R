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
# Para produzir grÃ¡ficos interativos
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

#corona <- read.csv(file="https://brasil.io/dataset/covid19/caso?format=csv")
#corona <- as_tibble(corona)

# transformar coluna `date` em data
#corona <- corona %>%
# mutate(date = ymd(date))

# transformar a coluna `is_last` em logical
#corona <- corona %>%
# mutate(is_last = ifelse(is_last == "True", TRUE, FALSE))

# remover as linhas com totais por cidade
#corona <- corona %>%
# dplyr::filter(place_type == "state")

#NOVO DATASET, DADOS MAIS RECENTES E ATUALIZADOS, MAIS RÁPIDO
#ESTOU TENTANDO MUDAR AS VARIÁVEIS PARA ESSE
#MUDEI OS GRÁFICOS E O MAPA


con <-
  gzcon(url(
    paste(
      "https://data.brasil.io/dataset/covid19/caso_full.csv.gz",
      sep = ""
    )
  ))
txt <- readLines(con)
coronaDeaths <- read.csv(textConnection(txt))

coronaDeaths <- coronaDeaths %>%
  mutate(date = ymd(date))

coronaDeaths <- coronaDeaths %>%
  filter(place_type == "state")


arquivo = "./shapes"
shape_br <-
  readOGR(arquivo, "estados", GDAL1_integer64_policy = TRUE)

shinyServer(function(input, output) {
  
  output$deathsforday <- renderPlotly({
    teste <- coronaDeaths %>%
      group_by(date) %>%
      #dplyr::filter(date!=(confi$date[a])) %>%
      summarise(confirm = sum(new_deaths))
    
    teste <- teste %>%
      #group_by(date) %>%
      #dplyr::filter(date!=(confi$date[a])) %>%
      #summarise(confirm = sum(new_deaths)) %>%
      ggplot(., aes(x = date, y = confirm), colour = "blue") +
      labs(x = "Data", y = "Mortes por dia", colour = "blue") +
      scale_colour_hue() +
      geom_col() +
      theme_bw()
    
    ggplotly()
    
    
  })
  
  output$confirforday <- renderPlotly({
    teste <- coronaDeaths %>%
      group_by(date) %>%
      #dplyr::filter(date!=(confi$date[a])) %>%
      summarise(confirm = sum(new_confirmed))
    
    teste <- teste %>%
      #group_by(date) %>%
      #dplyr::filter(date!=(confi$date[a])) %>%
      #summarise(confirm = sum(new_deaths)) %>%
      ggplot(., aes(x = date, y = confirm), colour = "blue") +
      labs(x = "Data", y = "Confirmados por dia", colour = "blue") +
      scale_colour_hue() +
      geom_col() +
      theme_bw()
    
    ggplotly()
    
  })
  
  output$hourlyPlot <- renderPlotly({
    if (input$graph2 == "conf2") {
      g <- coronaDeaths %>%
        dplyr::filter(
          state %in% c(
            "SP",
            "RJ",
            "CE",
            "PA",
            "MA",
            "AM",
            "PE",
            "BA",
            "PB",
            "ES",
            "DF",
            "AL",
            "MG",
            "AP",
            "RS",
            "RN",
            "SC",
            "SE",
            "RO",
            "PI",
            "AC",
            "PR",
            "GO",
            "TO",
            "RR",
            "MT",
            "MS"
          )
        ) %>%
        group_by(date) %>%
        #top_n(1, confirmed) %>%
        #ggplot(mtcars, aes(wt, mpg)) %>%
        ggplot(.,
               aes(
                 x = date,
                 y = last_available_confirmed,
                 group = state,
                 colour = state
               )) +
        labs(x = "Data",
             y = "Casos Confirmados",
             colour = "Estado") +
        scale_colour_hue()  +
        geom_line() +
        theme_bw()
      
      ggplotly()
      
      
    }
    else if (input$graph2 == "dea2") {
      g <- coronaDeaths %>%
        dplyr::filter(
          state %in% c(
            "SP",
            "RJ",
            "CE",
            "PA",
            "MA",
            "AM",
            "PE",
            "BA",
            "PB",
            "ES",
            "DF",
            "AL",
            "MG",
            "AP",
            "RS",
            "RN",
            "SC",
            "SE",
            "RO",
            "PI",
            "AC",
            "PR",
            "GO",
            "TO",
            "RR",
            "MT",
            "MS"
          )
        ) %>%
        group_by(date) %>%
        #top_n(1, confirmed) %>%
        #ggplot(mtcars, aes(wt, mpg)) %>%
        ggplot(.,
               aes(
                 x = date,
                 y = last_available_deaths,
                 group = state,
                 colour = state
               )) +
        labs(x = "Data",
             y = "Mortes confirmadas",
             colour = "Estado") +
        scale_colour_hue()  +
        geom_line() +
        theme_bw()
      
      ggplotly()
    }
  })
  
  output$confirPlot <- renderPlotly({
    if (input$graph == "conf")
    {
      confi <- coronaDeaths %>%
        group_by(date) %>%
        summarise(confirm = sum(last_available_confirmed))
      
      a <- NROW(confi)
      #confi$confirm[a]
      if ((confi$confirm[a]) < confi$confirm[a - 2])
      {
        confirmedDe <- coronaDeaths %>%
          group_by(date) %>%
          dplyr::filter(date != (confi$date[a])) %>%
          summarise(confirm = sum(last_available_confirmed)) %>%
          ggplot(., aes(x = date, y = confirm), colour = "blue") +
          geom_line() +
          labs(x = "Data",
               y = "Total de Casos Confirmados",
               colour = "blue") +
          scale_colour_hue() +
          theme_bw()
        
        ggplotly()
        
      } else{
        confirmedDe <- coronaDeaths %>%
          group_by(date) %>%
          summarise(confirm = sum(last_available_confirmed)) %>%
          ggplot(., aes(x = date, y = confirm), colour = "blue") +
          geom_line() +
          labs(x = "Data",
               y = "Total de Casos Confirmados",
               colour = "blue") +
          scale_colour_hue() +
          theme_bw()
        
        ggplotly()
      }
      
    } else if (input$graph == "dea") {
      confi <- coronaDeaths %>%
        group_by(date) %>%
        summarise(confirm = sum(last_available_deaths))
      
      a <- NROW(confi)
      #confi$confirm[a]
      
      if ((confi$confirm[a]) < confi$confirm[a - 2])
      {
        confirmedDe <- coronaDeaths %>%
          group_by(date) %>%
          dplyr::filter(date != (confi$date[a])) %>%
          summarise(confirm = sum(last_available_deaths)) %>%
          ggplot(., aes(x = date, y = confirm), colour = "blue") +
          geom_line() +
          labs(x = "Data",
               y = "Total de Mortos",
               colour = "blue") +
          #scale_colour_viridis_d() +
          theme_bw()
        
        ggplotly()
        
      } else{
        confirmedDe <- coronaDeaths %>%
          group_by(date) %>%
          summarise(confirm = sum(last_available_deaths)) %>%
          ggplot(., aes(x = date, y = confirm), colour = "blue") +
          geom_line() +
          labs(x = "Data",
               y = "Total de Mortos",
               colour = "blue") +
          #scale_colour_viridis_d() +
          theme_bw()
        
        ggplotly()
      }
    }
    
  })
  
  output$employTable <- renderDT({
    hoje <- ymd(input$Date)
    h <- coronaDeaths %>%
      dplyr::filter(date == hoje) %>%
      arrange(desc(last_available_confirmed)) %>%
      select(
        date,
        state,
        last_available_confirmed,
        last_available_deaths,
        last_available_death_rate,
        last_available_confirmed_per_100k_inhabitants
      )
    
    datatable(h, options = list(pageLenght = 5))
  })
  
  output$map <- renderLeaflet({
    hoje <- ymd(input$Date)
    
    if (input$variable == "con100") {
      h <- coronaDeaths %>%
        dplyr::filter(date == hoje) %>%
        select(last_available_confirmed_per_100k_inhabitants, state)
      pal <- colorNumeric(
        palette = "Paired",
        domain = h$last_available_confirmed_per_100k_inhabitants
      )
      
      mapa <- leaflet(h) %>% addTiles()
      mapa %>% addPolygons(
        data = shape_br,
        weight = 1,
        col = ~ pal(h$last_available_confirmed_per_100k_inhabitants),
        highlightOptions = highlightOptions(
          color = "blue",
          weight = 3,
          bringToFront = TRUE
        ),
        label = ~ paste(
          h$state,
          h$last_available_confirmed_per_100k_inhabitants
        )
      ) %>%
        
        addLegend(
          "bottomright",
          pal = pal,
          values = h$last_available_confirmed_per_100k_inhabitants,
          title = "Infec. 100k",
          #labFormat = labelFormat(prefix = "$"),
          opacity = 1
        )
      
    }
    else if (input$variable == "dea") {
      hoje <- ymd(input$Date)
      h <- coronaDeaths %>%
        filter(date == hoje) %>%
        select(last_available_deaths, state)
      
      pal <- colorNumeric(palette = "Accent",
                          domain = h$last_available_deaths)
      
      mapa <- leaflet(h) %>% addTiles()
      mapa %>%
        addPolygons(
          data = shape_br,
          weight = 1,
          col = ~ pal(h$last_available_deaths),
          highlightOptions = highlightOptions(
            color = "blue",
            weight = 3,
            bringToFront = TRUE
          ),
          label = ~ paste(h$state, h$last_available_deaths)
        ) %>%
        
        addLegend(
          "bottomright",
          pal = pal,
          values = h$last_available_deaths,
          title = "Mortes",
          #labFormat = labelFormat(prefix = "$"),
          opacity = 1
        )
      
      
    } else if (input$variable == "conf")
    {
      hoje <- ymd(input$Date)
      
      h <- coronaDeaths %>%
        filter(date == hoje) %>%
        select(last_available_confirmed, state)
      
      pal <- colorNumeric(palette = "Accent",
                          domain = h$last_available_confirmed)
      
      mapa <- leaflet(h) %>% addTiles()
      mapa %>%
        addPolygons(
          data = shape_br,
          weight = 1,
          col = ~ pal(h$last_available_confirmed),
          highlightOptions = highlightOptions(
            color = "blue",
            weight = 3,
            bringToFront = TRUE
          ),
          label = ~ paste(h$state, h$last_available_confirmed)
        ) %>%
        
        addLegend(
          "bottomright",
          pal = pal,
          values = h$last_available_confirmed,
          title = "Confirmados",
          #labFormat = labelFormat(prefix = "$"),
          opacity = 1
        )
      
    }
  })
  
  output$progressBox <- renderValueBox({
    hoje <- ymd(input$Date)
    confirmedDay <- coronaDeaths %>%
      dplyr::filter(date == hoje) %>%
      summarise(confirm = sum(last_available_deaths))
    
    valueBox(paste0(confirmedDay), "Mortes Confirmadas",
             color = "purple", icon = icon("users"))
  })
  
  output$approvalBox <- renderValueBox({
    hoje <- ymd(input$Date)
    
    confirmedDay <- coronaDeaths %>%
      dplyr::filter(date == hoje) %>%
      summarise(confirm = sum(new_deaths))
    
    valueBox(paste0(confirmedDay), "Mortes no dia",
             color = "blue", icon = icon("skull"))
    
  })
  
  output$confirmed <- renderValueBox({
    hoje <- ymd(input$Date)
    
    confirmed <- coronaDeaths %>%
      dplyr::filter(date == hoje) %>%
      summarise(confirm = sum(last_available_confirmed))
    
    valueBox(paste0(confirmed), "Casos Confirmados",
             color = "red", icon = icon("heartbeat"))
  })
  
  output$warnmsg <- renderPrint({
    hoje <- ymd(input$Date)
    confirmed <- coronaDeaths %>%
      dplyr::filter(date == hoje)
    
    a <- NROW(confirmed)
    
    if (a < 27) {
      print("WARNING MESSAGE - Dados impletos! Verifique a tabela!",
            col = "red")
    }
    
  })
  
  output$war <- renderPrint({
    hoje <- ymd(input$Date)
    confirmed <- coronaDeaths %>%
      dplyr::filter(date == hoje)
    
    a <- NROW(confirmed)
    
    if (a < 27) {
      print("WARNING MESSAGE - Dados imcompletos do dia! Verifique o dia anterior.",
            col = "red")
    }
    
  })
  
})
