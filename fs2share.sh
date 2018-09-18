#!/bin/bash

if [ -d $1 ] ; then
  hash=$(ipfs add -r $1 | sed -e '$!d' | awk '{split($0, a, " "); print a[2]}')
  echo "https://gateway.ipfs.io/ipfs/${hash}"
elif [ -f $1 ] ; then
  hash=$(ipfs add -r $1 | sed -e '$!d' | awk '{split($0, a, " "); print a[2]}')
  echo "https://gateway.ipfs.io/ipfs/${hash}"
fi

