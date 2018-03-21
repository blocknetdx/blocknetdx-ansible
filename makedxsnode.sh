#!/usr/bin/env bash
mynodename=$1
mynewnodeaccount=$(./blocknetdx-cli getaccountaddress ${mynodename})
echo "new account address ${mynewnodeaccount}"
mynewkey=$(./blocknetdx-cli servicenode genkey)
echo "new key ${mynewkey}"
ansible-playbook -i ./hosts makedxsnode.yml -e "servicenodeprivkey=${mynewkey}"
echo $mynewkey >> buildlog.txt
