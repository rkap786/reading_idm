# reading comprehension item difficulty modeling
Modeling difficulty of reading comprehension items
### Cleaned data file for embeddings 
File name: data_passage_ques_options_pv.csv
Passage information: Passage, Question text, and Options text (Options 1-4)
Pvalue: average for question

### Cleaned data file with other information about passage and questions
File name: data_qual_data.csv


### Cleaning data
Raw file: Combined data_edit - Data_combined_edit.csv
File for processing: R/Process data.qmd

### BERT embeddings
Generated from last layer + averaged across embedding length
Generates embeddings for each sentence with d = 768
