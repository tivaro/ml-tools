#!/bin/bash
NUM_DEVICES=4

echo "Selecting GPU with most free memory" 1>&2
MOST_MEM=0
for ID in $(seq 0 `expr $NUM_DEVICES - 1`)
do 
    # Select FB Memory usage section
    MEM=$(nvidia-smi -q -d MEMORY -i $ID | grep -Pzo "FB Memory Usage *\n.*\n.*\n.*\n")
    MEM=$(echo "$MEM" | grep -Po " +Free.+") # Get free FB Memory line
    MEM=$(echo "$MEM" | grep -Po "\d+") # Get Numeric value
    echo "GPU$ID: $MEM MiB Free" 1>&2
    if [ "$MEM" -gt "$MOST_MEM" ];then
        MOST_MEM=$MEM
        BEST_DEVICE=$ID
    fi
done

echo "Selected GPU $BEST_DEVICE with $MOST_MEM MiB of free memory" 1>&2
echo $BEST_DEVICE
