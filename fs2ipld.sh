#!/bin/bash

conf_dir=$HOME/.fs2ipld
dir=$HOME/Notes

ipfs=$(which ipfs)
last_date=$(date +%s)
crypt=1

function encrypt {

  echo "REMOVING...$1"
  rm -rf $1
  cp -R $dir $conf_dir

  pushd $1 

  find . -type f -exec gpg --encrypt --recipient "datafatmunger" {} \;
  find . -type f  ! -name "*.gpg"  -delete

  popd

}

function add_commit {

    last_hash=$(cat $conf_dir/ipld_hash)

    # Add directory and files to IPFS - JBG
    hash=$($ipfs add -r $1 | sed -e '$!d' | awk '{split($0, a, " "); print a[2]}')

    if [ $crypt -eq 1 ] ; then
      rm -rf $1 
    fi

    pushd $conf_dir
    
    date=$(date +%s)

    if [ ${#last_hash} -gt 0 ] ; then 
      echo "{ \
        \"prev\": { \"/\": \"$last_hash\" }, \
        \"dir\": { \"/\": \"$hash\" }, \
        \"date\": $date \
      }" > state.json
    else 
      echo "{ \
        \"dir\": { \"/\": \"$hash\" }, \
        \"date\": $date \
      }" > state.json
    fi

    ldhash=$($ipfs dag put state.json)
    $ipfs name publish $ldhash
    echo $ldhash > ipld_hash
    
    popd 
}

inotifywait -r -m \
  -e close_write \
  -e move \
  -e delete \
  "$dir" --format "%e %w" |
  while read event file; do 
    d=$(date +%s)

    if [ $d -gt $last_date ] ; then
      echo "UPDATE HAPPENED! $event $file $d"
      last_date=$d

      # Create the configuration directory if it doesn't exist - JBG
      mkdir -p $conf_dir
      
      work_dir=$dir

      if [ $crypt -eq 1 ] ; then
        work_dir=$conf_dir/$(basename $dir)
        encrypt $work_dir
      fi
      add_commit $work_dir
    fi
  done

