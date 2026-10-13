# Changelog

## 0.5.8 (October 2026)

### Server

New:

- Introducing Universal Search: Find channels, programmes, movies, series and recordings from any page with Ctrl/⌘ + K.
- Recordings can now be combined into one .mkv file once they are finished. This is optional; turn it on in Settings → Recordings
- Recurring recordings are now visible as a series in the recordings tab. This gives a better overview and episode tracking.
- Added new features for the Home Assistant integration, see [casazapp.tv/homeassistant](https://casazapp.tv/homeassistant).

Fixed:

- Small bugfixes

### Android app

New:

- Recurring recordings are now visible as a series in the recordings tab. This gives a better overview and episode tracking.
- As mentioned with the previous server release, Home Assistant is now integrated with CasaZapp TV. You can now control your CasaZapp TV app with Home Assistant. Check it out at [casazapp.tv/homeassistant](https://casazapp.tv/homeassistant)!

Fixed:

- Small bugfixes

### Home Assistant integration

0.1.1:

- Play and stop on the CasaZapp TV app. This needs server and app 0.5.8, with "Allow remote control" turned on in the app
- Shows what is playing when someone watches a recording, and can stop it

<sub>CasaZapp TV is continuously in development. If you have any ideas, feature requests or bugs, report them on [GitHub](https://github.com/QuadNL/CasaZapp-TV-release/issues).</sub>

## 0.5.7 (October 2026)

### Server

New:

- Introducing API keys which will give you more control over CasaZapp TV server, see [casazapp.tv/api](https://casazapp.tv/api)
- Excited introduction of Home Assistant integration! See [casazapp.tv/homeassistant](https://casazapp.tv/homeassistant)
- Improved playlist management: full category and channel names, and drag to reorder
- Improved the radio playback for web, app and casting devices.
- Small settings UI optimizations

Fixed:

- Small bugfixes

### Android app

New:

- Improved the radio playback for web, app and casting devices.
- Small settings UI optimizations

Fixed:

- Small bugfixes

### Home Assistant integration

0.1.0, the first public version: see [CasaZapp-TV-homeassistant](https://github.com/QuadNL/CasaZapp-TV-homeassistant) and [the guide](https://casazapp.tv/homeassistant).

## 0.5.6 (October 2026)

### Server

New:

- Added new recording options, you can schedule recordings without an EPG
- You can now change colour, height and more with subtitle options
- Improved loading speed when switching between pages

Fixed:

- Fixed player menus going off screen

### Android app

New:

- Added new recording options, you can schedule recordings without an EPG *
- You can now change colour, height and more with subtitle options
- Improved loading speed when switching between screens
- Improved remote control navigation on Android TV

Fixed:

- Fixed pop-ups too large on Android TV

<sub>* Requires CasaZapp TV server v0.5.6</sub>

## 0.5.5 (October 2026)

### Server

New:

- Series recording: record every episode of a programme, with options
- Recording storage: warning when the disk is almost full, and Keep for recordings
- Guide days per playlist, to plan recordings ahead
- Move several channels at once in lists
- Episodes in the player, with next episode and up next
- Subtitles: upload your own or search OpenSubtitles (free API key), with timing

Fixed:

- Films and episodes without sound in the browser now play with sound
- No more cast icon over the browser player

## 0.5.4 (September 2026)

### Server

New:

- Sync progress per list (live channels, movies, series) on the playlist
- Log and "Download diagnostics" in Settings → System

Fixed:

- Large playlists no longer run out of memory while syncing
- Providers that only accept known players now work
- Provider errors now show the HTTP status

## 0.5.3 (September 2026)

### Server

Fixed:

- New installs start without fixing folder permissions first
- Allow the use of custom .local name for mDNS

Changed:

- Removed the maintenance announcement before a restart
- Changed slogan

## 0.5.2 (September 2026)

### Server

- Added update notice for new server versions
- Added website link in about

### Android app

- Added update notice for new server version
- Added website link in about
- Fixed CasaZapp TV logo in portrait

## 0.5.1 (September 2026)

### Server

- Added Chromecast support
- Added improved device pairing experience
- Added mDNS support (casazapp.local:port, requires docker network_mode: host)
- Docker config update: Add PUBLIC_URL for better mDNS support (requires proxy)

Introducing connect.casazapp.tv for easy server connections.

### Android app

- Added Chromecast support (phone and tablet, with server)
- Added improved device pairing experience
- Finds your server on the network automatically
- App version now shows with a v

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
