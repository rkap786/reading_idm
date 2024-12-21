import sys
import torch

from peft import AutoPeftModelForCausalLM

output_dir = sys.argv[1]

model = AutoPeftModelForCausalLM.from_pretrained(output_dir)
model = model.merge_and_unload().to(torch.bfloat16)
model.save_pretrained(output_dir)