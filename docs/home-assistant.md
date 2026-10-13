# Home Assistant

See what plays, follow recordings and your providers, plan and stop recordings, and play radio,
channels and recordings on any speaker or player Home Assistant knows.

## What you need

- A CasaZapp TV server 0.5.7 or newer.
- Home Assistant 2026.10 or newer, the version it is tested with.
- An [API key](api.md#an-api-key). Read only is enough to look and to play on your speakers; to
  record and stop, make one that may also control.

The integration is open source, in its own repository:
[github.com/QuadNL/CasaZapp-TV-homeassistant](https://github.com/QuadNL/CasaZapp-TV-homeassistant).

## Installing via HACS (recommended)

[![Open your Home Assistant instance and open a repository inside the Home Assistant Community Store.](https://my.home-assistant.io/badges/hacs_repository.svg)](https://my.home-assistant.io/redirect/hacs_repository/?owner=QuadNL&repository=CasaZapp-TV-homeassistant&category=integration)

or

1. Go to HACS → ⋮ (top right) → Custom repositories.
1. Add the repository `https://github.com/QuadNL/CasaZapp-TV-homeassistant`, type **Integration**.
1. Search for **CasaZapp TV** and download it.
1. Restart Home Assistant.
1. Go to Settings → Devices & services.
1. Add the **CasaZapp TV** integration, with your server's address (for example
   `http://192.168.1.10:8080`) and the API key.

On the same network Home Assistant may find the server by itself; then only the key is asked.
HACS tells you about new versions.

## Installing by hand

1. Download `casazapp_tv.zip` from the
   [latest release](https://github.com/QuadNL/CasaZapp-TV-homeassistant/releases/latest).
1. Make the folder `/config/custom_components/casazapp_tv/` and unpack the zip into it, with the
   File editor or Samba add-on, or over SSH.
1. Restart Home Assistant, then add the integration as above. To update later: replace the
   folder's contents with a newer zip and restart.

## What you get

**Sensors**

| Entity | Shows |
| --- | --- |
| Now playing | "Channel: programme", "2 streams" or "Nothing" |
| Watching | How many devices watch, with the list in its attributes |
| Recording, Recording now | Whether something records, and what |
| Next recording | When the next one starts |
| Planned recordings, Recordings | How many |
| Last channel, Continue watching | Of the key's profile |
| Channels, Movies, Series | The library |
| Recordings disk free, Recordings disk full | With a key of a profile that looks after the server |
| _Provider_ ends, _Provider_ connections, _Provider_ sync | Per provider, same |
| Server (update) | A newer CasaZapp TV server; the server doesn't update itself |

**A media player per device that watches**, named as the server shows it ("Living room TV ·
Admin"): the title, the channel, the programme's progress and the logo, with stop. A device
that watched before stays, idle.

**Actions** for automations and dashboards:

- `casazapp_tv.record`: now for some minutes, or from a start to a stop;
- `casazapp_tv.stop_recording`;
- `casazapp_tv.delete_recording`;
- `casazapp_tv.stop_stream`.

**Media browser:** CasaZapp TV with Favourites, My lists, Recent channels, Playlists (with their
categories, as in the apps) and Recordings. Pick a speaker or player and play: radio on a
speaker, a channel or a recording on a TV. On the server's Active now it shows as
"_key name_: _speaker_", and you can stop it there or in Home Assistant.

## Playing on the CasaZapp TV app

From server and app 0.5.8, Home Assistant can also play on the CasaZapp TV app itself, for example
on your television:

1. On the device, in the app: Settings → Connection and devices → **Allow remote control** → On.
   It is off by default, and only the device itself can turn it on.
2. While the app is open, its media player in Home Assistant can play a channel or recording from
   the media browser, and stop it.

**When the app is closed** it can't hear anything. A link opens it and plays right away:

- `casazapp://play/channel/12`
- `casazapp://play/recording/276`
- `casazapp://play/movie/40`

The number is the one on your own server. To find it, open the channel, recording or film in the
web app and look at the address:

| In the web app | Link |
| --- | --- |
| `/watch/12` | `casazapp://play/channel/12` |
| `/recordings/276` | `casazapp://play/recording/276` |
| `/movie/40` | `casazapp://play/movie/40` |

With an API key, `/api/playlists/<id>/channels` and `/api/recordings` give the numbers too.

With the [Android TV Remote](https://www.home-assistant.io/integrations/androidtv_remote/)
integration, which most Google TV and Android TV devices use, a script opens it on the
television:

```yaml
action: media_player.play_media
target:
  entity_id: media_player.living_room_tv
data:
  media_content_type: url
  media_content_id: casazapp://play/channel/12
```

With the [Android Debug Bridge](https://www.home-assistant.io/integrations/androidtv/)
integration it goes like this:

```yaml
action: androidtv.adb_command
target:
  entity_id: media_player.living_room_tv
data:
  command: am start -a android.intent.action.VIEW -d casazapp://play/channel/12 nl.casazapp.tv
```

If the app isn't paired yet or asks who's watching, it plays as soon as that is done.

## Examples

Record the evening news every weekday, from an automation:

{% raw %}
```yaml
action: casazapp_tv.record
data:
  channel_id: 1
  start: "{{ today_at('20:00') }}"
  stop: "{{ today_at('20:30') }}"
```
{% endraw %}

Play a radio station on the kitchen speaker: open the media browser on that speaker, then
CasaZapp TV → My lists, and pick the station.

## When something is off

- **The integration asks for the key again:** the key was revoked. Make a new one and fill it in.
- **A speaker doesn't show the channels:** it only shows what it can play. Channels come as
  sound for a speaker and as video for a screen.
- **The app's player has no play button:** the app isn't open, or "Allow remote control" is off
  there. Home Assistant links the player by the device's name, so two devices with that name and
  remote control on can't be told apart: give one a name of its own when you pair it.
- Anything else: [open an issue](https://github.com/QuadNL/CasaZapp-TV-release/issues).
