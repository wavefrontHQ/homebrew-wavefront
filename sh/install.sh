#!/bin/bash

TELEGRAF_CONF_FILE=/usr/local/etc/telegraf.conf
TELEGRAF_BACKUP_FILE=/usr/local/etc/telegraf.conf.old
DEFAULT_TELEGRAF_CONF_FILE=/usr/local/etc/telegraf.conf.default
PROXY_CONF_DIR=/usr/local/etc/wavefront/wavefront-proxy
PROXY_CONF_FILE=${PROXY_CONF_DIR}/wavefront.conf
PROXY_BACKUP_FILE=${PROXY_CONF_DIR}/wavefront.conf.old
DEFAULT_PROXY_CONF_FILE=${PROXY_CONF_DIR}/wavefront.conf.default

PROXY_SERVICE_NAME=wfproxy
PROXY_NEXT_SERVICE_NAME=wfproxynext
TELEGRAF_SERVICE_NAME=telegraf
OLD_TELEGRAF_SERVICE_NAME=wftelegraf

function print_usage_and_exit() {
    echo "Failure: $1"
    echo "Usage: $0 [-p | -a] [-tuhf]"
    echo -e "\t-a Install the telegraf agent. -h is required with this option."
    echo -e "\t-h string  The host address of the proxy the agent connects to."
    echo -e "\t-p Install the Wavefront proxy. -t and -u are required with this option."
    echo -e "\t-t string  The Wavefront API token."
    echo -e "\t-u string  The Wavefront URL. Typically http://WAVEFRONT_URL/api".
    echo -e "\t-f string  Optional user friendly hostname used in reporting the telegraf and proxy metrics. Defaults to os.Hostname()".
    echo -e "\t-n Install the Wavefront proxy-next. -p required with this option.".
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

function install_service() {
    SERVICE=$1
    FAIL_MSG=$2
    stop_if_installed $SERVICE
    brew install $SERVICE
    check_status $? $FAIL_MSG
}

function stop_if_installed() {
    SERVICE=$1
    brew list | grep -q "${SERVICE}$"
    if [[ $? -eq 0 ]]; then
        brew services stop ${SERVICE}
    fi
}

function uninstall_if_installed() {
    SERVICE=$1
    brew list | grep -q "${SERVICE}$"
    if [[ $? -eq 0 ]]; then
        brew services stop ${SERVICE}
        brew uninstall ${SERVICE}
        return 0
    fi
    return 1
}

function remove_old_telegraf() {
    # We used to distribute a custom telegraf install named wftelegraf
    # but now use the mainline telegraf install available via homebrew-core
    uninstall_if_installed $OLD_TELEGRAF_SERVICE_NAME
    if [[ $? -eq 0 ]] ; then
        echo "Uninstalled $OLD_TELEGRAF_SERVICE_NAME service"
        echo "Installing mainline $TELEGRAF_SERVICE_NAME service..."
    fi
}

function delete_proxy_files() {
    rm -f ${PROXY_CONF_DIR}/.wavefront_id
}

function configure_proxy() {
    TOKEN=$1
    URL=$2
    HOSTNAME=$3

    # cleanup previous proxy install
    delete_proxy_files

    if [[ -f $DEFAULT_PROXY_CONF_FILE ]] ; then
        mv $PROXY_CONF_FILE $PROXY_BACKUP_FILE
        rm -f $DEFAULT_PROXY_CONF_FILE
    fi

    curl -sL https://raw.githubusercontent.com/wavefronthq/homebrew-wavefront/master/conf/wavefront.conf > $PROXY_CONF_FILE

    # replace token
    sed -i'.bak' "s/TOKEN_HERE/${TOKEN}/" $PROXY_CONF_FILE

    # replace server url
    sed -i'.bak' "s/WAVEFRONT_SERVER_URL/${URL//\//\\/}/" $PROXY_CONF_FILE

    if [[ -n ${HOSTNAME} ]] ; then
        sed -i'.bak' "s/myHost/${HOSTNAME}/" $PROXY_CONF_FILE
    fi
    rm -f ${PROXY_CONF_FILE}.bak
}

function configure_agent() {
    PROXY_HOST=$1
    FRIENDLY_HOSTNAME=$2

    # set PROXY_HOST to localhost if it equals the hostname in proxy conf
    if [[ -f $PROXY_CONF_FILE ]] ; then
        grep -q "hostname=${PROXY_HOST}$" $PROXY_CONF_FILE
        if [[ $? -eq 0 ]]; then
            PROXY_HOST=localhost
        fi
    fi

    cat > /usr/local/etc/telegraf.d/10-wavefront.conf <<- EOM
    ## Configuration for the Wavefront proxy to send metrics to
    [[outputs.wavefront]]
    # prefix = "telegraf."
      host = "$PROXY_HOST"
      port = 2878
      metric_separator = "."
      source_override = ["hostname", "agent_host", "node_host"]
      convert_paths = true
      use_regex = false
EOM

    install_wf_telegraf_conf $FRIENDLY_HOSTNAME
}

function install_wf_telegraf_conf() {
    FRIENDLY_HOSTNAME=$1
    if [[ -f $TELEGRAF_CONF_FILE ]] ; then
        mv $TELEGRAF_CONF_FILE $TELEGRAF_BACKUP_FILE 
        rm -f $DEFAULT_TELEGRAF_CONF_FILE
    fi
    curl -sL https://raw.githubusercontent.com/wavefronthq/homebrew-wavefront/master/conf/telegraf.conf > $TELEGRAF_CONF_FILE
    sed -i'.bak' "s/hostname = \"\"/hostname = \"$FRIENDLY_HOSTNAME\"/" $TELEGRAF_CONF_FILE
    rm -f ${TELEGRAF_CONF_FILE}.bak
}

function prompt_hostname() {
    read -p "Enter user-friendly hostname (Press Enter to use default: ${FRIENDLY_HOSTNAME}): " answer
    if [[ -n ${answer} ]] ; then
        FRIENDLY_HOSTNAME=${answer}
    fi
}

function check_status() {
    STATUS=$1
    MSG=$2
    if [ $STATUS -ne 0 ]; then
        echo $MSG
        exit 1
    fi
}

# main()

check_operating_system

TOKEN=
URL=
PROXY_HOST=
INSTALL_PROXY=
INSTALL_PROXY_NEXT=
INSTALL_AGENT=
FRIENDLY_HOSTNAME=
while getopts "t:u:h:f:pan" opt; do
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
    f)
      FRIENDLY_HOSTNAME="$OPTARG"
      ;;
    p)
      INSTALL_PROXY=y
      ;;
    a)
      INSTALL_AGENT=y
      ;;
    n)
      INSTALL_PROXY_NEXT=y
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
        if [ -n "$INSTALL_PROXY" ]; then
            PROXY_HOST="localhost"
        else
            print_usage_and_exit "Proxy HOST argument required."
        fi
    fi
fi

check_homebrew_installed
if [ $? -ne 0 ]; then
    echo "Homebrew is not installed. Installing Homebrew."
    install_homebrew
fi

check_homebrew_installed
check_status $? "Homebrew required. Aborting installation."

if [[ -z ${FRIENDLY_HOSTNAME} ]] ; then
    FRIENDLY_HOSTNAME=`hostname`
fi
echo "Using hostname: ${FRIENDLY_HOSTNAME}"

# update homebrew
brew update

# install the wavefront Tap
brew tap wavefrontHQ/wavefront
check_status $? "Error installing the wavefront tap."

# install proxy and/or agent
if [ -n "$INSTALL_PROXY" ]; then
    service_name=$PROXY_SERVICE_NAME
    if [ -n "$INSTALL_PROXY_NEXT" ]; then
        service_name=$PROXY_NEXT_SERVICE_NAME
    fi
    install_service $service_name "Wavefront proxy installation failed."
    configure_proxy $TOKEN $URL $FRIENDLY_HOSTNAME
    brew services start $service_name
    check_status $? "Error starting $service_name."
fi

if [ -n "$INSTALL_AGENT" ]; then
    remove_old_telegraf
    install_service $TELEGRAF_SERVICE_NAME "Telegraf agent installation failed."
    configure_agent $PROXY_HOST $FRIENDLY_HOSTNAME
    brew services start $TELEGRAF_SERVICE_NAME
    check_status $? "Error starting $TELEGRAF_SERVICE_NAME."
fi
