#!/usr/bin/env bash

source /sbin/hdfs-lib.sh

function accumulo_instance_exists() {
  local INSTANCE=$1
  local LS=$(zookeeper-client -server $ZOOKEEPERS ls /accumulo/instances/$INSTANCE 2>&1 > /dev/null)
  if [[ $LS == *"does not exist"* ]]; then
    return 1
  else
    return 0
  fi
}

function wait_until_accumulo_is_available() {
  local INSTANCE=${1:-accumulo}
  wait_until_hdfs_is_available
  with_backoff accumulo_instance_exists $INSTANCE
}

function zookeeper_is_available(){
  [ $(nc ${ZOOKEEPERS} 2181 <<< ruok) == imok ]
  return $?
}

function ensure_user() {
  if [ ! $(id -u $1) ]; then useradd $1 -g root; fi
}
