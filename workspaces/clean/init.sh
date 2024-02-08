#!/bin/bash

if [[ -d ansible ]]; then
   rm -r ./ansible 
fi

cp -r ~/ansible ansible

docker build . -f Dockerfile -t clean && docker run --rm -it clean

