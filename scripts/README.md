# tts-map-kit/scripts

This directory contains the scripts used by the Map Kit assets. Each asset has a directory named after itself, containing the following files:

* assetname.lua
* assetname.xml
* version

They may optionally contain the following files as well:

* assetname.min.lua

The asset files themselves may be found in the /assets folder.

## Updater.lua

This is a standalone copy of the function used to update in-gameassets. If I ever figure out some kind of build chain for this it would be nice to have it automatically appended to the various *assetname.lua* files in the `/scripts/` directory. I'm all ears.