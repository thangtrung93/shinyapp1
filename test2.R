

library(shiny)
library(ggplot2)
library(RMySQL)
library(dbConnect)
library(DBI)
library(pitchRx)

mydb = dbConnect(MySQL(), user='root', password='17081993', dbname='world', host='localhost')
dbListTables(mydb)
myQuery <- "select * from countrylanguage"
df <- dbGetQuery(mydb, myQuery)

ui <- shinyUI(fluidPage(sidebarLayout(
  sidebarPanel(uiOutput("slider")),
  mainPanel(plotOutput("plot"))
)))

server <- shinyServer(function(input, output, session){
  autoInvalidate <- reactiveTimer(50000, session)
  observe({
    df <- dbGetQuery(mydb, myQuery)
    autoInvalidate()
    print(unique(df$IsOfficial))
    
    output$slider <- renderUI({
      autoInvalidate()
      choose_region = unique(df$IsOfficial)
      selectInput("region", "Choose region", choose_region)
    })
    df1 <- reactive(df[df$IsOfficial %in% input$region, ])
    output$plot <- renderPlot({
      autoInvalidate()
      ggplot(df1(), aes(x = df1()$CountryCode,y = df1()$Percentage)) + geom_bar(stat = 'identity', fill='steelblue') +
        ggtitle("Volume and Delivery LT")
  })
})
})
shinyApp(ui, server)

