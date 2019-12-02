#!/usr/bin/env bash
# This script is still beta, please edit WALLETPATH to match your ENV
#

WALLETNAME="blocknetdx-cli -datadir=/media/atcsecure/ssdchaindata/blocknetmain/"
WALLETPATH=/home/atcsecure/dx/3140classic/blocknetdx-3.14.0/bin/
mynodename=$1

# create account using nodename
mynewnodeaccount=$(${WALLETPATH}${WALLETNAME} getaccountaddress ${mynodename})
echo "new account address ${mynewnodeaccount}"
# send 5k to new address
echo "sending"
myvinhash=$(${WALLETPATH}${WALLETNAME} sendtoaddress ${mynewnodeaccount} 5000)
# gen snode key
echo "generating snode key"
mynewkey=$(${WALLETPATH}${WALLETNAME} servicenode genkey)
# get vout value
echo "waiting..."
sleep 90

echo "new key ${mynewkey}"

# Build snode via aws using ansible
ansible-playbook -i ./hosts ./makedxsnode.yml -e "servicenodeprivkey=${mynewkey} snodename=${mynodename}"
#load up ip 
mynewip=$(head -n 1 ~/currentip.txt)
echo "currentip: ${mynewip}"
echo "waiting..."
sleep 90

echo "-----------" >> buildlog.txt
echo $mynodename >> buildlog.txt
echo $mynewip >> buildlog.txt
echo $mynewnodeaccount >> buildlog.txt
echo $myvinhash >> buildlog.txt
echo $mynewkey >> buildlog.txt
echo $myhashvoutvalue >> buildlog.txt

echo "getting vout value"
myhashvoutvalue=$(${WALLETPATH}${WALLETNAME} listunspent | grep ${mynewnodeaccount} -A 5 -B 2 | grep 'vout' | cut -d':' -f2-)
# clean it up - remove first/last chars from string
myhashvoutvalue=${myhashvoutvalue:1:${#myhashvoutvalue}-2}
echo "vout ${myhashvoutvalue}"

# lock it
mylockresults=$(${WALLETPATH}${WALLETNAME} lockunspent false "[{\"txid\":\"${myvinhash}\",\"vout\":${myhashvoutvalue}}]")

echo $mylockresults >> buildlog.txt
echo "-----------" >> buildlog.txt
echo "${mynodename} ${mynewip}:41412 $mynewkey $myvinhash $myhashvoutvalue">> snode.conf
#echo $ansibleresults >> abuildresults.txt

