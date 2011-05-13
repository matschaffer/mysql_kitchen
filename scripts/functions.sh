IMG="$HOME/Desktop/Not Backed Up/OS/VBox Images/Ubuntu64Base.ova"

import() {
  VBoxManage import "$IMG" --vsys 0 --vmname "$1"
  VBoxManage modifyvm "$1" --macaddress1 auto
}

destroy() {
  VBoxManage unregistervm "$1" --delete
}

bridge() {
  local NIC=$(echo $(VBoxManage list bridgedifs | grep -m1 Name | awk '{ $1=""; print $0 }'))
  echo "Bridging networking to $NIC"
  VBoxManage modifyvm "$1" --nic1 bridged --bridgeadapter1 "$NIC"
}

start() {
  VBoxManage startvm "$1" --type headless
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

stop() {
  VBoxManage controlvm "$1" acpipowerbutton
  while VBoxManage list runningvms | grep "$1" > /dev/null 2>&1; do
    sleep 1
  done
  sleep 1
}
