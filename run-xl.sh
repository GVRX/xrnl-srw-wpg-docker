#!/bin/bash

docker run -t -d --name xl \
       --mount src="$(pwd)/xl",target=/opt/xl,type=bind \
       --mount src="$(pwd)/data",target=/data,type=bind wpg-xl

