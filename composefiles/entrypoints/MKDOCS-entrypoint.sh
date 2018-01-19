#! /bin/bash

# MKDOCS_HOME=/mkdocs

cd docs

mkdocs gh-deploy

mkdocs serve -a 0.0.0.0:8000
