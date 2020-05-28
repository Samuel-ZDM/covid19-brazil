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



options(shiny.sanitize.errors = FALSE)



shinyUI( 
        dashboardPage(dashboardHeader(title = "COVID-19 BRAZIL"),
                      
                      dashboardSidebar(dateInput("Date", label = "Input Date", 
                                                 value = Sys.Date())
                      ),
                      
                      dashboardBody(
                       mainPanel(tabsetPanel(type = "tabs",
                                                          tabPanel("Menu",
                                                                   fluidRow(column(width = 12, offset =0,
                                                                     infoBoxOutput("confirmed"),
                                                                     infoBoxOutput("progressBox"),
                                                                     infoBoxOutput("approvalBox"),
                                                                     
                                                                            
                                                                     
                                                                   )
                                                                   ),
                                                                   
                                                                   
                                                                   h1("COVID-19 NO BRASIL", align = "center"),
                                                                   p("Esta aplicação visa mostrar a evolução e
                                                                    o atual estado do coronavirus no Brasil."),
                                                                   p("Os dados são obtidos do seguinte data set:",
                                                                     span("https://brasil.io/home/", style = "color:blue")),
                                                                   p("Informações sobre o coronavírus no Brasil:",
                                                                     span("https://coronavirus.saude.gov.br", style = "color:blue")),
                                                                   p("Plataforma do Governo com dados bem detalhados sobre infectados, 
                                                                    pessoas hospitalizadas e insumos utilizados:",
                                                                     span("https://covid.saude.gov.br", style = "color:blue")),
                                                                   h4("Os dados podem estar incompletos. Isso depende da atualização do banco de dados.
                                                                     Eles estarão incompletos quando o infobox Deaths Day estiver IND."),
                                                                   h4("Escolha a data no sidebar para verificar a evolução da doença no mapa, 
                                                                       na tabela e nos infobox, até a data escolhida.")
                                                                    
                                                                   
                                                          ),
                                                          tabPanel( "All",
                                                                   
                                                                    fluidRow( textOutput("war"),
                                                                              column(width = 3, offset = 1,
                                                                                      selectInput("graph", "Variable:",
                                                                                                  c("Confirmed" = "conf",
                                                                                                    "Death" = "dea"
                                                                                                        )) ),
                                                                               plotlyOutput("confirPlot", height = "50%"))
                                                                            ),
                                                          tabPanel("Plot",
                                                                   plotlyOutput("hourlyPlot",height = "80%")
                                                          ),
                                             tabPanel( "Map", 
                                                       fluidRow(column(width = 9, textOutput("warnmsg"),
                                                                       leafletOutput("map")),
                                                                column(width = 3,
                                                                       selectInput("variable", "Variable:",
                                                                                   c("Confirmed100k" = "con100",
                                                                                     "Death" = "dea",
                                                                                     "Confirmed" = "conf")),
                                                                       ),
                                                                
                                                                                 
                                                                
                                                                ),
                                                       ),
                                                          tabPanel("Table", DTOutput("employTable"))))
                                    
                                   
                                    
                      )
))
