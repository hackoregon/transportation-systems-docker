## Quickstart

Quickest way to to get a GEODJANGO container up and running:

1. Unless you are developing on the image itself you'll want to create your own Github repo and then clone locally so you have a base repo. Use the python .gitignore template.

2.  cd into directory `$ cd <your-repo`

3. Open the .gitignore file in your text editor and add: `**/env.sh` and save.

4. Create a env.sh file (You might want to create a directory ie: `$mkdir bin` to house this and other files, but instructions will be based on all files at root).

5. Open the env.sh file in a text editor and add the following variables with your chosen values:

```
export PROJECT_NAME='<YOUR_PROJECT_NAME>'
export DEBUG='BOOL_DEBUG_MODE'
export API_DOCKER_IMAGE='YOUR_DESIRED_LOCAL_DOCKER_IMAGE'
export CONTAINER_NAME='LOCAL_CONTAINER_NAME'

```

6. Create GEODJANGO DOCKERFILE in root of github repo

For the GeoDjango container, which can be used as the basis for any project needing to provide a Django Rest Framework API to serve GIS based data this would be your basic template:

```
FROM bhgrant/hacko-geodjango
ENV PYTHONUNBUFFERED 1
EXPOSE 8000

WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt
RUN python
COPY . /code/
ENTRYPOINT [ "/code/docker-entrypoint.sh" ]
```

7. Create GeoDjango entrypoint file

`$ touch docker-entrypoint.sh`

Now let's open this file up in your text editor of choice.

At this point you may only be entering in the basic django startup command to run the dev server environment:

```
#! /bin/bash

python3 manage.py runserver 0.0.0.0:8000
```

Go ahead and save this file.

8. Create the requirements.txt file  

The above DOCKERFILE uses pip to install any additional python packages you may need. If you don't want to create this file at this time, you may opt not to but will have to remove the related lines from the DOCKERFILE.

9. Create the docker-compose.yml file (You are probably going to want to include a POSTGRES or another database container in this but you should be able to run a basic development implementation using the defuault sqlite):
```
version: '3'
services:
  api:
    environment:
    - DEBUG=${DEBUG}
    - PROJECT_NAME=${PROJECT_NAME}
    build:
      context: .
    image: "${API_DOCKER_IMAGE}"
    command: /docker-entrypoint.sh
    volumes:
      - ..:/code
    ports:
      - "8000:8000"
```

The [Docker-Compose Reference | Docker](https://docs.docker.com/compose/compose-file/) will be your source of truth on the individual pieces of this.

10. Source the environment file: `source $ /path/to/env.sh`

11. You should now be able to create an initial Django project by running the following command:

```
`docker-compose -p $PROJECT_NAME run api django-admin.py startproject $PROJECT_NAME .`
```

12. At this point you should be able to startup your basic Django app:

```
docker-compose -p $PROJECT_NAME up
```

13. And go to `localhost:8000` in your browser to see the initial DJANGO APP

14. If you keep this container running and open a new terminal window you should be able to ssh into the container:

```
docker exec -it <YOUR_CONTAINER_NAME> /bin/bash
```

15. At this point you can run bash commands and the like.

16. You should be able to start developing. You may want to add a more advanced database (https://github.com/hackoregon/postgis-geocoder-test), walkthrough the GeoDjango tutorial (https://docs.djangoproject.com/en/2.0/ref/contrib/gis/tutorial/), or build a Django Rest Framework (http://www.django-rest-framework.org/) app with the POSTGIS backing as next steps. Using the ssh shell could help with this.


## Docker Environment

This portion of the guide, will also provide some introductory information into Docker to help our volunteers get up and running in this project season.

## Getting Started - What is Docker?

If you are not familiar with Docker, your first step should be understanding the basics of Docker, ie how it works, some terms, and how it is different then running a full virtual machine like Vagrant.

I would suggest watching this video to get a short introduction into Docker:  
[Docker Tutorial - What is Docker & Docker Containers, Images, etc?](https://www.youtube.com/watch?v=pGYAg7TMmp0)


This is also a great guide to review:  
[A Beginner-Friendly Introduction to Containers, VMs and Docker](https://medium.freecodecamp.org/a-beginner-friendly-introduction-to-containers-vms-and-docker-79a9e3e119b)

Next, you will need to install Docker if you have not already...


## Installing Docker

Instead of providing specific instructions here, we will link to the Docker guides on installing.

* We will be working with Docker CE (Community Edition) as an Open Source Project.

### Installing for Macs

*System Requirements*

* Mac hardware must be a 2010 or newer model, with Intel’s hardware support for memory management unit (MMU) virtualization; i.e., Extended Page Tables (EPT) and Unrestricted Mode. You can check to see if your machine has this support by running the following command in a terminal: sysctl kern.hv_support

* macOS El Capitan 10.11 and newer macOS releases are supported. At a minimum, Docker for Mac requires macOS Yosemite 10.10.3 or newer, with the caveat that going forward 10.10.x is a use-at-your-own risk proposition.

* Starting with Docker for Mac Stable release 1.13, and concurrent Edge releases, we will no longer address issues specific to macOS Yosemite 10.10. In future releases, Docker for Mac could stop working on macOS Yosemite 10.10 due to the deprecated status of this macOS version. We recommend upgrading to the latest version of macOS.

* At least 4GB of RAM

* VirtualBox prior to version 4.3.30 must NOT be installed (it is incompatible with Docker for Mac). If you have a newer version of VirtualBox installed, it’s fine.

If your system does not meet these minimum requirements you will not be able to run Docker for Mac. You may attempt to run using [Docker Toolbox](https://docs.docker.com/toolbox/overview/) but this has not been tested and we may have limited assistance to troubleshoot issues.

*Installation*

When you are ready follow Docker's Official Guide to install Docker for Mac:  
[Docker for Mac Installation](https://docs.docker.com/docker-for-mac/install/)

All work should be done using the "Stable" build.

### Installing for Windows 10

<Update Coming>

### Installing for Ubuntu/Linux Systems

You will want to consult Docker's Guides to installation on Linux Systems:

* [Ubuntu](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* [Debian](https://docs.docker.com/engine/installation/linux/docker-ce/debian/)
* [CentOS](https://docs.docker.com/engine/installation/linux/docker-ce/centos/)
* [Fedora](https://docs.docker.com/engine/installation/linux/docker-ce/fedora/)

### About this Repo

This repo contains the source files for building the docker images that will be used to and deploy the 2018 Hack Oregon Transportation Systems API and Database. The base image has been built to use only env variables for repo name and other assets. As such it should be useful across other teams.
