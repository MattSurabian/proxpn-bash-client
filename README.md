# ProXPN OpenVPN Bash Client

[ProXPN](http://proxpn.com/) provides [OpenVPN](https://openvpn.net/) exit nodes all around the world and is a great service to use when connected to untrusted WiFi hotspots or a censored and monitored network. It's also very useful if you need to alter your geographic location to test web applications or services from different locales.

The problem with ProXPN, is that until recently they didn't provide or maintain a Linux client, so Linux users were left to sort out how to securely connect to ProXPN's OpenVPN servers themselves or stop using the service. This repo endeavored to fix that.

```
$ proxpn

Welcome to the ProXPN OpenVPN Bash Client!
This script must be run as root in order to successfully apply network route configurati
on.

Elevated permissions not detected, falling back to dry-run mode...

What protocol would you like to connect with?
Generally, TCP is the best choice on networks prone to packet loss.
Be advised if you don't have a paid account, you can only use the FREE UDP exit node.
1) tcp
2) udp
Select a protocol to use for this connection (1-2)2

Which exit node would you like to use?
1) Chicago	        7) Paris	      13) NYC		 19) HongKong
2) Hafnarfjordur    8) Singapore      14) Netherlands2	 20) Frankfurt
3) Toronto	        9) Zurich	      15) Seattle	 21) SanJose
4) Netherlands	   10) Frankfurt2     16) Stockholm	 22) FREE
5) Bucharest	   11) London	      17) Miami
6) LA2		       12) LA	          18) Sydney
Select an exit node (1-22): 8

Dry run complete!
Use following OpenVPN command to connect to ProXPN:
/usr/bin/openvpn --config /home/matt/.config/proxpn/proxpn.ovpn --remote 191.101.242.121
 443 udp --auth-nocache --auth-user-pass /home/matt/.config/proxpn/login.conf


```

### Prerequisites

Because this repo is designed to enable secure and private communications, dependencies have been kept to an absolute minimum. All that is required to use this shell script is `openvpn` itself, and of course a ProXPN account. 

It's likely your system's package manager knows how to get and install `openvpn` already. [More details about installing `openvpn` can be found here](https://openvpn.net/index.php/open-source/documentation/howto.html#install).

**Debian/Ubuntu**

The official repositories have OpenVPN available so install it!

```
apt-get install openvpn
```

**RPM**

The official repositories have OpenVPN available so install it!

```
rpm -i openvpn
```

**Arch Linux**

The official repositories have OpenVPN available so [install it with pacman](https://wiki.archlinux.org/index.php/OpenVPN#Install_OpenVPN).

```
pacman -S openvpn
```

**OS X**

The simplest way to install OpenVPN in OS X is with [Homebrew](http://brew.sh/)

```
brew install openvpn
```
**Note:** Mac uses may, upon receiving a build error mentioning not being able to use *unsigned kexts*, have to install another package in order to install openvpn, which can be done with the following command:
```
brew install Caskroom/cask/tuntap
```

### Installing This Script

To use this script you can either clone this repo, or download the source from the [releases page](https://github.com/MattSurabian/proxpn-bash-client/releases).

For an automated installation run the included install script `sudo ./install.sh`. If you'd prefer to install this script without `sudo` you may do so, however without elevated privledges it will only setup the configuration files, leaving you responsible for copying the script somewhere in your path, like `/usr/local/bin`. If you would prefer to do the entire install manually and avoid the install script completely here's how:

 - Create a `proxpn` directory in `~/.config`: ` mkdir -p ~/.config/proxpn` and store the included `proxpn.ovpn` file there: `cp ./proxpn.ovpn ~/.config/proxpn/`. 
 - The main script should be given execute permissions `chmod +x proxpn` and copied to somewhere in your `$PATH`, for example in either `/usr/local/bin` or `/usr/bin`. This should allow you to run the command `proxpn` from any location.
 - Optionally store authentication credentials, as mentioned in the following section.

### Authentication Credentials

When using the VPN, this script does not handle the ProXPN authentication prompt; that comes entirely from the `openvpn` program itself. If you want to avoid entering your credentials you can create a file at `~/.config/proxpn/login.conf` with your ProXPN username on one line and password on another. The install script also asks if you would like to do this, so you don't need the manually work with the file.  Again, this shell script does NOTHING with that file other than point OpenVPN to it. The specification for that file and the `--auth-user-pass` flag can be found in the [OpenVPN documentation](https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html).

### Supported Exit Nodes

This script supports the following ProXPN exit nodes:

*TCP*

```
  1) Chicago	  5) London	   9) Stockholm	   13) SanJose
  2) Toronto	  6) LA		   10) Miami
  3) Netherlands  7) NYC	   11) Sydney
  4) Frankfurt2	  8) Seattle   12) Frankfurt
```

*UDP*

```
1) Chicago	        7) Paris	      13) NYC		    19) HongKong
2) Hafnarfjordur    8) Singapore      14) Netherlands2	20) Frankfurt
3) Toronto	        9) Zurich	      15) Seattle	    21) SanJose
4) Netherlands	   10) Frankfurt2     16) Stockholm	    22) FREE
5) Bucharest	   11) London	      17) Miami
6) LA2		       12) LA	          18) Sydney
```

### Usage

This shell script will need to be run using `sudo` because it's establishing a VPN connection. You'll notice when installing ProXPN's client software on supported systems it will also request elevated access. While this isn't something to take lightly, the hope is this script is easy enough to digest that you feel confident and secure running it as `sudo`.  
If the script is run without `sudo` dry run mode is enabled, which does not attempt to establish a connection but prints an OpenVPN command to STDOUT that can be copied and used directly. Dry run mode can also be enabled by passing the flag `--dry-run`.

### Non-Interactive Mode

This script typically requires interaction from the user to select a protocol and an exit node to connect to, however the `--remote` and `--proto` flags (or: `-r`, `-remote`, `-p`, `-proto`) allows this script to be run in non-interactive mode.
The `--proto` flag expects the name of the protocol to use (`udp` or `tcp`) and the `--remote` flag expects the case senstive name of the exit node to connect to. To automatically connect to the UDP New York City exit node, for example, use the command: `sudo proxpn --proto udp --remote NYC`.

### How does this script work?

Bash is notorious for being difficult to read and understand. For this reason the code has been kept simple, brief, and is liberally commented. The following list describes, in plain English, what this script is doing.

  1. Check if openvpn is installed:
    - If it isn't, exit. 
    - If it is, store the path to the executable as the variable `OPENVPN`
  1. Setup constants which tell the program where to find the OpenVPN config file and where to look for an optional file containing the user's ProXPN credentials (by default it checks inside `~/.config/proxpn`).
      - If no OpenVPN config file is found, exit. 
      - If no credentials file is found tell the user they're expected to login.
  1. Check if the command was run without `sudo` or if the flag `--dry-run`, or `--remote` was passed. 
    - If `--dry-run` was passed, set the `dryRun` variable to `true`, causing the script to stop before attempting to open a connection to ProXPN and instead print an OpenVPN command to STDOUT.
    - If `--proto` was passed, set the `proto` variable to the value and make sure it's valid (`tcp|udp`). If it is, proceed, if not print an error and exit.
    - If `--remote` was passed check the `exit_nodes` array to see if the specified remote exit is known. If it is, proceed, if not, print an error and exit
  1. Setup a [bash `trap`](http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_12_02.html) to catch if the user prematurely exits the script by pressing control-c.
    - If they do, make sure that `stty echo` has been called. This ensures that if user input was hidden (OpenVPN does this after prompting for a username and password) it doesn't continue to be hidden after the application is closed. This is a terminal specific issue.
  1. Setup an array containing all of the ProXPN exit node IP addresses as provided by ProXPN manifest located at: http://proxpn.com/updater/locations-v3.xml
  1. Show the user all of the exit nodes available given the protocol they chose and ask them to choose one
    - If their response is valid, set the remote server 
    - If it isn't, exit.
  1. If in dry run mode, print the OpenVPN command to STDOUT and exit, otherwise attempt to establish a connection to ProXPN.
    - If the user hasn't provided a credentials file to `openvpn` and dry run mode was not enabled then they will be prompted for a password.
    - Terminate the VPN tunnel at anytime with control-c.

### Does this work for the free edition of ProXPN?

Yes, but non-paid ProXPN users will only be able to successfully connect to the rate limited `FREE` UDP exit node.
