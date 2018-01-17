#!/bin/bash

source ./bin/env.sh

while getopts ":kri:" opt; do
    case "$opt" in
      k)
        docker kill $CONTAINER_NAME
        ;;
      r)
        docker rm -f $CONTAINER_NAME
        ;;
      i)
        docker rmi $CONTAINER_NAME
        ;;
      *)
        echo "nothing"
        ;;
    esac
done
