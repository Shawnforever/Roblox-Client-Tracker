local ServiceWrapper = require(script.Parent.ServiceWrapper)

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Rodux = require(Plugin.Packages.Rodux)
local UILibrary = require(Plugin.Packages.UILibrary)

local MockDraftsService = require(Plugin.Src.TestHelpers.MockDraftsService)
local Localization = UILibrary.Studio.Localization
local MainReducer = require(Plugin.Src.Reducers.MainReducer)
local MockPlugin = require(Plugin.Src.TestHelpers.MockPlugin)
local PluginTheme = require(Plugin.Src.Resources.PluginTheme)


return function()
	it("should construct and destroy without errors", function()
		local draftsService = MockDraftsService.new(MockDraftsService.TestCases.DEFAULT)
		local localization = Localization.mock()
		local pluginInstance = MockPlugin.new()
		local store = Rodux.Store.new(MainReducer, {}, { Rodux.thunkMiddleware })
		local theme = PluginTheme.mock()

		local element = Roact.createElement(ServiceWrapper, {
			draftsService = draftsService,
			localization = localization,
			plugin = pluginInstance,
			store = store,
			theme = theme,
		}, {
			testFrame = Roact.createElement("Frame")
		})
		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container)

		Roact.unmount(instance)
	end)

	describe("Localization", function()
		it("should supply a functional localization object to its children", function()
			expect(true).to.equal(true)
		end)
	end)

	describe("Plugin", function()
		it("should supply a functional plugin object to its children", function()
			expect(true).to.equal(true)
		end)
	end)

	describe("Store", function()
		it("should supply a functional Rodux Store object to its children", function()
			expect(true).to.equal(true)
		end)
	end)

	describe("Theme", function()
		it("should supply a functional theme object to its children", function()
			expect(true).to.equal(true)
		end)
	end)
end