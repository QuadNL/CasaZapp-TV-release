#!/usr/bin/env bash
# CasaZapp TV server in a Proxmox LXC.
#
# Run on the Proxmox host, as root, in the host's shell:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/QuadNL/CasaZapp-TV-release/main/deployment/pve-casazapp-tv-lxc.sh)"
#
# It makes a Debian 13 container with Docker and starts the server from
# deployment/docker-compose.yml in the same repo. Every question has a default; press Enter to take
# it. Set any of these, as with the community scripts, and that question is skipped:
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

# A question with a default; asked only when there is someone to answer it.
ask() {
  local var=$1 question=$2 default=$3 answer
  if [ -n "${!var:-}" ]; then return; fi
  if [ -t 0 ]; then
    read -rp "$question [$default]: " answer
    printf -v "$var" '%s' "${answer:-$default}"
  else
    printf -v "$var" '%s' "$default"
  fi
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

# The first active storage that holds the given content (rootdir for containers, vztmpl for templates).
first_storage() { pvesm status -content "$1" 2>/dev/null | awk 'NR > 1 && $3 == "active" { print $1; exit }'; }

say "CasaZapp TV server in a Proxmox LXC"
ask var_ctid "Container ID" "$(pvesh get /cluster/nextid)"
ask var_hostname "Hostname" "casazapp-tv"
ask var_cpu "CPU cores" "2"
ask var_ram "Memory (MB)" "2048"
ask var_disk "Disk (GB), recordings included" "32"
ask var_storage "Storage for the container" "$(first_storage rootdir)"
ask var_template_storage "Storage for the template" "$(first_storage vztmpl)"
ask var_brg "Network bridge" "vmbr0"
ask var_public_url "Your own address, e.g. https://tv.example.com" "none"
[ "$var_public_url" = "none" ] && var_public_url=""
if [ -n "$var_public_url" ]; then ask var_trust_proxy "Behind a reverse proxy? (true/false)" "true"; fi
var_trust_proxy=${var_trust_proxy:-false}

[ -n "$var_storage" ] || fail "no storage for containers found"
[ -n "$var_template_storage" ] || fail "no storage for templates found"
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
