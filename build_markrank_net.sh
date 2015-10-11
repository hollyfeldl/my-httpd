#!/bin/bash

# script to rebuild the markrank.net website

echo "**********************************"
echo "* Build markrank.net             *"
echo "**********************************"

# look for container name as the second parm and if not default it

if [ -z $2 ] 
then
	curContainer="my-httpd"
	echo "No container provided, default to" $curContainer
else
	curContainer=$2
	echo "Container set to" $curContainer
fi

# look for the project id
if [ -z $1 ] 
then
	curProject="my-container-httpd"
	echo "No project provided, default to" $curProject
else
	curProject=$1
	echo "Project set to" $curProject
fi

# ask if we shoud continue
echo -n "Should we proceed (y/n)?"
read curPrompt
case $curPrompt in
	y) echo "Let's Go!";;
	Y) echo "Sure, same thing. Let's Go!";;
    *) echo "Well, better luck next time."; exit 0;;
esac

# look for the Dockerfile
if test -e "./Dockerfile"
then 
	echo "Using local Dockerfile"
	cat ./Dockerfile
else
	echo "Cannot find Dockerfile to build container"
	exit 1
fi

echo "rebuild the container using the latest httpd" 
docker build -t gcr.io/$curProject/$curContainer --pull=true .

# some feedback
docker images | grep $curContainer

echo "push the container to gcloud repository"
gcloud docker push gcr.io/$curProject/$curContainer

echo "build the cluster"
gcloud container clusters create $curContainer-cluster --num-nodes 1 --machine-type g1-small

echo "start a pod with the image"
kubectl run $curContainer --image=gcr.io/$curProject/$curContainer --port=80

echo "expose the service with an external load balancer"
kubectl expose rc $curContainer --create-external-load-balancer=true

# some feedback
kubectl get services $curContainer

# we are done
exit 0

