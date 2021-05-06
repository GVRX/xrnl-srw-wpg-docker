#!/bin/bash


# usage:  sh run.sh <name-to-give-container> <name-of-image> <command to run (optional>

docker run -t -d --name $1 \
       --mount src="$(pwd)/xl",target=/opt/xl,type=bind \
       --mount src="$(pwd)/data",target=/data,type=bind \
       --mount src="$(pwd)/xrnl",target=/opt/xrnl,type=bind \
       $2 \
       $3 

