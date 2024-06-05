# linux-game-server-scripts
Scripts to configure and deploy game servers on LXC's

Could expand in building out docker images but LXC's provide's easier update management afaik.

## LXD container configuration script
Use LXD to configure and deploy a container.
1. Download pre-defined yaml-container
2. ~~Check server for storage and network configuration~~ (Complexity omitted for now)
3. 
```

```

## Proxmox container tool script
Use Proxmox's simplified tool to manage LXC's.
```

```

## Game server scripts
1. Add dedicated user (Steam)
2. Download and Install SteamCMD
3. Install dedicated server
4. Run server to check for errors
5. Create Server services and timers and then enable them
6. 

### Valheim

#### Install with one command
```sh 
curl -fsSL https://github.com/elvinlai1/linux-game-server-scripts/blob/main/valheim.sh | sh
```

### Palword

#### Install with one command
```sh
curl -fsSL https://github.com/elvinlai1/linux-game-server-scripts/blob/main/palworld.sh | sh 
```




<br>

# Links

## SteamCMD
https://developer.valvesoftware.com/wiki/SteamCMD

## Valheim Dedicated Server
https://valheim.fandom.com/wiki/Dedicated_servers

## Palworld Dedicated Server
https://tech.palworldgame.com/getting-started/deploy-dedicated-server

## PCT
https://pve.proxmox.com/pve-docs/pct.1.html

