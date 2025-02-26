#pip install -U transformers>=4.48.0
import transformers
from transformers import AutoTokenizer, ModernBertForMaskedLM, AutoModelForMaskedLM, AutoModel
import torch
import numpy as np
from numpy import savetxt
import pandas as pd

def vectorize_with_pretrained_embeddings(sentences):

    """
    Produces a tensor containing a BERT embedding for each sentence in the dataset or in a
    batch
    Args:
    sentences: List of sentences of length n
    Returns:
    embeddings: A 2D torch array containing embeddings for each of the n sentences (n x d)
                where d = 768
    """


    tokenizer = AutoTokenizer.from_pretrained('answerdotai/ModernBERT-base')
    pretrained_model = AutoModel.from_pretrained('answerdotai/ModernBERT-base', output_hidden_states=False)
    pretrained_model.eval()
    embeddings = []
    for sentence in sentences:
        #print("sentence:", sentence)
        #with_tags = "[CLS] " + sentence + " [SEP]"
        tokenized_sentence= tokenizer(sentence, padding=True, truncation=True, return_tensors="pt")
        #print(tokenizer.decode(tokenized_sentence['input_ids'][0]))
        #print(tokenized_sentence['input_ids'][0])
        # print(len(tokenized_sentence['input_ids'][0]))
        with torch.no_grad():
            outputs = pretrained_model(**tokenized_sentence).last_hidden_state # The output is the
        #last hidden state of the pretrained model of shape 1 x sentence_length x ModernBERT embedding_length
        #print('outputs: ', outputs)
        #print("dim:",outputs.shape)
        #print("average dim:", torch.mean(outputs, dim = 1).shape)
        embeddings.append(torch.mean(outputs, dim = 1))# we average across the embedding length
        #dimension to produce constant sized tensors
    embeddings = torch.cat(embeddings, dim = 0)
    print('Shape of embeddings tensor (n x d = 768): ', embeddings.shape)
    return embeddings.cpu().detach().numpy()

if __name__ == "__main__":
    f= pd.read_csv('/Users/radhika/Library/CloudStorage/GoogleDrive-rkap786@stanford.edu/My Drive/0. Projects - Stanford/Item generation/Data/Data/Processed/data_passage_ques_options_pv.csv')
    print('f shape:',f.shape)
    ques_alloptions_tag = f['QuestionText'] + '\n Correct answer: ' + f['option_correct_ans'] + "\n" + '\n Wrong answer 1: ' + f['option_distractor1'] + "\n" + '\n Wrong answer 2: ' + f['option_distractor2'] + "\n" + '\n Wrong answer 3: ' + f['option_distractor3'] + "\n" + f['Passage']
    ques_alloptions_tag= vectorize_with_pretrained_embeddings(ques_alloptions_tag)
    df= pd.DataFrame(ques_alloptions_tag)
    df['PassNumUnq'] = list_PassNumUnq
    df['QNoUnq'] = list_QNoUnq
    
    df.to_csv('/Users/radhika/Library/CloudStorage/GoogleDrive-rkap786@stanford.edu/My Drive/0. Projects - Stanford/Item generation/Data/Embeddings/question_alldistractors_embed_mbert.csv')

