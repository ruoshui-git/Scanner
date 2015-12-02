#!/bin/bash

# ANSI Escape Codes
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
RESET="\033[m"

DATE=`date +"%Y_%m_%d"`
LOG=logs/${DATE}.csv
VALID_BARCODE_LENGTH=9

function show_prompt() {
    echo "============================="
    echo -n "Swipe card: "
}

echo "STUDENT OSIS, DATE: $DATE" >> $LOG

function cleanup() {
    cat "$1" | sort -r | uniq | cat > tmp
    mv tmp "$1"
}

function scan() {
    # Update log name if dates were overridden
    printf "${YELLOW}Enter \"exit\" to cleanup duplicates and exit${RESET}\n"
    while [[ true ]]; do
        show_prompt
        read barcode
        if [[ $barcode == "exit" ]]; then
            cleanup $LOG
            exit
        elif [[ ${#barcode} != $VALID_BARCODE_LENGTH ]]; then
            tput bel
            printf "${RED}ERROR: Invalid barcode${RESET}\n"
        elif echo $barcode | grep "[^0-9]\+" > /dev/null; then
            tput bel
            printf "${RED}ERROR: Invalid barcode${RESET}\n"
        else
            if [[ ! -f $LOG ]]; then
                touch $LOG
            fi
            # Only send barcodes that haven't been logged yet
            if [[ $(grep $barcode $LOG) == "" ]]; then
                printf "${GREEN}Got barcode: ${barcode}${RESET}\n"
                # Append barcode to log
                echo $barcode >> $LOG
            else
                printf "${YELLOW}You already scanned in${RESET}\n"
            fi
        fi
    done
}

scan

