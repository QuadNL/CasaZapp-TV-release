#!/usr/bin/env bash
# CasaZapp TV server in a Proxmox LXC.
#
# Run on the Proxmox host, as root, in the host's shell:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/QuadNL/CasaZapp-TV-release/main/deployment/pve-casazapp-tv-lxc.sh)"
#
# It makes a Debian 13 container with Docker and starts the server from
# deployment/docker-compose.yml in the same repo. Choose "Default settings", or "Advanced settings"
# to set each value yourself. Set any of these, as with the community scripts, and it isn't asked:
#   var_ctid var_hostname var_cpu var_ram var_disk var_storage var_template_storage var_brg
#   var_public_url var_trust_proxy
# Without a terminal nothing is asked at all.
#
# Run the same line inside the container to update the server.
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/QuadNL/CasaZapp-TV-release/main"
APP_DIR="/opt/casazapp-tv"

say() { printf '\033[1;33m==>\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

# Menus as in the Proxmox community scripts; whiptail is on every Proxmox host.
TITLE="CasaZapp TV"
interactive() { [ -t 0 ] && command -v whiptail >/dev/null; }

# A text box with a default; skipped when the variable is set already.
input() {
  local var=$1 question=$2 default=$3 answer
  [ -n "${!var:-}" ] && return
  if interactive; then
    answer=$(whiptail --title "$TITLE" --inputbox "$question" 10 68 "$default" 3>&1 1>&2 2>&3) || fail "cancelled"
  else
    answer=$default
  fi
  printf -v "$var" '%s' "$answer"
}

# A list of the active storages that hold the given content, with their type and free space.
pick_storage() {
  local var=$1 question=$2 content=$3 items=() name type avail answer
  [ -n "${!var:-}" ] && return
  while read -r name type avail; do
    items+=("$name" "$(printf '%-10s %5s GB free' "$type" "$((avail / 1024 / 1024))")")
  done < <(pvesm status -content "$content" 2>/dev/null | awk 'NR > 1 && $3 == "active" { print $1, $2, $6 }')
  [ "${#items[@]}" -gt 0 ] || fail "no storage for $content found"
  if [ "${#items[@]}" -eq 2 ] || ! interactive; then
    printf -v "$var" '%s' "${items[0]}"
    return
  fi
  answer=$(whiptail --title "$TITLE" --menu "$question" 16 68 6 "${items[@]}" 3>&1 1>&2 2>&3) || fail "cancelled"
  printf -v "$var" '%s' "$answer"
}

# A list of the network bridges; vmbr0 without asking in the default settings.
pick_bridge() {
  local var=$1 ask=$2 items=() bridge answer
  [ -n "${!var:-}" ] && return
  for bridge in $(ip -o link show type bridge | awk -F': ' '{ print $2 }' | grep -Ev '^(docker|br-)'); do
    items+=("$bridge" "")
  done
  [ "${#items[@]}" -gt 0 ] || fail "no network bridge found"
  if [ "$ask" != yes ] || [ "${#items[@]}" -eq 2 ] || ! interactive; then
    if ip link show vmbr0 >/dev/null 2>&1; then answer=vmbr0; else answer=${items[0]}; fi
  else
    answer=$(whiptail --title "$TITLE" --menu "Network bridge" 14 50 5 "${items[@]}" 3>&1 1>&2 2>&3) || fail "cancelled"
  fi
  printf -v "$var" '%s' "$answer"
}

[ "$(id -u)" -eq 0 ] || fail "run this as root"

# Inside the container this script made: update the server, as the community scripts do.
if ! command -v pct >/dev/null && [ -f "$APP_DIR/docker-compose.yml" ]; then
  say "Updating CasaZapp TV"
  cd "$APP_DIR"
  docker compose pull --quiet
  docker compose up -d
  docker image prune -f >/dev/null
  say "Done"
  exit 0
fi
command -v pct >/dev/null && command -v pveam >/dev/null || fail "pct and pveam not found: run this on a Proxmox VE host"

say "CasaZapp TV server in a Proxmox LXC"
MODE=default
if interactive; then
  MODE=$(whiptail --title "$TITLE" --menu "Set up a CasaZapp TV server in a new container." 12 68 2 \
    default "Default settings (recommended)" \
    advanced "Advanced settings" 3>&1 1>&2 2>&3) || fail "cancelled"
fi
if [ "$MODE" = advanced ]; then
  input var_ctid "Container ID" "$(pvesh get /cluster/nextid)"
  input var_hostname "Hostname" "casazapp-tv"
  input var_cpu "CPU cores" "2"
  input var_ram "Memory in MB" "2048"
  input var_disk "Disk size in GB, recordings included" "32"
  input var_public_url "Your own address, for example https://tv.example.com. Leave empty if you have none." ""
fi
var_ctid=${var_ctid:-$(pvesh get /cluster/nextid)}
var_hostname=${var_hostname:-casazapp-tv}
var_cpu=${var_cpu:-2}
var_ram=${var_ram:-2048}
var_disk=${var_disk:-32}
var_public_url=${var_public_url:-}
pick_storage var_storage "Where should the container go?" rootdir
pick_storage var_template_storage "Where should the Debian template go?" vztmpl
pick_bridge var_brg "$([ "$MODE" = advanced ] && echo yes)"
if [ -n "$var_public_url" ] && [ -z "${var_trust_proxy:-}" ]; then
  var_trust_proxy=false
  if ! interactive || whiptail --title "$TITLE" --yesno "Is $var_public_url behind a reverse proxy?" 8 68; then
    var_trust_proxy=true
  fi
fi
var_trust_proxy=${var_trust_proxy:-false}

if interactive; then
  whiptail --title "$TITLE" --yesno "Create this container?

  ID:        $var_ctid
  Hostname:  $var_hostname
  CPU:       $var_cpu cores
  Memory:    $var_ram MB
  Disk:      $var_disk GB on $var_storage
  Network:   $var_brg (DHCP)
  Address:   ${var_public_url:-none}" 18 68 || fail "cancelled"
fi

pct status "$var_ctid" >/dev/null 2>&1 && fail "container $var_ctid already exists"

say "Getting the newest Debian template"
pveam update >/dev/null
# Debian 13, or 12 on an older Proxmox that doesn't offer 13 yet.
TEMPLATE=""
for release in 13 12; do
  TEMPLATE=$(pveam available --section system | awk -v r="^debian-$release-standard_" '$2 ~ r { print $2 }' | sort -V | tail -n 1)
  [ -n "$TEMPLATE" ] && break
done
[ -n "$TEMPLATE" ] || fail "no Debian template found"
if ! pveam list "$var_template_storage" | grep -q "$TEMPLATE"; then
  pveam download "$var_template_storage" "$TEMPLATE" >/dev/null
fi

say "Creating container $var_ctid ($var_hostname)"
# Docker in an unprivileged container needs nesting and keyctl.
pct create "$var_ctid" "$var_template_storage:vztmpl/$TEMPLATE" \
  --hostname "$var_hostname" \
  --cores "$var_cpu" \
  --memory "$var_ram" \
  --swap 512 \
  --rootfs "$var_storage:$var_disk" \
  --net0 "name=eth0,bridge=$var_brg,ip=dhcp" \
  --features nesting=1,keyctl=1 \
  --unprivileged 1 \
  --onboot 1 \
  --tags casazapp-tv \
  --description "CasaZapp TV server: https://casazapp.tv" >/dev/null
pct start "$var_ctid"

say "Waiting for the network"
IP=""
for _ in $(seq 1 30); do
  IP=$(pct exec "$var_ctid" -- hostname -I 2>/dev/null | awk '{ print $1 }') || true
  if [ -n "$IP" ] && pct exec "$var_ctid" -- getent hosts raw.githubusercontent.com >/dev/null 2>&1; then break; fi
  sleep 2
done
[ -n "$IP" ] || fail "the container got no IP address (DHCP on $var_brg?)"

say "Installing Docker"
pct exec "$var_ctid" -- bash -c "apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl ca-certificates >/dev/null"
pct exec "$var_ctid" -- bash -c "curl -fsSL https://get.docker.com | sh >/dev/null"

say "Starting CasaZapp TV"
pct exec "$var_ctid" -- bash -c "mkdir -p $APP_DIR && cd $APP_DIR \
  && curl -fsSLO $REPO_RAW/deployment/docker-compose.yml \
  && printf 'PUBLIC_URL=%s\nTRUST_PROXY=%s\n' '$var_public_url' '$var_trust_proxy' > .env \
  && docker compose up -d --quiet-pull"

say "Done"
cat <<EOF

  CasaZapp TV runs in container $var_ctid.

  Open:     http://$IP:8080   (or http://casazapp.local:8080 on your home network)
  Folder:   $APP_DIR in the container (compose file, .env, data, recordings)
  Update:   run the same install line in the container's console (pct enter $var_ctid)

EOF
