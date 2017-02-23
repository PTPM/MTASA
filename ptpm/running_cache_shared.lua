local runningCache = {
	watch = {["ptpm_accounts"] = true},
	running = {}
}

if localPlayer then
	addEventHandler("onClientResourceStart", root,
		function(res)
			if res ~= resource then
				externalResourceStart(res)
			else
				checkRunningResources()
			end
		end
	)

	addEventHandler("onClientResourceStop", root,
		function(res)
			if res ~= resource then
				externalResourceStop(res)
			end
		end
	)
else
	addEventHandler("onResourceStart", root,
		function(res)
			if res ~= resource then
				externalResourceStart(res)
			else
				checkRunningResources()
			end
		end
	)

	addEventHandler("onResourceStop", root,
		function(res)
			if res ~= resource then
				externalResourceStop(res)
			end
		end
	)
end

-- when we start up, check through all the watch resources
function checkRunningResources()
	for resName in pairs(runningCache.watch) do
		local res = getResourceFromName(resName)

		if res then
			if getResourceState(res) == "running" then
				runningCache.running[resName] = true
			end
		end
	end
end


function externalResourceStart(res) 
	local name = getResourceName(res)

	if not runningCache.watch[name] then
		return
	end

	runningCache.running[name] = true
end

function externalResourceStop(res)
	local name = getResourceName(res)

	if not runningCache.watch[name] then
		return
	end

	runningCache.running[name] = nil	
end


function isRunning(resourceName)
	if runningCache.watch[resourceName] then
		return runningCache.running[resourceName]
	end

	local resource = getResourceFromName(resourceName)
	if resource then
		if getResourceState(resource) == "running" then
			return true
		end
	end
	return false
end