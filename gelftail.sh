#!/bin/bash

cd gelftail;go get;go build --tags netgo -o gelftail-linux-amd64;echo built `pwd`;cd ..

docker build -t xqtech/gelftail gelftail/
docker service rm gelftail
docker service create --name=gelftail -p=12202:12202/udp --replicas=1 --network=my_network xqtech/gelftail
