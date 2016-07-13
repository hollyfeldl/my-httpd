#!/bin/bash

# script to perform a rolling upgrade to markrank.net website

echo "**********************************"
echo "* Upgrade markrank.net           *"
echo "*                                *"
echo "**********************************"

# look for container name as the second parm and if not default it

if [ -z $4 ] 
then
	curRepController="markrank-net-httpd-rc"
	echo "WARN - No replication controller provided, default to" $curRepController
else
	$curRepController=$4
	echo "INFO - replication controller set to" $curRepController
fi

if [ -z $3 ] 
then
	curKeyPath="/home/mark/dev/private_keys"
	echo "WARN - No path to the private SSL stuff, default to" $curKeyPath
else
	$curKeyPath=$3
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

#look what is in the SSL staging area
ls -als ./ssl

# clear it out
echo -n "Should we empty ssl directory (y/n)?"
read curClearSSL
case $curClearSSL in
	y) echo "Let's Go!"; rm -v ./ssl/*.pem ;;
	Y) echo "Sure, same thing. Let's Go!"; rm -v ./ssl/*.pem ;;
    *) echo "Well, better luck next time."; exit 0;;
esac

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

# look for the the private key
if test -e "$curKeyPath/markrank-key.pem"
then 
	echo "INFO - Found the private key file"
	cp -v $curKeyPath/markrank-key.pem ./ssl/markrank-key.pem
else
	echo "ERROR - Cannot find private key file file"
	exit 1
fi

echo "INFO - Build a new cert with a 90 day life"
openssl req -new -x509 -key ./ssl/markrank-key.pem -out ./ssl/markrank.pem -days 90 -nodes

echo "INFO - Come up with unique container label"
curLabel=$(date --rfc-3339=date)
echo "INFO - Container will be "$curContainer":"$curLabel

echo "INFO - Run SASS to build the CSS"
sass ./html/static/markrank_flex.sass ./html/static/markrank_flex.css
ls -al ./html/static/markrank_flex.*

echo "INFO - rebuild the container using the latest httpd" 
docker build -t gcr.io/$curProject/$curContainer:$curLabel --pull=true .

# some feedback
docker images | grep $curContainer

echo "INFO - push the container to gcloud repository"
gcloud docker push gcr.io/$curProject/$curContainer:$curLabel

echo "INFO - perform a rolling upgrade of " $curRepController " to the new container image"
kubectl rolling-update $curRepController --image=gcr.io/$curProject/$curContainer:$curLabel

echo "INFO - Feedback some public cert info"
openssl x509 -sha256 -in ./ssl/markrank.pem -fingerprint -serial -startdate -enddate

echo "INFO - check the replication controller version (kubectl describe rc " $curRepController ")" 
kubectl describe rc $curRepController

echo "INFO - clean up the local cert info"
rm -v ./ssl/markrank.pem
rm -v ./ssl/markrank-key.pem

# we are done
exit 0

