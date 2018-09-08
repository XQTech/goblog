#!/bin/bash

cd accountservice;go get;go build --tags netgo -o accountservice-linux-amd64;echo built `pwd`;cd ..
cd vipservice;go get;go build --tags netgo -o vipservice-linux-amd64;echo built `pwd`;cd ..
cd healthchecker;go get;go build --tags netgo -o healthchecker-linux-amd64;echo built `pwd`;cd ..

cp healthchecker/healthchecker-linux-amd64 accountservice/
cp healthchecker/healthchecker-linux-amd64 vipservice/

docker build -t xqtech/accountservice accountservice/
docker service rm accountservice
docker service create --name=accountservice --replicas=1 --network=my_network -p=6767:6767 xqtech/accountservice

docker build -t xqtech/vipservice vipservice/
docker service rm vipservice
docker service create --name=vipservice --replicas=1 --network=my_network xqtech/vipservice
