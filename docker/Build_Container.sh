#!/bin/bash
#Date: 1-6-20
#Description: Build bert-ipu-quickstart container image.

docker_repo="cirrascale/bert-ipu-quickstart"
docker_tag="v1.0"

docker build -f Dockerfile -t $docker_repo:$docker_tag ../
