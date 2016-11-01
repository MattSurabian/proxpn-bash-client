#!/usr/bin/env bash

SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

configRoot=$(eval echo ~$SUDO_USER)/.config/proxpn/;
configFileName="proxpn.ovpn";
configFilePath="$SDIR/$configFileName"
userConfigFilePath="$configRoot/$configFileName";
executableFileName="proxpn";
executableFilePath="$SDIR/$executableFileName";
systemInstallPath="/usr/local/bin";
executableSystemInstallPath="$systemInstallPath/$executableFileName";
userCredsFileName="login.conf";
userCredsFilePath="$configRoot/$userCredsFileName";
configOnly="false"

# Source: https://gist.github.com/hoylen/6607180
PROG="$(basename "$0")";
VERSION="0.2";

#----------------------------------------------------------------
# Process command line options

HELP_TEXT="Usage: $PROG [options]
Options:
  -f | --force          Allow overwriting existing files on system if they already exist.  Useful for at least updating login info, and for also restoring program defaults.
  -s | --symlink        Install the main program executable as a link to the original contained within this project, rather than copying it over into the system directory.  This may allow for simply updating the main project via source control, but be aware that changing its location may break the symlink, and would require re-installation.
  -c | --configuration  Skip adding the script to the user's PATH and just create proxpn configuration files.
  -h | --help           show this help message";
   
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)
          echo "$HELP_TEXT";
          exit 0;
          ;;
        -c | --configuration)
          configOnly="true"
          ;;
        -s | --symlink)
          symlinkToMainExecutable="true";
          ;;
        -f | --force)
          overwriteFiles="true";
          ;;
        --)
          shift;
          break;
          ;; # end of options
    esac
    shift
done

if [ $EUID != 0 -a $configOnly != true ]; then
  echo "This script must be run as root in order to copy the script to $systemInstallPath."
  echo "Falling back to configuration only mode. You must re-run this script with sudo or manually copy the proxpn script into your PATH before using the proxpn command."
  echo
  configOnly="true"
fi

[[ -z "$overwriteFiles" ]] && overwriteFiles="false";
[[ -z "$symlinkToMainExecutable" ]] && symlinkToMainExecutable="false";

#----------------------------------------------------------------

if [[ ! -d "$configRoot" ]]; then
  mkdir -p "$configRoot";
fi

## Install system-wide configuration, if not already installed.
echo "Attempting to install configuration file to: $userConfigFilePath"
if [[ -f "$userConfigFilePath" && ! "$overwriteFiles" == "true" ]]; then
  echo "Configuration file already exists; continuing installation...";
elif [[ -f "$configFilePath" ]]; then
  if cp "$configFilePath" "$userConfigFilePath"; then
    echo "Successfully installed configuration file.";
  else
    echo "Error: Not able to install system-wide configuration file; exiting...";
    exit 1;
  fi
else
  echo "Error: OpenVPN configuration file not found in project: \"$SDIR/$configFileName\"";
  echo "Exiting...";
  exit 1;
fi

## Install system-wide program link, if not already installed.
echo "Attempting to install executable to: $executableSystemInstallPath"
if [[ -f "$executableSystemInstallPath" && ! "$overwriteFiles" == "true" ]]; then
  echo "System-wide program link already exists; continuing installation...";
elif [ $configOnly == "true" ]; then
  echo "Operating in configuration only mode. Skipping system-wide progam linking..."
elif [[ -f "$executableFilePath" ]]; then
  if [[ -f "$executableSystemInstallPath" ]]; then
    rm "$executableSystemInstallPath";
  fi
  if [[ "$symlinkToMainExecutable" == "true" ]]; then
    if ln -s "$executableFilePath" "$executableSystemInstallPath"; then
      echo "Successfully installed system-wide program link.";
    else
      echo "Error: Not able to install system-wide program link; exiting...";
      exit 1;
    fi
  else
    if cp "$executableFilePath" "$executableSystemInstallPath"; then
      echo "Successfully installed system-wide program file.";
    else
      echo "Error: Not able to install system-wide program file; exiting...";
      exit 1;
    fi
  fi
else
  echo "Error: Main executable file not found in project: \"$executableFilePath\"";
  echo "Exiting...";
  exit 1;
fi

## Install system-wide credentials file, if not already installed.
echo "Attempting to install credentials file to: $userCredsFilePath"
if [[ -f "$userCredsFilePath" && ! "$overwriteFiles" == "true" ]]; then
  echo "System-wide credentials file already exists; continuing installation...";
else
  while [[ "$storeCredentialsChoice" != "y" && "$storeCredentialsChoice" != "n" ]]; do
    read -p "Do you want to enter and store your credentials? (y/n): " storeCredentialsChoice;
  done
  if [[ "$storeCredentialsChoice" == "y" ]]; then
    read -p "Username: " username;
    read -s -p "Password: " password;
    if echo -e "$username\n$password" > "$userCredsFilePath"; then
      echo "Successfully installed system-wide credentials file.";
      unset username;
      unset password;
      chmod 600 "$userCredsFilePath";
    else
      echo "Error: Not able to install system-wide credentials file; exiting...";
      unset username;
      unset password;
      exit 1;
    fi
  else
    if [[ -f "$userCredsFilePath" ]]; then
      echo "Choosing to not overwrite permanently stored credentials.  Using existing information on system.";
    else
      echo "Choosing to not permanently store credentials.  They will have to be entered upon successive executions of the main script.";
    fi
  fi
fi
