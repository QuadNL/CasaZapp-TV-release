# Proxmox

Run this in the shell of your Proxmox host:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/QuadNL/CasaZapp-TV-release/main/deployment/pve-casazapp-tv-lxc.sh)"
```

Read [the script](https://github.com/QuadNL/CasaZapp-TV-release/blob/main/deployment/pve-casazapp-tv-lxc.sh)
first if you like.

## What it asks

- **Default settings:** only where the container goes (the storage) if you have more than one.
  It gets 2 cores, 2 GB of memory, 32 GB of disk and an address from your network (DHCP).
- **Advanced settings:** you pick the container ID, hostname, cores, memory, disk size, network
  bridge, a fixed IP address with its gateway, the name on your home network (`casazapp.local`)
  and your own address if you use one behind a reverse proxy.

Before anything is made you see a summary to confirm.

## What it does

It makes an unprivileged Debian container on your Proxmox host with Docker in it, and starts the
server there with [the same compose file](server-docker.md#docker-composeyml) as a Docker install.
The container starts with the host and takes over its time zone and language settings. At the end
it shows the address to open.

Everything lives in `/opt/casazapp-tv` in the container: the compose file, your settings in
`.env`, and the `data`, `recordings` and `cache` folders.

## Updating

Open the container's console in Proxmox (or `pct enter <ID>` on the host) and type:

```bash
update
```

It updates the container and the server, and cleans up what's no longer needed.
