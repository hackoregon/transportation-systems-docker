#! /bin/bash
usage() { echo "Usage: $0 [-d] for a docs build or [-g] for a geodjango build " 1>&2; exit 1; }

source ./bin/env.sh

while getopts ":dg" opt; do
    case "$opt" in
        d)
          docker-compose -f ./composefiles/mkdocs-compose.yml build
          ;;
        g)
          docker-compose -f ./composefiles/geodjango-compose.yml build
          ;;
        *)
          usage
          ;;
    esac
done
