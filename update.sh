#!/bin/bash

set -e

if [ $# -eq 0 ] ; then
	echo "Usage: ./update.sh <docker/swarm tag or branch>"
	exit
fi

SWARM_REPO=${SWARM_REPO-https://github.com/docker/swarm.git}

VERSION=$1

# cd to the current directory so the script can be run from anywhere.
cd `dirname $0`

# Update the certificates.
echo "Updating certificates..."
./certs/update.sh

echo "Fetching and building swarm $VERSION..."

# Create a temporary directory.
TEMP=`mktemp -d`

git clone -b $VERSION $SWARM_REPO $TEMP
docker build -t swarm-builder $TEMP

# Create a dummy swarmbuild container so we can run a cp against it.
ID=$(docker create swarm-builder)

# Update the local binary.
docker cp $ID:/go/bin/swarm .

# Cleanup.
docker rm -f $ID
docker rmi swarm-builder

echo "Building swarm.exe $VERSION..."

docker build -t swarm-builder:windows --build-arg GOOS=windows $TEMP

# Create a dummy swarmbuild container so we can run a cp against it.
ID=$(docker create swarm-builder:windows)

# Update the local binary.
docker cp $ID:/go/bin/windows_amd64/swarm.exe .
mv swarm.exe swarm-unsupported.exe

# Cleanup.
docker rm -f $ID
docker rmi swarm-builder:windows

echo "Done."
