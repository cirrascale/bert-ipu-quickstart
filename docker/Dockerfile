#Date: 1-6-20
#Description: Create a container environment to run the bert-ipu-quickstart(https://github.com/cirrascale/bert-ipu-quickstart).

FROM ubuntu:18.04
ENV LANG en_US.UTF-8
ENV LC_ALL=C.UTF-8
ENV poplar_SDK_version=1.0.97
RUN apt-get update && apt-get install -y software-properties-common \
                                         virtualenv \
                                         libboost-dev \
                                         git \
                                         wget \
                                         curl \
                                         unzip \
                                         make \
                                         g++


## Install Poplar drivers/libs
WORKDIR /opt/gc/poplar/
# Copy Poplar SDK
COPY poplar_sdk-* ./poplar_sdk-$poplar_SDK_version

# Set gc paths for poplar, gc_driver, and popart
ENV gc_poplar_path="/opt/gc/poplar/poplar_sdk-*/poplar-*/"
ENV gc_driver_path="/opt/gc/poplar/poplar_sdk-*/gc_drivers-*/"
ENV gc_popart_path="/opt/gc/poplar/poplar_sdk-*/popart-*/"

RUN echo source ${gc_poplar_path}enable.sh'\n'\
source ${gc_driver_path}enable.sh'\n'\
source ${gc_popart_path}enable.sh >> /etc/bash.bashrc


## Copy bert directory
WORKDIR /workspace
COPY bert/ ./bert


## Setup python environment
ENV GC_VIRTUALENV=/opt/gc_virtualenv
RUN virtualenv $GC_VIRTUALENV -p python3.6
ENV PATH="$GC_VIRTUALENV/bin:$PATH"

WORKDIR /workspace/bert/
RUN pip install -r requirements.txt


## Compile "custom_ops"
RUN ["bash", "-c", "source ${gc_popart_path}enable.sh && source ${gc_poplar_path}enable.sh && make"]


## Download google's pretrained BERT-Base, Uncased weights
RUN mkdir -p data/ckpts && \
    wget https://storage.googleapis.com/bert_models/2018_10_18/uncased_L-12_H-768_A-12.zip && \
    unzip uncased_L-12_H-768_A-12 && \
    mv uncased_L-12_H-768_A-12 data/ckpts/ && \
    rm uncased_L-12_H-768_A-12.zip


## Download the SQuAD dataset
RUN mkdir -p data/squad && \
    curl -L https://rajpurkar.github.io/SQuAD-explorer/dataset/train-v1.1.json -o data/squad/train-v1.1.json && \
    curl -L https://rajpurkar.github.io/SQuAD-explorer/dataset/dev-v1.1.json -o data/squad/dev-v1.1.json && \
    curl -L https://raw.githubusercontent.com/allenai/bi-att-flow/master/squad/evaluate-v1.1.py -o data/squad/evaluate-v1.1.py
