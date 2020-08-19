--[[
	Checks the sanitization of modules in the DeveloperFramework.
	Consider modules not having tests to be a test failure, and
	consider components not using Typecheck.wrap to be a test failure.
]]

return function()
	local Framework = script.Parent
	local NO_TEST_DIRECTORIES = {
		Framework.StudioUI.StudioFrameworkStyles,
	}

	local ignoredFileNamesSiblingToTests = {
		["example"] = true,
		["renderExample"] = true,
		["style"] = true,
	}

	local function shouldHaveTests(targetScript)
		for _, folder in ipairs(NO_TEST_DIRECTORIES) do
			if targetScript:IsDescendantOf(folder) then
				return false
			end
		end
		return true
	end

	local function fileShouldBeValidated(targetScript)
		if targetScript:IsA("ModuleScript") then
			-- is this a test file?
			if targetScript.Name:find(".spec") then
				return false
			end

			-- is this a child of a Fractal-design directory?
			if (ignoredFileNamesSiblingToTests[targetScript.Name] and targetScript.Parent:FindFirstChild("test.spec")) then
				return false
			end

			-- is this a directory of other files?
			if #targetScript:GetChildren() > 0 then
				-- is this a Fractal-design directory?
				if targetScript:FindFirstChild("test.spec") then
					return true
				end

				-- run the tests if they are there
				return targetScript:FindFirstChild("init.spec")
			else
				-- this just a regular ModuleScript
				return true
			end

		elseif targetScript:IsA("Folder") then
			return true

		elseif targetScript:IsA("LocalizationTable") then
			return false
		end

		warn("Unexpected file case : " .. targetScript:GetFullName() .. " : " .. targetScript.ClassName)
		return false
	end

	local function checkForTests(targetScript, directory)
		local scriptNeedsTests = targetScript:IsA("ModuleScript") and not (targetScript.Name:find(".spec"))
		local innerTestSpec = targetScript:FindFirstChild("test.spec")
		if (scriptNeedsTests or innerTestSpec) and shouldHaveTests(targetScript) then
			local tests
			if innerTestSpec then
				tests = innerTestSpec
			else
				tests = targetScript.Parent:FindFirstChild(targetScript.Name .. ".spec")
			end
			assert(tests, string.format("Module `%s.lua` in %s has no tests!",
				targetScript.Name, directory.Name))
			expect(tests).to.be.ok()
		end
	end

	local function checkForTypecheck(targetScript, directory)
		local value = require(targetScript)
		local isImmutable = getmetatable(value) ~= nil and getmetatable(value).__newindex ~= nil
		local isComponent = type(value) == "table" and not isImmutable and value.render ~= nil
		if isComponent then
			local wraps = value.validateProps ~= nil
			assert(wraps, string.format("Component `%s.lua` in %s does not use Typecheck.wrap!",
				targetScript.Name, directory.Name))
			expect(wraps).to.equal(true)
		end
	end

	local function checkDirectory(directory)
		local source = directory:GetDescendants()
		for _, targetScript in ipairs(source) do
			if fileShouldBeValidated(targetScript) then
				checkForTests(targetScript, directory)
				checkForTypecheck(targetScript, directory)
			end
		end
	end

	it("should check every UI component", function()
		checkDirectory(Framework.UI)
	end)

	it("should check every StudioUI component", function()
		checkDirectory(Framework.StudioUI)
	end)

	it("should check every ContextServices item", function()
		checkDirectory(Framework.ContextServices)
	end)

	it("should check every Util module", function()
		checkDirectory(Framework.Util)
	end)
end
