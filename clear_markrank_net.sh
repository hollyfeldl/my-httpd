#!/bin/bash

# script to clear the gcloud objects for markrank.net website

echo "**********************************"
echo "* Clear markrank.net             *"
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

# some feedback
kubectl get services $curContainer

# ask if we shoud continue
echo -n "Sure you want to do this (y/n)?"
read curPrompt
case $curPrompt in
	y) echo "Let's Go!";;
	Y) echo "Sure, same thing. Let's Go!";;
    *) echo "Well, better luck next time."; exit 0;;
esac

echo "Step 1 - Delete the service"
kubectl delete services $curContainer

echo "Step 2 - Stop the pod(s)"
kubectl stop rc $curContainer

echo "Step 3 - Drop the cluster"
gcloud container clusters delete $curContainer-cluster

echo "Check that things are clean"
gcloud container clusters list

# we are done
exit 0

