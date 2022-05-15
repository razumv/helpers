#!/bin/bash

source $HOME/.bash_profile
cd $HOME/$WORKSPACE
docker-compose pull
docker-compose down
docker-compose up -d
