# Installing the server

The server runs as one Docker container. Anything that runs Docker will do: a NAS, a small
Linux box, a Proxmox LXC, a Raspberry Pi 4 or newer (64-bit).

## What you need

- Docker with the compose plugin.
- About 300 MB for the image, plus room for the database (usually well under 1 GB).
- Room for recordings, if you use them. An hour of HD is roughly 1 to 3 GB.

## The image

The server is `ghcr.io/quadnl/casazapp-tv-release`, for `amd64` and `arm64`
([all versions](https://github.com/QuadNL/CasaZapp-TV-release/pkgs/container/casazapp-tv-release)).

| Tag      | Follows                                    |
| -------- | ------------------------------------------ |
| `latest` | The newest release                         |
| `0.5`    | The newest 0.5 release, not the next minor |
| `0.5.2`  | Exactly that version (any version number)  |

## Folders

The container uses three folders. Give each its own mount, so a full recordings disk can't take
the database down with it.

| In the container | Contents                                          | Back it up? |
| ---------------- | ------------------------------------------------- | ----------- |
| `/data`          | Database, encryption key, channel logos           | Yes         |
| `/recordings`    | Recordings                                        | If you like |
| `/cache`         | Pause and cast buffers; cleared at start          | No          |

`/recordings` and `/cache` are only used when `RECORDINGS_DIR` and `CACHE_DIR` point there, as in
the compose file below. Without them everything lives under `/data`.

## Quick start

```bash
mkdir casazapp-tv && cd casazapp-tv
curl -fsSLO https://casazapp.tv/docker-compose.yml
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

The file from the quick start:

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
    volumes:
      - ./data:/data
      - ./recordings:/recordings
      - ./cache:/cache
    restart: unless-stopped
```

With `network_mode: host` the server listens on port 8080 of the host itself (`PORT` changes
it) and apps find it by name, see [Find it by name](#find-it-by-name-on-your-network). Can't use
host network, for example on Docker Desktop? Replace that line with:

```yaml
    ports:
      - "8080:8080"
```

`TZ`, `TRUST_PROXY` and `PUBLIC_URL` can go in `.env`; any other setting from
[Settings](#settings) goes under `environment:`.

## First start

Open `http://<your-server>:8080`. A new install starts a setup wizard:

1. Set the `admin` password (10+ characters) and the language.
2. Add an Xtream or M3U playlist.
3. Pick the logo countries (default: international).
4. Download the Android app.

Everything after step 1 can be skipped and done later in Settings. To skip the wizard, set
`ADMIN_PASSWORD` before the very first start.

Forgot it later?

```bash
docker exec casazapp-tv reset-password
```

## Settings

All of these are optional.

| Variable         | Default            | What it does                                                         |
| ---------------- | ------------------ | -------------------------------------------------------------------- |
| `PORT`           | `8080`             | Port the server listens on (with host network: on the host)          |
| `TZ`             | UTC                | Time zone for the guide and recordings                               |
| `RECORDINGS_DIR` | `/data/recordings` | Where recordings go                                                  |
| `CACHE_DIR`      | `/data`            | Where the pause and cast buffers go (`timeshift` and `cast` folders) |
| `TRUST_PROXY`    | `false`            | `true` behind a reverse proxy, so it sees the real client and HTTPS  |
| `APP_SECRET`     | generated          | Key for the stored provider passwords (see below)                    |
| `ADMIN_PASSWORD` | set in the wizard  | Password for `admin` on the first start only; skips the wizard       |
| `MDNS`           | `true`             | Announce the server on the home network (needs host network, below)  |
| `MDNS_NAME`      | `casazapp`         | The `.local` name: `casazapp` becomes `casazapp.local`               |
| `PUBLIC_URL`     | –                  | Your address for the server; apps that find it connect there         |
| `LOG_LEVEL`      | `info`             | `debug`, `info`, `warn` or `error`                                   |

### About APP_SECRET

Provider passwords are stored encrypted. The key is in `/data/secret.key` unless you set
`APP_SECRET`. Lose both and the server can no longer read your playlist logins: you'd have to
enter them again. Keep `/data` in your backup and you're fine.

## Find it by name on your network

The server announces itself as `casazapp.local`. The Android app then lists it on its connect
screen, and a browser on a PC or Mac can open `http://casazapp.local:8080`.

This needs `network_mode: host`, as in the compose file above: with `ports:` Docker keeps the
announcement inside the container.

Set `PUBLIC_URL` to the address you use for the server (for example `https://tv.example.com`):
the app then connects there instead of to the local IP, so it also works away from home.

Without host network the Android app still finds the server: it scans your network for it. A
browser can't, so there you type the IP address.

Bookmark `connect.casazapp.tv` to open your server from any browser: it remembers the address in
that browser.

## Behind a reverse proxy

You'll want HTTPS if you use the app away from home, and the web app needs it to install as a PWA.
Any reverse proxy works. With Nginx Proxy Manager:

1. Add a proxy host that forwards to `http://<docker-host>:8080`.
2. Turn on SSL with Let's Encrypt and "Force SSL".
3. Set `TRUST_PROXY=true` on the container.

Most providers send HLS, which is fine as is. If yours sends one long MPEG-TS stream, add this under
"Advanced" in the proxy host, or the stream stops after a minute:

```nginx
proxy_buffering off;
proxy_read_timeout 1h;
```

## Casting to a Chromecast

Cast from the web app in Chrome, or from the Android app on a phone or tablet. The Chromecast gets
its stream from your server, so:

- the web app must run over HTTPS (Chrome only offers casting there);
- the Chromecast must reach the address you opened the server on (your home network, or your
  HTTPS domain).

Live TV starts about 12 seconds behind live. Casting takes over the place of the device that
started it.

## Updating

When a newer server is out, Settings → About shows "Update available" under the server version,
with what's new. For that the server asks GitHub for the list of releases every six hours.

```bash
docker compose pull
docker compose up -d
```

## Backups and moving

Stop the container first, so the database is closed cleanly, then copy the `data` folder. On the
new host, put it back, use the same compose file and start. Take `secret.key` along, or the same
`APP_SECRET`.

Don't run the old and new server at the same time: if your subscription allows one connection,
they'll fight over it.
