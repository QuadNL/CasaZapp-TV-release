<img width="1686" height="368" alt="casazapp-tv-logo-light" src="https://github.com/user-attachments/assets/8d88dc9f-e830-4ae2-a31e-693001ff49bc" />

# CasaZapp TV

Your own TV player, on your own server.

CasaZapp TV plays the IPTV subscription you already have. It runs on a server at home, so your
channel lists, favourites, recordings and watch history stay with you.

There are two parts:

- **The server**, a Docker image. It keeps your playlists, fetches the programme guide, records,
  and serves the web app you use in a browser or install on your phone as a PWA.
- **The Android app**, for Google TV, Chromecast with Google TV, Android TV boxes and Android
  phones. It pairs with your server, or works on its own with a playlist on the device.

The server image (`ghcr.io/quadnl/casazapp-tv`) and the Android app will be published on the
[releases page](../../releases). Until then this repository holds the documentation.

## What it does

- Live TV with a programme guide, your own channel lists and favourites, and search across
  channels and programmes.
- Films and series from Xtream providers, with "continue watching" and a watchlist.
- Pause live TV and pick up where you left off; record a programme or a set time on the server.
- Profiles for everyone at home, each with their own favourites, lists, history, "continue
  watching" and watchlist, a PIN if you want one, and limits for the kids.
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

## Disclaimer
CasaZapp TV is a generic media player application designed to play user-provided content. CasaZapp TV does not provide, distribute, store, or own any media, streams, channels, or playlists.

Users must supply their own content via legal streaming links, URLs, or playlists. CasaZapp TV is not affiliated with any content provider, third-party IPTV service, or broadcaster, and does not endorse or condone the streaming of copyrighted material without proper authorization.

The user assumes full responsibility for all content played through the CasaZapp TV application.

## Support the project

If you enjoy using the app, please consider to buy me a coffee.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/U2W120MCVZ)

[ko_fi_shield]: https://img.shields.io/static/v1.svg?label=%20&message=Ko-Fi&color=F16061&logo=ko-fi&logoColor=white
[ko_fi]: https://ko-fi.com/U2W120MCVZ
