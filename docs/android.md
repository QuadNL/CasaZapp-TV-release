# The Android app

One APK for everything: Google TV, Chromecast with Google TV, Android TV boxes, phones and
tablets. It needs Android 6 or newer. The app picks the TV or phone layout by itself.

## Installing

The app isn't in the Play Store (yet), so it's installed from the APK on the
[releases page](https://github.com/QuadNL/CasaZapp-TV-release/releases).

**On a phone:** open the releases page on the phone, download `casazapp-tv.apk` and open it.
Android asks once whether your browser may install apps; allow it.

**On a TV or Chromecast:** the easiest way is the free app *Downloader* by AFTVnews.

1. Install *Downloader* from the Play Store on the TV.
2. Allow it to install apps: Settings → Apps → Security & restrictions → Unknown sources.
3. In Downloader, enter the address of the APK from the releases page and install it.

After that the app updates itself: when a new version is out it says so under Settings, and one
press downloads and installs it. The app closes when the update is done; open it again.

## Connecting to your server

1. Open the app and choose **Connect to a CasaZapp TV server**.
2. Enter the address of your server, for example `https://tv.example.com`.
3. The app shows a code of eight characters.
4. On a device where you're signed in (a browser, a phone), go to Settings → Connection and devices
   and enter the code.

That's all. The device stays paired until you remove it on the same page. It never sees your
password.

## Without a server

Choose **On this device** and add an M3U or Xtream playlist. Live TV, the guide, favourites and
your own lists work locally on the device. Pausing live TV and recordings need the server.

## The remote

In the player:

| Key            | Does                                                  |
| -------------- | ----------------------------------------------------- |
| Up / Down      | Next or previous channel                              |
| Right          | The guide                                             |
| OK             | The buttons (pause, record, favourite, guide)         |
| Hold OK        | Add or remove the channel from your favourites        |
| Play/Pause     | Pause, and go on where you left off                   |
| Left / Right   | When paused or in a film: 10 seconds back or forward  |
| Back           | Hide the buttons, or close the player                 |
