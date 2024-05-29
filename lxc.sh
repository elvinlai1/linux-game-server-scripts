#/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

read -p "Enter the name of the container:" container_name
echo $container_name


if [ -z "$container_name" ]; then
    echo "No container name provided"
    exit
fi

if [ -d "/var/lib/lxc/$container_name" ]; then
    echo "Container already exists"
    exit
fi

lxc-create -n $container_name -t download -- -d ubuntu -r bionic -a amd64
lxc-attach -n $container_name --veth lxcbr0,vmbr0

#lxc-start -F -n $container_name --logfile /var/log/lxc/$container_name.log

# Wait for the container to start
sleep 10

lxc-info -n $container_name | grep "IPV4"