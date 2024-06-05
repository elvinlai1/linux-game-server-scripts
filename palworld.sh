#!/bin/bash


#Download the server
steamcmd +login anonymous +app_update 2394010 validate +quit

#Start server
cd ~/Steam/steamapps/common/PalServer
./Palserver.sh
