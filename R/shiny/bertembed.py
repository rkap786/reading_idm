import transformers
import torch
import sys
import json
import numpy as np


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
        tokenized_sentence = tokenized_sentence[:512]  # Truncate to BERT's maximum token limit
        indices_from_tokens = tokenizer.convert_tokens_to_ids(tokenized_sentence)
        segments_ids = [1] * len(indices_from_tokens)
        tokens_tensor = torch.tensor([indices_from_tokens])
        segments_tensors = torch.tensor([segments_ids])
        with torch.no_grad():
            outputs = pretrained_model(tokens_tensor, segments_tensors)[0]  # Last hidden state
            embeddings.append(torch.mean(outputs, dim=1))  # Average over the sequence length
    embeddings = torch.cat(embeddings, dim=0)
    return embeddings.cpu().detach().numpy()


def main():
    # Step 1: Read JSON input from stdin
    input_json = sys.stdin.read()
    inputs = json.loads(input_json)

    # Step 2: Combine input text
    passage = inputs.get("Passage", "")
    question = inputs.get("QuestionText", "")
    distractors = inputs.get("Distractors", "")
    combined_input = [f"{question} {passage} {distractors}"]  # List of one sentence

    # Step 3: Generate BERT embeddings
    try:
        embedding = vectorize_with_pretrained_embeddings(combined_input)  # Shape: 1x768
        embedding_flat = embedding.flatten()  # Flatten to a 1D array
        embedding_str = ",".join(map(str, embedding_flat))  # Convert to comma-separated string

        # Step 4: Print the embedding to stdout (for R to capture)
        print(embedding_str)
    except Exception as e:
        print(f"Error generating BERT embeddings: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()