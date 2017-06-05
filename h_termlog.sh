HOME_DIR="/Users/`id -un`"
DATE_TIME=`date +%Y%m%d_%H%M%S`
LOG_DIR="${HOME_DIR}/logs/termlog"
LOG_FILE="${LOG_DIR}/localhost_${DATE_TIME}.log"
TMP_DIR="${HOME_DIR}/tmp"
TMP_LOG_FILE="${TMP_DIR}/localhost_${DATE_TIME}.log.tmp"
mkdir -p ${LOG_DIR}
mkdir -p ${TMP_DIR}
touch ${TMP_LOG_FILE}
tail -F ${TMP_LOG_FILE} | awk '{ date_cmd="date +%m/%d_%H:%M:%S"; date_cmd | getline date; print date " " $0; close(date_cmd)}' > ${LOG_FILE} &
TAIL_PID=`ps -ef | grep "tail -F ${TMP_LOG_FILE}" | grep -v grep | awk '{ print $2 }'`
script -a -t 0 ${TMP_LOG_FILE}
echo kill `ps -ef | grep ${TAIL_PID} | grep -v grep`
kill ${TAIL_PID} || echo "Failed to kill ${TAIL_PID}"
rm ${TMP_LOG_FILE} || echo "Failed to remove ${TMP_LOG_FILE}"
echo "LOGGING COMMPLETE!!! LOGFILE IS ${LOG_FILE}"
exit
