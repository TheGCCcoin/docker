#!/bin/sh
echo Building build_daemon

docker build -f Dockerfile.build -t thegcccoin/build .
docker container create --name build_daemon thegcccoin/build
docker container cp build_daemon:/root/build/TheGCCcoin-source-code/src/TheGCCcoind ./TheGCCcoind
docker container rm -f build_daemon

#echo Building TheGCCcoind host
#docker build --no-cache -t thegcccoin/daemon .
#docker container create --name TheGCCcoind thegcccoin/daemon

#docker run -it --name=TheGCCcoind -v ${PWD}/TheGCC:/root/TheGCC -p 127.0.0.1:9332:9332 thegcccoin/daemon:latest
