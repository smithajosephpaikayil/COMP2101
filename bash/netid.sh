#!/bin/bash
#
# this script displays some host identification information for a Linux machine
#
# Sample output:
#   Hostname      : zubu
#   LAN Address   : 192.168.2.2
#   LAN Name      : net2-linux
#   External IP   : 1.2.3.4
#   External Name : some.name.from.our.isp

# the LAN info in this script uses a hardcoded interface name of "eno1"
#    - change eno1 to whatever interface you have and want to gather info about in order to test the script

# TASK 1: Accept options on the command line for verbose mode and an interface name
#         If the user includes the option -v on the command line, set the varaible $verbose to contain the string "yes"
#            e.g. network-config-expanded.sh -v
#         If the user includes one and only one string on the command line without any option letter in front of it, only show information for that interface
#            e.g. network-config-expanded.sh ens34
#         Your script must allow the user to specify both verbose mode and an interface name if they want
# TASK 2: Dynamically identify the list of interface names for the computer running the script, and use a for loop to generate the report for every interface except loopback

################
# Data Gathering
################
# the first part is run once to get information about the host
# grep is used to filter ip command output so we don't have extra junk in our output
# stream editing with sed and awk are used to extract only the data we want displayed



#***************************TASK 1*************************************#
verbose="no"

# without options, OUTPUT - general summary
if [ $# -eq 0 ]; then
  my_hostname=$(hostname)
  default_router_address=$(ip r s default| cut -d ' ' -f 3)
  default_router_name=$(getent hosts $default_router_address|awk '{print $2}')
  external_address=$(curl -s icanhazip.com)
  external_name=$(getent hosts $external_address | awk '{print $2}')
  cat <<EOF
  System Identification Summary
  =============================
  Hostname      : $my_hostname
  Default Router: $default_router_address
  Router Name   : $default_router_name
  External IP   : $external_address
  External Name : $external_name
EOF
fi

#With options
while [ $# -gt 0 ]; do
  case "$1" in
    -v )
    verbose="yes"
    ;;
  esac

#1)if the user enters the -v command then print the system summary, 
#2)break the loop, continue with the rest of the summary
  if [ $1 = "-v" ]; then
    [ "$verbose" = "yes" ] && echo "Gathering host information"
    # we use the hostname command to get our system name
    my_hostname=$(hostname)
    [ "$verbose" = "yes" ] && echo "Identifying default route"
    # the default route can be found in the route table normally
    # the router name is obtained with getent
    default_router_address=$(ip r s default| cut -d ' ' -f 3)
    default_router_name=$(getent hosts $default_router_address|awk '{print $2}')
    [ "$verbose" = "yes" ] && echo "Checking for external IP address and hostname"
    # finding external information relies on curl being installed and relies on live internet connection
    external_address=$(curl -s icanhazip.com)
    external_name=$(getent hosts $external_address | awk '{print $2}')
    cat <<EOF
    System Identification Summary
    =============================
    Hostname      : $my_hostname
    Default Router: $default_router_address
    Router Name   : $default_router_name
    External IP   : $external_address
    External Name : $external_name
EOF
  break
  fi
# if option is not -v
  if [ $# -eq 1 -a "$1" != "-v" ]; then
    interface="$1"
    ipv4_address=$(ip a s $interface|awk -F '[/ ]+' '/inet /{print $3}')
    ipv4_hostname=$(getent hosts $ipv4_address | awk '{print $2}')
    network_address=$(ip route list dev $interface scope link|cut -d ' ' -f 1)
    network_number=$(cut -d / -f 1 <<<"$network_address")
    network_name=$(getent networks $network_number|awk '{print $1}')
    cat <<EOF
    Interface $interface:
    ===============
    Address         : $ipv4_address
    Name            : $ipv4_hostname
    Network Address : $network_address
    Network Name    : $network_name
EOF
  break
  fi
  shift
done



#***************************TASK 2*************************************#
#list all the interfaces to the user - use awk to extract data from 'ip a'
allInterfaces=$(ip a | awk '/: e/{print $2}')
#to determine how many times the loop needs to run, I need to know how many interfaces there are
numberOfInterfaces=$( ip a | awk '/: e/{print $2}' | wc -l )
for (( count=1; count <= $numberOfInterfaces; count++ )); do
  interface=$(ip a | awk '/: e/ {print $2}' | awk "NR==$count")
  [ "$verbose" = "yes" ] && echo "Reporting on interface: $interface"
  [ "$verbose" = "yes" ] && echo "Getting IPV4 address and name for interface $interface "
  ipv4_address=$(ip a s $interface|awk -F '[/ ]+' '/inet /{print $3}')
  ipv4_hostname=$(getent hosts $ipv4_address | awk '{print $2}')
  [ "$verbose" = "yes" ] && echo "Getting IPV4 network block info and name for interface $interface"
  network_address=$(ip route list dev $interface scope link|cut -d ' ' -f 1)
  network_number=$(cut -d / -f 1 <<<"$network_address")
  network_name=$(getent networks $network_number|awk '{print $1}')
  cat <<EOF
  Interface $interface:
  ===============
  Address         : $ipv4_address
  Name            : $ipv4_hostname
  Network Address : $network_address
  Network Name    : $network_name
EOF
done
