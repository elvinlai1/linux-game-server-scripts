# linux-game-server-scripts
Scripts to configure and deploy game servers on LXC's

Could expand in building out docker images but LXC's provide's easier update management afaik.


# Games 
Install and configure with one command
## Valheim
```sh 
curl -fsSL https://github.com/elvinlai1/linux-game-server-scripts/blob/main/valheim.sh | sh
```

## Palword
```sh
curl -fsSL https://github.com/elvinlai1/linux-game-server-scripts/blob/main/palworld.sh | sh 
```

## Game server scripts
1. Add dedicated user (Steam)
2. Download and Install SteamCMD
3. Install dedicated server
4. Run server to check for errors
5. Create Server schedule services and timers
    - Schedule start, stop, reboot
6. Create Rsync to file server
7. Enable services


# To-Do
<details>f

## LXD container configuration script
Use LXD to configure and deploy a container.
1. Download pre-defined yaml-container
2. ~~Check server for storage and network configuration~~ (Complexity omitted for now)
3. 



## Proxmox container tool script
Use Proxmox's simplified tool to manage LXC's.


## Links


### Shell Style Guide: Authored, revised and maintained by many Googlers.
https://google.github.io/styleguide/shellguide.html

#### SteamCMD
https://developer.valvesoftware.com/wiki/SteamCMD

#### Valheim Dedicated Server
https://valheim.fandom.com/wiki/Dedicated_servers

#### Palworld Dedicated Server
https://tech.palworldgame.com/getting-started/deploy-dedicated-server

#### PCT
https://pve.proxmox.com/pve-docs/pct.1.html

</details>