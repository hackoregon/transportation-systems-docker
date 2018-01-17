#! /bin/bash

echo $PROJECT_NAME

mkdocs new $PROJECT_NAME

mv $PROJECT_NAME/mkdocks.yml .
mv /docs$PROJECT_NAME ./docs
