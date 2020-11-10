# tts-map-kit/data

This directory contains the various scripts used by the Map Kit assets. Each asset has a directory named after itself, containing the following files:

* assetname.lua
* assetname.xml
* assetname.json
* version

They may optionally contain the following files as well:

* assetname.min.lua

## Updater.lua

This is a standalone copy of the function used to update in-gameassets. If I ever figure out some kind of build chain for this it would be nice to have it automatically appended to the various *assetname.lua* files in the `/scripts/` directory. I'm all ears.

## Editing the code

You will need to ensure that this folder is accessible to your editor plugin for the various require functions to work correctly.

If you are using Rolando's plugin for VSCode then add the map-kit folder path to the TTSLua.includeOtherFilesPaths settings (e.g.: `S:\unity-projects\map-kit\`). Be sure to add the root folder, not the data folder itself.

However, if you are using an editor that doesn't support additional directories then you will need to make a symlink to the **data** folder in your Documents/Tabletop Simulator folder. Typically this is done with the following in command prompt:

    `mklink /D "C:\Users\<username>\Documents\Tabletop Simulator\data" S:\unity-projects\map-kit\data`