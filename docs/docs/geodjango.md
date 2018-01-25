# GEODJANGO Container

These steps should get you up and running with the GeoDjango Container:

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

RUN mkdir /code
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
`RUN mkdir /code` - runs the mkdir command. Each time a RUN, COPY, or ADD command is used, a new layer is created. Later changes will only cause the containing layer down to be rebuilt.
`WORKDIR /code` This sets the current directory
`COPY requirements.txt /code/
RUN pip install -r requirements.txt` - These lines copy the requirements.txt file into the base directory of the image ('/code') and then runs pip install to install any of the specified packages. You will want to add any new packages that you need into this file. Be sure to specify the version number to avoid packages being updated upon a new run of docker build.
`RUN python` - confirms python is working
`COPY . /code/` creates a new layer copying rest of the local directory into the docker image (this moves your actual app code into the image)

`ENTRYPOINT [ "/code/bin/docker-entrypoint.sh" ]` The command or shell script that the container will run as default. This may be overridden in the docker-compose file or a CLI command.

## Create GeoDjango Entrypoint files

In order to organize the files a bit easier, let's go ahead and create a bin folder:

1. `$ cd <Local Github repo>`
2. `$ mkdir bin`
3. `$ cd bin`

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

Notice the requirements.txt? Well lets go ahead and create this.

If you are not familiar with python, the requirements.txt file is will you will list all the python package requirements for the project. PIP will install these packages upon build and startup of the container depending on if any changes are detected.

If you were using the base python image, you would be adding in all the necessary packages into this file. However the GEODJANGO docker image in this repo has many of the necessary packages already installed, so you will not have to include them. See the [geodjango-requirements.txt](/requirements/geodjango-requirements.txt) file.

Now once again, thinking about dev vs. prod environments, lets create a local requirements file:

local-requirements.txt
