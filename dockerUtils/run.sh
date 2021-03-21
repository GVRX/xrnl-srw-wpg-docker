#!/bin/bash

docker run -t -d --name $1 \
       --mount src="$(pwd)/xl",target=/opt/xl,type=bind \
       --mount src="$(pwd)/data",target=/data,type=bind \
       --mount src="$(pwd)/xrnl",target=/opt/xrnl,type=bind \
       $2 

