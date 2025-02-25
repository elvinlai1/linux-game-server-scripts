#!/bin/bash
# First check if the script is being run as root
root_check() {
  if [[ "$(id -u)" -ne 0 || $(ps -o comm= -p $PPID) == "sudo" ]]; then
    clear
    msg_error "Please run this script as root."
    echo -e "\nExiting..."
    sleep 2
    exit
  fi
}

#One stop shop for all the variable declarations and functions

# Global Variables
#--------------------------------------
RED="\e[31m"
ORANGE="\e[33m"
GREEN="\e[32m"
RESET="\e[0m"

service_files=(
    "$server_name-server.service"
    "$server_name-server-shutdown.service"
    "$server_name-server-start.timer"
    "$server_name-server-stop.timer"
    )

template_files=(
    "$service_start_template"
    "$service_shutdown_template"
    "$timer_start_template"
    "$timer_stop_template"
    )

#--------------------------------------
# Functions
#--------------------------------------

install_steamcmd(){
    # Install steamcmd
    sudo add-apt-repository multiverse; sudo dpkg --add-architecture i386; sudo apt update
    apt-get install steamcmd -y
    # Check if the command was successful
    if [[ $? -ne 0 ]]; then
        echo "Error installing steamcmd"
        # Optionally, exit the script with an error code (e.g., exit 1)
        exit 1
    fi
}

setup_user(){
    # Create a user for the server
    useradd -m -s /bin/bash steam
    # Check if the command was successful
    if [[ $? -ne 0 ]]; then
        echo "Error creating user: steam"
        # Optionally, exit the script with an error code (e.g., exit 1)
        exit 1
    fi
}
##############################
# Install server dependecies
# Arguements: 
#   Triggers setup_user, install_steamcmd
#   creates game server start script
##############################
setup_server(){

valheim_server_script="$(cat <<-EOF
#!/bin/bash
export templdpath=$LD_LIBRARY_PATH  
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH  
export SteamAppID=892970

echo "Starting server PRESS CTRL-C to exit"  
./valheim_server.x86_64 -name "<servername>" -port 2456 -nographics -batchmode -world "<worldname>" -password "<serverpassword>" -public 1  
export LD_LIBRARY_PATH=$templdpath
EOF
)"
    setup_user
    install_steamcmd
    steamcmd +@sSteamCmdForcePlatformType linux +force_install_dir /path/to/server +login anonymous +app_update 896660 -beta none validate +quit
    touch /home/steam/valheimserver/valheim.sh
    echo "$valheim_server_script" > /home/steam/valheimserver/valheim.sh
}

##############################
# Check if local files are identical to new files byte wise
# Arguements: 
#   None
# Output:
#   Echo local file status 
##############################
check_file_diff(){
    # Create a tmp file with template content and compare it with the existing file
    if [ "$(diff -q $1 <(echo "$2"))" ]; then
        echo -e "${ORANGE}$1 is different from the template!${RESET}"
        echo -e "Updating $1..."
        echo "$2" > $1
        echo -e "$1 ${GREEN}updated!\n${RESET}"
    else 
        echo -e "$1 is the same as the template!\n"
    fi 
}

##############################
# Add changes to file or creates file if it doesn't exist 
# Output: 
#   Create file and overwrite local file
#   Outputs file created
##############################
create_file(){
    touch $1
    echo "$2" >> $1
    echo -e $1 "${GREEN}created!\n${RESET}"
}

##############################
# Check if local service files exist
############################## 
check_if_service_file_exist(){
    echo -e "Checking if the service files exist...\n"
    for (( i=0; i<${#service_files[@]}; i++ )); do 
        if [ -s "${service_files[$i]}" ]; then
            echo -e "${GREEN}${service_files[$i]} already exists!${RESET}"
            echo -e "Checking if it's the same as the template..."
            check_file_diff "${service_files[$i]}" "${template_files[$i]}"
            sleep 1
        else
            echo -e "${RED}${service_files[$i]} does not exist${RESET}"
            echo -e "Creating ${service_files[$i]}..."
            create_file "${service_files[$i]}" "${template_files[$i]}"
            sleep 1
        fi
    done
}

##############################
# Loop through hard defined services and enable them
##############################
enable_services(){
    for service_file in "${service_files[@]}"; do
        systemctl enable "$service_file"
        # Check if the command was successful
        if [[ $? -ne 0 ]]; then
            echo "Error enabling service: $service_file"
            # Optionally, exit the script with an error code (e.g., exit 1)
            exit 1
        fi
    done
}

##############################
# Loop through services and start them
##############################
start_services(){
    for service_file in "${service_files[@]}"; do
        systemctl start "$service_file"
        # Check if the command was successful
        if [[ $? -ne 0 ]]; then
            echo "Error starting service: $service_file"
            # Optionally, exit the script with an error code (e.g., exit 1)
            exit 1
        fi
    done
}

##############################
# Create defined services
##############################
create_services(){

server_name="valheim"

timer_start_calendar="*-*-* 14:00:00"
timer_stop_calendar="*-*-* 01:00:00"

# Service start
service_start_template="$(cat <<-EOF
[Unit]
Description=$server_name Server
Wants=network-online.target
After=syslog.target network-online.target2

[Service]
Type=simple
Restart=on-failure
RestartSec=5
User=steam
WorkingDirectory=/home/steam/valheimserver
ExecStart=/bin/bash /home/steam/valheimserver/valheim.sh

[Install]
WantedBy=multi-user.target
EOF
)"

# Shutdown service
service_shutdown_template="$(cat <<-EOF
[Unit]
Description=Shutdown $server_name-server Shutdown Service 

[Service]
ExecStart=systemctl stop $server_name-server
User=steam
EOF
)"

# Timer start
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

# Timer stop
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



}

##############################
# Create Rsync backup
##############################
create_rsync(){
    rsync -avzhP -e 'ssh -p 44' /opt/test/ 192.168.10.24:/Backup
}

##############################
# Enable defined services
##############################
enable_services(){

}


#--------------------------------------
# Start
#--------------------------------------
setup_server

check_if_service_file_exist "${service_files[@]}" "${template_files[@]}"

create_services
create_rsync
enable_services
start_services

