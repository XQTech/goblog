#!/bin/bash
set CGO_ENABLED=0
set GOOS=linux
set GOARCH=amd64
cd accountservice;go get;go build -o accountservice-linux-amd64;echo built `pwd`;cd ..
cd healthchecker;go get;go build -o healthchecker-linux-amd64;echo built `pwd`;cd ..

GOOS=linux GOARCH=amd64 go build -tags netgo -o healthchecker-linux-amd64
GOOS=linux GOARCH=amd64 go build -tags netgo -o accountservice-linux-amd64

export GOOS=windows
cp healthchecker/healthchecker-linux-amd64 accountservice/
docker build -t xqtech/accountservice ./
docker run --rm xqtech/accountservice
docker service rm accountservice
docker service create --name=accountservice --replicas=1 --network=my_network -p=6767:6767 xqtech/accountservice