library(shiny)

server <- function(input, output) { 
  
  output$contents <- renderDataTable({
    
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
  
  }
