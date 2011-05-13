#!/bin/sh

destroy() {
  VBoxManage unregistervm "$1" --delete
}
destroy MySQLMaster
destroy MySQLSlave
