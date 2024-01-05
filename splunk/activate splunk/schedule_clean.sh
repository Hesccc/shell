#!/bin/bash

# Author: tacoff
# Comment: clean license limit

SPLUNK_HOME="/opt/splunk"
SPLUNK_BIN="$SPLUNK_HOME/bin/splunk"
SPLUNK_LOGDIR="$SPLUNK_HOME/var/log/splunk"
USER="admin"
PASSWORD="password"
FLAG_CLEAN=""

function log_msg() {
    current_time=$(date +"%F %T")
    MSG="$current_time $1"
    echo $MSG
}

function exec_reset() {
    log_msg "execute the license clean"
    SPLUNK_DATADIR=$($SPLUNK_BIN  show datastore-dir | grep -Eo "/\w+.*")
    log_msg "SPLUNK_DATADIR: $SPLUNK_DATADIR"
    $SPLUNK_BIN stop
    rm -rf $SPLUNK_DATADIR/fishbucket/40*
    # ls -l $SPLUNK_DATADIR/fishbucket/40*
    rm -rf $SPLUNK_DATADIR/fishbucket/rawdata/*
    # ls -ld $SPLUNK_DATADIR/fishbucket/rawdata/
    rm -rf $SPLUNK_LOGDIR/license*
    # ls -l $SPLUNK_LOGDIR/license*
    $SPLUNK_BIN start
}

function check_health() {
    FLAG_CLEAN=$($SPLUNK_BIN search "index=main earliest=-3m | stats count" -auth $USER:$PASSWORD 2>&1 | grep -o "license limit too many times")
}

function main() {
    log_msg "ready to check the license"
    check_health
    license_status=$FLAG_CLEAN
    log_msg "license status: $license_status"
    if [[ $license_status != "" ]]
    then
        exec_reset
    fi
}

main
