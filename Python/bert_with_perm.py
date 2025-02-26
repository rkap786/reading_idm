import transformers
import torch
import itertools
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


    tokenizer = transformers.BertTokenizer.from_pretrained('bert-base-cased')
    pretrained_model = transformers.BertModel.from_pretrained('bert-base-cased', output_hidden_states=False)
    pretrained_model.eval()
    embeddings = []
    for sentence in sentences:
        with_tags = "[CLS] " + sentence + " [SEP]"
        tokenized_sentence = tokenizer.tokenize(with_tags)
        tokenized_sentence = tokenized_sentence[:512]
        # print(tokenized_sentence)
        # print(len(tokenized_sentence))
        indices_from_tokens = tokenizer.convert_tokens_to_ids(tokenized_sentence)
        segments_ids = [1] * len(indices_from_tokens)
        tokens_tensor = torch.tensor([indices_from_tokens])
        segments_tensors = torch.tensor([segments_ids])
        # print(indices_from_tokens)
        # print(tokens_tensor)
        # print(segments_tensors)
        with torch.no_grad():
            outputs = pretrained_model(tokens_tensor, segments_tensors)[0] # The output is the
            #last hidden state of the pretrained model of shape 1 x sentence_length x BERT embedding_length
            embeddings.append(torch.mean(outputs, dim = 1))# we average across the embedding length
            #dimension to produce constant sized tensors
    print(embeddings[0].shape)
    embeddings = torch.cat(embeddings, dim = 0)
    print('Shape of embeddings tensor (n x d = 768): ', embeddings.shape)
    return embeddings.cpu().detach().numpy()

if __name__ == "__main__":
    f= pd.read_csv('/Users/radhika/Library/CloudStorage/GoogleDrive-rkap786@stanford.edu/My Drive/0. Projects - Stanford/Item generation/Data/Data/Processed/data_passage_ques_options_pv.csv')
    print('f shape:',f.shape)
    ques_alloptions_tag = f['QuestionText'] + '\n Correct answer: ' + f['option_correct_ans'] + "\n" + '\n Wrong answer 1: ' + f['option_distractor1'] + "\n" + '\n Wrong answer 2: ' + f['option_distractor2'] + "\n" + '\n Wrong answer 3: ' + f['option_distractor3'] + "\n" + f['Passage']

    nr= f.shape[0]
    print('number of rows', nr)
    list_PassNumUnq = []
    list_QNoUnq = []
    list_permute_id = []
    list_text = []
    list_score = []
    for i in range(nr):
    #print(f["option_correct_ans"][i])
        answer = [
                    "Correct answer: " + f["option_correct_ans"][i],
                    "Wrong answer 1: " + f["option_distractor1"][i],
                    "Wrong answer 2: " + f["option_distractor2"][i],
                    "Wrong answer 3: " + f["option_distractor3"][i],
                ]
        answers = list(itertools.permutations(answer))
        for permute_id, answer in enumerate(answers):
            text = (f['QuestionText'][i] + "\n" +
                    answer[0] + "\n" +
                    answer[1] + "\n" +
                    answer[2] + "\n" +
                    answer[3] + "\n" +
                    f['Passage'][i]
                )
            list_PassNumUnq.append(f['PassNumUnq'][i])
            list_QNoUnq.append(f['QNoUnq'][i])
            list_permute_id.append(permute_id)
            list_text.append(text)
            list_score.append(f['pVal'][i])

    ques_alloptions_tag= vectorize_with_pretrained_embeddings(list_text)
    df= pd.DataFrame(ques_alloptions_tag)
    df['PassNumUnq'] = list_PassNumUnq
    df['QNoUnq'] = list_QNoUnq
    df['permutation']= list_permute_id

    df.to_csv('/Users/radhika/Library/CloudStorage/GoogleDrive-rkap786@stanford.edu/My Drive/0. Projects - Stanford/Item generation/Data/Embeddings/question_embed_correct.csv')

