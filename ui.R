library(shinydashboard)

dashboardPage(  dashboardHeader(title = "Control Charts"),
                dashboardSidebar(
                  sidebarMenu(
                    menuItem("Upload Data", tabName = "upload", icon = icon("upload")),
                    menuItem("Data Typing", tabName = "selection", icon = icon("project-diagram")),
                    menuItem("Control Chart", tabName = "chart", icon = icon("chart-line"))
                  )
                ),
                dashboardBody(
                  tabItems(
                    # First tab content
                    tabItem(tabName = "upload",
                            fluidRow(
                              box(title = "Upload CSV File", width = 4,
                                  fileInput("file1", "",
                                            multiple = FALSE,
                                            accept = c("text/csv",
                                                       "text/comma-separated-values,text/plain",
                                                       ".csv")))
                
                            ),
                            fluidRow(
                              box(title = "File Preview", width = 12,
                                  dataTableOutput("contents")
                              )
                            )
                    ),
                    
                    # Second tab content
                    tabItem(tabName = "selection",
                            fluidRow(
                              box(title = "Type of Data", width = 4,
                                  selectInput("type", label = "",
                                              choices = c("Count or Classification",
                                                          "Continuous")),
                                  conditionalPanel(
                                    condition = "input.type == 'Count or Classification'",
                                    p("Whole numbers that are counted, not measured.")
                                    
                                  ),
                                  conditionalPanel(
                                    condition = "input.type == 'Continuous'",
                                    p("Measurement on some scale like time, money, throughput, ect.")
                                  )
                                  ),
                              conditionalPanel(
                                condition = "input.type == 'Count or Classification'",
                                box(title = "Nonconformites", width = 4,
                                    selectInput("nonconformities", label = "",
                                                choices = c("Count", "Classification")),
                                    conditionalPanel(
                                      condition = "input.nonconformities == 'Count'",
                                      p("Whole number of errors per subgroup. Numerator can be greater than denominator (opportunities).")
                                    ),
                                    conditionalPanel(
                                      condition = "input.nonconformities == 'Classification'",
                                      p("Pass/Fail. Numerator can't be greater than denominator (n).")
                                    ))
                                
                              ),
                              conditionalPanel(
                                condition = "input.type == 'Continuous'",
                                box(title = "Subgroups", width = 4,
                                    selectInput("subgroups", label = "",
                                                choices = c("Single Observation",
                                                            "Multiple Values")),
                                    conditionalPanel(
                                      condition = "input.subgroups == 'Single Observation'",
                                      p("Each subgroup is composed of a single observation.")
                                    ),
                                    conditionalPanel(
                                      condition = "input.subgroups == 'Multiple Values'",
                                      p("Each subgroup is composed of multiple values.")
                                    ))
                              ),
                              conditionalPanel(
                                condition = "input.type == 'Count or Classification'",
                                box(title = "Area of Opportunity", width = 4,
                                    selectInput("opportunity", label = "",
                                                choices = c("Equal", "Unequal")),
                                    conditionalPanel(
                                      condition = "input.opportunity == 'Equal'",
                                      p("The denominator (n) is always the same.")
                                    ),
                                    conditionalPanel(
                                      condition = "input.opportunity == 'Unequal'",
                                      p("The denominator (n) changes.")
                                    ))
                              )
                              
                            )
                    ),
                    
                    tabItem(tabName = "chart",
                            fluidRow(
                              box(title = "Chart Type", width = 4,
                                  uiOutput("chart_choices")
                                 )
                              ),
                            fluidRow(
                              box(title = "X-Axis", width = 4,
                                  uiOutput("x_axis")
                                  ),
                              box(title = "Y-Axis", width = 4,
                                  uiOutput("y_axis")
                                  ),
                              box(title = "N", width = 4,
                                  uiOutput("n")
                                  )
                              ),
                            fluidRow(
                                box(title = "Control Chart", width = 12,
                                    plotOutput("chart")
                                )
                              )
                            )
                            
                            
                            
                    )
                    
))