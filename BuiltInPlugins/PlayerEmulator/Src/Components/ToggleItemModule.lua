--[[
	ToggleItemModule for boolean policy items

	Props:
		string Key
			Label text
		boolean IsOn
		boolean Enabled

		function ToggleCallback
			The reason we extract this as a module.
			Because the ToggleButton in UILibrary only takes isOn as parameter,
			but we need pass key into callback for any meaning logic business
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local ContextServices = require(Plugin.Packages.Framework.ContextServices)
local UILibrary = require(Plugin.Packages.UILibrary)
local ToggleButton = UILibrary.Component.ToggleButton

local ToggleItemModule = Roact.PureComponent:extend("ToggleItemModule")

function ToggleItemModule:init(props)
	self.onToggle = function(isOn)
		local enabled = self.props.Enabled
		if enabled then
			local key = props.Key
			props.ToggleCallback(key, isOn, props.Plugin:get())
		end
	end
end

function ToggleItemModule:render()
	local props = self.props
	local theme = props.Theme:get("Plugin")

	local key = props.Key
	local isOn = props.IsOn
	local enabled = props.Enabled

	return Roact.createElement("Frame", {
		Size = theme.TOGGLE_ITEM_FRAME_SIZE,
		BackgroundTransparency = 1,
	}, {
		TextLabel = Roact.createElement("TextLabel", {
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextColor3 = enabled and theme.TextColor or theme.DisabledColor,
			Size = theme.TOGGLE_ITEM_LABEL_SIZE,
			Text = key,
			BackgroundTransparency = 1,
		}),
		Toggle = Roact.createElement(ToggleButton, {
			Size = UDim2.new(0, theme.TOGGLE_BUTTON_WIDTH, 0, theme.TOGGLE_BUTTON_HEIGHT),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, theme.TOGGLE_BUTTON_OFFSET, 0.5, -theme.TOGGLE_BUTTON_HEIGHT/2),
			Enabled = enabled,
			IsOn = isOn,
			onToggle = self.onToggle,
		})
	})
end

ContextServices.mapToProps(ToggleItemModule, {
	Plugin = ContextServices.Plugin,
	Theme = ContextServices.Theme,
})

return ToggleItemModule