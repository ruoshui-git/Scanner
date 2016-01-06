#!/bin/bash

# ANSI Escape Codes
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
RESET="\033[m"

# Get some constants for the Date, Log Filename, and the length of a valid
# barcode
DATE=`date +"%Y_%m_%d"`
LOG=logs/${DATE}.csv
VALID_BARCODE_LENGTH=9

# Login variables
ADMIN_NAME=""
ADMIN_PWORD=""

SERVER_ADDR="http://stuyctf.me:11235"

# Define a method to show a prompt
function show_prompt() {
    echo "============================="
    echo -n "Swipe card: "
}

# Make a cleanup script to organize the log and remove duplicates
function cleanup() {
    echo "Cleaning up..."
    # A brief explanation: cat the first parameter, which should be the log file
    # into sort, which sorts it. The sorted list is put into 'uniq' which removes
    # duplicate values, and then that gets put into a tmp file, which then
    # replaces the log file with that tmp file.
    cat "$1" | sort | uniq | cat > tmp
    mv tmp "$1"
}

function traphook() {
    cleanup $LOG
}

# Add a shutdown hook so the log is cleaned when script exits
trap traphook EXIT

function login() {
    # Read login credentials and validate with server
    echo "Admin login:"
    if [[ $ADMIN_EMAIL == "" ]]; then
        echo -n "Username: "
        read name
        ADMIN_NAME=$name
    fi
    echo -n "Password: "
    read -s pass
    echo ""
    response=$(curl -# -X GET $SERVER_ADDR"?username=${ADMIN_NAME}&pword=${pass}")
    if [[ $response =~ "bad_login" ]]; then
        printf "${RED}ERROR: Could not contact server${RESET}\n"
        exit
    elif [[ $response =~ "no_osis" ]]; then
        printf "${GREEN}Validation successful${RESET}\n"
        ADMIN_PWORD=$pass
    else
        # Print out error message
        printf "${RED}${response}${RESET}\n"
        exit
    fi
}

function scan() {
    # Update log name if dates were overridden
    printf "${YELLOW}Enter \"exit\" to cleanup duplicates and exit${RESET}\n"
    while [[ true ]]; do
        # Display the prompt
        show_prompt
        # Keep reading a barcode from stdin
        read barcode
        # The conditionals should be self explanatory
        if [[ $barcode == "exit" ]]; then
            exit
        elif [[ ${#barcode} != $VALID_BARCODE_LENGTH ]]; then
            # tput bel 'displays' the ASCII bell character, which invokes a
            # sound
            tput bel
            printf "${RED}ERROR: Invalid barcode${RESET}\n"
        elif echo $barcode | grep "[^0-9]\+" > /dev/null; then
            tput bel
            printf "${RED}ERROR: Invalid barcode${RESET}\n"
        else
            # Create the log file if it doesn't exist yet.
            if [[ ! -f $LOG ]]; then
                touch $LOG
            fi
            # Only send barcodes that haven't been logged yet
            if [[ $(grep $barcode $LOG) == "" ]]; then
                printf "${GREEN}Got barcode: ${barcode}${RESET}\n"
                # Append barcode to log
                echo $barcode >> $LOG
                # Curl the server
                curl --silent -X GET "${SERVER_ADDR}?username=${ADMIN_NAME}&pword=${ADMIN_PWORD}&osis=${barcode}&date=${DATE}" &
            else
                printf "${YELLOW}You already scanned in${RESET}\n"
            fi
        fi
    done
}

function custom_upload() {
    curl --silent -X GET ${SERVER_ADDR}"?username=${ADMIN_NAME}&pword=${ADMIN_PWORD}&osis=$2&date=$1"
}

function dump_csv() {
    FILE=$1
    cat $1 | while read num; do
        custom_upload "${FILE%%.*}" $num
    done
}

# Admin Login
login
# Invoke the scan function
scan

