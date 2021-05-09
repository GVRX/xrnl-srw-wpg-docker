#!/bin/bash

# usage:  
# build.sh <name of image>

docker build -t $1 .
