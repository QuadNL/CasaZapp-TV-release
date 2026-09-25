# Installing the server

The server runs as one Docker container. Anything that runs Docker will do: a NAS, a small
Linux box, a Proxmox LXC, a Raspberry Pi 4 or newer (64-bit).

## What you need

- Docker with the compose plugin.
- About 300 MB for the image, plus room for the database (usually well under 1 GB).
- Room for recordings, if you use them. An hour of HD is roughly 1 to 3 GB.

## Folders

The container uses three folders. Give each its own mount, so a full recordings disk can't take
the database down with it.

| In the container | What goes there                                   | Back it up? |
| ---------------- | ------------------------------------------------- | ----------- |
| `/data`          | Database, encryption key, channel logos           | Yes         |
| `/recordings`    | Recordings                                        | If you like |
| `/cache`         | The buffer of a paused channel; cleared at start  | No          |

`/recordings` and `/cache` are only used when `RECORDINGS_DIR` and `CACHE_DIR` point there, as in
the compose file below. Without them everything lives under `/data`.

## docker-compose.yml

```yaml
services:
  casazapp-tv:
    image: ghcr.io/quadnl/casazapp-tv:latest
    container_name: casazapp-tv
    ports:
      - "8080:8080"
    environment:
      TZ: Europe/Amsterdam
      RECORDINGS_DIR: /recordings
      CACHE_DIR: /cache
    volumes:
      - ./data:/data
      - ./recordings:/recordings
      - ./cache:/cache
    restart: unless-stopped
```

Start it:

```bash
docker compose up -d
```

## First sign-in

On the first start the server creates the account `admin` with a random password and prints it
once in the log:

```bash
docker compose logs casazapp-tv
```

Open `http://<your-server>:8080`, sign in, and change the password under Settings. If you'd rather
choose the password yourself, set `ADMIN_PASSWORD` before the very first start.

Forgot it later?

```bash
docker exec casazapp-tv reset-password
```

## Settings

All of these are optional.

| Variable         | Default            | What it does                                                        |
| ---------------- | ------------------ | ------------------------------------------------------------------- |
| `PORT`           | `8080`             | Port inside the container                                           |
| `TZ`             | UTC                | Time zone for the guide and recordings                              |
| `RECORDINGS_DIR` | `/data/recordings` | Where recordings go                                                 |
| `CACHE_DIR`      | `/data`            | Where the pause buffer goes (in a `timeshift` folder)               |
| `TRUST_PROXY`    | `false`            | `true` behind a reverse proxy, so it sees the real client and HTTPS |
| `APP_SECRET`     | generated          | Key for the stored provider passwords (see below)                   |
| `ADMIN_PASSWORD` | generated          | Password for `admin` on the first start only                        |
| `LOG_LEVEL`      | `info`             | `debug`, `info`, `warn` or `error`                                  |

### About APP_SECRET

Provider passwords are stored encrypted. The key is in `/data/secret.key` unless you set
`APP_SECRET`. Lose both and the server can no longer read your playlist logins: you'd have to
enter them again. Keep `/data` in your backup and you're fine.

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

## Updating

```bash
docker compose pull
docker compose up -d
```

A restart cuts off whoever is watching. To warn them first, run this a few seconds before; open
apps show a countdown and reload by themselves afterwards:

```bash
docker exec casazapp-tv announce-maintenance 10
```

## Backups and moving

Stop the container first, so the database is closed cleanly, then copy the `data` folder. On the
new host, put it back, use the same compose file and start. Take `secret.key` along, or the same
`APP_SECRET`.

Don't run the old and new server at the same time: if your subscription allows one connection,
they'll fight over it.
