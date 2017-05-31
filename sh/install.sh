#!/bin/bash

function print_usage_and_exit() {
    echo "Failure: $1"
    echo "Usage: $0 [-p | -a] [-tuh]"
    echo -e "\t-a Install the telegraf agent. -h is required with this option."
    echo -e "\t-h string  The host address of the proxy the agent connects to."
    echo -e "\t-p Install the Wavefront proxy. -t and -u are required with this option."
    echo -e "\t-t string  The Wavefront API token."
    echo -e "\t-u string  The Wavefront URL. Typically http://WAVEFRONT_URL/api".
    echo "Example usage:"
    echo "$0 -p -t API_TOKEN -u WAVEFRONT_URL"
    echo "$0 -a -h PROXY_HOST"
    echo "$0 -p -t API_TOKEN -u WAVEFRONT_URL -a -h PROXY_HOST"
    exit 1
}

function check_operating_system() {
    if [ "$(uname)" == "Darwin" ]; then
        echo "Mac OS X"
    else
        echo "Unsupported operating system!"
        exit 1
    fi
}

function check_homebrew_installed() {
    BREW_PATH=$(which brew)
    return $?
}

function install_homebrew() {
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

function configure_proxy() {
    TOKEN=$1
    URL=$2

    CONF_FILE=/usr/local/etc/wfproxy.conf

    # replace token
    sed -i '' "s/TOKEN_HERE/${TOKEN}/" $CONF_FILE

    # replace server url
    sed -i '' "s/WAVEFRONT_SERVER_URL/${URL//\//\\/}/" $CONF_FILE
}

function configure_agent() {
    HOST=$1
    cat > /usr/local/etc/telegraf.d/10-wavefront.conf <<- EOM
    ## Configuration for the Wavefront proxy to send metrics to
    [[outputs.wavefront]]
    # prefix = "telegraf."
      host = "$HOST"
      port = 2878
      metric_separator = "."
      source_override = ["hostname", "snmp_host", "node_host"]
      convert_paths = true
      use_regex = false
EOM
}

# main()

check_operating_system

TOKEN=
URL=
PROXY_HOST=
INSTALL_PROXY=
INSTALL_AGENT=
while getopts "t:u:h:pa" opt; do
  case $opt in
    t)
      TOKEN="$OPTARG"
      ;;
    u)
      URL="$OPTARG"
      ;;
    h)
      PROXY_HOST="$OPTARG"
      ;;
    p)
      INSTALL_PROXY=y
      ;;
    a)
      INSTALL_AGENT=y
      ;;
    \?)
      print_usage_and_exit "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [[ -z "$INSTALL_PROXY" && -z "$INSTALL_AGENT" ]]; then
    print_usage_and_exit "-p or -a is required."
fi

if [ -n "$INSTALL_PROXY" ]; then
    if [[ -z "$URL" || -z "$TOKEN" ]]; then
        print_usage_and_exit "Wavefront URL and API Token required."
    fi
fi

if [ -n "$INSTALL_AGENT" ]; then
    if [ -z "$PROXY_HOST" ]; then
        print_usage_and_exit "Proxy HOST argument required."
    fi
fi

check_homebrew_installed
if [ $? -ne 0 ]; then
    echo "Homebrew is not installed. Installing Homebrew."
    install_homebrew
fi

check_homebrew_installed
if [ $? -ne 0 ]; then
    echo "Homebrew required. Aborting installation."
    exit 1
fi

# install the wavefront Tap
brew tap wavefrontHQ/wavefront

# install proxy and/or agent
if [ -n "$INSTALL_PROXY" ]; then
    brew install wfproxy
    configure_proxy $TOKEN $URL
    brew services start wfproxy
fi

if [ -n "$INSTALL_AGENT" ]; then
    brew install wftelegraf
    configure_agent $PROXY_HOST
    brew services start wftelegraf
fi
