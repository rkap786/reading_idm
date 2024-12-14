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

### Data dictionary

| Column Name            | Data Type | Description                                                      |
|------------------------|-----------|------------------------------------------------------------------|
| pdfname                | string    | Name of the PDF document from which the data was extracted       |
| PassNumUnq             | string    | Unique identifier for each passage within the document           |
| Passage                | string    | Text of the passage                                              |
| pass_text_bold_yn      | int       | Indicator if the passage text contains bold formatting (1 = Yes, 0 = No) |
| pass_text_italics_yn   | int       | Indicator if the passage text contains italics formatting (1 = Yes, 0 = No) |
| pass_text_fn_yn        | int       | Indicator if the passage text contains footnotes (1 = Yes, 0 = No) |
| pass_text_underline_yn | int       | Indicator if the passage text contains underlining (1 = Yes, 0 = No) |
| pass_highlight_yn      | int       | Indicator if the passage text is highlighted (1 = Yes, 0 = No) |
| numPara                | int       | Number of paragraphs in the passage                              |
| PassageWordCount.gen   | int       | Word count of the passage                                       |
| ques_text_para_yn      | int       | Indicator if the question text includes paragraphs (1 = Yes, 0 = No) |
| ques_text_sentence_yn  | int       | Indicator if the question text includes complete sentences (1 = Yes, 0 = No) |
| option_correct_ans     | string    | Text of the correct answer option                               |
| option_distractor1     | object    | Text of the first distractor (incorrect answer option)          |
| option_distractor2     | object    | Text of the second distractor                                   |
| option_distractor3     | object    | Text of the third distractor                                    |
| ques_order             | int       | Order of the question within the passage                        |
| year                   | int       | Year of the document                                            |
| grade                  | string    | Grade level relevant to the passage or question                 |
| state                  | object    | State from which the passage or document originates             |
| fk                     | int       | Flesch Kincaid score (generated from Python package)           |
| pVal                   | int       | % correct responses (mean at the grade level for given state)  |
|DESPL|	int|	Paragraph length, number of sentences in a paragraph, mean|
|DESPLd|	int|	Paragraph length, number of sentences in a pragraph, standard deviation|
|DESSL|	int|	Sentence length, number of words, mean|
|DESSLd|	int|	Sentence length, number of words, standard deviation|
|DESWLsy|	int|	Word length, number of syllables, mean|
|DESWLsyd|	int|	Word length, number of syllables, standard deviation|
|DESWLlt|	int|	Word length, number of letters, mean|
|DESWLltd|	int|	Word length, number of letters, standard deviation|
|PCNARz|	int|	Text Easability PC Narrativity, z score|
|PCNARp|	int|	Text Easability PC Narrativity, percentile|
|PCSYNz|	int|	Text Easability PC Syntactic simplicity, z score|
|PCSYNp|	int|	Text Easability PC Syntactic simplicity, percentile|
|PCCNCz|	int|	Text Easability PC Word concreteness, z score|
|PCCNCp|	int|	Text Easability PC Word concreteness, percentile|
|PCREFz|	int|	Text Easability PC Referential cohesion, z score|
|PCREFp|	int|	Text Easability PC Referential cohesion, percentile|
|PCDCz|	int|	Text Easability PC Deep cohesion, z score|
|PCDCp|	int|	Text Easability PC Deep cohesion, percentile|
|PCVERBz|	int|	Text Easability PC Verb cohesion, z score|
|PCVERBp|	int|	Text Easability PC Verb cohesion, percentile|
|PCCONNz|	int|	Text Easability PC Connectivity, z score|
|PCCONNp|	int|	Text Easability PC Connectivity, percentile|
|PCTEMPz|	int|	Text Easability PC Temporality, z score|
|PCTEMPp|	int|	Text Easability PC Temporality, percentile|
|CRFNO1|	int|	Noun overlap, adjacent sentences, binary, mean|
|CRFAO1|	int|	Argument overlap, adjacent sentences, binary, mean|
|CRFSO1|	int|	Stem overlap, adjacent sentences, binary, mean|
|CRFNOa|	int|	Noun overlap, all sentences, binary, mean|
|CRFAOa|	int|	Argument overlap, all sentences, binary, mean|
|CRFSOa|	int|	Stem overlap, all sentences, binary, mean|
|CRFCWO1|	int|	Content word overlap, adjacent sentences, proportional, mean|
|CRFCWO1d|	int|	Content word overlap, adjacent sentences, proportional, standard deviation|
|CRFCWOa|	int|	Content word overlap, all sentences, proportional, mean|
|CRFCWOad|	int|	Content word overlap, all sentences, proportional, standard deviation|
|LSASS1|	int|	LSA overlap, adjacent sentences, mean|
|LSASS1d|	int|	LSA overlap, adjacent sentences, standard deviation|
|LSASSp|	int|	LSA overlap, all sentences in paragraph, mean|
|LSASSpd|	int|	LSA overlap, all sentences in paragraph, standard deviation|
|LSAPP1|	int|	LSA overlap, adjacent paragraphs, mean|
|LSAPP1d|	int|	LSA overlap, adjacent paragraphs, standard deviation|
|LSAGN|	int|	LSA given/new, sentences, mean|
|LSAGNd|	int|	LSA given/new, sentences, standard deviation|
|LDTTRc|	int|	Lexical diversity, type-token ratio, content word lemmas|
|LDTTRa|	int|	Lexical diversity, type-token ratio, all words|
|LDMTLD|	int|	Lexical diversity, MTLD, all words|
|LDVOCD|	int|	Lexical diversity, VOCD, all words|
|CNCAll|	int|	All connectives incidence|
|CNCCaus|	int|	Causal connectives incidence|
|CNCLogic|	int|	Logical connectives incidence|
|CNCADC|	int|	Adversative and contrastive connectives incidence|
|CNCTemp|	int|	Temporal connectives incidence|
|CNCTempx|	int|	Expanded temporal connectives incidence|
|CNCAdd|	int|	Additive connectives incidence|
|CNCPos|	int|	Positive connectives incidence|
|CNCNeg|	int|	Negative connectives incidence|
|SMCAUSv|	int|	Causal verb incidence|
|SMCAUSvp|	int|	Causal verbs and causal particles incidence|
|SMINTEp|	int|	Intentional verbs incidence|
|SMCAUSr|	int|	Ratio of casual particles to causal verbs|
|SMINTEr|	int|	Ratio of intentional particles to intentional verbs|
|SMCAUSlsa|	int|	LSA verb overlap|
|SMCAUSwn|	int|	WordNet verb overlap|
|SMTEMP|	int|	Temporal cohesion, tense and aspect repetition, mean|
|SYNLE|	int|	Left embeddedness, words before main verb, mean|
|SYNNP|	int|	Number of modifiers per noun phrase, mean|
|SYNMEDpos|	int|	Minimal Edit Distance, part of speech|
|SYNMEDwrd|	int|	Minimal Edit Distance, all words|
|SYNMEDlem|	int|	Minimal Edit Distance, lemmas|
|SYNSTRUTa|	int|	Sentence syntax similarity, adjacent sentences, mean|
|SYNSTRUTt|	int|	Sentence syntax similarity, all combinations, across paragraphs, mean|
|DRNP|	int|	Noun phrase density, incidence|
|DRVP|	int|	Verb phrase density, incidence|
|DRAP|	int|	Adverbial phrase density, incidence|
|DRPP|	int|	Preposition phrase density, incidence|
|DRPVAL|	int|	Agentless passive voice density, incidence|
|DRNEG|	int|	Negation density, incidence|
|DRGERUND|	int|	Gerund density, incidence|
|DRINF|	int|	Infinitive density, incidence|
|WRDNOUN|	int|	Noun incidence|
|WRDVERB|	int|	Verb incidence|
|WRDADJ|	int|	Adjective incidence|
|WRDADV|	int|	Adverb incidence|
|WRDPRO|	int|	Pronoun incidence|
|WRDPRP1s|	int|	First person singular pronoun incidence|
|WRDPRP1p|	int|	First person plural pronoun incidence|
|WRDPRP2|	int|	Second person pronoun incidence|
|WRDPRP3s|	int|	Third person singular pronoun incidence|
|WRDPRP3p|	int|	Third person plural pronoun incidence|
|WRDFRQc|	int|	CELEX word frequency for content words, mean|
|WRDFRQa|	int|	CELEX Log frequency for all words, mean|
|WRDFRQmc|	int|	CELEX Log minimum frequency for content words, mean|
|WRDAOAc|	int|	Age of acquisition for content words, mean|
|WRDFAMc|	int|	Familiarity for content words, mean|
|WRDCNCc|	int|	Concreteness for content words, mean|
|WRDIMGc|	int|	Imagability for content words, mean|
|WRDMEAc|	int|	Meaningfulness, Colorado norms, content words, mean|
|WRDPOLc|	int|	Polysemy for content words, mean|
|WRDHYPn|	int|	Hypernymy for nouns, mean|
|WRDHYPv|	int|	Hypernymy for verbs, mean|
|WRDHYPnv|	int|	Hypernymy for nouns and verbs, mean|
|RDL2|	int|	Coh-Metrix L2 Readability|
