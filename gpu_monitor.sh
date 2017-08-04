#!/bin/bash

SERVER_LIST=~/scripts/config/gpu_server.lst
GPU_FLAG=0
PROC_FLAG=0
OFFLINE_FLAG=0
OFFLINE_SERVER="#"

if ! [ -f $SERVER_LIST ];then
    echo "No such File : $SERVER_LIST"
fi

if [ $# -eq 0 ];then
    GPU_FLAG=1
    PROC_FLAG=1
elif [ "$1" == "-gpu" ] ;then
    GPU_FLAG=1
elif [ "$1" == "-p" ] ;then
    PROC_FLAG=1
else
    echo "Invalid input"
    echo "Usage : gpu_monitor.sh      #Show GPU status and Processes in GPU"
    echo "        gpu_monitor.sh -gpu #Show GPU status"
    echo "        gpu_monitor.sh -p   #Show Processes in GPU"
    exit
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

if [ $GPU_FLAG -eq 1 ];then
    echo "|----------------------------------------+----------------------+----------------------+"
    echo "|  Host  | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |"
    echo "|  Name  | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |"
    echo "|========================================+======================+======================|"
    
    for SERVER in `cat $SERVER_LIST | egrep -v "${OFFLINE_SERVER}"`
    do
        ssh $SERVER "nvidia-smi" | awk -v svr="$SERVER" -v flags=0 '/.=/ {flags=flags+1}; {if(flags==1 && NF==0) exit}; {if(flags==1) print "|"svr,$0};' | grep "| "
    done
    
    echo "+----------------------------------------+----------------------+----------------------+"
    echo ""
fi

if [ $PROC_FLAG -eq 1 ] ;then
    echo "+--------------------------------------------------------------------------------------+"
    echo "|  Host  | Processes:                                                       GPU Memory |"
    echo "|  Name  |  GPU       PID  Type  Process name                               Usage      |"
    echo "|========================================+======================+======================|"
    echo "+--------------------------------------------------------------------------------------+"
    
    for SERVER in `cat $SERVER_LIST | egrep -v "${OFFLINE_SERVER}"`
    do
        ssh $SERVER "nvidia-smi" | awk -v svr="$SERVER" -v flags=0 '/.=/ {flags=flags+1}; {if(flags==3) print "|"svr,$0}; /Processes:/ {flags=flags+1}' | grep "| "
    done
    
    echo "+--------------------------------------------------------------------------------------+"
    echo ""
fi
