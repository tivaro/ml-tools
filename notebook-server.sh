#!/bin/bash
DEFAULT_PORT=5050
LOG_PATH="/volume/home/ties/logs/jupy"

# TODO:
# name logs with port/pid and clean them up on stopping
# see https://stackoverflow.com/questions/3855108/redirecting-standard-output-to-a-file-containing-the-pid-of-the-logging-process
if [ "$#" -eq 0 ]; then
    echo "Usage:"
    echo "notebook-server start"
    echo "notebook-server list"
    echo "notebook-server stop port"
    echo "notebook-server getpid port"
else

    if [ $1 = "start" ]; then
        port="${2:-$DEFAULT_PORT}"
        echo "Trying to start notebook server at port $port"
        ipython notebook --no-browser --port=$port > "$LOG_PATH/$(date +%F_%R).log" 2>&1 &
        unset port

    elif [ $1 = "list" ]; then
        jupyter notebook list

    elif [ $1 = "stop" ]; then
        echo "Stopping notebook server"
        s_port=$2
        s_pid=./$0 getpid $s_port
        if [ -z "$s_pid" ]; then
            echo "No server found on port $s_port"
        else
            echo "Killing server on port $s_port with pid $s_pid"
            kill $s_pid
        fi
        unset s_port s_pid

    elif [ $1 = "getpid" ]; then
        echo $(netstat -tulpn 2>/dev/null | grep ":$2" | grep -oP '\d+\D+\K\d+' | tail -n 1)

    fi
fi