library(shiny)
library(dplyr)
library(qicharts2)

server <- function(input, output) { 
  
  get_file_contents <- reactive({
    
    req(input$file1)
    
    tryCatch(
      {
        df <- readr::read_csv(input$file1$datapath)
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
      }
    )
    
    df
    
  })
  
  output$contents <- renderDataTable({
    
    get_file_contents()
    
  })
  
  output$chart_choices <- renderUI({
    
    type_ <- input$type

    type_ <- ifelse(type_ == "Count or Classification",
                    input$nonconformities,
                    type_)

    opportunity_ <- ifelse(type_ == "Count",
                           input$opportunity,
                           NA_character_)

    subgroup_ <- ifelse(type_ == "Continuous",
                        input$subgroups,
                        NA_character_)
    
    filter_table <- tibble::tibble(type = type_,
                                   opportunity = opportunity_,
                                   subgroup = subgroup_)

    chart_choices <- charts %>% 
      dplyr::semi_join(filter_table, c("type", "opportunity", "subgroup"))
    
    selectInput("chart", label = "", choices = chart_choices$chart)

  })
  
  output$x_axis <- renderUI({
    df <- get_file_contents()
    
    selectInput("x_axis", label = "", choices = names(df))
  })
  
  output$y_axis <- renderUI({
    df <- get_file_contents()
    
    selectInput("y_axis", label = "", choices = names(df), names(df)[2])
  })
  
  output$n <- renderUI({
    df <- get_file_contents()
    
    selectInput("n", label = "", choices = c(NA, names(df)), selected = NA)
  })
  
  output$chart <- renderPlot({
    df <- get_file_contents()
    
    n <- input$n
    
    if(is.na(n)) {
      n <- NULL
    } else {
      n <- df[[n]]
    }
    
    qic(df[[input$x_axis]], df[[input$y_axis]], n,
        chart = input$chart)
  })
  
}
