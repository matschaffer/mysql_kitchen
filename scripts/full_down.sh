#!/bin/sh

source "`dirname $0`/functions.sh"

stop MySQLMaster
stop MySQLSlave
destroy MySQLMaster
destroy MySQLSlave

