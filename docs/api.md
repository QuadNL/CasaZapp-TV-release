# API and Home Assistant

Your CasaZapp TV server has an API for your own scripts, dashboards and home automation. Ready
to use: the **[Home Assistant integration](home-assistant.md)**.

## An API key

On the server: Settings → Account → API keys. A key belongs to the profile that makes it and
never does more than that profile may.

- **Read only:** what plays, recordings, the profile's favourites, lists and recent channels,
  and playing on a speaker or player of your own.
- **Read and control:** also plan, stop and remove recordings and stop streams.
- A profile that looks after the server also sees the recordings disk, the providers and server
  updates.

The key is shown once, when you make it. You can revoke it at any time on the same page.

## Using it

Send the key with every request:

```sh
curl -H "Authorization: Bearer <your key>" http://<your-server>:8080/api/integration/status
```

That gives a summary in one go: what plays where, recording now and next, the providers and
what the profile watched last.

## Every route

Your server explains its own API at **`/api/docs`**, for example
`http://<your-server>:8080/api/docs`. It lists every route a key may use, with an example
answer and a button to try it:

| Group | What |
| --- | --- |
| Status | What happens on the server |
| Recent | What the key's profile watched |
| Channels | The profile's favourites, lists and playlists |
| Play | A channel or recording on a speaker or player of your own |
| Recordings | Plan, stop and remove |
| Streams | Who watches, and stopping a stream |
| Pictures | Logos and stills, with the same key |

## Playing on your own speakers

A key can ask for a link to a channel or recording, for a speaker or player
that isn't a CasaZapp TV app:

- a TV or Chromecast with a screen gets the channel with its picture;
- a speaker gets only the sound, as mp3;
- radio on a TV shows the CasaZapp TV logo and the channel's name instead of black.

Each link is temporary and ends by itself. It counts for your provider's connections like anyone
watching, and shows on the server's Active now, where you can stop it.
