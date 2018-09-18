#!/bin/bash

#pushd $1 

#find $1 -type d -exec gpg --decrypt-files {} \;

for f in $(find $1 -type f) ; do
  echo $f
  gpg --decrypt-files $f
  rm $f
done

#popd

