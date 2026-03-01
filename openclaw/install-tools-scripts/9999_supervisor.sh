#! /bin/bash

apt install -y supervisor

mkdir -p $SUPERVISOR_DIR/logs
mkdir -p $SUPERVISOR_DIR/run
chown -R ${USER_NAME}:${USER_NAME} $SUPERVISOR_DIR