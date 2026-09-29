# After installing

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

With the Proxmox script: open the container's console (or `pct enter <ID>` on the host) and type
`update`. With Docker, in the folder with the compose file:

```bash
docker compose pull
docker compose up -d
```

When a newer server is out, Settings → About shows "Update available" under the server version,
with what's new. For that the server asks GitHub for the list of releases every six hours.

## Backups and moving

Stop the container first, so the database is closed cleanly, then copy the `data` folder. On the
new host, put it back, use the same compose file and start. Take `secret.key` along, or the same
`APP_SECRET`.

Don't run the old and new server at the same time: if your subscription allows one connection,
they'll fight over it.
