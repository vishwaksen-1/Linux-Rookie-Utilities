#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [-full] [-cookie <cookiefile>] [-output <outputfile>] [-useragent <useragent>] [-header <header>] <URL>"
    echo "       $0 -help"
    echo "This script takes a URL and prints out all sub-directories"
    echo ""
    echo "Options:"
    echo "  -full              Show full output of wget"
    echo "  -cookie <f>        Use cookies from file <f> or directly given"
    echo "  -output <f>        Save output to file <f>"
    echo "  -useragent <ua>    Set custom User-Agent string"
    echo "  -header <h>        Add custom HTTP header (e.g., 'X-Forwarded-For: 1.2.3.4')"
    echo "  -timeout <t>       Set timeout in seconds (default: 10)"
    echo "  -retry <r>         Set number of retries (default: 3)"
    echo "  -verbose           Enable verbose output"
    echo "  -help              Display this help message"
    exit 1
}

# Function to ask yes/no questions
ask_yes_no() {
    while true; do
        read -p "$1 (yes/no): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Check if a URL is provided as an argument or if help is requested
if [ -z "$1" ] || [ "$1" == "-help" ]; then
    usage
fi

# Parse the command line options
COOKIES=""
FULL_OUTPUT=false
OUTPUT_FILE=""
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
CUSTOM_HEADERS=""
TIMEOUT=10
RETRY=3
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -full)
            FULL_OUTPUT=true
            shift
            ;;
        -cookie)
            if [ -f "$2" ]; then
                COOKIES="--load-cookies $2"
            else
                echo "Cookie file $2 not found, using it as cookie"
                COOKIES="--header 'Cookie: $2'"
            fi
            shift 2
            ;;
        -output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -useragent)
            USER_AGENT="$2"
            shift 2
            ;;
        -header)
            CUSTOM_HEADERS+="--header '$2' "
            shift 2
            ;;
        -timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -retry)
            RETRY="$2"
            shift 2
            ;;
        -verbose)
            VERBOSE=true
            shift
            ;;
        *)
            URL="$1"
            shift
            ;;
    esac
done

# Check if URL is provided
if [ -z "$URL" ]; then
    echo "Error: URL is required."
    usage
fi

# Verbose output
if $VERBOSE; then
    echo "Running with options:"
    echo "  URL: $URL"
    echo "  Cookies: $COOKIES"
    echo "  User-Agent: $USER_AGENT"
    echo "  Custom Headers: $CUSTOM_HEADERS"
    echo "  Timeout: $TIMEOUT"
    echo "  Retry: $RETRY"
    echo "  Output File: $OUTPUT_FILE"
    echo "  Full Output: $FULL_OUTPUT"
fi

# Create a temporary directory for wget output
TMP_DIR=$(mktemp -d)
echo "Using temporary directory: $TMP_DIR"

# Run wget with the specified options
WGET_CMD="wget $COOKIES --user-agent='$USER_AGENT' $CUSTOM_HEADERS --timeout=$TIMEOUT --tries=$RETRY -r --no-parent -P '$TMP_DIR' '$URL'"

if $FULL_OUTPUT; then
    if [ -n "$OUTPUT_FILE" ]; then
        eval $WGET_CMD > "$OUTPUT_FILE" 2>&1
    else
        eval $WGET_CMD
    fi
else
    if [ -n "$OUTPUT_FILE" ]; then
        eval $WGET_CMD 2>&1 | grep -F "$URL" > "$OUTPUT_FILE"
    else
        eval $WGET_CMD 2>&1 | grep -F "$URL"
    fi
fi

# Ask the user if they want to keep the folder
if ask_yes_no "Do you want to keep the downloaded folder?"; then
    if [ -n "$OUTPUT_FILE" ]; then
        mv "$TMP_DIR" "$(pwd)/$(basename $TMP_DIR)"
        echo "Folder moved to: $(pwd)/$(basename $TMP_DIR)"
    else
        echo "Folder remains in: $TMP_DIR"
    fi
else
    # Remove the temporary directory
    rm -rf "$TMP_DIR"
    echo "Temporary folder removed."
fi