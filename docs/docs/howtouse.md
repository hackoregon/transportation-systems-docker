# How-to Use these Docker Images

 This repo is only meant for the source files for the image itself. If you are using the image for development you will want to follow the steps in this guide.

 These instructions are largely based on the [Docker Quickstart Guide to Docker and Django| Docker](https://docs.docker.com/compose/django/).

## Create new project repo

First go ahead a create the new repo for the project. If this is a Hack Oregon project, create the repo within the Hack Oregon organization. If you are unable to, contact a member of the leadership team. When creating the repo in the UI, you may want to choose a .gitignore template as well as licence type.

Once the repo is created, clone the empty repo to your local machine. Follow your project rules in terms of branching and git workflow. I will not mention this going forward but will say I suggest branching at this point.

## Create the DOCKERFILE

Now you will want to go ahead and create the DOCKERFILE that will be used to define your container. You will need a DOCKERFILE for each container that will be involved in your project. As such you may want to name them <SERVICE>-DOCKERFILE, ie: API-DOCKERFILE and DB-DOCKERFILE

## Create the Entrypoint files

You will have a few steps to the startup of the container, thus you will want to define a shell script to run when starting up the docker container.

Think about the steps in this. It will be things you want to happen each time the container starts. Too long of startup may cause the container to fail later healthchecks on EC2
