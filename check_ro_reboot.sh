#!/bin/bash

host="pmweb02.ds.lax1.oversee.net util01.tm.lax1.oversee.net hermit.internal rtdb0-ds.lad.internal"

de_tmx_servers=$(for i in `seq 23 28`; do echo -n "decisionengine$i.ds.lax1.oversee.net "; done)
tmx_rook_servers=$(for i in `seq -f %02g 1 6`; do echo -n "tmxrook$i.tm.lax1.oversee.net "; done)

de_ds_servers=$(for i in `seq -f %02g 1 9`; do echo -n "decisionengine$i.ds.lax1.oversee.net "; done)
re_servers=$(for i in `seq -f %02g 1 5`; do echo -n "renderer$i.ds.lax1.oversee.net "; done)
tdd_servers=$(for i in `seq -f %02g 1 5`; do echo -n "tdd$i.ds.lax1.oversee.net "; done)
lm_servers=$(for i in `seq -f %02g 4 9`; do echo -n "lm$i.ds.lax1.oversee.net "; done)
dsopt_servers=$(for i in `seq -f %02g 1 6`; do echo -n "dsopt$i.ds.lax1.oversee.net "; done)
dsoptmemcache_servers=$(for i in `seq -f %02g 1 4`; do echo -n "dsoptmemcache$i.ds.lax1.oversee.net "; done)



kba_servers=$(for i in `seq -f %02g 1 3`; do echo -n "kba$i.ds.lax1.oversee.net "; done)
kbb_servers=$(for i in `seq -f %02g 1 3`; do echo -n "kbb$i.ds.lax1.oversee.net "; done)
kbc_servers=$(for i in `seq -f %02g 1 3`; do echo -n "kbc$i.ds.lax1.oversee.net "; done)
kbd_servers=$(for i in `seq -f %02g 1 4`; do echo -n "kbd$i.ds.lax1.oversee.net "; done)
kbe_servers=$(for i in `seq -f %02g 1 3`; do echo -n "kbe$i.ds.lax1.oversee.net "; done)
kbumm_servers=$(for i in `seq -f %02g 1 3`; do echo -n "kbumm$i.ds.lax1.oversee.net "; done)
uaparser_servers=$(for i in `seq -f %02g 1 3`; do echo -n "uaparser$i.ds.lax1.oversee.net "; done)

xfetch_servers=$(for i in `seq 1 10`; do echo -n "fx$i-ds.lad.internal "; done)

tmx_keyword_servers=$(for i in `seq -f %02g 1 1`; do echo -n "kw$i.tm.lax1.oversee.net "; done)
tmx_redirect_servers=$(for i in 1 3; do echo -n "redir0$i.tm.lax1.oversee.net "; done)

ssh_command="sudo ssh -q -i /home/dsdeploy/.ssh/id_dsa -o StrictHostKeyChecking=no -o ConnectTimeout=1 -t -t -l dsdeploy"

#cmd="hostname; if [[ `sudo touch /test_ro.txt &> /dev/null; echo $?` == 1 ]]; then echo ro; sudo /sbin/init 6; else echo rw; fi"
#cmd='if [[ `sudo touch /test_ro.txt &> /dev/null; echo $?` == 1 ]] || [[ `sudo touch /var/test_ro.txt &> /dev/null; echo $?` == 1 ]]; then echo "CRITICAL - Root and/or /var mounts are RO; rebooting."; sudo /sbin/init 6; else echo "Mounts are RW."; fi'

command_ro_test='if [[ `sudo touch /test_ro.txt &> /dev/null; echo $?` == 1 ]] || [[ `sudo touch /var/test_ro.txt &> /dev/null; echo $?` == 1 ]]; then echo "CRITICAL - Root and/or /var mounts are read only; rebooting."; else echo "Mounts are read write."; fi'

command_tmxrookserver_restart="hostname"

timestamp='date +%F_%T'


tmx_rook_restart_service(){
  host=$1;
  exit_code="-1"

  echo "`$timestamp` Waiting 2 seconds before checking online status for $host."
  sleep 2

  until [ $exit_code -eq 0 ]; do
    sleep 1
    exit_code=`$ssh_command $host;echo $?`
    echo "exit code for $host: $exit_code";
  done

  for i in $tmx_rook_servers; do
    echo "`$timestamp` Restarting tmxrookserver services on $i."
    $ssh_command $i "$command_tmxrookserver_restart"
    echo "`$timestamp` Sleeping for five seconds before going on to the next host."
    sleep 5;
  done
}


check_ro(){
  for i in $1; do
    echo -n "`$timestamp` $i: "
    output=`$ssh_command $i "$command_ro_test"`
    if [ $? != 0 ];
      then echo "WARNING - Connection timeout. Check host for online status."
    elif [[ $output =~ "CRITICAL" ]] && [[ $i =~ "hermit" ]];
      then echo $output
      
      tmx_rook_restart_service $i
    else echo "OK - $output"
    fi
  done
}

main(){
  echo "`$timestamp` Starting read only check."

  check_ro "$host"
  check_ro "$de_tmx_servers"
  check_ro "$tmx_rook_servers"
  check_ro "$kba_servers"
  check_ro "$kbb_servers"
  check_ro "$kbd_servers"
  check_ro "$kbumm_servers"
  check_ro "$xfetch_servers"
  check_ro "$uaparser_servers"
  check_ro "$tmx_keyword_servers"
  check_ro "$tmx_redirect_servers"

  check_ro "$kbc_servers"
  check_ro "$kbe_servers"
  check_ro "$de_ds_servers"
  check_ro "$re_servers"
  check_ro "$tdd_servers"
  check_ro "$lm_servers"
  check_ro "$dsopt_servers"
  check_ro "$dsoptmemcache_servers"

  echo "`$timestamp` Read only check completed."
}

main >> /usr/local/oversee/var/log/check_ro_reboot.txt 
