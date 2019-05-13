#!/bin/bash

echo "entering!"

{
  . /docker-helpers.sh
  function cleanup_docker() {
    clean_docker || true
    stop_docker || true
  }
  trap cleanup_docker EXIT
}

"$@"
