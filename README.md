Welcome to generals.ar, a two-player AR implementation of the popular online game [generals.io](generals.io) for iOS. Created during the Uncommon Hacks 2024 hackathon.

# How to play #
## Start the server ##
Note that the device running the server must be on the same network as the device(s) running the app.

1. Clone the [generals-ar-server](https://github.com/adinilfeld/generals-ar-server) repo.
2. If needed, install uvicorn (for example, by running `pip install uvicorn`)
3. From the top level of the server repo, run `uvicorn app:app --host 0.0.0.0 --port 8000`


## Install the app ##
Note that the device(s) running the app must be running iOS/iPadOS 17.4 or higher.

1. Clone this repo.
2. Open the top-level `generals.ar.xcodeproj` file in XCode
3. On line 219 of Game.swift, modify the IP address to use the local address of your device running the server (keeping port 8000). Please don't commit this change!
   - To find this IP address, you can go System Settings -> Network -> Details (next to your wifi network).
   - For example, if your IP address is 192.168.1.10, then line 219 should now be
     ```
     let serverURL = "http://192.168.1.10:8000"
     ```
5. Connect your device (iPhone or iPad) with a physical cable and wait for it to appear in XCode
6. Click the Build button (looks like a "play" button)
7. If needed, follow any prompts to (a) enable Developer Mode, and (b) trust the Developer App certificate; afterwards, build again
8. Follow instructions 3-5 to install the app on a second device.

## Play the game! ##
To reset the game: 
1. Close the server (CTRL+C, then CTRL+Z)
2. Close all installed apps
3. Restart the server
4. Re-open the apps

Enjoy!
