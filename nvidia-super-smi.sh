#!/bin/bash
SMI=$(nvidia-smi)
PIDS=$(echo "$SMI" | grep -Po "(|)\s+\d\s+(\d+)\s+.+(MiB |)") #get last (process lines)
PIDS=$(echo "$PIDS" | grep -Po " +\d + \d+") # Get core_id pid
PIDS=$(echo "$PIDS" | grep -Po "\d+$") #get just the pids

for PID in $PIDS
do
    USER=$(ps -up $PID | grep -Po "^.+?\s+\d+" | grep -Po "^.+?\s")
    USER=`printf "%-9s" $USER` #right pad with spaces
    USERS="$USERS"$'\n'" $USER|"
done

# Add table header
USERS="=========+$USERS"
USERS="  User   |"$'\n'" $USERS"
USERS="  proc   |"$'\n'" $USERS"
USERS="---------+"$'\n'" $USERS"
USERS="$USERS"$'\n'"----------+"




SMI_L=$(echo "$SMI" | wc -l)
U_L=$(echo "$USERS" | wc -l)
ADD_L=$(($SMI_L-$U_L))

SPACER=`printf ' \n%.0s' $(seq 0 $ADD_L)`
USERS="$SPACER$USERS"
 
paste <(echo "$SMI") <(echo "$USERS") --delimiters ''
