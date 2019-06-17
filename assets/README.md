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
* CustomAssetbundle  
	* AssetbundleURL
	* AssetbundleSecondaryURL
	* MaterialIndex
	* TypeIndex
	* LoopingEffectIndex
* CustomAssetbundle  
	* AssetbundleURL
	* AssetbundleSecondaryURL
	* MaterialIndex
	* TypeIndex
	* LoopingEffectIndex

Custom_Model
		"CustomMesh": {
		"MeshURL": "https://drive.google.com/uc?export=download&id=1NWmGQ72bc5Aq13Pa8A7aHxrtQ708NLlJ",
		"DiffuseURL": "https://drive.google.com/uc?export=download&id=1n6as5Hl-pokluFeN5PmDdKMDu9AsRE-v",
		"NormalURL": "",
		"ColliderURL": "",
		"Convex": true,
		"MaterialIndex": 3,
		"TypeIndex": 1,
		"CastShadows": true
		},

Custom_Assetbundle
		"CustomAssetbundle": {
		"AssetbundleURL": "http://cloud-3.steamusercontent.com/ugc/776223162096463307/8081AFFB1F1BEE15DE1B329CAE63D59D34C26C41/",
		"AssetbundleSecondaryURL": "",
		"MaterialIndex": 0,
		"TypeIndex": 0,
		"LoopingEffectIndex": 0
		},

Custom_Board
	"CustomImage": {
		"ImageURL": "https://www.staples-3p.com/s7/is/image/Staples/m006880770_sc7?$splssku$",
		"ImageSecondaryURL": "",
		"WidthScale": 1.0
	}

Custom_Tile
	"CustomImage": {
		"ImageURL": "https://images.homedepot-static.com/productImages/1a268670-ce23-44c0-afb1-6616765ce83c/svn/cream-trafficmaster-ceramic-tile-uf6z-64_300.jpg",
		"ImageSecondaryURL": "",
		"WidthScale": 0.0,
		"CustomTile": {
		"Type": 0,
		"Thickness": 0.2,
		"Stackable": false,
		"Stretch": true
	}

Custom_Token
	"CustomImage": {
		"ImageURL": "https://assets.coingecko.com/coins/images/2214/large/token.png?1547036499",
		"ImageSecondaryURL": "",
		"WidthScale": 0.0,
		"CustomToken": {
			"Thickness": 0.2,
			"MergeDistancePixels": 15.0,
			"Stackable": false
		}
	},

Custom_Dice
	"CustomImage": {
		"ImageURL": "https://cdn11.bigcommerce.com/s-70184/images/stencil/1280x1280/products/327/8270/green-dice-opaque-16mm__76543.1549390614.jpg?c=2?imbypass=on",
		"ImageSecondaryURL": "",
		"WidthScale": 0.0,
		"CustomDice": {
			"Type": 1
		}
	},

Figurine_Custom
	"CustomImage": {
		"ImageURL": "https://www.geekstore.fr/35065-home_default/figurine-fortnite-skull-trooper-.jpg",
		"ImageSecondaryURL": "",
		"WidthScale": 0.0
	},





The following values are ignored:
* Locked
* Position
* Scale
* ColorTint