#!/bin/bash

function list_removal() {
    echo "This will uninstall the following:"
    echo -e "\t The Wavefront proxy"
    echo -e "\t The Wavefront telegraf agent"
    echo -e "\t The Homebrew Wavefront tap"
}

function uninstall_cmd() {
    CMD=$1
    CMD_PATH=$(brew list $CMD)
    if [ $? -eq 0 ]; then
        brew services stop $CMD
        brew uninstall $CMD
    fi
}

list_removal

uninstall_cmd wfproxy
uninstall_cmd wftelegraf
brew untap wavefronthq/wavefront
