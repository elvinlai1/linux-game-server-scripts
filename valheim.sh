#!/bin/sh
if [ $(id -u) = 0 ]; then
    echo "Please run as root"
    exit 1
fi

server_name="valheim"

echo "\nCreating $server_name Service Files:"
echo "- Main Service File"
echo "- Daily Shutdown Service"
echo "- Daily Start Timer"
echo "- Stop Timer"
echo

create_start_service() {
if [ -s "$server_name-server.service" ]; then
    echo "$server_name Service File Exists"
    echo "> Removing $server_name Service\n"
    rm $server_name-server.service
fi

service_template="$(cat <<-EOF
[Unit]
Description=$server_name Server

[Service]
ExecStart=/home/steam/$server_name/start_server.sh
User=steam
Group=steam
Restart=always
RestartSec=5
EOF
)"

touch $server_name-server.service
echo "$service_template" >> $server_name-server.service

}

create_shutdown_service(){ 

if [ -s "$server_name-shutdown.service" ]; then
    echo "$server_name Shutdown Service File Exists"
    echo "> Removing $server_name Shutdown Service\n"
    rm $server_name-shutdown.service
fi

shutdown_template="$(cat <<-EOF
[Unit]
Description=Shutdown Palworld 

[Service]
ExecStart=systemctl stop palserver
User=root
Group=root
EOF
)"

touch $server_name-shutdown.service
echo "$shutdown_template" >> $server_name-shutdown.service

}

create_start_timer() {

if [ -s "$server_name-start.timer" ]; then
    echo "$server_name Start Timer File Exists"
    echo "> Removing $server_name Start Timer\n"
    rm $server_name-start.timer
fi 
 
timer_description="$server_name Start Timer"
timer_unit="$server_name_server.service"
timer_start_calendar="*-*-* 09:00:00"

timer_template="$(cat <<-EOF
[Unit]
Description=$timer_description

[Timer]
Unit=$timer_unit
OnCalendar=$timer_calendar
Persistent=true

[Install]
WantedBy=timers.target
EOF
)"

touch $server_name-start.timer
echo "$timer_template" >> $server_name-start.timer

}

create_stop_timer() { 

if [ -s "$server_name-stop.timer" ]; then
    echo "$server_name Stop Timer File Exists"
    echo "> Removing $server_name Stop Timer\n"
    rm $server_name-stop.timer
fi 

timer_description="$server_name Start Timer"
timer_unit="$server_name-server.service"
timer_stop_calendar="*-*-* 09:00:00"

timer_template="$(cat <<-EOF
[Unit]
Description=$timer_description

[Timer]
Unit=$timer_unit
OnCalendar=$timer_calendar
Persistent=true

[Install]
WantedBy=timers.target
EOF
)"

touch $server_name-stop.timer
echo "$timer_template" >> $server_name-stop.timer

}

create_start_service
create_shutdown_service
create_start_timer
create_stop_timer