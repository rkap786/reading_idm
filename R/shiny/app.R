# Load required libraries
library(shiny)
library(jsonlite)  # For JSON conversion
library(reticulate) # For calling Python scripts
library(caret)
library(dplyr)

setwd('/Users/radhika/Library/CloudStorage/GoogleDrive-rkap786@stanford.edu/My Drive/0. Projects - Stanford/Item generation/Code/reading_idm/R/shiny')

# Use the system's Python executable or configure Python path
#use_virtualenv("venv")
use_python("/usr/bin/python3")  # Adjust to your Python path if needed
model= readRDS("model.rds")

# Sample data table to display
difficulty_table <- data.frame(
  Grade = c("Grade 3", "Grade 4", "Grade 5", "Grade 6", "Grade 7", "Grade 8"),
  `Mean Grade-Level Difficulty` = c(0.3, 0.431, 0.533, 0.611, 0.656, 0.7)
)

# Define UI for the Shiny application
ui <- fluidPage(
  titlePanel("Reading comprehension difficulty prediction using BERT embeddings"),
  fluidRow(
    column(
      width = 12,
      h4("How does this work?"),
      p("This app predicts average difficulty for an item. Difficulty can be interpreted using the table below. As the table shows, difficulty increases with grade level.
        For example, an item of difficulty 0.3 is of average difficulty for Grade 3, an item of difficulty 0.4 is of average difficulty for Grade 4, and so on. Note that as difficulty increases, probability of correct answer reduces."),
      
      # Display the table as a rendered output
      h5(""),
      tableOutput("difficultyTable"),
      
      # Add external link for NWEA norms
      p("Difficulty outputs are on a linear scale. The scale is defined to have mean difficulty of 0.3 at Grade 3 and mean difficulty 0.7 at Grade 8. This scale is based on grade level growth norms reported by ",
        a("NWEA MAP Spring 2020 Reading Student Achievement Norms", 
          href = "https://www.nwea.org/uploads/MAP-Growth-Normative-Data-Overview.pdf", target = "_blank"))
    )
  ),
  
  # App UI elements
  sidebarLayout(
    sidebarPanel(
      width = 12,
      textInput("passage", "Passage", placeholder = "Enter passage text here"),
      textInput("question", "Question Text", placeholder = "Enter question text here"),
      textInput("correctAnswer", "Correct Answer", placeholder = "Enter the correct answer here"),
      
      # Numeric input to ask how many incorrect options (distractors)
      numericInput("numDistractors", "Number of Incorrect Options:", value = 1, min = 1, max = 10),
      
      # Dynamic UI for the distractors
      uiOutput("distractorsInputs"),
      
      actionButton("printBtn", "Estimate difficulty")
    ),
    
    mainPanel(
      h3("Estimated difficulty"),
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
server <- function(input, output, session) {
  # Reactive value to store predictions
  predictions <- reactiveVal(NULL)
  
  #df <- reactiveVal(data.frame())
  
  # Render the difficulty table in the UI
  output$difficultyTable <- renderTable({
    difficulty_table
  }, rownames = FALSE)  # Avoid showing rownames in the table
  
  # Dynamically generate text inputs for distractors based on user input
  output$distractorsInputs <- renderUI({
    n <- input$numDistractors  # Get the number of distractors
    if (is.null(n) || n <= 0) return(NULL)  # No inputs if value is invalid
    
    # Generate textInput fields dynamically
    lapply(1:n, function(i) {
      textInput(inputId = paste0("distractor", i), 
                label = paste("Wrong answer", i), 
                placeholder = paste("Enter wrong answer", i))
    })
  })
  
  
  # Event triggered when the button is clicked
  observeEvent(input$printBtn, {
    distractors <- c(sapply(1:input$numDistractors, function(i) {input[[paste0("distractor", i)]]}))
    # Combine the distractors into a single string
    for (i in 1:length(distractors)) {
      distractors[i]= paste0("wrong answer ",i,":", distractors[i])
    }
    distractors <- c(paste0("Correct answer:",input$correctAnswer), distractors)
    distractors=paste(distractors, collapse = " \n")
    print(distractors)
    
    # Call the Python script and capture the dataframe
    python_output <- call_python_script(input$passage, 
                                        input$question, 
                                        distractors)
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
