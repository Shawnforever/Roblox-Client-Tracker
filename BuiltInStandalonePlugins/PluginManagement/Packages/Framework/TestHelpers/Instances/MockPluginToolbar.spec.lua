local MockPluginToolbar = require(script.Parent.MockPluginToolbar)

return function()
	describe("CreateButton", function()
		it("should support legacy API", function()
			local toolbar = MockPluginToolbar.new(nil, "")

			local button = toolbar:CreateButton("id", "tooltip", "icon", "text")
			expect(button._toolbar).to.equal(toolbar)
			expect(button._id).to.equal("id")
			expect(button.Tooltip).to.equal("tooltip")
			expect(button.Icon).to.equal("icon")
			expect(button.Text).to.equal("text")
			button:Destroy()

			button = toolbar:CreateButton("", "foo")
			expect(button._id).to.equal("foo")
			expect(button.Tooltip).to.equal("foo")
			expect(button.Icon).to.equal("")
			expect(button.Text).to.equal("foo")
			button:Destroy()

			toolbar:Destroy()
		end)

		it("should support new API", function()
			local toolbar = MockPluginToolbar.new(nil, "")
			local button = toolbar:CreateButton("foo_id")
			expect(button._toolbar).to.equal(toolbar)
			expect(button._id).to.equal("foo_id")
			expect(button.Tooltip).to.equal("")
			expect(button.Icon).to.equal("")
			expect(button.Text).to.equal("foo_id")
			button:Destroy()
			toolbar:Destroy()
		end)
	end)
end
