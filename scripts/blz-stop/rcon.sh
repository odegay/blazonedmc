#!/bin/bash

SERVER="localhost"
PORT="25575"
PASSWORD=""
SECURE=0
SECURE_PORT=""

RCON_HEADER=$(echo -e "\xff\xff\xff\xff")
ESCAPE_CHAR=$(echo -en "\x1b")

# Send raw rcon command
# $1	 nc parameters Server Port
# $2...	 Raw rcon message
# stdout Raw reply from the rcon server
function rcon_send_raw()
{
	echo -e "SENDING: $RCON_HEADER${@:2} AND THIS $1"
	echo -n login | nc -u -v -w 1 $1 
	echo -n "$RCON_HEADER${@:2}" | nc -u -v -w 1 $1

	# nc -u -v -w 1 $1 RCON_HEADER${@:2}
}

# Send raw rcon command
# $1	 Server
# $2	 Port
# $3	 Password
# $4	 Secure protocol
# $5...	 Rcon command
# stdout Reply from the rcon server
function rcon_send()
{
	local SERVER=$1
	local PORT=$2
	local COMMAND=${@:3}
	echo -e "SERVER: $SERVER"
	echo -e "PORT $PORT"
	echo -e "COMMAND $COMMAND"	
	rcon_send_raw "$SERVER $PORT" rcon $PASSWORD $COMMAND 
	#| rcon_strip_header n | rcon_recolor
}

# Create MD4 HMAC
# $1	 Password
# $2...	 Data
# stdout Binary hash
function rcon_hash()
{
	echo -n ${@:2} | openssl dgst -md4 -hmac $1 -binary
}

# Remove the header from rcon packets
# $* additional strings to be removed
# stdin -> stdout
function rcon_strip_header()
{
	sed -r "s/^$RCON_HEADER$*//"
}

# Remove rcon colors
# Single-digit colors are converted to ANSI colors, complex colors are stripped
# stdin -> stdout
function rcon_recolor()
{
	sed -r \
		-e "s/^|([^^])\^0/\\1${ESCAPE_CHAR}[0m/g" \
		-e "s/^|([^^])\^([1-47])/\\1${ESCAPE_CHAR}[1;3\\2m/g" \
		-e "s/^|([^^])\^5/\\1${ESCAPE_CHAR}[1;36m/g" \
		-e "s/^|([^^])\^6/\\1${ESCAPE_CHAR}[1;35m/g" \
		-e "s/^|([^^])\^[89]/\\1${ESCAPE_CHAR}[1;37m/g" \
		-e "s/^|([^^])\^x[[:xdigit:]]{3}/\\1${ESCAPE_CHAR}[0m/g" \
		-e "s/\^\^/^/g" \
		
	echo -en "${ESCAPE_CHAR}[0m"
}

function show_help()
{
	echo -e "\e[1mNAME\e[0m"
	echo -e "\t$0 - Send a single rcon command"
	echo
	echo -e "\e[1mSYNOPSIS\e[0m"
	echo -e "\t\e[1m$0\e[0m [\e[4moptions\e[0m...] [\e[1m-c \e[4;22mcommand\e[0m...]"
	echo -e "\t\e[1m$0\e[0m \e[1mhelp\e[0m|\e[1m-h\e[0m|\e[1m--help\e[0m"
	echo
	echo -e "\e[1mOPTIONS\e[0m"
	echo -e "\e[1m-host=\e[22;4mserver"
	echo -e "\tSet rcon server. Default: \e[1m$SERVER\e[0m"
	echo -e "\e[1m-p\e[22;4mport\e[0m|\e[1m-P\e[22;4mport\e[0m|\e[1m-port=\e[22;4mport\e[0m"
	echo
	echo -e "\e[1mNOTES\e[0m"
	echo -e " * Unrecognized paramters are interpreted as rcon commands"
	echo -e " * If no rcon commands are passed, it will read them from standard input"
	echo -e " * A single call to $0 results in a single rcon command being executed"
	echo -e " * If the command produces some output, it is shown on standard output"
	echo
}


cat_command=false
rcon_command=""

if [ $# -eq 0 ]
  then    
	read -p "No arguments supplied. Press enter"
	show_help
	exit 0
fi

for arg in $@
do
	echo "$arg"	
	if $cat_command
	then
		rcon_command="$rcon_command $arg"
	else
		case $arg in
			help|--help|-h)
				show_help
				exit 0
				;;
			-host=*)
				SERVER=${arg#*=}
				;;
			-port=*)
				PORT=${arg#*=}
				;;
			*)
				rcon_command="$rcon_command $arg"
				;;
		esac
	fi
done

if [ -z "$rcon_command" ] 
then
	read -p "No command argument supplied. Press enter"
	show_help
	exit 0
fi

rcon_command=${rcon_command# }


echo -e "Sending SERVER = : $SERVER" 
echo -e "Sending PORT = : $PORT" 
echo -e "Sending PASSWORD = : $PASSWORD" 
echo -e "Sending SECURE = : $SECURE" 
echo -e "Sending rcon_command = : $rcon_command" 

rcon_send $SERVER $PORT "$rcon_command"