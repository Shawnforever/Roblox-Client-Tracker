local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Theming = require(Plugin.Src.ContextServices.Theming)
local UILibrary = require(Plugin.Packages.UILibrary)
local Localizing = UILibrary.Localizing
local Separator = UILibrary.Component.Separator

local DFFlagPreloadAsyncCallbackFunction = settings():getFFlag("PreloadAsyncCallbackFunction")
local FFlagEnableRbxThumbAPI = settings():GetFFlag("EnableRbxThumbAPI")

local ContentProvider = game:GetService("ContentProvider")

local ASSET_SIZE = 150

local TilePlace = Roact.PureComponent:extend("TilePlace")

function TilePlace:init()
	self.state = {
		assetFetchStatus = nil,		
	}

	self.isMounted = false
	
	if self.props.Id then
		self.thumbnailUrl = string.format("rbxthumb://type=Asset&id=%i&w=%i&h=%i", self.props.Id, ASSET_SIZE, ASSET_SIZE)
	end
end

function TilePlace:didMount()
	self.isMounted = true
	if DFFlagPreloadAsyncCallbackFunction and FFlagEnableRbxThumbAPI and self.props.Id then
		spawn(function()
			local asset = { self.thumbnailUrl }
			local function setStatus(contentId, status)
				if self.isMounted then
					self:setState({
						assetFetchStatus = status
					})
				end
			end
			ContentProvider:PreloadAsync(asset, setStatus)
		end)
	end
end

function TilePlace:willUnmount()
	self.isMounted = false
end

function TilePlace:render()
	return Theming.withTheme(function(theme)
		return Localizing.withLocalization(function(localizing)
			local props = self.props

			local name = props.Name
			local selected = props.Selected
			local lastItem = props.LastItem
			local onActivated = props.OnActivated
			local layoutOrder = props.LayoutOrder or 0

			local image = theme.icons.thumbnailPlaceHolder
			if props.Id and self.state.assetFetchStatus == Enum.AssetFetchStatus.Success then
				image = self.thumbnailUrl
			elseif props.Id == nil then
				image = theme.icons.newPlace
			end

			return Roact.createElement("ImageButton", {
				Size = UDim2.new(1, -40, 0, 80),
				LayoutOrder = layoutOrder,
				BackgroundTransparency = 1,
				[Roact.Event.Activated] = onActivated,
			}, {

				Icon = Roact.createElement("ImageLabel", {
					Image = image,
					Size = UDim2.new(0, 60, 0, 60),
					Position = UDim2.new(0, 10, 0, 10),
					BorderSizePixel = 0,
				}),

				Tile = Roact.createElement("Frame", {
					Position = UDim2.new(0, 80, 0, 0),
					Size = UDim2.new(1, -80, 1, 0),
					BackgroundTransparency = 1,
				}, {
					Pad = Roact.createElement("UIPadding", {
						PaddingLeft =  UDim.new(0, 10),
						PaddingRight =  UDim.new(0, 10),
						PaddingBottom = UDim.new(0, 10),
					}),

					Name = Roact.createElement("TextLabel", {
						Text = name,
						Size = UDim2.new(1, 0, 1, 0),
						TextXAlignment = 0,

						TextWrapped = true,
						TextSize = 11,
						BorderSizePixel = 0,
						BackgroundTransparency = 1,
						TextColor3 = theme.textColor,
					}),

					Selected = selected and Roact.createElement("ImageLabel", {
						Image = theme.icons.checkmark,
						Size = UDim2.new(0, 30, 0, 30),
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -30, 0.5, 0),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
					}),

					Seperator = not lastItem and Roact.createElement(Separator, {
						Weight = 1,
						Position = UDim2.new(0.5, 0, 1, 10),
					}),
				}),
			})
		end)
	end)
end

return TilePlace
