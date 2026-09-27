# Changelog

## 0.5.0 (September 2026)

Server and Android app share version 0.5.0.

### Server and web app

- First start opens a setup wizard: admin password and language, playlist, logo countries, apps.
  No password in the log anymore; `ADMIN_PASSWORD` still skips it.
- A welcome walkthrough after signing in. Turn it off in the last step or under Settings → General.
- The web app starts in English. New installs fetch only the "international" channel logos.
- Playlists, managing a playlist and own lists now sit inside Settings.
- The app download points to `casazapp.tv/app`, which always serves the newest APK.

### Android app

- Version number in line with the server.

## 0.4.1 (September 2026)

### Profiles

- Everyone at home gets a profile with their own favourites, channel lists, history, "continue
  watching" and watchlist. The admin sets up the playlists for everyone.
- "Who's watching?" when you open the app or the web app, with a PIN where one is set.
- Each device can always ask, or start with one profile.
- Profiles can be limited: no settings, playlists or devices, no recording, or no managing of
  other profiles.
- The admin profile always exists and keeps every right. Give it a PIN of at least four digits.
- Pick an icon and a colour, or use a picture of your own (web app and phone). Tap the pencil
  on the picture to change it.

### Server

- Separate folders for recordings and cache: mount `/recordings` and `/cache` next to `/data`
  (see [the server guide](docs/server.md)).
- A film stopped from another device really stops.
- A playlist without a programme guide says so.

### Android app

- Search the guide from the player, on TV and phone.
- Back leaves the player on a TV again.
- Opening Playlists in Settings no longer crashes the app.
- Channels that redirect to another server play without a server too.
