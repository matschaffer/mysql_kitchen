#!/bin/sh

source "`dirname $0`/functions.sh"

import MySQLMaster
import MySQLSlave
bridge MySQLMaster
bridge MySQLSlave
start MySQLMaster
start MySQLSlave

MASTER=`get_ip MySQLMaster`
SLAVE=`get_ip MySQLSlave`

echo "Master IP: $MASTER"
echo "Slave IP: $SLAVE"

# TODO: Remove this once littlechef releases apt-get update and node file
#       resolution fix.
alias cook=~/code/littlechef/cook

cook node:$MASTER deploy_chef:gems=yes,ask=no
cook node:$SLAVE deploy_chef:gems=yes,ask=no
cook node:$MASTER role:mysql_master
cook node:$SLAVE role:mysql_slave

cat <<-HELP
All done! Re-cook with:

    cook node:$MASTER role:mysql_master
    cook node:$SLAVE role:mysql_slave

HELP
