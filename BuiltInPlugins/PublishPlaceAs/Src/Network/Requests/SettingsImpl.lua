--[[
	Interface for changing ingame settings.

	Flow:
		SettingsImpl can be provided via a SettingsImplProvider, then
		used as an Interface by the SaveChanges and LoadAllSettings thunks
		to save and load settings. Other implementations, such as
		SettingsImpl_mock, can be provided to allow testing.
]]

local StudioService = game:GetService("StudioService")

local Plugin = script.Parent.Parent.Parent.Parent
local Promise = require(Plugin.Packages.Promise)

local Configuration = require(Plugin.Src.Network.Requests.Configuration)
local RootPlaceInfo = require(Plugin.Src.Network.Requests.RootPlaceInfo)

--[[
	Used to save the chosen state of all game settings by saving to web
	endpoints or setting properties in the datamodel.
]]
local function saveAll(state, onClose)
	local configuration = {}
	local rootPlaceInfo = {}

	for setting, value in pairs(state) do
		-- Add name, genre, and playable devices
		if Configuration.AcceptsValue(setting) then
			configuration[setting] = value
		-- Add the game description
		elseif RootPlaceInfo.AcceptsValue(setting) then
			rootPlaceInfo[setting] = value
		end
	end

	StudioService:publishAs(0, 0)

	spawn(function()
		StudioService.GamePublishedToRoblox:wait()
		local setRequests = {
			Configuration.Set(game.GameId, configuration),
			RootPlaceInfo.Set(game.GameId, rootPlaceInfo),
		}
		Promise.all(setRequests):andThen(function()
			StudioService:SetUniverseDisplayName(configuration.name)
			StudioService:emitPlacePublishedSignal()
			onClose()
		end):catch(function(err)
			warn("PublishPlaceAs: Could not publish configuration settings.")
			warn(tostring(err))
		end)
	end)

end

return {
	saveAll = saveAll,
}