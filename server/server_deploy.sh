#!/bin/bash

# stop all docker containres
docker stop $(docker ps -a -q)
# remove all docker containres
docker rm $(docker ps -a -q)
# docker remove docker images
docker image rm mdlab-app
# docker load local image
docker load -i mdlab.tar
# docker start
docker run --name mdlab-app --tty --publish 8080:8080 mdlab-app

