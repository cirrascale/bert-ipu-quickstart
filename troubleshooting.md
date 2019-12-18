# Troubleshooting
This document provides known bugs and common errors found when running the BERT IPU quickstart.

## Error:
This error occurs at the tail end of training Bert on the SQuAD dataset during the validation step.

```bash
Traceback (most recent call last):
  File "bert.py", line 751, in <module>
    main(args)
  File "bert.py", line 722, in main
    main(utils.get_validation_args(args))
  File "bert.py", line 695, in main
    session, anchors = bert_inference_session(model, args, data_flow, losses, device)
  File "bert.py", line 252, in bert_inference_session
    userOptions=options)
  File "/opt/gc/poplar/poplar_sdk-ubuntu_18_04-1.0.49-3bb7d0c32f/popart-ubuntu_18_04-1.0.49-e64013ecc5/python/popart/session.py", line 87, in __init__
    inputShapeInfo, userOptions, passes)
popart_core.popart_exception: For pipelining, depth (batchesPerStep) must be at least 4 for 4 IPUs
```

## Solution:
This is a known bug that requires an SDK update from Graphcore to remedy. Therefore, currently there is no fix, but a fix will be made in the next Graphcore SDK release. (Current release of SDK as of testing is 1.0.49)

## Error:
This error occurs when the IPUs have not been reset after a system shutdown or reboot.

```bash
terminate called after throwing an instance of 'GraphcoreDeviceAccessExceptions::graphcore_device_access_error'
  what():  Device 0 needs a parity init. Cannot load binary. Please run 'gc-reset -p -d 0'.
```

## Solution:
Run the "gc-reset" on the IPU device. It's recommended by graphcore to reset all IPU devices after a reboot or shutdown.

```bash
# Run the IPU reset command
# set gc driver path
gc_driver_path="/opt/gc/poplar/poplar_sdk-*/gc_drivers-*/"

# source enable.sh in "gc_driver_path"
source ${gc_driver_path}enable.sh

# reset IPU device 0
gc-reset -d 0 -p
```

Optionally, you can reset all IPUs on the system (recommended).

```bash
# get total IPUs on system
numIPUs=$(gc-info --ipu-count)

# RESET IPUs
DEVICE_ID=0
# reset each IPU, and initialize tile parity on each IPU
while [ $DEVICE_ID -lt $numIPUs ]; do
  gc-reset -d $DEVICE_ID -p
  let DEVICE_ID++
done
```


## Error:
The directory "uncased_L-12_H-768_A-12" was not found. This directory contains google's pre-trained weights for BERT.

```bash
Traceback (most recent call last):
  File "bert_data/create_pretraining_data.py", line 480, in <module>
    main(args)
  File "bert_data/create_pretraining_data.py", line 438, in main
    vocab_file=args.vocab_file, do_lower_case=args.do_lower_case)
  File "/home/USER/examples/applications/popart/bert/bert_data/tokenization.py", line 164, in __init__
    self.vocab = load_vocab(vocab_file)
  File "/home/USER/examples/applications/popart/bert/bert_data/tokenization.py", line 124, in load_vocab
    with open(vocab_file, "r") as reader:
FileNotFoundError: [Errno 2] No such file or directory: 'uncased_L-12_H-768_A-12/vocab.txt'
```

## Solution:
Download the zip file "uncased_L-12_H-768_A-12" from google BERT git repo (https://github.com/google-research/bert#Pre-trained-models). Place the unzipped directory at the expected default path "data/ckpts/", or change the "vocab_file" and "tf_checkpoint" variables in the "configs/squad_base.json" file to your download path.

```bash
mkdir -p data/ckpts

wget https://storage.googleapis.com/bert_models/2018_10_18/uncased_L-12_H-768_A-12.zip

unzip uncased_L-12_H-768_A-12.zip
rm uncased_L-12_H-768_A-12.zip

mv uncased_L-12_H-768_A-12 data/ckpts/
```


## Error:
Expected timings do not match actual timings.

```bash
Traceback (most recent call last):
  File "bert.py", line 751, in <module>
    main(args)
  File "bert.py", line 699, in main
    iteration)
  File "bert.py", line 617, in bert_infer_loop
    logits, iteration)
  File "bert.py", line 570, in bert_process_infer_data
    mean_latency, min_latency, max_latency = compute_latency(args, start_times, end_times)
  File "bert.py", line 542, in compute_latency
    raise RuntimeError("More timings than there are items in the batch. Something is wrong.")
RuntimeError: More timings than there are items in the batch. Something is wrong.
```

## Solution
Drop the "--no-drop-remainder" flag from "bert.py" or set the "no_drop_remainder" variable to false in your config json file.
