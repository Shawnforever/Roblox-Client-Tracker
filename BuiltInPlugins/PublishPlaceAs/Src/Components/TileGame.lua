local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Theming = require(Plugin.Src.ContextServices.Theming)
local UILibrary = require(Plugin.Packages.UILibrary)
local Localizing = UILibrary.Localizing
local Separator = UILibrary.Component.Separator

local ContentProvider = game:GetService("ContentProvider")

local FFlagBatchThumbnailAddNewThumbnailTypes = game:GetFastFlag("BatchThumbnailAddNewThumbnailTypes")

local FFlagStudioLocalizePrivacyTypesInPublishPlaceAs = game:DefineFastFlag("StudioLocalizePrivacyTypesInPublishPlaceAs", false)

local ICON_SIZE = 150
local TILE_FOOTER_SIZE = 35
local NAME_SIZE = 70
local PADDING = 5

local TileGame = Roact.PureComponent:extend("TileGame")

function TileGame:init()
	self.state = {
		assetFetchStatus = nil,		
	}

	self.isMounted = false

	self.thumbnailUrl = FFlagBatchThumbnailAddNewThumbnailTypes and string.format("rbxthumb://type=AutoGeneratedAsset&id=%i&w=%i&h=%i", self.props.Id, ICON_SIZE, ICON_SIZE)
		or string.format("rbxthumb://type=GameIcon&id=%i&w=%i&h=%i", self.props.Id, ICON_SIZE, ICON_SIZE)
end

function TileGame:didMount()
	self.isMounted = true
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

function TileGame:willUnmount()
	self.isMounted = false
end

function TileGame:render()
	return Theming.withTheme(function(theme)
		return Localizing.withLocalization(function(localizing)
			local props = self.props
			
			local name = props.Name
			local layoutOrder = props.LayoutOrder or 0
			local state = props.State
			local onActivated = props.OnActivated

			local isThumbnail = self.state.assetFetchStatus == Enum.AssetFetchStatus.Success

			return Roact.createElement("ImageButton", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE + TILE_FOOTER_SIZE),
				LayoutOrder = layoutOrder,

				[Roact.Event.Activated] = onActivated
			}, {
				Icon = Roact.createElement("ImageLabel", {
					Position = UDim2.new(0, 0, 0, 0),
					Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
					Image = isThumbnail and self.thumbnailUrl or theme.icons.thumbnailPlaceHolder,
					ImageColor3 = isThumbnail and Color3.new(1, 1, 1) or theme.icons.imageColor,
					BackgroundColor3 = theme.icons.backgroundColor,
					BorderSizePixel = 0,
				}),

				Name = Roact.createElement("TextLabel", {
					Text = name,
					Position = UDim2.new(0, 0, 1, -1.5 * TILE_FOOTER_SIZE + PADDING),
					Size = UDim2.new(1, 0, 0, NAME_SIZE),

					TextWrapped = true,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 14,
					Font = theme.font,
					TextColor3 = theme.textColor,
					BackgroundTransparency = 1,
				}),

				Separator = Roact.createElement(Separator, {
					Weight = 1,
					Padding = 10,
					Position = UDim2.new(0.5, 0, 1, PADDING),
				}),

				State = Roact.createElement("TextLabel", {
					-- use localization keys PrivacyType.Public or PrivacyType.Private
					Text = FFlagStudioLocalizePrivacyTypesInPublishPlaceAs and localizing:getText("PrivacyType", state) or state,
					Position = UDim2.new(0, 0, 1, 0),
					Size = UDim2.new(1, 0, 0, TILE_FOOTER_SIZE),

					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextSize = 12,
					Font = theme.font,
					TextColor3 = state == "Public" and theme.successText.text or theme.dimmerTextColor,
					BackgroundTransparency = 1,
				}),
			})
		end)
	end)
end

return TileGame
