#library(devtools)
#install_github('tagteam/Publish')

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

#library(rgdal) 
library(leaflet)

# Mapa do Brasil
#install.packages('brazilmaps')
#library(brazilmaps)

#install.packages('rsconnect')
#library(rsconnect)
#rsconnect::deployApp("C:/viproject/coronaBrazil")

#library(conflicted)
#conflict_prefer("filter", "sf")



##options(shiny.sanitize.errors = FALSE)


dashboardPage(
  dashboardHeader(title = "COVID-19 BRAZIL"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Sobre", tabName = "sobre"),
      menuItem("Total", tabName = "total"),
      menuItem("Estados", tabName = "estados"),
      menuItem("Mapa", tabName = "mapa"),
      menuItem("Dados", tabName = "dados"),
      
      dateInput("Date", label = "Data", value = Sys.Date())
    
    )),
  
   dashboardBody(
    tabItems(
     tabItem("sobre", fluidRow(column(width = 12, offset =0,
                      tags$br(),                    
                      infoBoxOutput("confirmed"),
                      infoBoxOutput("progressBox"),
                      infoBoxOutput("approvalBox"),)),
                  
                      h1("COVID-19 NO BRASIL", align = "center"),
                      p("Esta aplicação visa mostrar a evolução e o atual estado do coronavírus no Brasil."),
                      p("Os dados são obtidos do seguinte dataset:",
                        tags$a(href="https://brasil.io/home/", "https://brasil.io/home/", style = "color:blue")),
                      p("Informações sobre o coronavírus no Brasil:",
                        tags$a(href="https://coronavirus.saude.gov.br", "https://coronavirus.saude.gov.br", style = "color:blue")),
                      p("Plataforma do Governo com dados bem detalhados sobre infectados, pessoas hospitalizadas e insumos utilizados:",
                        tags$a(href="https://covid.saude.gov.br", "https://covid.saude.gov.br", style = "color:blue")),
                       
                      h4("Os dados podem estar incompletos. Isso depende da atualização do banco de dados."),
                      h4("Escolha a data no sidebar para verificar a evolução da doença no mapa, na tabela e nos infobox, até a data escolhida.")),
      
     tabItem("total", fluidRow( #textOutput("war"),
                      column(width = 5, offset = 2,
                      selectInput("graph", "Variable:", c("Confirmados" = "conf","Mortos" = "dea"))),
                      plotlyOutput("confirPlot", width = "800px", height = "600px"))),
      
     tabItem("estados", fluidRow( #textOutput("war2"),
                        column(width = 5, offset = 2,
                        selectInput("graph2", "Variable:",c("Confirmados" = "conf2","Mortos" = "dea2"))), 
                        plotlyOutput("hourlyPlot", width = "800px", height = "600px")),),
      
     tabItem("mapa", fluidRow(column(width = 9, 
                     textOutput("warnmsg"),
                     leafletOutput("map", width = "800px", height = "600px")),
                     column(width = 5,
                     selectInput("variable", "Variaveis:",c("Confirmados/100000" = "con100","Mortes" = "dea","Confirmados" = "conf")),),),),
     
     tabItem("dados", DTOutput("employTable")))))
