#!/bin/bash

# ANSI Escape Codes
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
MAGENTA="$(tput setaf 5)"
RESET="$(tput setaf 7)"

# Get some constants for the Date, Log Filename, and the length of a valid
# barcode
DATE=$(date +"%Y_%m_%d")
LOG=logs/${DATE}.csv
VALID_BARCODE_LENGTH=9

# Login variables
ADMIN_NAME=""
ADMIN_PWORD=""

SERVER_ADDR="http://162.243.115.175:11235"

#Scanner
strike=false
# Define a method to show a prompt
function show_prompt() {
    echo "============================="
    echo -n "Swipe card: "
}

# Sort list, removing duplicates in the process.
function cleanup() {
    echo "Cleaning up..."
    sort -u -o "$1" "$1"
}

function traphook() {
    cleanup "$LOG"
}

# Add a shutdown hook so the log is cleaned when script exits
trap traphook EXIT

function login() {
    # Read login credentials and validate with server
    echo "Admin login:"
    if [[ $ADMIN_EMAIL == "" ]]; then
        echo -n "Username: "
        read -r name
        ADMIN_NAME=$name
    fi
    echo -n "Password: "
    read -r -s pass
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
        local error = $(echo "$response" | grep 'title')
        echo "$error"
        #printf "${RED}${response}${RESET}\n"
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
        read -r barcode
        # The conditionals should be self explanatory
        if [[ $barcode == "exit" ]]; then
            exit
        elif [[ $barcode == "help" ]]; then
            helpMenu
        elif [[ $barcode == "strike add" ]]; then
            printf "${GREEN}ADDING STRIKES ====================================${RESET}\n"
            strike=1
        elif [[ $barcode == "strike subtract" ]]; then
            printf "${GREEN}SUBTRACTING STRIKES ====================================${RESET}\n"
            strike=2
        elif [[ $barcode == "strike off" ]]; then
            printf "${GREEN}STRIKE SYSTEM OFF ====================================${RESET}\n"
            strike=0
        elif [[ ${#barcode} != $VALID_BARCODE_LENGTH ]]; then
            # tput bel 'displays' the ASCII bell character, which invokes a
            # sound
            tput bel
            printf "${RED}ERROR: Invalid barcode${RESET}\n"
        elif echo "$barcode" | grep "[^0-9]\+" > /dev/null; then
            tput bel
            printf "${RED}ERROR: Invalid barcode${RESET}\n"
        elif [[ $strike == 1 ]]; then
            printf "${GREEN}Strike added to ${barcode} ${RESET}\n"
            python strike.py 1 "$barcode"
            python strike_print.py "$barcode"
        elif [[ $strike == 2 ]]; then
            printf "${GREEN}Strike subtracted from ${barcode} ${RESET}\n"
            python strike.py -1 "$barcode"
            python strike_print.py "$barcode"
        else
            # Create the log file if it doesn't exist yet.
            if [[ ! -f $LOG ]]; then
                touch "$LOG"
            fi
            # Only send barcodes that haven't been logged yet
            if [[ $(grep "$barcode" "$LOG") == ""  ]]; then
                printf "${GREEN}Got barcode: ${barcode}${RESET}\n"
                python strike_print.py "$barcode"
                # Append barcode to log
                echo "$barcode" >> "$LOG"
                # Curl the server
                curl --silent -X GET "${SERVER_ADDR}?username=${ADMIN_NAME}&pword=${ADMIN_PWORD}&osis=${barcode}&date=${DATE}" > /dev/null&
            else
                printf "${YELLOW}You already scanned in${RESET}\n"
                python strike_print.py "$barcode"
            fi
        fi
    done
}

function helpMenu(){
    printf "${GREEN}HELP MENU ============================================================================================================${RESET}\n"
    printf "${YELLOW}strike add${MAGENTA}\t\t---\t\tone strike will be added to any ID scanned after \"strike on\" is entered${RESET}\n"
    printf "${YELLOW}strike subtract${MAGENTA}\t\t---\t\tone strike will be subtracted to any ID scanned after \"strike on\" is entered${RESET}\n"
    printf "${YELLOW}strike off${MAGENTA}\t\t---\t\t\"strike add\" or \"strike subtract\" will stop running${RESET}\n"
    printf "${YELLOW}help${MAGENTA}\t\t\t---\t\tdisplay the help menu${RESET}\n"
    printf "${GREEN}======================================================================================================================${RESET}\n\n"
}
function custom_upload() {
    curl --silent -X GET "${SERVER_ADDR}?username=${ADMIN_NAME}&pword=${ADMIN_PWORD}&osis=$2&date=$1" > /dev/null
}

function dump_csv() {
    while IFS= read -r num; do
        custom_upload "${1%%.*}" "$num"
    done < "$1"
}

# Admin Login
#login
# Invoke the scan function
helpMenu
scan

