--[[
    VIPServers is a wrapper around RadioButtonSet to display a Price config (field for price,
    label for fee, label for actual amount earned), and Subscriptions Count and Total VIP Servers Count 
    between the "On" and "Off" buttons.

    Necessary props:
        Price = number, the initial price to be shown in the text field.
        Enabled = boolean, whether or not this component is enabled.
        Selected = boolean, "true" if On button should be selected, "false" if the off button should be selected.
        LayoutOrder = number, order in which this component should appear under its parent.
        VIPServersData = table, a table of relevant VIP Servers info to populate the component.
            example of VIPServersData:
            {
                isEnabled = true,
                price = 1000000000000000,
                activeServersCount = 1000,
                activeSubscriptionsCount = 1000,
            }

        OnVipServersToggled = function(button), this is a callback thta is invoked with the button info, when the radio button is toggled.
            example of button info:
            {
                Id = true,
                Title = "This is a foo button.",
                Description = "Lorem ipsum",
            }
        OnVipServersPriceChanged = function(price), this is a callback to be invoked when the price field changes values
]]

local Plugin = script.Parent.Parent.Parent

local Cryo = require(Plugin.Cryo)
local Roact = require(Plugin.Roact)
local Framework = Plugin.Framework
local FitFrameOnAxis = require(Framework.Util).FitFrame.FitFrameOnAxis
local LayoutOrderIterator = require(Framework.Util.LayoutOrderIterator)

local ContextServices = require(Plugin.Framework.ContextServices)

local RadioButtonSet = require(Plugin.Src.Components.RadioButtonSet)
local RobuxFeeBase = require(Plugin.Src.Components.RobuxFeeBase)

local PaidAccess = Roact.PureComponent:extend("PaidAccess")

function PaidAccess:render()
    local props = self.props
    local localization = props.Localization
    local theme = props.Theme:get("Plugin")

    local layoutIndex = LayoutOrderIterator.new()

    local title = localization:getText("Monetization", "TitleVIPServers")

    local layoutOrder = props.LayoutOrder
    local vipServersData = props.VIPServersData

    local enabled = props.Enabled

    local selected = vipServersData.isEnabled
    local price =  vipServersData.price
    local serversCount = vipServersData.activeServersCount
    local subsCount = vipServersData.activeSubscriptionsCount

    local onVipServersToggled = props.OnVipServersToggled
    local onVipServersPriceChanged = props.OnVipServersPriceChanged

    local disabledSubText = localization:getText("Monetization", "VIPServersHint")

    local subscriptionsText = localization:getText("Monetization", "Subscriptions", { numOfSubscriptions = subsCount })

    local totalVIPServersText = localization:getText("Monetization", "TotalVIPServers", { totalVipServers = serversCount })

    local transparency = enabled and theme.robuxFeeBase.transparency.enabled or theme.robuxFeeBase.transparency.disabled

    local buttons = {
        {
            Id = true,
            Title = localization:getText("General", "SettingOn"),
            Children = {
                RobuxFeeBase = Roact.createElement(RobuxFeeBase, {
                    Price = price,
                    DisabledSubText = disabledSubText,

                    Enabled = enabled,

                    OnPriceChanged = onVipServersPriceChanged,

                    LayoutOrder = layoutIndex:getNextOrder(),
                }),
                SubscriptionsAndTotalFrame = Roact.createElement(FitFrameOnAxis, {
                    axis = FitFrameOnAxis.Axis.Vertical,
                    minimumSize = UDim2.new(1, 0, 0, 0),
                    FillDirection = Enum.FillDirection.Vertical,
                    BackgroundTransparency = 1,

                    LayoutOrder = layoutIndex:getNextOrder(),
                }, {
                    Subscriptions = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Normal, {
                        Text = subscriptionsText,
                        Size = UDim2.new(1, 0, 0, theme.rowHeight),
                        BackgroundTransparency = 1,

                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        TextTransparency = transparency,

                        LayoutOrder = 1,
                    })),

                    TotalVIPServers = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Normal, {
                        Text = totalVIPServersText,
                        Size = UDim2.new(1, 0, 0, theme.rowHeight),
                        BackgroundTransparency = 1,

                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        TextTransparency = transparency,

                        LayoutOrder = 2,
                    })),
                }),
            }
        },
        {
            Id = false,
            Title = localization:getText("General", "SettingOff"),
        },
    }

    return Roact.createElement(FitFrameOnAxis, {
        axis = FitFrameOnAxis.Axis.Vertical,
        minimumSize = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,

        LayoutOrder = layoutOrder,
    }, {
        OnOffToggle = Roact.createElement(RadioButtonSet, {
            Title = title,

            Buttons = buttons,

            Enabled = enabled,
            Selected = selected,
            SelectionChanged = onVipServersToggled,
        })
    })
end

ContextServices.mapToProps(PaidAccess, {
    Localization = ContextServices.Localization,
    Theme = ContextServices.Theme,
})

return PaidAccess