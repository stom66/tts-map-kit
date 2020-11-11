# tts-map-kit/data

This directory contains the various scripts used by the Map Kit assets. Each asset has a directory named after itself, containing the following files:

* assetname.lua
* assetname.xml
* assetname.json
* version

They may optionally contain the following files as well:

* assetname.min.lua

## Editing the code

You will need to ensure that this folder is accessible to your editor plugin for the various require functions to work correctly.

If you are using Rolando's plugin for VSCode then add the map-kit folder path to the TTSLua.includeOtherFilesPaths settings (e.g.: `S:\unity-projects\map-kit\`). Be sure to add the root folder, not the data folder itself.

However, if you are using an editor that doesn't support additional directories then you will need to make a symlink to the **data** folder in your Documents/Tabletop Simulator folder. Typically this is done with the following in command prompt:

    `mklink /D "C:\Users\<username>\Documents\Tabletop Simulator\data" S:\unity-projects\map-kit\data`

## Adding the updater

Add the code for the updater as follows:

```lua
require("data/updater.min")
function onLoad()
	updater = {
		name    = "boxfan",
        version = "20190617a",
        repo    = "https://github.com/stom66/tts-map-kit/tree/master/data"
	}
	checkForUpdates(updater.name, updater.version, updater.repo)
end
```

## Pushing updates

Be sure to update the version number in both the `version` file and the variable in the respective Lua file when pushing updates to asssets. If these miss-match they'll cause problems with the updater as the various assets compare their version to the `version` file to determine if they should pull the latest version of their lua file.