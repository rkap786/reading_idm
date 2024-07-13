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
Stored under Data. Files:
1. question_embed_correct.csv: Embeddings for question text + correct answer
2. question_embed_dis1.csv: Embeddings for question text + distractor1
3. question_embed_dis2.csv: Embeddings for question text + distractor2
4. question_embed_dis3.csv: Embeddings for question text + distractor3
5. question_embed.csv: Embeddings for question text ONLY
6. option_embed_correct.csv: Embeddings for correct answer text ONLY
7. optionembed1.csv: Embeddings for distractor1 text ONLY
8. optionembed2.csv: Embeddings for distractor2 text ONLY
9. optionembed3.csv: Embeddings for distractor3 text ONLY
