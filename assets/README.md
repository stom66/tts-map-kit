# tts-map-kit/assets

This directory contains the various asset files for the Map Kit. Each asset has a directory named after itself, containing the following files:

* [assetname].blend
* [assetname].unity3d
* custom.json

The scripts for these assets may be found in the /scripts folder.

### Notes on custom.json

The custom.json file contains the custom properties for each asset. These are directly copied from the save file, and the following properties must be rpesent:

* Name - *The object type, eg Custom_Assetbundle, Custom_Model*
* Nickname - *Object name, eg the setName() value*
* Description - *Object description, eg the setDescription() value*
* Grid
* Snap
* IgnoreFoW
* Autoraise
* Sticky
* Tooltip
* GridProjection
* HideWhenFaceDown
* Hands

The final element of the array is the array of custom properties. It's name is dependant on the type of object (see the above Name property), as are its values.
* CustomAssetbundle - * *

The following values are ignored:
* Locked
* Position
* Scale
* ColorTint