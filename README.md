# bert-ipu-quickstart
This repo is a quickstart on how to run BERT using a Graphcore IPU on [Cirrascale Cloud](https://www.cirrascale.com).
For more indepth information on running BERT on IPU, refer to https://github.com/graphcore/examples/tree/master/applications/popart/bert, which this repo is forked from.

For more information about Graphcore IPUs please visit https://www.graphcore.ai/.
To get started with your very own Graphcore IPU server on Cirrascale Cloud, please visit https://cirrascale.com/graphcore-cloud.php#signup.


## Before you begin installs
Install software packages we will use for this quickstart.
```bash
sudo apt update
sudo apt install virtualenv libboost-dev git wget curl unzip -y
```


## Clone this repo
```bash
git clone https://github.com/cirrascale/bert-ipu-quickstart.git
```


## Setup your environment

### Activate poplar SDK
Add the poplar SDK paths to environment variables.
```bash
# Set gc paths for poplar, gc_drivers, and popart
gc_poplar_path="/opt/gc/poplar/poplar_sdk-*/poplar-*/"
gc_driver_path="/opt/gc/poplar/poplar_sdk-*/gc_drivers-*/"
gc_popart_path="/opt/gc/poplar/poplar_sdk-*/popart-*/"

# Source enable.sh for "gc_poplar_path", "gc_driver_path", and "gc_popart_path"
source ${gc_poplar_path}enable.sh
source ${gc_driver_path}enable.sh
source ${gc_popart_path}enable.sh
```

### Setup python environment
Create the python virtual environment and install required python packages.
```bash
virtualenv gc_virtualenv -p python3.6
source gc_virtualenv/bin/activate

cd bert-ipu-quickstart/bert/
pip install -r requirements.txt
```

### Compile "custom_ops"
Compile custom BERT operators targeted for the graphcore IPU.
```bash
make
```

### Download google's pretrained BERT-Base, Uncased weights
Google has links to download the "pre-trained" BERT model at https://github.com/google-research/bert#Pre-trained-models.
```bash
mkdir -p data/ckpts

wget https://storage.googleapis.com/bert_models/2018_10_18/uncased_L-12_H-768_A-12.zip

unzip uncased_L-12_H-768_A-12

mv uncased_L-12_H-768_A-12 data/ckpts/

rm uncased_L-12_H-768_A-12.zip
```


## Fine-tune training using the SQuAD 1.1 dataset

### Download the SQuAD dataset
This quickstart uses the SquAD 1.1 dataset to evaluate and analyze the performance of the model. To use this dataset, download train-v1.1.json, dev-v1.1.json, and evaluate-v1.1.py using the following commands:
```bash
mkdir -p data/squad

curl -L https://rajpurkar.github.io/SQuAD-explorer/dataset/train-v1.1.json -o data/squad/train-v1.1.json
curl -L https://rajpurkar.github.io/SQuAD-explorer/dataset/dev-v1.1.json -o data/squad/dev-v1.1.json
curl -L https://raw.githubusercontent.com/allenai/bi-att-flow/master/squad/evaluate-v1.1.py -o data/squad/evaluate-v1.1.py
```

### Run fine-tune training on SQuAD 1.1 dataset
Run the bert training script passing in the squad_base.json config file.
```bash
python bert.py --config configs/squad_base.json
```

### View training logs with TensorBoard
```bash
tensorboard --logdir logs
```

### Verify your results
When the training script completes, you should see results similar to the following:
```bash
***** Eval results *****
INFO F1 Score: 88.41249612335034 | Exact Match: 81.2488174077578
```


## Next steps
Edit the files in "configs/" to tweak hyperparameters and experiment with settings.
To learn how to do BERT pre-training on IPUs or leverage your own dataset, please refer to Graphcore's BERT example (https://github.com/graphcore/examples/tree/master/applications/popart/bert).


## Troubleshooting
For common errors when running this quickstart please reference our [troubleshooting doc](troubleshooting.md).
