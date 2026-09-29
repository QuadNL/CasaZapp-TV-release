# Settings

All of these are optional. Put them in the `.env` file next to the compose file (with
[Proxmox](server-proxmox.md): `/opt/casazapp-tv/.env` in the container), then start again with
`docker compose up -d`. `TZ`, `TRUST_PROXY`, `PUBLIC_URL` and `MDNS_NAME` work that way as they
are; any other setting also needs a line under `environment:` in the compose file.

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

## About APP_SECRET

Provider passwords are stored encrypted. The key is in `/data/secret.key` unless you set
`APP_SECRET`. Lose both and the server can no longer read your playlist logins: you'd have to
enter them again. Keep `/data` in your backup and you're fine.
