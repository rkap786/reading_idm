from datasets import load_dataset, Dataset
from embed_text_package.embed_text_v2 import Embedder
from torch.utils.data import DataLoader
import itertools
import pickle
import torch

ds = load_dataset("domingue-lab/question_difficulty", split="train")
model = "meta-llama/Llama-3.1-8B"
num_gpu =  4

if __name__ == "__main__":
    embedder = Embedder()
    embedder.load(
	model,
        tensor_parallel_size=num_gpu,
    	enable_chunked_prefill=False,
    	enforce_eager=True,
	dtype=torch.float16
    )
    list_text = []
    list_score = []

    # ds = Dataset.from_dict(ds[:10])

    for sample in ds:
        answer = [
            "Correct answer: " + sample["option_correct_ans"],
            "Wrong answer 1: " + sample["option_distractor1"],
            "Wrong answer 2: " + sample["option_distractor2"],
            "Wrong answer 3: " + sample["option_distractor3"],
        ]
        answers = list(itertools.permutations(answer))
        # answers = answer[:2]
        for answer in answers:
            text = (
                sample["Passage"] + "\n" + sample["QuestionText"] + "\n" +
                answer[0] + "\n" +
                answer[1] + "\n" +
                answer[2] + "\n" +
                answer[3]
            )
            list_text.append(text)
            list_score.append(sample["pVal"])

    combine_ds = Dataset.from_dict({"text": list_text})
    ds_emb = (
        embedder.get_embeddings(
            DataLoader(combine_ds, batch_size=1),
            embedder.which_model,
            ["text"],
        )
        .data["text"]
        .to_pylist()
    )

    new_ds = Dataset.from_dict({"embedding": ds_emb, "score": list_score})

    with open('embedding.pkl', 'wb') as f:
        pickle.dump(new_ds, f)

    new_ds.push_to_hub("stair-lab/question_difficulty_embedded-full")
    

    
