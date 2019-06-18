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