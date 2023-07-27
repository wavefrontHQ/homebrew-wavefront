#!/bin/bash

INSTALL_AGENT=y
INSTALL_PROXY=y

echo "******* $INSTALL_PROXY ********"

if [ -n "$INSTALL_PROXY" ]; then
    brew install wfproxy
fi

echo "******* $INSTALL_AGENT ********"

if [ -n "$INSTALL_AGENT" ]; then
    brew install telegraf
fi
