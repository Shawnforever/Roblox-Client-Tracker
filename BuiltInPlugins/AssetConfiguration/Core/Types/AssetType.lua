local FFlagFixGetAssetTypeErrorHandling = game:GetFastFlag("FixGetAssetTypeErrorHandling")
local FFlagEnableToolboxVideos = game:GetFastFlag("EnableToolboxVideos")

local Plugin = script.Parent.Parent.Parent

local Util = Plugin.Core.Util
local convertArrayToTable = require(Util.convertArrayToTable)

local AssetType = {}

-- For asset preview panel, where we don't have asset typeId.
AssetType.TYPES = {
	ModelType = 1, -- MeshPart, Mesh, Model
	ImageType = 2,
	SoundType = 3,	-- Sound comes with the model or mesh.
	ScriptType = 4, -- Server, local, module
	PluginType = 5,
	OtherType = 6,
	LoadingType = 7,
	VideoType = FFlagEnableToolboxVideos and 8 or nil,
}

-- For check if we show preview button or not.
AssetType.AssetTypesPreviewEnabled = convertArrayToTable({
	Enum.AssetType.Mesh.Value,
	Enum.AssetType.MeshPart.Value,
	Enum.AssetType.Model.Value,
	Enum.AssetType.Decal.Value,
	Enum.AssetType.Image.Value,
	Enum.AssetType.Audio.Value,
	Enum.AssetType.Lua.Value,
	Enum.AssetType.Plugin.Value,
	FFlagEnableToolboxVideos and Enum.AssetType.Video.Value or nil,
})

-- For AssetPreview, we devide assets into four categories.
-- For any parts or meshes, we will need to do a model preview.
-- For images, we show only an image.
-- For sound, we will need to show something and provide play control. (Will
-- probably improve this in the future)
-- For BaseScript, show only names while for all other type show assetName and type
function AssetType:getAssetType(assetInstance)
	local notInstance
	if FFlagFixGetAssetTypeErrorHandling then
		notInstance = not assetInstance or typeof(assetInstance) ~= "Instance"
	else
		notInstance = not assetInstance
	end

	if notInstance then
		return self.TYPES.LoadingType
	elseif assetInstance:IsA("BasePart")
		or assetInstance:IsA("Model")
		or assetInstance:IsA("BackpackItem")
		or assetInstance:IsA("Accoutrement") then
		return self.TYPES.ModelType
	elseif assetInstance:IsA("Decal")
		or assetInstance:IsA("ImageLabel")
		or assetInstance:IsA("ImageButton")
		or assetInstance:IsA("Texture")
		or assetInstance:IsA("Sky") then
		return self.TYPES.ImageType
	elseif assetInstance:IsA("Sound") then
		return self.TYPES.SoundType
	elseif FFlagEnableToolboxVideos and assetInstance:IsA("VideoFrame") then
		return self.TYPES.VideoType
	elseif assetInstance:IsA("BaseScript") then
		return self.TYPES.ScriptType
	else
		return self.TYPES.OtherType
	end
end

function AssetType:isModel(currentType)
	return currentType == self.TYPES.ModelType
end

function AssetType:isImage(currentType)
	return currentType == self.TYPES.ImageType
end

function AssetType:isAudio(currentType)
	return currentType == self.TYPES.SoundType
end

function AssetType:isScript(currentType)
	return currentType == self.TYPES.ScriptType
end

function AssetType:isPlugin(currentType)
	return currentType == self.TYPES.PluginType
end

function AssetType:markAsPlugin()
	return self.TYPES.PluginType
end

function AssetType:isOtherType(currentType)
	return currentType == self.TYPES.OtherType
end

function AssetType:isLoading(currentType)
	return currentType == self.TYPES.LoadingType
end

function AssetType:isPreviewAvailable(typeId)
	return AssetType.AssetTypesPreviewEnabled[typeId]
end

return AssetType