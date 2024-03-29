Welcome to generals.ar, a two-player AR implementation of the popular online game [generals.io](generals.io) for iOS. Created during the Uncommon Hacks 2024 hackathon.

# How to play #
## Install the app ##
Note that the device(s) running the app must be running iOS/iPadOS 17.4 or higher.

1. Clone this repo.
2. Open the top-level `generals.ar.xcodeproj` file in XCode
3. Connect your device (iPhone or iPad) to a laptop
4. Click the Build button (looks like a "play" button)
5. If needed, follow any prompts to trust the Developer App certificate on your device, and build again
6. Follow instructions 2-4 to install the app on a second device.

## Start the server ##
Note that the device running the server must be on the same network as the devices running the app.

1. Clone the [generals-ar-server](https://github.com/adinilfeld/generals-ar-server) repo.
2. If needed, install uvicorn (for example, by running `pip install uvicorn`)
3. From the top level of the server repo, run `uvicorn app:app --host 0000 --port 8000`

## Play the game! ##
To start a new game: 
1. Close the server
2. Close all installed apps
3. Restart the server
4. Re-open the apps

Enjoy!
