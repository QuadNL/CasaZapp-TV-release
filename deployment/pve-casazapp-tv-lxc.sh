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
#   var_public_url var_trust_proxy var_mdns_name
# Without a terminal nothing is asked at all.
#
# Run the same line inside the container to update the server.
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/QuadNL/CasaZapp-TV-release/main"
APP_DIR="/opt/casazapp-tv"
LOG="/tmp/casazapp-tv-install.log"

ORANGE=$'\033[38;5;215m'
GREEN=$'\033[32m'
RED=$'\033[31m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

fail() { printf '\n  %s%s%s\n\n' "$RED" "$*" "$RESET" >&2; exit 1; }

# The name, line by line: CasaZapp in white, TV in orange as in the logo.
header() {
  local text line
  mapfile -t text <<'EOF'
  ___               ____                 _______   __
 / __|__ _ ___ __ _|_  /__ _ _ __ _ __  |_   _\ \ / /
| (__/ _` (_-</ _` |/ // _` | '_ \ '_ \   | |  \ V /
 \___\__,_/__/\__,_/___\__,_| .__/ .__/   |_|   \_/
                            |_|  |_|
EOF
  if [ -t 1 ]; then clear; fi
  echo
  for line in "${text[@]}"; do
    # "CasaZapp" takes the first 39 columns.
    printf '  %s%s%s%s%s\n' "$BOLD" "${line:0:39}" "$ORANGE" "${line:39}" "$RESET"
    if [ -t 1 ]; then sleep 0.06; fi
  done
  printf '  %s%s%s\n' "$ORANGE" "─────────────────────────────────────────────────────" "$RESET"
  printf '  %sThe best TV player, in your home.%s\n\n' "$DIM" "$RESET"
}

# A label and a value, lined up, for the summary before the steps.
setting() { printf '  %s%-10s%s %s\n' "$DIM" "$1" "$RESET" "$2"; }

# A box with rounded corners around the given lines, as wide as the longest one; colour codes in a
# line don't count for the width.
box() {
  local title=$1 line plain width=${#1}
  shift
  for line in "$@"; do
    plain=$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*m//g')
    [ "${#plain}" -gt "$width" ] && width=${#plain}
  done
  printf '  %s╭─ %s%s%s %s╮%s\n' "$ORANGE" "$BOLD" "$title" "$RESET$ORANGE" "$(printf '─%.0s' $(seq 1 $((width + 1 - ${#title}))))" "$RESET"
  for line in "$@"; do
    plain=$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*m//g')
    printf '  %s│%s  %s%*s  %s│%s\n' "$ORANGE" "$RESET" "$line" $((width - ${#plain})) "" "$ORANGE" "$RESET"
  done
  printf '  %s╰%s╯%s\n' "$ORANGE" "$(printf '─%.0s' $(seq 1 $((width + 4))))" "$RESET"
}

# One step: a spinner while it runs, then a tick. Its output goes to the log; on failure the end of
# the log is shown.
task() {
  local title=$1 pid i=0 frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
  shift
  "$@" >>"$LOG" 2>&1 &
  pid=$!
  if [ -t 1 ]; then
    while kill -0 "$pid" 2>/dev/null; do
      printf '\r  %s%s%s %s' "$ORANGE" "${frames[i % 10]}" "$RESET" "$title"
      i=$((i + 1))
      sleep 0.1
    done
  fi
  if wait "$pid"; then
    printf '\r  %s✔%s %s\n' "$GREEN" "$RESET" "$title"
  else
    printf '\r  %s✖%s %s\n\n' "$RED" "$RESET" "$title"
    tail -n 20 "$LOG" | sed 's/^/    /' >&2
    fail "$title failed. The whole log is in $LOG"
  fi
}

# Menus as in the Proxmox community scripts; whiptail is on every Proxmox host.
TITLE="CasaZapp TV"
interactive() { [ -t 0 ] && command -v whiptail >/dev/null; }

# A text box with a default; skipped when the variable is set already.
input() {
  local var=$1 question=$2 default=$3 answer
  [ -n "${!var:-}" ] && return
  if interactive; then
    answer=$(whiptail --title "$TITLE" --inputbox "$question" 10 68 "$default" 3>&1 1>&2 2>&3) || fail "Cancelled."
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
  [ "${#items[@]}" -gt 0 ] || fail "No storage for $content found."
  if [ "${#items[@]}" -eq 2 ] || ! interactive; then
    printf -v "$var" '%s' "${items[0]}"
    return
  fi
  answer=$(whiptail --title "$TITLE" --menu "$question" 16 68 6 "${items[@]}" 3>&1 1>&2 2>&3) || fail "Cancelled."
  printf -v "$var" '%s' "$answer"
}

# The bridges configured on this node, as under Network in the Proxmox interface (not the firewall
# and VLAN bridges Proxmox makes by itself), each with its comment or address.
bridges() {
  pvesh get "/nodes/$(hostname)/network" --type any_bridge --output-format json 2>/dev/null |
    perl -MJSON::PP -e '
      for (sort { $a->{iface} cmp $b->{iface} } @{ decode_json(join "", <STDIN>) }) {
        (my $note = $_->{comments} // $_->{cidr} // "") =~ s/\s+/ /g;
        $note =~ s/^ | $//g;
        print "$_->{iface}\t$note\n";
      }'
}

# A list of the network bridges; vmbr0 without asking in the default settings.
pick_bridge() {
  local var=$1 ask=$2 items=() bridge note answer
  [ -n "${!var:-}" ] && return
  while IFS=$'\t' read -r bridge note; do
    items+=("$bridge" "$(printf '%s' "$note" | cut -c1-40)")
  done < <(bridges)
  [ "${#items[@]}" -gt 0 ] || fail "No network bridge found."
  if [ "$ask" != yes ] || [ "${#items[@]}" -eq 2 ] || ! interactive; then
    if ip link show vmbr0 >/dev/null 2>&1; then answer=vmbr0; else answer=${items[0]}; fi
  else
    answer=$(whiptail --title "$TITLE" --menu "Network bridge" 14 50 5 "${items[@]}" 3>&1 1>&2 2>&3) || fail "Cancelled."
  fi
  printf -v "$var" '%s' "$answer"
}

# Waits until the server answers, running commands with the given function (here or in the
# container); when it doesn't, the server's own log goes into ours.
wait_health() {
  local run=$1
  for _ in $(seq 1 30); do
    if $run "curl -fsS http://127.0.0.1:8080/api/health" >/dev/null 2>&1; then return 0; fi
    sleep 2
  done
  echo "The server doesn't answer. Its log:"
  $run "docker logs casazapp-tv --tail 20" || true
  return 1
}

[ "$(id -u)" -eq 0 ] || fail "Run this as root."

# Inside the container this script made: update the server, as the community scripts do.
if ! command -v pct >/dev/null && [ -f "$APP_DIR/docker-compose.yml" ]; then
  here() { bash -c "$1"; }
  header
  : >"$LOG"
  task "Updating the container" here "apt-get update -q && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -q"
  # The server runs as user 1000; folders made for root by an older version of this script get fixed.
  task "Updating CasaZapp TV" here "cd $APP_DIR && mkdir -p data recordings cache \
    && chown -R 1000:1000 data recordings cache \
    && docker compose pull && docker compose up -d && docker image prune -f"
  task "Checking running state" wait_health here
  echo
  box "CasaZapp TV is up to date" "Guide    https://casazapp.tv/server"
  echo
  exit 0
fi
command -v pct >/dev/null && command -v pveam >/dev/null || fail "pct and pveam not found: run this on a Proxmox VE host."

header
MODE=default
if interactive; then
  MODE=$(whiptail --title "$TITLE" --menu "Set up a CasaZapp TV server in a new container." 12 68 2 \
    default "Default settings (recommended)" \
    advanced "Advanced settings" 3>&1 1>&2 2>&3) || fail "Cancelled."
fi
if [ "$MODE" = advanced ]; then
  input var_ctid "Container ID" "$(pvesh get /cluster/nextid)"
  input var_hostname "Hostname" "casazapp-tv"
  input var_cpu "CPU cores" "2"
  input var_ram "Memory in MB" "2048"
  input var_disk "Disk size in GB, recordings included" "32"
  input var_mdns_name "Name on your home network (a second server needs its own): NAME.local" "casazapp"
  input var_public_url "Your own address, for example https://tv.example.com. Leave empty if you have none." ""
fi
var_ctid=${var_ctid:-$(pvesh get /cluster/nextid)}
var_hostname=${var_hostname:-casazapp-tv}
var_cpu=${var_cpu:-2}
var_ram=${var_ram:-2048}
var_disk=${var_disk:-32}
var_public_url=${var_public_url:-}
var_mdns_name=${var_mdns_name:-casazapp}
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
  Name:      $var_mdns_name.local
  Address:   ${var_public_url:-none}" 19 68 || fail "Cancelled."
fi

pct status "$var_ctid" >/dev/null 2>&1 && fail "Container $var_ctid already exists."

LOG="/tmp/casazapp-tv-install-$var_ctid.log"
: >"$LOG"
TEMPLATE_FILE="$LOG.template"

# Debian 13, or 12 on an older Proxmox that doesn't offer 13 yet, for this host's processor: the
# list has amd64 and arm64 templates, and the wrong one can't start ("Exec format error").
get_template() {
  local arch release template=""
  arch=$(dpkg --print-architecture)
  pveam update
  for release in 13 12; do
    template=$(pveam available --section system | awk -v r="^debian-$release-standard_.*_${arch}[.]tar" '$2 ~ r { print $2 }' | sort -V | tail -n 1)
    [ -n "$template" ] && break
  done
  [ -n "$template" ] || { echo "No Debian template found."; return 1; }
  if ! pveam list "$var_template_storage" | grep -q "$template"; then
    pveam download "$var_template_storage" "$template"
  fi
  echo "$template" >"$TEMPLATE_FILE"
}

# Docker in an unprivileged container needs nesting and keyctl.
create_container() {
  pct create "$var_ctid" "$var_template_storage:vztmpl/$(cat "$TEMPLATE_FILE")" \
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
    --description "CasaZapp TV server: https://casazapp.tv"
}

start_container() {
  pct start "$var_ctid" && return 0
  echo "Container $var_ctid was made but doesn't start."
  echo "See why with: pct start $var_ctid --debug"
  echo "Remove it with: pct destroy $var_ctid"
  return 1
}

# A command in the container, with a locale that exists there (the one from an SSH session may not).
in_ct() { pct exec "$var_ctid" -- env LANG=C.UTF-8 LC_ALL=C.UTF-8 DEBIAN_FRONTEND=noninteractive bash -c "$1"; }

wait_network() {
  for _ in $(seq 1 30); do
    if [ -n "$(in_ct 'hostname -I' 2>/dev/null)" ] && in_ct "getent hosts raw.githubusercontent.com" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  echo "The container got no IP address or can't reach the internet (DHCP on $var_brg?)"
  return 1
}

header
setting "Container" "$var_ctid ($var_hostname), $var_cpu cores, $var_ram MB"
setting "Disk" "$var_disk GB on $var_storage"
setting "Network" "$var_brg, DHCP, $var_mdns_name.local"
if [ -n "$var_public_url" ]; then setting "Address" "$var_public_url"; fi
echo
task "Getting the Debian template" get_template
task "Creating container $var_ctid ($var_hostname)" create_container
task "Starting the container" start_container
task "Waiting for the network" wait_network
task "Updating the container" in_ct "apt-get update -q && apt-get upgrade -y -q && apt-get install -y -q curl ca-certificates"
task "Installing Docker" in_ct "curl -fsSL https://get.docker.com | sh"
# The server runs as user 1000 in its image; Docker would make these folders for root.
task "Setting up CasaZapp TV" in_ct "mkdir -p $APP_DIR/data $APP_DIR/recordings $APP_DIR/cache \
  && chown -R 1000:1000 $APP_DIR/data $APP_DIR/recordings $APP_DIR/cache \
  && cd $APP_DIR \
  && curl -fsSLO $REPO_RAW/deployment/docker-compose.yml \
  && printf 'PUBLIC_URL=%s\nTRUST_PROXY=%s\nMDNS_NAME=%s\n' '$var_public_url' '$var_trust_proxy' '$var_mdns_name' > .env \
  && docker compose up -d --quiet-pull"
task "Checking running state" wait_health in_ct
rm -f "$TEMPLATE_FILE"

IP=$(in_ct 'hostname -I' | awk '{ print $1 }')
echo
box "CasaZapp TV is running"   "Open     ${ORANGE}http://$IP:8080${RESET}"   "         http://$var_mdns_name.local:8080 on your home network"   "Connect  https://connect.casazapp.tv"   "Guide    https://casazapp.tv/server"   "Update   run the same line in the container (pct enter $var_ctid)"
echo
