#!/bin/bash
rsync -avzhP -e 'ssh -p 44' /opt/test/ 192.168.10.24:/Backup

