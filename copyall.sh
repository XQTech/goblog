#!/bin/bash

cd accountservice;go get;go build --tags netgo -o accountservice-linux-amd64;echo built `pwd`;cd ..
cd vipservice;go get;go build --tags netgo -o vipservice-linux-amd64;echo built `pwd`;cd ..
cd healthchecker;go get;go build --tags netgo -o healthchecker-linux-amd64;echo built `pwd`;cd ..
cd imageservice;go get;go build --tags netgo -o imageservice-linux-amd64;echo built `pwd`;cd ..


cp healthchecker/healthchecker-linux-amd64 accountservice/
cp healthchecker/healthchecker-linux-amd64 vipservice/
cp healthchecker/healthchecker-linux-amd64 imageservice/

docker build -t xqtech/accountservice accountservice/
docker service rm accountservice
docker service create --log-driver=gelf --log-opt gelf-address=udp://192.168.31.32:12202 --log-opt gelf-compression-type=none --name=accountservice --replicas=1 --network=my_network -p=6767:6767 xqtech/accountservice

docker build -t xqtech/vipservice vipservice/
docker service rm vipservice
docker service create --log-driver=gelf --log-opt gelf-address=udp://192.168.31.32:12202 --log-opt gelf-compression-type=none --name=vipservice --replicas=1 --network=my_network xqtech/vipservice

docker build -t xqtech/imageservice imageservice/
docker service rm imageservice
docker service create --log-driver=gelf --log-opt gelf-address=udp://192.168.31.32:12202 --log-opt gelf-compression-type=none --name=imageservice --replicas=1 --network=my_network -p=7777:7777 xqtech/imageservice