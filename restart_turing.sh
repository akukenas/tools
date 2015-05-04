#!/bin/bash

#server_groups="tdd renderer decisionengine kba kbb kbc kbd kbe kbumm uaparser"
server_groups="tdd renderer decisionengine kbc kbe"

tdd_servers=$(for i in `seq -f %02g 1 5`; do echo -n "tdd$i.ds.lax1.oversee.net "; done)
renderer_servers=$(for i in `seq -f %02g 1 5`; do echo -n "renderer$i.ds.lax1.oversee.net "; done)
decisionengine_servers=$(for i in `seq -f %02g 1 9`; do echo -n "decisionengine$i.ds.lax1.oversee.net "; done)
kba_servers=$(for i in `seq -f %02g 1 3`; do echo -n "kba$i.ds.lax1.oversee.net "; done)
kbb_servers=$(for i in `seq -f %02g 1 3`; do echo -n "kbb$i.ds.lax1.oversee.net "; done)
kbc_servers=$(for i in `seq -f %02g 1 3`; do echo -n "kbc$i.ds.lax1.oversee.net "; done)
kbd_servers=$(for i in `seq -f %02g 1 4`; do echo -n "kbd$i.ds.lax1.oversee.net "; done)
kbe_servers=$(for i in `seq -f %02g 1 3`; do echo -n "kbe$i.ds.lax1.oversee.net "; done)
kbumm_servers=$(for i in `seq -f %02g 1 3`; do echo -n "kbumm$i.ds.lax1.oversee.net "; done)
uaparser_servers=$(for i in `seq -f %02g 1 3`; do echo -n "uaparser$i.ds.lax1.oversee.net "; done)

tdd_services=(sitterd 1 1 tdd 6 6 log_server 1 1)
renderer_services=(sitterd 1 1 renderer_server 13 1)
decisionengine_services=(sitterd 1 1 decisionengine_server 13 1 log_server 1 1)
kba_services=(sitterd 1 1 adultscore_server 3 1 kmart_server 3 6 dsopt30_proxyd 1 1)
kbb_services=(sitterd 1 1 category_domain_server 3 1 kmart_server 3 3 bidvalue_server 3 1 dsopt30_proxyd 1 1)
kbc_services=(sitterd 1 1 kmart_server 3 6 dsopt30_proxyd 1 1)
kbd_services=(sitterd 1 1 bizrule_server 13 1 dsopt30_proxyd 1 1)
kbe_services=(sitterd 1 1 autotester_server 13 1 dsopt30_proxyd 1 1)
kbumm_services=(sitterd 1 1 umm_server 3 6)
uaparser_services=(sitterd 1 1 uas_serverd 6 1)

tdd_pid="tdd.01.pid tdd.02.pid tdd.03.pid tdd.04.pid tdd.05.pid tdd.06.pid log_server.pid"
renderer_pid="renderer_server.pid"
decisionengine_pid="decisionengine_server.pid log_server.pid"
kba_pid="adultscore.pid category.pid dsopt30_proxyd.pid generic_optin.pid generic.pid goldentail_domain.pid goldentail_keyword.pid kw_sdo.pid"
kbb_pid="bidvalue_server.pid cadillac.pid category_domain.pid cat_mu.pid dsopt30_proxyd.pid optoff.pid"
kbc_pid="dsopt2_3_1.pid dsopt2_4.pid dsopt30_proxyd.pid kw_exclusion_aid.pid kw_exclusion_domain.pid kw_inclusion_country.pid kw_inclusion.pid"
kbd_pid="bizrule_server.pid dsopt30_proxyd.pid"
kbe_pid="autotester_server.pid dsopt30_proxyd.pid"
kbumm_pid="ds_bid_multiplier_umm1_server.pid ds_bid_multiplier_umm2_server.pid ds_bid_multiplier_umm3_server.pid ds_bid_multiplier_umm4_server.pid ds_bid_multiplier_umm5_server.pid umm_ds_keywords.pid"
uaparser_pid="uas_serverd.pid"

ssh_command="sudo ssh -q -i /home/dsdeploy/.ssh/id_dsa -o StrictHostKeyChecking=no -o ConnectTimeout=1 -t -t -l dsdeploy"

timestamp='date +%F_%T'

build_restart_datareceiver_service(){
restart_datareceiver_service="
  echo \"\`\$timestamp\` - $host: Calling stop for receiverd.\";
  sudo /etc/init.d/receiverd stop &> /dev/null;
  if (( "$?" != 0 )); then echo \"\`\$timestamp\` - $host: datereceiver did not stop successfully. Going to manually kill the process.\";
  sudo pgrep -9 -f datareceiver &> /dev/null && sudo rm -f /usr/local/oversee/var/run/datareceiver.pid &> /dev/null; fi;
  echo \"\`\$timestamp\` - $host: Sleeping for 1 seconds.\";
  sleep 1;
  echo \"\`\$timestamp\` - $host: Calling start for receiverd.\";
  sudo /etc/init.d/receiverd start &> /dev/null;
  echo \"\`\$timestamp\` - $host: Sleeping for 1 seconds.\";
  sleep 1;
"
}

log_file="/usr/local/oversee/var/log/turing_services_check.txt"
warnings_file="/usr/local/oversee/var/log/turing_services_check_warnings.txt"
criticals_file="/usr/local/oversee/var/log/turing_services_critical.txt"
email_addresses="akukenas@domainsponsor.com, akukenas@oversee.net"

build_restart_sitterd_services(){
  restart_sitterd_services="
  timestamp=\"date +%F_%T\";
  echo \"\`\$timestamp\` - $host: Calling killall for sitterd.\";
  sudo /etc/init.d/sitterd killall &> /dev/null &&
  echo \"\`\$timestamp\` - $host: Sleeping for five seconds to let sitterd shutdown gracefully.\";
  sleep 5;
  echo \"\`\$timestamp\` - $host: Changing directiory to Turing pid dir (/usr/local/oversee/var/run) \"; 
  cd /usr/local/oversee/var/run; 
  echo \"\`\$timestamp\` - $host: If they still exist, removing pids ${!group_pid}\"\".\"; 
  sudo rm -f ${!group_pid} &&
  echo \"\`\$timestamp\` - $host: Calling start for sitterd.\";
  sudo /etc/init.d/sitterd start  &> /dev/null &&
  echo \"\`\$timestamp\` - $host: Sleeping for five seconds to let sitterd startup.\";
  sleep 5;"
}

build_turing_sitterd_check(){
  services_array=($1)
  group=$2
  number_of_values=${#services_array[@]}
  group_pid=$group"_pid"
  listener=": Listener"
  index=0;
  service_check="host=\`hostname\`; timestamp=\`date +%F_%T\`; if (( "

  while (( $index < $number_of_values)); do
    if [[ "$group" != "tdd" ]];
      then
        if [[ ${services_array[$index]} =~ "_server$" ]] && [[ ${services_array[$index]} != "log_server" ]]
          then service_check_addition="
               (( 
               (( \`pgrep -f ^${services_array[$index]}|wc -l\`
               == $((${services_array[$index+1]}*${services_array[$index+2]})) )) 
               && 
               (( 
               (( \$(for i in \`pgrep -U nobody -f \"^${services_array[$index]}$listener\"\`; do echo \$i; pgrep -P \$i;done|wc -l) 
               == $((${services_array[$index+1]}*${services_array[$index+2]})) 
               )) 
               )) 
               ))"

          else service_check_addition="
               (( 
               (( \`pgrep -f ^${services_array[$index]}|wc -l\` 
               == ${services_array[$index+1]} 
               )) 
               && 
               (( \`pgrep -U nobody -f ^${services_array[$index]}|wc -l\` 
               == ${services_array[$index+1]} 
               )) 
               ))"
        fi
      else service_check_addition="
           (( 
           (( \`pgrep -f ^${services_array[$index]}|wc -l\` 
           == ${services_array[$index+1]} 
           )) 
           && 
           (( \`pgrep -U nobody -f ^${services_array[$index]}|wc -l\` 
           == ${services_array[$index+1]} 
           )) 
           ))"
    fi
    service_check=$service_check$service_check_addition
    index=$[$index+3]
    if (( $index < number_of_values  ));
      then service_check="
           $service_check && "
      else service_check="
           $service_check )); 
           then
             echo \"\$timestamp - \$host: OK - Service check passed.\";
           else
             echo \"\$timestamp - \$host: CRITICAL - Service check failed.\";
           fi;
           sleep 1"
    fi
  done

  echo $service_check
}

check_turing(){
  servers=($1)
  services=($2)
  services_count=$((${#services[@]}/3))
  server_group=`echo $1|grep -o "^[[:lower:]]*"`
  group_pid=$server_group"_pid"
  check="$( build_turing_sitterd_check "`echo ${services[@]}`" $server_group)"

#  echo "server group: $server_group"
#  echo "servers: $1"
#  echo "server_group: $server_group"
#  echo "services_count: $services_count"

  for i in ${servers[@]}; do
    host=$i
    count=services_count
#    echo "services: `echo ${services[@]}` server_group: $server_group"
#    echo "server: $i"
#    echo -e "check_command: $check \n"
    output=`$ssh_command $host "$check"`

    if [ $? != 0 ];
      then echo "`$timestamp` - $host: WARNING - Connection timeout. Check host for online status." | tee -a $warnings_file
    elif [[ $output =~ "CRITICAL" ]];
      then
        echo $output | tee -a $criticals_file
        build_restart_sitterd_services
        build_restart_datareceiver_service
        $ssh_command $host "$restart_sitterd_services $restart_datareceiver_service"
    else echo $output
    echo "`$timestamp` - $host: Logged out."
    fi

#    echo
#    echo $output
  done
}

main(){
  echo -n > $criticals_file
  echo "`$timestamp` - Starting Turing services check."

  for i in $server_groups; do
    servers=$i"_servers"
    pid=$i"_pid"
    service=$i"_services[@]"
    check_turing "${!servers}" "`echo ${!service}`"
  done
  
  if [[ -s $criticals_file  ]];
    then  mail -s "Turing Services check script - hosts that needed services restarted" $email_addresses < $criticals_file
  fi

  echo "`$timestamp` - Turing services check completed."
}

main >> $log_file
