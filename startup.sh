#!/bin/bash

set -x
MY_WORKSPACE_CONTAINER_NAME="${1:?please specify a container name}"
MY_WORKSPACE_CONTAINER_IMAGE="myworkstation"
GMAIL_USER="vincent.riesop@gmail.com"
RESET_CONTAINER=1
LOCAL_USER_NAME=dev

WORKINGDIR="${2:?please specify a working dir}"

function build_image() {
    docker build \
        --build-arg GMAIL_USER="${GMAIL_USER}" \
        --build-arg LOCAL_USER_NAME="$LOCAL_USER_NAME" \
        -t "${MY_WORKSPACE_CONTAINER_IMAGE}":latest .
}

function start_container() {
    docker start ${MY_WORKSPACE_CONTAINER_NAME}
}

function create_container() {
    docker create \
            --name "${MY_WORKSPACE_CONTAINER_NAME}" \
            -t \
            -v  ~/.ssh:/home/dev/.ssh \
            -v  ${WORKINGDIR}:/home/dev/workingdir \
            "${MY_WORKSPACE_CONTAINER_IMAGE}:latest"
}

function connect_container(){
    docker exec -it "${MY_WORKSPACE_CONTAINER_NAME}" /bin/bash
}

function remove_container(){
    docker stop "${MY_WORKSPACE_CONTAINER_NAME}" 
    docker rm "${MY_WORKSPACE_CONTAINER_NAME}"
}


function main_entry(){

    build_image

    if [ "$(docker ps -q -f name=${MY_WORKSPACE_CONTAINER_NAME})" ]; then
        echo "### Container exists"
        if [ "$RESET_CONTAINER" ]; then
            echo "### Removing Container first (RESET_CONTAINER enabled)"
            remove_container 
            echo "### Re-Creating container"
            create_container
        fi
    else 
        echo "### Creating container"
        create_container
    fi

    if [ "$( docker container inspect -f '{{.State.Status}}' $MY_WORKSPACE_CONTAINER_NAME )" == "running" ]; then 
        echo "### Already running."
    else
        start_container
    fi
    echo "### Connecting to ${MY_WORKSPACE_CONTAINER_NAME} container"
    connect_container
}


main_entry
