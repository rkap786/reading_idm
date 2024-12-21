# reading comprehension item difficulty modeling
Project goal: Model and predict difficulty of reading comprehension items

### Cleaning data
File for processing the data : R/Process data.qmd

### Predicted value
Item difficulty is measured as percent correct responses or p-value. This value is adjusted to the logit scale


| Column Name            | Data Type | Description                                                    |
| pVal                   | int       | % correct responses (mean at the grade level for given state)  |



### Features used in prediction
**1. Embeddings**
**(a) BERT embeddings**
- Generated from last layer + averaged across embedding length
- Generates embeddings for each sentence with d = 768
- Text inputs are truncated at 512 characters if length exceeds limit

BERT embeddings are generated for the following text combinations:
1. question_embed_correct.csv: Embeddings for question text + correct answer
2. question_embed_dis1.csv: Embeddings for question text + distractor1
3. question_embed_dis2.csv: Embeddings for question text + distractor2
4. question_embed_dis3.csv: Embeddings for question text + distractor3
5. question_embed.csv: Embeddings for question text ONLY
6. option_embed_correct.csv: Embeddings for correct answer text ONLY
7. optionembed1.csv: Embeddings for distractor1 text ONLY
8. optionembed2.csv: Embeddings for distractor2 text ONLY
9. optionembed3.csv: Embeddings for distractor3 text ONLY

**(b) LlAMA embeddings (8b parameters model)**
- Generated from last layer
- Generates embeddings for each sentence with d = 4096

**2. Text analysis features**

| Column Name            | Data Type | Description                                                      |
|------------------------|-----------|------------------------------------------------------------------|
| Passage                | string    | Text of the passage                                              |
| numPara                | int       | Number of paragraphs in the passage                              |
| PassageWordCount.gen   | int       | Word count of the passage                                       |
| fk                     | int       | Flesch Kincaid score (generated from Python package)           |
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

3. **Assessment characteristics**
   
| Column Name            | Data Type | Description                                                      |
|------------------------|-----------|------------------------------------------------------------------|
| pass_highlight_yn      | int       | Indicator if the passage text is highlighted (1 = Yes, 0 = No) |
| ques_text_para_yn      | int       | Indicator if the question text includes paragraphs (1 = Yes, 0 = No) |
| ques_text_sentence_yn  | int       | Indicator if the question text includes complete sentences (1 = Yes, 0 = No) |
| ques_highlight_yn      | int       | Indicator if the question text includes highlighted text (1 = Yes, 0 = No) |
| ques_order             | int       | Order of the question within the passage                        |



