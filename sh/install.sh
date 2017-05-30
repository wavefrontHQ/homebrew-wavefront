#!/bin/bash

function print_usage() {
    echo "URL and API Token required."
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
while getopts "t:u:p:" opt; do
  case $opt in
    t)
      TOKEN="$OPTARG"
      ;;
    u)
      URL="$OPTARG"
      ;;
    p)
      PROXY_HOST="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [[ -z "$URL" || -z "$TOKEN" || -z "$PROXY_HOST" ]]; then
    print_usage
    exit 1
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

# install proxy and agent
brew tap wavefrontHQ/wavefront
brew install wfproxy --with-wftelegraf

configure_proxy $TOKEN $URL
brew services start wfproxy

configure_agent $PROXY_HOST
brew services start wftelegraf
