#!/bin/sh

stop() {
  VBoxManage controlvm $1 acpipowerbutton
}

wait_for_stop() {
  while VBoxManage list runningvms | grep "$1" > /dev/null 2>&1; do
    sleep 1
  done
}

stop MySQLMaster
stop MySQLSlave
wait_for_stop MySQLMaster
wait_for_stop MySQLSlave
