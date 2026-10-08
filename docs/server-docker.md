# Docker

## What you need

- Docker with the compose plugin.
- About 300 MB for the image, plus room for the database (usually well under 1 GB).
- Room for recordings, if you use them. An hour of HD is roughly 1 to 3 GB.

## Quick start

```bash
mkdir casazapp-tv && cd casazapp-tv
curl -fsSLO https://raw.githubusercontent.com/QuadNL/CasaZapp-TV-release/main/deployment/docker-compose.yml
docker compose up -d
```

That's it: open `http://<your-server>:8080`. Using your own domain behind a reverse proxy? Put
your settings in a `.env` file next to the compose file and start again:

```bash
cat > .env <<'EOF'
PUBLIC_URL=https://tv.example.com
TRUST_PROXY=true
EOF
docker compose up -d
```

## docker-compose.yml

The file from the quick start, [`deployment/docker-compose.yml`](https://github.com/QuadNL/CasaZapp-TV-release/blob/main/deployment/docker-compose.yml)
in the release repo:

```yaml
# CasaZapp TV server. See casazapp.tv/server for what each line does.
# Your own settings go in a .env file next to this one, for example:
#   PUBLIC_URL=https://tv.example.com
#   TRUST_PROXY=true
services:
  casazapp-tv:
    image: ghcr.io/quadnl/casazapp-tv-release:latest
    container_name: casazapp-tv
    # Host network, so apps find the server as casazapp.local. It listens on port 8080.
    network_mode: host
    # Without host network (for example Docker Desktop), use this instead:
    # ports:
    #   - "8080:8080"
    environment:
      TZ: ${TZ:-Europe/Amsterdam}
      RECORDINGS_DIR: /recordings
      CACHE_DIR: /cache
      # true behind a reverse proxy (Nginx Proxy Manager, Caddy, Traefik)
      TRUST_PROXY: ${TRUST_PROXY:-false}
      # The address you use for the server; apps that find it on the network connect there
      PUBLIC_URL: ${PUBLIC_URL:-}
      # The name on your home network: casazapp becomes casazapp.local
      MDNS_NAME: ${MDNS_NAME:-casazapp}
    volumes:
      - ./data:/data
      - ./recordings:/recordings
      - ./cache:/cache
    restart: unless-stopped
```

With `network_mode: host` the server listens on port 8080 of the host itself (`PORT` changes
it) and apps find it by name, see [Find it by name](server-after.md#find-it-by-name-on-your-network). Can't use
host network, for example on Docker Desktop? Replace that line with:

```yaml
    ports:
      - "8080:8080"
```

`TZ`, `TRUST_PROXY`, `PUBLIC_URL` and `MDNS_NAME` can go in `.env`; any other setting from
[Settings](server-settings.md) goes under `environment:`.

## The image

The server is `ghcr.io/quadnl/casazapp-tv-release`, for `amd64` and `arm64`
([all versions](https://github.com/QuadNL/CasaZapp-TV-release/pkgs/container/casazapp-tv-release)).

| Tag      | Follows                                    |
| -------- | ------------------------------------------ |
| `latest` | The newest release                         |
| `0.5`    | The newest 0.5 release, not the next minor |
| `0.5.6`  | Exactly that version (any version number)  |

## Folders

The container uses three folders. Give each its own mount, so a full recordings disk can't take
the database down with it.

| In the container | Contents                                          | Back it up? |
| ---------------- | ------------------------------------------------- | ----------- |
| `/data`          | Database, encryption key, channel logos           | Yes         |
| `/recordings`    | Recordings                                        | If you like |
| `/cache`         | Pause and cast buffers; cleared at start          | No          |

`/recordings` and `/cache` are only used when `RECORDINGS_DIR` and `CACHE_DIR` point there, as in
the compose file above. Without them everything lives under `/data`.
