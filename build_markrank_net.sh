#!/bin/bash

# script to rebuild the markrank.net website

echo "**********************************"
echo "* Build markrank.net             *"
echo "**********************************"

# look for container name as the second parm and if not default it

if [ -z $3 ] 
then
	curKeyPath="/home/mark/dev/private_keys"
	echo "WARN - No path to the private SSL stuff, default to" $curKeyPath
else
	curContainer=$3
	echo "INFO - Container set to" $curKeyPath
fi

if [ -z $2 ] 
then
	curContainer="my-httpd"
	echo "WARN - No container provided, default to" $curContainer
else
	curContainer=$2
	echo "INFO - Container set to" $curContainer
fi

# look for the project id
if [ -z $1 ] 
then
	curProject="my-container-httpd"
	echo "WARN - No project provided, default to" $curProject
else
	curProject=$1
	echo "INFO - Project set to" $curProject
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
	echo "INFO - Using local Dockerfile"
	cat ./Dockerfile
else
	echo "ERROR - Cannot find Dockerfile to build container"
	exit 1
fi

# look for the DH Parms
if test -e "$curKeyPath/dhparams_2048.pem"
then 
	echo "INFO - Found DH Parms file"
	cp -v $curKeyPath/dhparams_2048.pem ./dhparams_2048.pem
else
	echo "ERROR - Cannot find DH Params file"
	exit 1
fi

# look for the the private key
if test -e "$curKeyPath/markrank-key.pem"
then 
	echo "INFO - Found the private key file"
	cp -v $curKeyPath/markrank-key.pem ./markrank-key.pem
else
	echo "ERROR - Cannot find private key file file"
	exit 1
fi

echo "INFO - Build a new cert with a 90 day life"
openssl req -new -x509 -key ./markrank-key.pem -out ./markrank-part.pem -days 90 -nodes

echo "INFO - Add on the unique DH Parms to the end of the cert"
cat ./markrank-part.pem ./dhparams_2048.pem > ./markrank.pem

echo "INFO - rebuild the container using the latest httpd" 
docker build -t gcr.io/$curProject/$curContainer --pull=true .

# some feedback
docker images | grep $curContainer

echo "INFO - push the container to gcloud repository"
gcloud docker push gcr.io/$curProject/$curContainer

echo "INFO - build the cluster"
gcloud container clusters create $curContainer-cluster --num-nodes 1 --machine-type g1-small

echo "INFO - start a pod with the image on port 443"
kubectl run $curContainer --image=gcr.io/$curProject/$curContainer --port=443

echo "INFO - expose the service with an external load balancer"
kubectl expose rc $curContainer --create-external-load-balancer=true

echo "INFO - clean up the local cert info"
rm -v ./markrank.pem
rm -v ./markrank-key.pem
rm -v ./markrank-part.pem
rm -v ./dhparams_2048.pem

echo "INFO - where is it running (kubectl get services)" 
kubectl get services $curContainer

# we are done
exit 0

