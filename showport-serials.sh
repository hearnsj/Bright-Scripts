#!/bin/bash
for nodename in $(cmsh -c "device; foreach * (get hostname)")
do
 #
 # we cannnot log into mgmt01
 if [[ "$nodename" == "mgmt01" ]]; then
   continue
  fi 
  macad=$(cmsh -c "device use $nodename; get mac")
  echo -n   $nodename,$macad  
  # switchport=$(cmsh -c "device showport $macad")
  # echo -n -e ,  $switchport
  # and print out what the ethernet switch assignment is - does this match up?
  ethport=$(cmsh -c "device use $nodename ; get ethernetswitch")
  echo -n  -e ,$ethport

  serial=$(ssh $nodename "module load ipmitool ; ipmitool fru print 0  | grep Product | grep Serial | cut -d : -f 2")
  serial=`echo $serial  | sed "s/^[ \t]*//" `
  echo -n -e ,$serial

  ipaddr=$(ssh $nodename "ip addr show dev  enp6s0f0  | grep inet | grep -v inet6 ")
  ipaddr=`echo $ipaddr | awk '{print $2}' | cut -d '/' -f 1` 
  echo  -e ,$ipaddr

done
