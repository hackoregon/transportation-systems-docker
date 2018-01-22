#! /bin/bash
usage() { echo "Usage: $0 [-l] for a local build or [-t] for a travis build " 1>&2; exit 1; }

source ./bin/env.sh

while getopts ":mgtn" opt; do
    case "$opt" in
        m)
          docker-compose -f ./composefiles/mkdocs-compose.yml -p $PROJECT_NAME up
          ;;
        g)
          docker-compose -f ./composefiles/geodjango-compose.yml -p $PROJECT_NAME up
          ;;
        t)
          docker-compose -f ./composefiles/travis-docker-compose.yml -p $PROJECT_NAME up
          ;;
        *)
          usage
          ;;
    esac
done
