#!/bin/sh

# create image
#docker build . --file Dockerfile --tag mdlab-app --platform linux/amd64
# save image localy
docker save -o ./docker-images/mdlab.tar mdlab-app
# upload docker image on cloud server
scp ./docker-images/mdlab.tar ${SERVER_USER}@${SERVER_IP}:/root/server
scp ./server_deploy.sh ${SERVER_USER}@${SERVER_IP}:/root/server

ssh ${SERVER_USER}@${SERVER_IP} "cd server && sh server_deploy.sh"
