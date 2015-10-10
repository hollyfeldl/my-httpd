#!/bin/bash

# script to rebuild the markrank.net website

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


# we are done
exit 0

