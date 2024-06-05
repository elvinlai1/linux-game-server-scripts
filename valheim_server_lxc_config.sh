cat <<EOF | lxd init --preseed

config: 
  core.https_address: ""
  core.trust_password: ""
  images.auto_update_interval: 12

networks:
  - name: external0
    type: macvlan
    config:
      parent: wlp1s0
      ipv4.address: auto
      ipv6.address: none

storage_pools:
  - name: servers
    description: ""
    driver: zfs
    config: {}

storage_volumes:
  - name: valheim_server
    pool: servers

profiles:
  - name: valheim
    config:
      limits.memory: 2GiB
      limits.cpu: "2"
      description: "Valheim server profile"
    devices:
      root:
        path: /
        pool: servers
        type: disk

EOF100