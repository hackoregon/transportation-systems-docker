#! /bin/bash
usage() { echo "Usage: $0 [-d] for a docs build, [-g] for a geodjango build, [-c] to create a django project using the PROJECT_NAME variable in env.sh" 1>&2; exit 1; }

source ./bin/env.sh

while getopts ":dgct" opt; do
    case "$opt" in
        d)
          docker-compose -f ./composefiles/mkdocs-compose.yml -p $PROJECT_NAME build
          ;;
        g)
          docker-compose -f ./composefiles/geodjango-compose.yml -p $PROJECT_NAME build
          ;;
        c)
          docker-compose -f ./composefiles/geodjango-compose.yml -p $PROJECT_NAME run api django-admin.py startproject $PROJECT_NAME .
          ;;
        t)
          docker build -f ./dockerfiles/GEODJANGO-DOCKERFILE --pull --cache-from $API_DOCKER_IMAGE --tag $API_DOCKER_IMAGE .
          ;;
        *)
          usage
          ;;
    esac
done
