#! /bin/bash
usage() { echo "Usage: $0 [-l] for a local build or [-t] for a travis build " 1>&2; exit 1; }

source ./bin/env.sh

while getopts ":mtn" opt; do
    case "$opt" in
        m)
          docker-compose -f mkdocs-compose.yml up
          ;;
        n)
          docker-compose -f new-docker-compose.yml up
          ;;
        t)
          docker-compose -f travis-docker-compose.yml up
          ;;
        *)
          usage
          ;;
    esac
done
