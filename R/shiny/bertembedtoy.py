import sys
import json
import transformers
import torch
import numpy as np
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
  #print(embeddings[0].shape)
  embeddings = torch.cat(embeddings, dim = 0)
  #print('Shape of embeddings tensor (n x d = 768): ', embeddings.shape)
  return embeddings.cpu().detach().numpy()



def main():
    # Step 1: Read JSON input from stdin
    input_json = sys.stdin.read()
    inputs = json.loads(input_json)

    # Step 2: Extract inputs
    passage = inputs.get("Passage", "")
    question = inputs.get("QuestionText", "")
    distractors = inputs.get("Distractors", "")
    
    # Combine inputs
    combined_input = [f"{question}\n{distractors}\n{passage}"]
    #print(combined_input)
    embedding = vectorize_with_pretrained_embeddings(combined_input)
    embedding_flat = embedding.flatten()  # Flatten to a 1D array
    embedding_str = ",".join(map(str, embedding_flat))
    print(embedding_str)
    #df= pd.DataFrame(embedding)
    
    # Send result to R
    #print(df)
    #df.to_csv(sys.stdout, index=False)

if __name__ == "__main__":
    main()
