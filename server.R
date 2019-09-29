library(shiny)
library(dplyr)
library(DT)
library(qicharts2)

server <- function(input, output, session) { 
  
  ###### Various Help Block Text Generators ######
  
  output$data_type_help_block <- renderText({
    
    if(input$data_type == "Count or Classification") {
      "Whole numbers that are counted, not measured."
    } else if(input$data_type == "Continuous") {
      "Measurement on some scale like time, money, throughput, etc."
    }
    
  })
  
  output$file_preview_help <- renderText({
    if(!is.null(input$source_file)) {
      "This tab shows the currently uploaded source data."
    }
  })
  
  output$nonconformities_help_block <- renderText({
    
    if(input$nonconformities == "Count") {
      "Whole number of errors per subgroup. Numerator can be greater than denominator (opportunities)."
    } else if(input$nonconformities == "Continuous") {
      "Pass/Fail. Numerator can't be greater than denominator (n)."
    }
    
  })

  output$opportunity_help_block <- renderText({
    
    if(input$opportunity == "Equal") {
      "The denominator (n) is always the same."
    } else if(input$opportunity == "Unequal") {
      "The denominator (n) changes."
    }
    
  })

  output$subgroups_help_block <- renderText({
    
    if(input$subgroups == "Single Observation") {
      "Each subgroup is composed of a single observation."
    } else if(input$subgroups == "Multiple Values") {
      "Each subgroup is composed of multiple values."
    }
    
  })
  
  ###### File Upload ######
  
  get_file_contents <- reactive({
    
    req(input$source_file)
    
    tryCatch(
      {
        df <- readr::read_csv(input$source_file$datapath)
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
      }
    )
    
    df
    
  })
  
  output$file_preview <- renderDT({
    
    get_file_contents()
    
  })
  
  ###### Control Chart Options ######
  
  observeEvent(input$data_type, {
    
    type_ <- input$data_type

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
    
    updateSelectInput(session, "chart_type", choices = chart_choices$chart)
    
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
  
  output$control_chart <- renderPlot({
    
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
