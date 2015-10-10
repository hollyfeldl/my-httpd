#!/bin/bash

#tests for build_markrank_net.sh

echo "Test no parms - type lower case y"
./build_markrank_net.sh 

echo "Test one parm - type upper case Y"
./build_markrank_net.sh parm1

echo "Test two parms - type y"
./build_markrank_net.sh parm1 parm2

echo "Test abort - type n"
./build_markrank_net.sh abort1 abort2


