local Screens = {
    MAIN = {
		Key = "MAIN",
	},
	PLACES = {
		Key = "PLACES",
	},
    MESHES = {
		Key = "MESHES",
	},
	IMAGES = {
		Key = "IMAGES",
	},
	PACKAGES = {
		Key = "PACKAGES",
	},
	SCRIPTS = {
		Key = "SCRIPTS",
	},
}

Screens.MESHES.Parent = Screens.MAIN.Key
Screens.IMAGES.Parent = Screens.MAIN.Key
Screens.PACKAGES.Parent = Screens.MAIN.Key
Screens.PLACES.Parent = Screens.MAIN.Key
Screens.SCRIPTS.Parent = Screens.MAIN.Key

Screens.MESHES.AssetType = Enum.AssetType.MeshPart
Screens.IMAGES.AssetType = Enum.AssetType.Image
Screens.PACKAGES.AssetType = Enum.AssetType.Package
Screens.PLACES.AssetType = Enum.AssetType.Place
Screens.SCRIPTS.AssetType = Enum.AssetType.Lua

Screens.PLACES.LayoutOrder = 1
Screens.IMAGES.LayoutOrder = 2
Screens.MESHES.LayoutOrder = 3
Screens.PACKAGES.LayoutOrder = 4
Screens.SCRIPTS.LayoutOrder = 5

return Screens