#!/bin/bash
BASENAME=`basename $0`
SERVER_LIST=~/scripts/config/gpu_server.lst
CMD="$1"
OFFLINE_FLAG=0
OFFLINE_SERVER="#"
YES_FLAG="-n"

if ! [ -f $SERVER_LIST ];then
    echo "No such File : $SERVER_LIST"
fi

if [ $# -eq 0 ];then
    echo "Invalid input"
    echo "Usage : $BASENAME \"command\"      #Broadcast command for all servers"
    exit
fi

if [ $# -eq 2 ];then
    YES_FLAG="$2"
fi

for SERVER in `cat $SERVER_LIST`
do
    nc -z -w 1 $SERVER 22
    OFFLINE_FLAG=`echo $?`
    if [ $OFFLINE_FLAG -ne 0 ];then
        OFFLINE_SERVER=`echo "${OFFLINE_SERVER}|${SERVER}"`
        echo "[WARN] Cannnot connnect $SERVER !!!"
    fi
done

echo "You will execute following command."
echo "####command####"
echo "$1"
echo ""
echo "Is it OK? [y/n]"
ANS="n"
if [ ${YES_FLAG} == "-y" ];then
    ANS="y"
else
    read ANS
fi

if [ $ANS == "y" ];then
    for SERVER in `cat $SERVER_LIST | egrep -v "${OFFLINE_SERVER}"`
    do
        echo "Exectuting in ${SERVER}"
        ssh ${SERVER} "${CMD}"
        if [ ${YES_FLAG} != "-y" ];then
            echo "Done. Press enter to continue."
            read
        fi
    done
fi
