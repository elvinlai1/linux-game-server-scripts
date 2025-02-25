#!/bin/bash

# ./create_lxc.sh 501 test_ct 

# Configuration Variables
CONTAINER_ID="$1"          
HOSTNAME="$2"             
TEMPLATE="local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"             
STORAGE="local"
VOLUME="local-lvm"
DISK_SIZE="8"              
PASSWORD="reddit"             
CPUS="2"            
MEMORY="4096"       
NET_BRIDGE="vmbr0" 
IP_ADDRESS="dhcp"  
VLAN_ID="30"                
# Container execution Variables     
RETRIES="4"
DELAY="5" # Seconds  

# Error Handling
if [ -z "$CONTAINER_ID" ] || [ -z "$HOSTNAME" ] || [ -z "$TEMPLATE" ] || [ -z "$STORAGE" ] || [ -z "$PASSWORD" ]; then
  echo "Usage: $0 <container_id> <hostname>"
  exit 1
fi

# Proxmox Command
pct create "$CONTAINER_ID" "$TEMPLATE" \
  --hostname "$HOSTNAME" \
  --rootfs "$VOLUME:$DISK_SIZE" \
  --password "$PASSWORD" \
  --cores "$CPUS" \
  --memory "$MEMORY" \
  --net0 "name=eth0,bridge=$NET_BRIDGE,ip=$IP_ADDRESS,tag=$VLAN_ID,type=veth" \
  --unprivileged 1

# Check if the command succeeded
if [ $? -eq 0 ]; then
  echo "LXC container $CONTAINER_ID created successfully."
  pct start "$CONTAINER_ID"
  echo "LXC container $CONTAINER_ID started."
else
  echo "Failed to create LXC container $CONTAINER_ID."
  exit 1
fi

for i in $(seq 1 $RETRIES); do
  echo "Attempt $i: Checking internet connectivity for container $CONTAINER_ID..."

  pct exec "$CONTAINER_ID" -- bash -c "ping -c 1 8.8.8.8 > /dev/null 2>&1"

  if [ $? -eq 0 ]; then
    echo "Container $CONTAINER_ID has internet connectivity (ping)."
    pct exec $CONTAINER_ID -- bash -c "wget -O lxc.sh https://raw.githubusercontent.com/elvinlai1/linux-game-server-scripts/refs/heads/main/lxc.sh"
    pct exec $CONTAINER_ID -- bash -c "cat lxc.sh"
    exit 0 # Exit successfully if connected
  else
    echo "Attempt $i failed. Retrying in $DELAY seconds..."
    sleep $DELAY
  fi
done

echo "Container $CONTAINER_ID failed to connect after $RETRIES attempts."
exit 1

exit 0


check_if_template_exist
check_if_storage