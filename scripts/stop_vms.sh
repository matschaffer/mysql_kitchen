#!/bin/sh

stop() {
  VBoxManage controlvm $1 acpipowerbutton
}
stop MySQLMaster
stop MySQLSlave
