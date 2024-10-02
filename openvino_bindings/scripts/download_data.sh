#!/usr/bin/env sh

cd data

git lfs install
git clone https://huggingface.co/OpenVINO/TinyLlama-1.1B-Chat-v1.0-int4-ov
