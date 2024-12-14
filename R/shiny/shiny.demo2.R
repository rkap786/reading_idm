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
  titlePanel("Difficulty Prediction App"),
  sidebarLayout(
    sidebarPanel(
      textInput("passage", "Passage", placeholder = "Enter passage text here"),
      textInput("question", "Question Text", placeholder = "Enter question text here"),
      textInput("distractors", "Distractors", placeholder = "Enter distractors text here"),
      actionButton("predictBtn", "Predict Difficulty")
    ),
    mainPanel(
      h3("Predicted Difficulty"),
      verbatimTextOutput("difficultyOutput")
    )
  )
)


# Get BERT embeddings
# Function to call Python script and get embeddings
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
    args = c("bertembed.py"),    # Python script name
    input = input_data,          # Pass input data as JSON
    stdout = TRUE                # Capture script output
  )
  
  # Convert the comma-separated string back into a numeric vector
  embedding <- as.numeric(unlist(strsplit(result, ",")))
  
  
  # Print the embedding for debugging
  cat("Generated Embedding: \n", embedding, "\n")
  
  return(embedding)
}

# Define server logic
server <- function(input, output) {
  result <- eventReactive(input$predict, {
    # Get embeddings from Python
    embedding <- call_python_script(input$passage, input$question, input$distractors)
    
    # Make prediction using the R model
    prediction <- predict(model, as.data.frame(t(embedding)))  # Transpose to match input format
    return(prediction)
  })
  
  output$difficulty <- renderPrint({
    result()
  })
}

# Run the Shiny App
shinyApp(ui = ui, server = server)
