--[[
	Networking

	Provides a re-usable implementation for network requests and other utilities
]]--
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local HttpResponse = require(Modules.LuaApp.Http.HttpResponse)
local StatusCodes = require(Modules.LuaApp.Http.StatusCodes)

local HttpService = game:GetService("HttpService")



-- helper functions
local function getHttpStatus(response)
	-- NOTE, this function expects to parse a response like this:
	-- HTTP 404 (HTTP/1.1 404 Not Found)

	for _, code in pairs(StatusCodes) do
		if code >= 100 and response:find(tostring(code)) then
			return code
		end
	end

	if response:find("2%d%d") then
		return StatusCodes.OK
	end

	if response:find("curl_easy_perform") and response:find("SSL") then
		return StatusCodes.BAD_TLS
	end

	return StatusCodes.UNKNOWN_ERROR
end


-- requestType : (string) "GET" or "POST"
-- httpAction : (function) a function that wraps the httpRequest
-- RETURNS : (HttpResponse) object containing information about the request
local function baseHttpHandler(requestType, httpAction)
	-- this function handles the actual network request and any and all additional
	-- business logic around the request.

	-- time how long the request takes to complete
	local startTime = tick()

	-- fetch the raw response from the server
	-- NOTE - this pcall will prevent the server from throwing errors on a 404 or other server problem
	local success, responseString = pcall(httpAction)
	local endTime = tick()

	-- package information about the response into a single object
	local responseTimeMs = (endTime - startTime) * 1000
	local statusCode = StatusCodes.OK
	if not success then
		statusCode = getHttpStatus(responseString)
	end

	return HttpResponse.new(responseString, responseTimeMs, statusCode)
end

-- httpImpl : (Service) an object that defines HttpGetAsync
-- url : (string)
local function httpGet(httpImpl, url)
	return baseHttpHandler("GET", function()
		return httpImpl:HttpGetAsync(url)
	end)
end

-- httpImpl : (Service) an object that defines HttpPostAsync
-- url : (string)
-- payload : (string)
-- contentType : (string)
local function httpPost(httpImpl, url, payload, contentType)
	if not contentType then
		contentType = "application/json"
	end

	return baseHttpHandler("POST", function()
		return httpImpl:HttpPostAsync(url, payload, contentType)
	end)
end

-- httpFunc : (function) one of the http functions defined above, like httpGet, or httpPost
-- ... : arguments to pass into the httpFunc
local function createHttpPromise(httpFunc, ...)
	-- make a promise to track the progress of a network request
	local args = {...}
	local httpPromise = Promise.new(function(resolve, reject)
		-- begin fetching the response from the server
		-- NOTE - the http function will yield the thread, so spawn a new one
		spawn(function()
			local httpResponse = httpFunc(unpack(args))

			if httpResponse.responseCode == StatusCodes.OK then
				resolve(httpResponse)
			else
				reject(httpResponse)
			end
		end)
	end)

	-- return the promise so people can patiently wait
	return httpPromise
end

-- TO DO:
-- add logic for RetryGet and RetryPost to automatically poll an endpoint for a proper response



-- public api
local Networking = {}
Networking.__index = Networking

-- httpImpl : (Service, optional) something that implements HttpGetAsync, and HttpPostAsync
function Networking.new(httpImpl)
	if not httpImpl then
		httpImpl = game
	end

	local networkObj = {
		_httpImpl = httpImpl
	}
	setmetatable(networkObj, Networking)

	return networkObj
end

-- fakeResponse : (string, optional) something to return when a faked network response returns
function Networking.mock(fakeResponse)
	if not fakeResponse then
		fakeResponse = "HTTP 0 (HTTP/1.1 0 No Connection)"
	end

	-- create a stub implementation that never calls out to the web
	local fakeHttpImpl = {}
	function fakeHttpImpl.HttpGetAsync(_)
		return fakeResponse
	end
	function fakeHttpImpl.HttpPostAsync(_)
		return fakeResponse
	end

	return Networking.new(fakeHttpImpl)
end


-- Response parsing utility functions
function Networking:jsonEncode(data)
	return HttpService:JSONEncode(data)
end

function Networking:jsonDecode(data)
	return HttpService:JSONDecode(data)
end


-- Http request functions

-- url : (string)
-- returns a Promise that resolves to an HttpResponse object
function Networking:httpGetJson(url)
	return createHttpPromise(httpGet, self._httpImpl, url):andThen(
		function(result)
			if result.responseCode == StatusCodes.OK then
				result.responseBody = self:jsonDecode(result.responseBody)
			end

			return result
		end)
end

-- url : (string)
-- payload : (string)
-- returns a Promise that resolves to an HttpResponse object
function Networking:httpPostJson(url, payload)
	return createHttpPromise(httpPost, self._httpImpl, url, payload):andThen(
		function(result)
			if result.responseCode == StatusCodes.OK then
				result.responseBody = self:jsonDecode(result.responseBody)
			end

			return result
		end)
end


return Networking