#!/bin/bash

SERVER_LIST=~/scripts/config/gpu_server.lst
TMP_DIR=~/tmp
GPU_FLAG=0
PROC_FLAG=0
VERBOSE_FLAG=0
OFFLINE_FLAG=0
OFFLINE_SERVER="#"

if ! [ -f $SERVER_LIST ];then
    echo "No such File : $SERVER_LIST"
fi

if [ $# -eq 0 ];then
    GPU_FLAG=1
    PROC_FLAG=1
    VERBOSE_FLAG=1
elif [ "$1" == "-gpu" ] ;then
    GPU_FLAG=1
elif [ "$1" == "-p" ] ;then
    PROC_FLAG=1
    if [ "$2" == "-v" ]; then
        VERBOSE_FLAG=1
    fi
else
    echo "Invalid input"
    echo "Usage : gpu_monitor.sh       #Show GPU status and Processes in GPU"
    echo "        gpu_monitor.sh -gpu  #Show GPU status"
    echo "        gpu_monitor.sh -p    #Show Processes in GPU"
    echo "        gpu_monitor.sh -p -v #Show Processes in GPU and Process details"
    exit
fi

for SERVER in `cat $SERVER_LIST`
do
    # nc -z -w 1 $SERVER 22
    ping -c 1 -W 1 $SERVER > /dev/null 2>&1
    OFFLINE_FLAG=`echo $?`
    if [ $OFFLINE_FLAG -ne 0 ];then
        OFFLINE_SERVER=`echo "${OFFLINE_SERVER}|${SERVER}"`
        echo "[WARN] Cannnot connnect $SERVER !!!"
    fi
done

for SERVER in `cat $SERVER_LIST | egrep -v "${OFFLINE_SERVER}"`
do
    ssh $SERVER "nvidia-smi" > ${TMP_DIR}/${SERVER}.log &
    ssh $SERVER "ps -ef" > ${TMP_DIR}/${SERVER}_ps.log &
done

# wait for all nvidia-smi
wait

if [ $GPU_FLAG -eq 1 ];then
    echo "|--------+-------------------------------+----------------------+----------------------+"
    echo "|  Host  | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |"
    echo "|  Name  | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |"
    echo "|========+===============================+======================+======================|"
    
    for SERVER in `cat $SERVER_LIST | egrep -v "${OFFLINE_SERVER}"`
    do
        cat ${TMP_DIR}/${SERVER}.log | awk -v svr="$SERVER" -v flags=0 '/.=/ {flags=flags+1}; {if(flags==1 && NF==0) exit}; {if(flags==1) print "|"svr,$0};' | grep "| "
    echo "+--------+-------------------------------+----------------------+----------------------+"
    done
    echo ""
fi

if [ $PROC_FLAG -eq 1 ] ;then
    echo "+--------+-----------------------------------------------------------------------------+"
    echo "|  Host  | Processes:                                                       GPU Memory |"
    echo "|  Name  |  GPU       PID  Type  Process name                               Usage      |"
    echo "|========+=============================================================================|"
    
    for SERVER in `cat $SERVER_LIST | egrep -v "${OFFLINE_SERVER}"`
    do
        cat ${TMP_DIR}/${SERVER}.log | awk -v svr="$SERVER" -v flags=0 '/.=/ {flags=flags+1}; {if(flags==3) print "|"svr,$0}; /Processes:/ {flags=flags+1}' | grep "| " | tee ${TMP_DIR}/${SERVER}-p.log
    echo "+--------+-----------------------------------------------------------------------------+"
    done
    echo ""
fi

if [ $VERBOSE_FLAG -eq 1 ] ;then
    echo "+--------+-----+-----------------------------------------------------------------------"
    echo "|  Host  | GPU | User  PID  PPID  C STIME TTY TIME CMD"
    echo "+--------+-----+-----------------------------------------------------------------------"

    for SERVER in `cat $SERVER_LIST | egrep -v "${OFFLINE_SERVER}"`
    do
        cat ${TMP_DIR}/${SERVER}-p.log | grep -v "No running" > /dev/null
        GPU_PROCESS_FLAG=$?
        if [ $GPU_PROCESS_FLAG -eq 0 ] ;then
            for GPU_NO in `cat ${TMP_DIR}/${SERVER}-p.log | grep -v "No running" | awk '{print $3}' | uniq`
            do
                for PID in `grep $GPU_NO ${TMP_DIR}/${SERVER}-p.log | grep -v "No running" | awk -v gpu=$GPU_NO '$3==gpu {print $4}'`
                do
                    cat ${TMP_DIR}/${SERVER}_ps.log | awk -v svr="$SERVER" -v gpu="$GPU_NO" -v pid="$PID" '$2==pid {print "|"svr" |   "gpu" |",$0}'
                done
            done
        echo "+--------+-----+-----------------------------------------------------------------------"
        fi
    done
fi


# clean up tmp files

for SERVER in `cat $SERVER_LIST | egrep -v "${OFFLINE_SERVER}"`
do
    rm ${TMP_DIR}/${SERVER}.log
done
