# Load required libraries
library(shiny)
library(jsonlite)  # For JSON conversion
library(reticulate) # For calling Python scripts
setwd('/Users/radhika/Library/CloudStorage/GoogleDrive-rkap786@stanford.edu/My Drive/0. Projects - Stanford/Item generation/Code/reading_idm/R/shiny')

# Use the system's Python executable or configure Python path
use_python("/usr/bin/python3")  # Adjust to your Python path if needed
model= readRDS("/Users/radhika/Documents/shiny/model.rds")

# Define UI for the Shiny application
ui <- fluidPage(
  titlePanel("Input to Python App"),
  sidebarLayout(
    sidebarPanel(
      textInput("passage", "Passage", placeholder = "Enter passage text here"),
      textInput("question", "Question Text", placeholder = "Enter question text here"),
      textInput("distractors", "Distractors", placeholder = "Enter distractors text here"),
      actionButton("printBtn", "Print Combined Input")
    ),
    mainPanel(
      h3("Reading comprehension difficulty prediction using BERT embeddings"),
      verbatimTextOutput("inputsOutput")
    )
  )
)

# Function to call Python script and get combined input
call_python_script <- function(passage, question, distractors) {
  # Prepare input data as JSON
  input_data <- toJSON(list(
    Passage = passage,
    QuestionText = question,
    Distractors = distractors
  ), auto_unbox = TRUE)
  
  
  # Call the Python script and capture the output
  result <- system2(
    command = "python3",         # Python executable
    args = c("bertembedtoy.py"),    # Python script name
    input = input_data,          # Pass input data as JSON
    stdout = TRUE                # Capture script output
  )
  
  # Return the result from Python
  #embedding_df <- read.csv(text = paste(result, collapse = "\n"))
  return(result)
  
}


# Read the CSV data into a dataframe
  #embedding_df <- read.csv(text =result)
# Define server logic
server <- function(input, output) {
  # Reactive value to store predictions
  predictions <- reactiveVal(NULL)
  #df <- reactiveVal(data.frame())
  
  # Event triggered when the button is clicked
  observeEvent(input$printBtn, {
    # Call the Python script and capture the dataframe
    python_output <- call_python_script(input$passage, input$question, input$distractors)
    result_vector <- as.numeric(unlist(strsplit(python_output, ",")))
    result_vector= as.data.frame(t(result_vector) )
    names(result_vector) = paste0("embed.bert", 1:768)
    model_predictions= predict(model, result_vector)
    predictions(model_predictions)
    
    #embedding_df <- read.csv(text = python_output)
    # Convert the Python output (CSV format) into a dataframe
    # Generate predictions using your model
    #embedding_df= as.vector(embedding_df)
    #model_predictions <- predict(model, embedding_df)  # Replace `model` with your trained model object
    # Update the reactive variable with predictions
    
  })
  
  # Output predictions to the UI (or use it elsewhere)
  output$inputsOutput <- renderPrint({
    predictions()
  })
}

# server <- function(input, output) {
#   # Reactive object to store the dataframe
#   df <- data.frame()
#   result <- eventReactive(input$printBtn, {
#     # Call the Python script to get the combined input
#     embedding_df <- call_python_script(input$passage, input$question, input$distractors)
#     df=embedding_df
#     return(embedding_df)
#   })
#   
#   # Render the combined input from Python
#   output$inputsOutput <- renderPrint({
#     #result()
#     df
#   })
# }

# Run the Shiny App
shinyApp(ui = ui, server = server)
