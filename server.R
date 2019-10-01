library(shiny)
library(shinyjs)
library(dplyr)
library(DT)
library(ggplot2)
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
    if(!is.null(values$source_data)) {
      NULL
    } else {
      "Your uploaded data will appear here"
    }
  })

  output$control_chart_help <- renderText({
    if(inherits(control_chart(), 'try-error')) {
      "Your chart output will appear here"
    } else {
      NULL
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
  
  values <- reactiveValues(source_data = NULL)
  
  observeEvent(input$source_file, {

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
    
    session$sendCustomMessage("enable_next", "file_next")
    
    values$source_data <- df
    
  })
  
  output$file_preview <- renderDT({
    
    values$source_data
    
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
  
  observeEvent(values$source_data, {
    
    x <- colnames(values$source_data)
    
    updateSelectInput(session, "x_axis", choices = x, selected = x[1])
    updateSelectInput(session, "y_axis", choices = x, selected = x[2])
    updateSelectInput(session, "n", choices = c(NA, x), selected = NA)
    
  })

  control_chart <- reactive({
    
    df <- values$source_data
    
    n <- input$n
    
    if(is.na(n)) {
      n <- NULL
    } else {
      n <- df[[n]]
    }
    
    try(qic(df[[input$x_axis]], df[[input$y_axis]], n,
        chart = input$chart_type, title = input$main_title,
        xlab = ifelse(input$x_title == "", input$x_axis, input$x_title),
        ylab = ifelse(input$y_title == "", input$y_title, input$y_title)),
        silent = TRUE)
    
  })
  
  output$download_chart <- downloadHandler(
    filename = function() {
      paste0("control_chart_", Sys.Date(), ".png")
    },
    content = function(file) {
      
      if(input$size_units == 'pixels') {
        width <- input$chart_width / 300
        height <- input$chart_height / 300
        units <- "in"
      } else {
        width = input$chart_width
        height = input$chart_height
        units <- input$size_units
      }
      
      ggplot2::ggsave(file, plot = control_chart(), device = "png", width = width, height = height, units = units)
      
    }
  )
  
  output$control_chart <- renderPlot({
    if(!inherits(control_chart(), 'try-error')) {
      control_chart()
    }
  })
  
  observeEvent(input$restart, {
    
    values$source_data <- NULL
    reset('source_file')
    
  })
  
}
