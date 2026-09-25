# CasaZapp TV

Your own TV player, on your own server.

CasaZapp TV plays the IPTV subscription you already have. It runs on a server at home, so your
channel lists, favourites, recordings and watch history stay with you.

There are two parts:

- **The server**, a Docker image. It keeps your playlists, fetches the programme guide, records,
  and serves the web app you use in a browser or install on your phone as a PWA.
- **The Android app**, for Google TV, Chromecast with Google TV, Android TV boxes and Android
  phones. It pairs with your server, or works on its own with a playlist on the device.

The Android app is on the [releases page](../../releases); the newest APK is always at
`https://github.com/QuadNL/CasaZapp-TV-release/releases/latest/download/casazapp-tv.apk`.
The server image is `ghcr.io/quadnl/casazapp-tv`, tagged per version.

## What it does

- Live TV with a programme guide, your own channel lists and favourites, and search across
  channels and programmes.
- Films and series from Xtream providers, with "continue watching" and a watchlist.
- Pause live TV and pick up where you left off; record a programme or a set time on the server.
- Profiles for everyone at home, each with their own history, "continue watching" and
  watchlist, a PIN if you want one, and limits for the kids. Favourites are shared.
- One player on every screen: the web app, a phone held upright or on its side, and the TV with
  its remote.
- Knows how many connections your provider allows. When all are in use it asks before taking one
  over, and shows who is watching what.
- M3U and Xtream playlists, channel logos, picture-in-picture and sound only on Android.
- Dutch and English.

CasaZapp TV comes without any channels or content. You bring a playlist from a provider you pay
for, or from a legal free source.

## Getting started

1. [Install the server](docs/server.md) with Docker. It takes a few minutes.
2. Open it in a browser, sign in, and add your playlist.
3. [Install the Android app](docs/android.md) on your TV or phone and pair it with a code.

Questions that come up often are in the [FAQ](docs/faq.md).

## Versions

Server and app share the first two numbers: server 0.4.x works with app 0.4.x. The last number
moves on its own for fixes. What changed is in the [changelog](CHANGELOG.md).

## Problems and ideas

Open an [issue](../../issues/new/choose). Say which version of the server and the app you run
(both are under Settings → About) and what you did just before it went wrong.

## About this repository

This is where CasaZapp TV is released. The source code is not public. The app and the server are
free to use at home.
