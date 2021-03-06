if not game:GetEngineFeature("LuaDraggers") then
	return
end

-- Libraries
local Plugin = script.Parent.Parent
local DraggerFramework = Plugin.Packages.DraggerFramework
local Roact = require(Plugin.Packages.Roact)

-- Dragger component
local DraggerContext_PluginImpl = require(DraggerFramework.Implementation.DraggerContext_PluginImpl)
local DraggerToolComponent = require(DraggerFramework.DraggerTools.DraggerToolComponent)
local MoveToolImpl = require(Plugin.Src.MoveToolImpl)

local PLUGIN_NAME = "MoveDragger"
local DRAGGER_TOOL_NAME = "Move"
local TOOLBAR_NAME = "Home"

local pluginEnabled = false
local pluginHandle = nil
local toolButton = nil

local function openPlugin()
	if pluginHandle then
		warn("Plugin handle already exists")
		return
	end

	pluginEnabled = true
	plugin:Activate(true)

	toolButton:SetActive(true)

	local draggerContext = DraggerContext_PluginImpl.new(plugin, game, settings())
	pluginHandle = Roact.mount(Roact.createElement(DraggerToolComponent, {
		AnalyticsName = "Move",
		Mouse = plugin:GetMouse(),
		AllowDragSelect = true,
		AllowFreeformDrag = true,
		ShowSelectionDot = false,
		DraggerContext = draggerContext,
		ToolImplementation = MoveToolImpl.new(draggerContext),
	}))
end

local function closePlugin()
	pluginEnabled = false
	toolButton:SetActive(false)
	if pluginHandle then
		Roact.unmount(pluginHandle)
		pluginHandle = nil
	end
end

local function main()
	plugin.Name = PLUGIN_NAME
	local toolbar = plugin:CreateToolbar(TOOLBAR_NAME)
	toolButton = toolbar:CreateButton(
		DRAGGER_TOOL_NAME,
		"Move an Object",
		"",
		"Move"
	)

	plugin.Deactivation:Connect(function()
		if pluginEnabled then
			closePlugin()
		end
	end)

	toolButton.Click:Connect(function()
		if pluginEnabled then
			closePlugin()
		else
			openPlugin()
		end
	end)
end

main()