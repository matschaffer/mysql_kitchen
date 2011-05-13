#!/bin/sh

IMG="$HOME/Desktop/Not Backed Up/OS/VBox Images/Ubuntu64Base.ova"
import() {
  VBoxManage import "$IMG" --vsys 0 --vmname "$1"
  VBoxManage modifyvm "$1" --macaddress1 auto
}
import MySQLMaster
import MySQLSlave
