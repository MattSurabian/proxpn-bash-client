#!/usr/bin/env bash

SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

CONF_BASE_PATH=/etc/proxpn
CONF_FILE=proxpn.ovpn
executableFileName="proxpn";
executableFilePath="$SDIR/$executableFileName";
systemInstallPath="/usr/local/bin";
executableSystemInstallPath="$systemInstallPath/$executableFileName"

if [ $EUID -ne 0 ]; then
   echo "This script must be run as root in order to install system-wide configuration and program link.";
   exit 1;
fi

## Install system-wide configuration

if [[ -f "$SDIR/$CONF_FILE" ]]; then
  if [[ ! -d "$CONF_BASE_PATH" ]]; then
    mkdir "$CONF_BASE_PATH";
  fi

  if cp "$SDIR/$CONF_FILE" "$CONF_BASE_PATH/"; then
    echo "Successfully installed system-wide configuration file.";
  else
    echo "Error: Not able to install system-wide configuration file; exiting...";
    exit 1;
  fi
else
  echo "Error: OpenVPN configuration file not found in project: \"$SDIR/$CONF_FILE\"";
  echo "Exiting...";
  exit 1;
fi

## Install system-wide program link

if [[ -f "$executableFilePath" ]]; then
  if ln -s "$(readlink -f "$executableFilePath")" "$executableSystemInstallPath"; then
    echo "Successfully installed system-wide program link.";
  else
    echo "Error: Not able to install system-wide program link; exiting...";
    exit 1;
  fi
else
  echo "Error: Main executable file not found in project: \"$executableFilePath\"";
  echo "Exiting...";
  exit 1;
fi