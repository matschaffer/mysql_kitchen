#!/bin/sh

bridge() {
  local NIC=$(echo $(VBoxManage list bridgedifs | grep -m1 Name | awk '{ $1=""; print $0 }'))
  echo "Bridging networking to $NIC"
  VBoxManage modifyvm "$1" --nic1 bridged --bridgeadapter1 "$NIC"
}

start() {
  VBoxManage startvm "$1" #--type headless
}

ip_info() {
  VBoxManage guestproperty get "$1" /VirtualBox/GuestInfo/Net/0/V4/IP | grep Value
}

get_ip() {
  while ! ip_info "$1" > /dev/null 2>&1; do
    sleep 1
  done
  ip_info "$1" | cut -d' ' -f2
}

bridge MySQLMaster
bridge MySQLSlave
start MySQLMaster
start MySQLSlave
echo "Master IP:" `get_ip MySQLMaster`
echo "Slave IP:" `get_ip MySQLSlave`
