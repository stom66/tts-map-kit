# Map Kit
### A collection of map-making models for use in Tabletop Simulator

This kit comprises of various components intended for use in the game Tabletop Simulator. There are several categories of assets including the following:

* Trees and tree stumps
* Shrubs and small plants
* Rocks
* Weather
* Skyboxes

---

### Weather
##### There's no such thing as bad weather, just the wrong type of clothing

Gives creators the ability to control the weather in their scene. Weather types as follows:

* Sun (nothing)
* Rain (light, medium, heavy, extreme)
* Hail (light, medium, heavy, extreme)
* Lightning (short, medium, long)
* Snow (light, medium, heavy, extreme)
* Wind - provided by the boxfan, interacts with Trees 
* Fog - various heights, low-lying or all-over. Adjustable density, collisions, color (all particle params)
* Autumn - leaves (light, medium, heavy, extreme)
* Dust motes (light, medium, heavy, extreme)
* Fireflies (lit and unlit)
* Clouds - low lying clouds to float over the table
* Mist/Fog - (light, medium, heavy, extreme)
* Tornado - one size destroys all

The weather zone is a single asset that contains all of the above weather animations. Its outline follows a 10x10x10 unit cube and can be scaled accordingly. Each weather type is managed by it's own animation controller which allows a zone to combine any of the possible different weather types.

---

### Trees

There are several trees available in the kit. Trees consist of the following:

**Tree colliders**

Colliders should be toggleable by the scene manager and will be held in the child named CollisionObject0. Colliders are as follows:

*   1 Capsule collider
Represents the main trunk of the tree and should not exceed the bounds of the 2 box colliders. It should not extend so far down as to include roots, nor should it extend high enough to encompass the uppermost section of the trunk.
*   1 Box collider:
Situated at the base of the tree for stability, it should extend further down than the bottom of the capsule collider, yet not enclose the roots. The tree model should extend slightly past the bottom of the collider to ensure a seamless lineup with terrain.
*   1 Box collider:
Placed at the top of the tree to enable objects to sit on top. The top of the box collider should be above the capsule collider to ensure a stable surface. The collider should be at a suitable height so that characters would not appear to be balancing above the tree.

---

### Shrubs and Plants
##### Small herbage for your daily needs

A variety of plants and shrubs, often with several models bundled into one to conserve save-file size.

* Shrub
* Shrub
* Shrub

---

### Rocks
##### A Druids best friend

Simple rock assets that come with the following features:

* Optional collider
* Changeable material for texture variations

Available models:
* Single Rock
* Cut rock - important for standing arrangements
* Rock fall / scree debris
* Rocky face

---

### Skyboxes
##### An Earth-centric solution to prjecting the celestial sphere

A skybox that is adjustable with various preset states:

* Dawn
* Midday
* Sunset
* Nightime
* Single color
* Possible loading additional textures from secondary assetbundle