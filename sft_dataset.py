from transformers import AutoTokenizer
from datasets import Dataset, DatasetDict
import pandas as pd
import os
from datasets import load_dataset, concatenate_datasets
from sklearn.model_selection import train_test_split

if __name__ == "__main__":
    tokenizer = AutoTokenizer.from_pretrained("meta-llama/Meta-Llama-3.1-8B-Instruct")
    dataset = load_dataset("stair-lab/questioin_difficulty", split="train")

    sft_chat = [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": (
            """Given a passage and a difficulty level ranging from 0 to 1, generate a multiple """
            """choices question with four options corresponding to the passage and the difficulty level. """
            """The higher the score is, the more difficult the question is. """
            """Output only the question, the 4 options where the first one is the correct option, """
            """and nothing else. \nPassage: %s. \nDifficulty: %s."""
            )
        },
        {"role": "assistant", "content": """%s"""},
    ]
    template = tokenizer.apply_chat_template(sft_chat, tokenize=False, add_generation_prompt=False)
    
    new_texts = []
    for sample in dataset:
        passage = sample['Passage']
        difficulty = 1 - sample['pVal']
        question_answer = (
            "Questions: " + sample["QuestionText"] + "\n" +
            "Correct answer: " + sample["option_correct_ans"] + "\n" +
            "Wrong answer 1: " + sample["option_distractor1"] + "\n" +
            "Wrong answer 2: " + sample["option_distractor2"] + "\n" +
            "Wrong answer 3: " + sample["option_distractor3"]
        )
        
        text = template % (passage, difficulty, question_answer)
        new_texts.append(text)
    print(new_texts[0])
        
    train_df, test_df = train_test_split(new_texts, test_size=0.2, random_state=42)
    train_dataset = Dataset.from_dict({"text": train_df})
    test_dataset = Dataset.from_dict({"text": test_df})
    dataset_dict = DatasetDict({
        "train": train_dataset,
        "test": test_dataset
    })
    dataset_dict.push_to_hub(f'stair-lab/question_difficulty-sft')
