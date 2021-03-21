#!/bin/bash

docker run -t -d --name xl-test \
       --mount src="$(pwd)/xl",target=/opt/xl,type=bind \
       --mount src="$(pwd)/data",target=/data,type=bind \
       --mount src="$(pwd)/xrnl",target=/opt/xrnl,type=bind \
       xl:0.2

