library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinydashboardPlus)

addHelpBlock <- function(x, help_text = "") {
  
  id <- x$children[[1]]$attribs$`for`
  
  help_block <- tags$span(id = paste0(id, "_help_block"), class = 'shiny-text-output help-block', help_text)
  
  x$children[[length(x$children) + 1]] <- help_block
  
  return(x)
  
}

dashboardPage(
  dashboardHeaderPlus(title = "Control Charts"),
                dashboardSidebar(disable = TRUE),
                dashboardBody(
                  fluidRow(
                    column(width = 3,
                      box(width = NULL, title = tagList(icon("upload"), "Upload Data"), 
                          collapsible = TRUE,
                          tags$p("Use this Upload Data box to upload your dataset. The file must be a flat comma separated (.csv) file with headers."),
                          fileInput("source_file", "", multiple = FALSE,
                            accept = c("text/csv",
                                       "text/comma-separated-values,text/plain",
                                       ".csv")
                          )
                      ),
                      box(width = NULL, title = tagList(icon("flowchart"), "Data Typing"), collapsible = TRUE, collapsed = FALSE,
                        tags$p("This Data Typing box allows you to categorize the type of data you are uploading so that the right control chart can be selected. The selections are based on the flow chart on page 151 of The Health Care Data Guide."),
                        addHelpBlock(selectizeInput("data_type", label = "Type of Data",
                                                                 choices = c("Count or Classification",
                                                                             "Continuous")), "Testing"),
                        conditionalPanel(
                          condition = "input.data_type == 'Count or Classification'",
                          addHelpBlock(selectInput("nonconformities", label = "Nonconformities",
                            choices = c("Count", "Classification")
                          )),
                          addHelpBlock(selectInput("opportunity", label = "Area of Opportunity",
                            choices = c("Equal", "Unequal")
                          ))
                        ),
                        conditionalPanel(
                          condition = "input.data_type == 'Continuous'",
                          addHelpBlock(selectInput("subgroups", label = "Subgroups",
                            choices = c("Single Observation", "Multiple Values")
                          ))
                        )
                      ),
                      box(width = NULL, title = tagList(icon("chart"), "Control Chart Options"), collapsible = TRUE, collapsed = FALSE,
                        tags$p("Once your data is uploaded and it's type is categorized, the Control Chart sidebar item can be used to create a control chart that can be downloaded."),
                        addHelpBlock(selectInput("chart_type", label = "Chart Type", choices = c())),
                        addHelpBlock(selectInput("x_axis", label = "X-Axis", choices = c()), "Choose a column in the dataset for the x-axis"),
                        addHelpBlock(selectInput("y_axis", label = "Y-Axis", choices = c()), "Choose a column in the dataset for the y-axis"),
                        addHelpBlock(selectInput("n", label = "N", choices = c()), "Subgroup sizes (denominator)")
                      )
                    ),
                    column(width = 9,
                      tabBox(width = NULL,
                        tabPanel("File Preview",
                          tags$p(textOutput("file_preview_help")),
                          DT::DTOutput("file_preview")         
                        ),
                        tabPanel("Control Chart",
                          tags$p(textOutput("control_chart_help")),
                          plotOutput("control_chart")         
                        )
                      )       
                    )
                  )
                    
))
