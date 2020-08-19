--[[
	LEGACY SUPPORT
	This exists to support plugins using the UILibrary that are
	migrating to the DeveloperFramework.

	UILibraryWrapper is a ContextItem that can be used to replace
	any overhead related to the UILibrary that a plugin may have.

	UILibraryWrapper expects to be provided
	after a Theme, Plugin, and Focus ContextItem.
]]

local noGetThemeError = [[
UILibraryProvider expects Theme to have a 'getUILibraryTheme' instance function.]]

local Framework = script.Parent.Parent
local Util = require(Framework.Util)
local FlagsList = Util.Flags.new({
	FFlagStudioDevFrameworkPackage = {"StudioDevFrameworkPackage"},
	FFlagRefactorDevFrameworkContextItems = {"RefactorDevFrameworkContextItems"},
})

local isUsedAsPackage = require(Framework.Util.isUsedAsPackage)

local shouldGetUILibraryFromParent = not FlagsList:get("FFlagStudioDevFrameworkPackage") or
	(FlagsList:get("FFlagStudioDevFrameworkPackage") and not isUsedAsPackage())

local UILibraryFromParent
if shouldGetUILibraryFromParent then
	-- We assume plugins will completely move away from the UILibrary
	-- to the Framework in the future, so we don't want to depend on it.
	if not Framework.Parent:FindFirstChild("UILibrary") then
		return nil
	end

	UILibraryFromParent = require(Framework.Parent.UILibrary)
end

local Roact = require(Framework.Parent.Roact)
local ContextItem = require(Framework.ContextServices.ContextItem)
local mapToProps = require(Framework.ContextServices.mapToProps)
local Theme = require(Framework.ContextServices.Theme)
local Plugin = require(Framework.ContextServices.Plugin)
local Focus = require(Framework.ContextServices.Focus)

local UILibraryProvider = Roact.PureComponent:extend("UILibraryProvider")

function UILibraryProvider:render()
	local props = self.props
	local plugin = props.Plugin
	local theme = props.Theme
	local focus = props.Focus
	local UILibrary = props.UILibrary

	assert(theme.getUILibraryTheme, noGetThemeError)

	return Roact.createElement(UILibrary.Wrapper, {
		theme = theme:getUILibraryTheme(),
		plugin = plugin:get(),
		focusGui = FlagsList:get("FFlagRefactorDevFrameworkContextItems") and focus:get() or focus:getTarget(),
	}, {
		Roact.oneChild(self.props[Roact.Children])
	})
end

mapToProps(UILibraryProvider, {
	Theme = Theme,
	Plugin = Plugin,
	Focus = Focus,
})

local UILibraryWrapper = ContextItem:extend("UILibraryWrapper")

function UILibraryWrapper.new(uiLibraryProp)
	local UILibrary

	if not FlagsList:get("FFlagStudioDevFrameworkPackage") or shouldGetUILibraryFromParent then
		UILibrary = UILibraryFromParent
	else
		UILibrary = uiLibraryProp
		assert(UILibrary, "UILibraryWrapper must be passed a reference to UILibrary")
	end

	local self = {
		UILibrary = UILibrary
	}
	setmetatable(self, UILibraryWrapper)

	return self
end

function UILibraryWrapper:createProvider(root)
	return Roact.createElement(UILibraryProvider, {
		UILibrary = self.UILibrary
	}, {root})
end

return UILibraryWrapper
