#!/bin/bash
root_check() {
  if [[ "$(id -u)" -ne 0 || $(ps -o comm= -p $PPID) == "sudo" ]]; then
    clear
    msg_error "Please run this script as root."
    echo -e "\nExiting..."
    sleep 2
    exit
  fi
}

#One stop shop for all the named services
server_name="valheim"
start_service_file="$server_name-server.service"
shutdown_service_file="$server_name-server-shutdown.service"
start_timer_file="$server_name-server-start.timer"
stop_timer_file="$server_name-server-stop.timer"

service_files=(
    "$start_service_file" 
    "$shutdown_service_file" 
    "$start_timer_file" 
    "$stop_timer_file"
    )

service_start_template="$(cat <<-EOF
[Unit]
Description=$server_name Server

[Service]
ExecStart=/bin/bash /home/steam/valheimserver/valheim.sh
User=steam
WorkingDirectory=/home/steam/valheimserver

[Install]
WantedBy=multi-user.target
EOF
)"


service_shutdown_template="$(cat <<-EOF
[Unit]
Description=Shutdown $server_name-server Shutdown Service 

[Service]
ExecStart=systemctl stop $server_name-server
User=steam
EOF
)"

timer_start_calendar="*-*-* 09:00:00"
timer_start_template="$(cat <<-EOF
[Unit]
Description=$server_name Start Timer

[Timer]
Unit=$server_name-server.service
OnCalendar=$timer_start_calendar
Persistent=true

[Install]
WantedBy=timers.target
EOF
)"

timer_stop_calendar="*-*-* 09:00:00"
timer_stop_template="$(cat <<-EOF
[Unit]
Description=$timer_description Stop Timer

[Timer]
Unit=$server_name-server-server-shutdown.service
OnCalendar=$timer_stop_calendar
Persistent=true

[Install]
WantedBy=timers.target
EOF
)"

#--------------------------------------
echo $'\nCreating '$server_name' Service Files:'
echo "- Server Service"
echo "- Shutdown Service"
echo "- Daily Start Timer"
echo "- Daily Stop Timer"
echo
#--------------------------------------

check_if_service_file_exist(){
    for file in ${service_files[@]}; do
        if [ -s "$file" ]; then
            echo "$file already exists"
        fi
    done
}


create_file(){
    touch $1
    echo "$2" >> $1
}


check_if_service_file_exist "${service_files[@]}"
rm -f ${service_files[@]}


echo -e "\nCreating New Service Files...\n"
create_file "$start_service_file" "$service_start_template"
create_file "$shutdown_service_file" "$shutdown_service_template"
create_file "$start_timer_file" "$start_timer_template"
create_file "$stop_timer_file" "$stop_timer_template"


# echo -e "\nEnabling Services...\n"

# systemctl enable $start_service_file
# # systemctl enable $shutdown_service_file
# # systemctl enable $start_timer_file
# # systemctl enable $stop_timer_file

# echo -e "\nStarting Services...\n"

# systemctl start $start_service_file
# # systemctl start $shutdown_service_file
# # systemctl start $start_timer_file
# # systemctl start $stop_timer_file

# echo -e "\nStatus of Services...\n"

# systemctl status $start_service_file
# # systemctl status $shutdown_service_file
# # systemctl status $start_timer_file
# # systemctl status $stop_timer_file

# echo -e "\nDone!\n"