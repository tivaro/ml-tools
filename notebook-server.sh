#!/bin/bash
DEFAULT_PORT=5050
NOTEBOOK_SERVER_LOG_PATH="/volume/home/ties/.log/jupy"
PRE_NOTEBOOK_COMMAND="source activate scyfer"

#TODO: Pass trough options on notebook-server start

if [ "$#" -eq 0 ]; then
    echo "Usage:"
    echo "notebook-server start (port)"
    echo "notebook-server list"
    echo "notebook-server stop port"
    echo "notebook-server restart port"
    echo "notebook-server view port"
    echo "notebook-server getpid port"
    echo "notebook-server getport pid"
else

    if [ $1 = "start" ]; then
        s_port="${2:-$DEFAULT_PORT}"
        echo "Trying to start notebook server at port $s_port"
        # from https://stackoverflow.com/questions/3855108/redirecting-standard-output-to-a-file-containing-the-pid-of-the-logging-process
        # requires bash3 or newer
        # Start a notebook server in a subshell so that we can redirect the log to
        #    a file with it's own pid, also store the pid
        s_pid=$( (echo ${BASHPID} && $PRE_NOTEBOOK_COMMAND && exec jupyter notebook --no-browser --port=$s_port > "$NOTEBOOK_SERVER_LOG_PATH/${BASHPID}.log" 2>&1) &)

        for n in {1..10}
        do
            s_port=$(. $0 getport $s_pid)
            if [ ! -z "$s_port" ]; then
                echo "Started server at port $s_port with pid $s_pid"
                break
            fi
            sleep 0.5
        done
        if [ -z "$s_port" ]; then
            echo "Started server at unknown port with pid $s_pid"
        fi

    elif [ $1 = "list" ]; then
        jupyter notebook list

    elif [ $1 = "view" ]; then
        s_pid=$(. $0 getpid $2)
        if [ -z "$s_pid" ]; then
            echo "No server found on port $2"
        else
            echo "Live view of notebook server on port $2"
            echo "(use Control-C to exit this live view)"
            (tail -100f "$NOTEBOOK_SERVER_LOG_PATH/${s_pid}.log")
        fi

    elif [ $1 = "stop" ]; then
        echo "Stopping notebook server"
        s_pid=$(. $0 getpid $2)
        if [ -z "$s_pid" ]; then
            echo "No server found on port $2"
        else
            echo "Killing server on port $2 with pid $s_pid"
            kill $s_pid
            echo "Cleaning up log file"
            rm "$NOTEBOOK_SERVER_LOG_PATH/$s_pid.log"
        fi

    elif [ $1 = "restart" ]; then
        echo "Restarting notebook server at port $2"
        . $0 stop $2
        sleep 0.5
        . $0 start $2

    elif [ $1 = "getpid" ]; then
        if [ ! -z "$2" ]; then
            # Note: This is ubuntu-specific
            netstat -tulpn 2>/dev/null | grep ":$2" | grep -oP '\d+\D+\K\d+' | tail -n 1
        fi

    elif [ $1 = "getport" ]; then
        s_logfile=$NOTEBOOK_SERVER_LOG_PATH/$2.log
        if [ -f "$s_logfile" ]; then
            # Note: This is ubuntu-specific
            head $s_logfile | grep  "The Jupyter Notebook is running at: .*" | grep -Eo ':[0-9]+/' | grep -Eo '[0-9]+'
        fi
    fi
fi
