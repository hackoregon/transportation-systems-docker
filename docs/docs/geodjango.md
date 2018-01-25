# GEODJANGO Container

These steps should get you up and running with the GeoDjango Container. These processes are open to improvement. Follow Hack Oregon and Team guidelines for development and submitting a Pull Request.

This guide attempts to walk through some best practices, strategies that will make your life easier but code changes. Docs are only alive as their users contribute to them.

We are roughly following

## Create new project repo

First go ahead a create the new repo for the project. If this is a Hack Oregon project, create the repo within the Hack Oregon organization. If you are unable to, contact a member of the leadership team.

When creating the repo in the UI, you should go ahead and select the Python .gitignore template as well as your desired license template.

Once the repo is created, clone the empty repo to your local machine. Follow your project rules in terms of branching and git workflow. I will not mention this going forward but will say I suggest branching at this point.

## Create GEODJANGO DOCKERFILE

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
ENTRYPOINT [ "/code/bin/docker-entrypoint.sh" ]
```

*Let's Break this Down*

`FROM bhgrant/hacko-geodjango` - First Step of the pulls the base image from Dockerhub and builds a container from this locally. See the Github Repo for this image to see what this includes.

`ENV PYTHONUNBUFFERED 1` - Sets the PYTHONUNBUFFERED environment variable  
`EXPOSE 8000` - opens this port  
`WORKDIR /code` This sets the current directory (the code directory exits in the docker image)
`COPY requirements.txt /code/  
RUN pip install -r requirements.txt` - These lines copy the requirements.txt file into the base directory of the image ('/code') and then runs pip install to install any of the specified packages. You will want to add any new packages that you need into this file. Be sure to specify the version number to avoid packages being updated upon a new run of docker build.  
`RUN python` - confirms python is working  
`COPY . /code/` creates a new layer copying rest of the local directory into the docker image (this moves your actual app code into the image)  

`ENTRYPOINT [ "/code/bin/docker-entrypoint.sh" ]` The command or shell script that the container will run as default. This may be overridden in the docker-compose file or a CLI command.  

## Create GeoDjango Entrypoint files

In order to organize the files a bit easier, let's go ahead and create a bin folder:

```
$ cd <Local Github repo>
$ mkdir bin
$ cd bin
```

Now we could go ahead and just name this new file `docker-entrypoint.sh`, the name we specified in the `ENTRYPOINT` line in the DOCKERFILE, but let's think ahead a bit. We may need to take some different startup steps if creating a local build vs. testing build vs. production build, or something along these lines.

Let's go ahead and create entrypoint files that reflect the environment, starting with the local/development build:

4. `$ touch local-geodjango-entrypoint.sh`

Now let's open this file up in your text editor of choice.

At this point you may only be entering in the basic django startup command to run the dev server environment:

```
#! /bin/bash

python3 manage.py runserver 0.0.0.0:8000
```

Go ahead and save this file.


## Create the Requirements.txt file

Ok, now let's go back and look at the DOCKERFILE.

```
...
COPY requirements.txt /code/
RUN pip install -r requirements.txt
...
```

Notice the requirements.txt? Well lets go ahead and create this.

If you are not familiar with python, the requirements.txt file is will you will list all the python package requirements for the project. PIP will install these packages upon build and startup of the container depending on if any changes are detected.

If you were using the official Docker Python image, you would be adding in all the necessary packages into this file for Django, DRF, your database connector, and so on. However the GEODJANGO docker image in this repo has many of the necessary packages already installed, so you will not have to include them. See the [geodjango-requirements.txt](https://github.com/hackoregon/transportation-systems-data-docker/blob/master/requirements/geodjango-requirements.txt) file.

Ok, so we got a good base for building the API but what about packages that are going to be useful in your API?

This is where you will adding a new requirements.txt file into your repo comes into play.

Think about where to put this, in root directory or possibly in a subfolder, if your use case may require multiple requirements files. If so you will need to change your path to this file in the DOCKERFILE.

Now add your packages here when you need. I would strongly advise specifying version numbers. Otherwise you may run into compatibility issues if the container is rebuilt as it will be checking for the current version anytime the container is rebuilt.


## Create the Docker-Compose.yml files

So we have most of the raw pieces of our development setup now (we'll talk database in a moment)

Our docker-compose.yml file will link this all together.

Here is the base template (you'll find this example in /composefiles/geodjango-compose.yml):

Again you may want to pay attention to the environment in naming though it will link all the services together, so you can drop the service name.

IE: `local-compose.yml`

```
version: '3'
services:
  db:
    image: znmeb/postgis
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_USER=${POSTGRES_USER}
  api:
    environment:
    - DEBUG=${DEBUG}
    - PROJECT_NAME=${PROJECT_NAME}
    build:
      context: ..
      dockerfile: /dockerfiles/GEODJANGO-DOCKERFILE
    image: "${API_DOCKER_IMAGE}"
    command: ./entrypoints/GEODJANGO-entrypoint.sh
    volumes:
      - ..:/code
    ports:
      - "8000:8000"
    depends_on:
      - db
```

The [Docker-Compose Reference | Docker](https://docs.docker.com/compose/compose-file/) will be your source of truth on the individual pieces of this.

*A few things to make note of:*

* String interpolation - ${VARIABLE} - these are environment variables being passed into the container (These will be set in the env.sh file to be discussed.)
* `context: ..` -  a string containing a path to the build. This is a relative path so this is stepping back one step in the directory structure (think `cd ..`), you may not want this, depending on location of compose file.
* This is using @znmeb's [PostGIS image](https://github.com/hackoregon/postgis-geocoder-test) for the database. The depends_on, means it will wait to create the api until the db is up and working to prevent an error if db is unavailable.

## Create an Environment file and add to .gitignore

First go ahead and add this to your .gitignore and save:

```
**/env.sh
```

**IF you name your environment file anything else be sure this is in the .gitignore**

Now in your bin folder create you env.sh file.

There is a rough template in the bin directory of this repo:

```
./bin/env.sh.sample
```

Environment variables will be important to moving the code through the stages of development from local dev to testing to eventually prod. They are also vital to *keeping secrets out of public or private code repositories*

At this point you will only need to set the variables that are being specified in the Docker-Compose file.

**Do not push an image which contains secrets to DockerHub**


## Building the Container and App First Time

For the first time you are getting the container up and running you should follow the basic steps in the [Quickstart: Compose and Django Container | Docker](https://docs.docker.com/compose/django/) from this point on:  
[Create a Django Project | Docker](https://docs.docker.com/compose/django/#create-a-django-project).

A few notes:
* If you have followed the templates provided the names of services and other variables may not directly match those in the example
* An example command that can use the env variables (make sure to `source` the file before): `docker-compose -f ./composefiles/geodjango-compose.yml -p $PROJECT_NAME run api django-admin.py startproject $PROJECT_NAME .`


Then you will also need to follow similar steps to configure the Django Rest Framework following their [Quickstart Guide | Django Rest Framework](http://www.django-rest-framework.org/tutorial/quickstart/) within the docker container.
* As you have already created the Django project, you will not do this again, just start with the startapp. Instead of running this within the project directory, run it in the root. so the project and app directories will be both children of the root directory.

In testing I had more success running these commands through an interactive Bash Shell in the container. To get that going follow the next steps to start up the container. With the container running, open an new terminal window and run:

```
docker exec -it <YOUR_CONTAINER_NAME> /bin/bash
```

This should open a SSH session into the docker container. You should then be able to run any commands needed.


## Starting the app

Checkout the `/bin/start-project.sh` file in this repo for examples on how to start the cotainer. As Docker-Compose and Docker CLI commands can become quite complex, you should create a similar script file to make restarting the container easy.

This will be important in the deployment chain as well, as you may run different startup commands based on the environment.

* Note you also will see the `kill.sh` file in the bin directory. These are the basic commands that you can use to kill the container or remove the image completely from your hard drive. You may find these handy in development if a container ever hangs on or you want to start from scratch to test a build.

## Next steps

Start building your app!.  But there is a lot more config that will come up as you go, especially as we move to building the full tool and deploy chain. Continue to document from here.

A good mind set to continue is the [12 Factor APP](https://12factor.net/)
