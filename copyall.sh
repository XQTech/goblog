#!/bin/bash
cd accountservice;go get;go build --tags netgo -o accountservice-linux-amd64;echo built `pwd`;cd ..
cd healthchecker;go get;go build --tags netgo -o healthchecker-linux-amd64;echo built `pwd`;cd ..
cp healthchecker/healthchecker-linux-amd64 accountservice/
docker build -t xqtech/accountservice accountservice/
docker service rm accountservice
docker service create --name=accountservice --replicas=1 --network=my_network -p=6767:6767 xqtech/accountservice