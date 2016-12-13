local bicycles = {}
local state = {
	fine = 0,
	damaged = 1,
	onFire = 2,
	dead = 3,
}
local rendering = false
addEvent("onClientBicycleSync", true)
addEvent("onBicycleDamageStateChange", true)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		triggerServerEvent("onClientBicycleReady", resourceRoot)
	end
)

addEventHandler("onClientBicycleSync", resourceRoot,
	function(bicycles_)
		for bicycle, data in pairs(bicycles_) do
			if bicycle and isElement(bicycle) then
				-- if something has changed state in the small time between joining and this triggering
				-- don't overwrite it
				if not bicycles[bicycle] then
					bicycles[bicycle] = {state = data.state, streamed = isElementStreamedIn(bicycle)}

					if data.state ~= state.fine then
						triggerEvent("onBicycleDamageStateChange", bicycle, state.fine, data.state)
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementDestroy", root,
	function()
		if bicycles[source] then
			stopTrackingBicycle(source)
		end
	end
)

function stopTrackingBicycle(bicycle)
	if bicycles[bicycle].effect then
		destroyElement(bicycles[bicycle].effect)
	end

	bicycles[bicycle] = nil

	if rendering and tableEmpty(bicycles) then
		removeEventHandler("onClientPreRender", root, showDamage)
		rendering = false
	end
end

addEventHandler("onBicycleDamageStateChange", root,
	function(oldState, newState)
		if (not source) or (not isElement(source)) then
			return
		end

		if not bicycles[source] then
			bicycles[source] = {state = newState, streamed = isElementStreamedIn(source)}
		end

		--outputDebugString("state changed to "..tostring(newState).. " on client")

		if newState == state.dead or newState == state.fine then
			stopTrackingBicycle(source)
			return	
		end

		local effectName

		if newState == state.damaged then
			effectName = "overheat_car"
		elseif newState == state.onFire then	
			effectName = "fire_bike"
		end

		if effectName then				
			if bicycles[source].effect then
				destroyElement(bicycles[source].effect)
			end

			local x, y, z = getElementPosition(source)
			
			bicycles[source].effect = createEffect(effectName, x, y, z, 270, 0, 0)	

			--outputDebugString(tostring(bicycles[source].effect) .. ", " .. tostring(tableEmpty(bicycles)))

			if bicycles[source].effect and (not rendering) then
				addEventHandler("onClientPreRender", root, showDamage)
				rendering = true
			end
		end		
	end
)

function showDamage()
	for bicycle, data in pairs(bicycles) do
		if bicycle and isElement(bicycle) and data.streamed and data.effect then
			local x, y, z = getElementPosition(bicycle)

			setElementPosition(data.effect, x, y, z)
		end
	end
end
--[[ stages for normal cars
	650: white smoke
	650 -> 500: gradually increases amount of smoke
	500: introduces black/grey smoke
	500 -> 260: smoke gradually becomes entirely black/grey
	260-ish: fire/blow
]]


addEventHandler("onClientElementStreamIn", root,
	function()
		if bicycles[source] then
			bicycles[source].streamed = true

			if not rendering then
				addEventHandler("onClientPreRender", root, showDamage)
				rendering = true
			end
		end
	end
)


addEventHandler("onClientElementStreamOut", root,
	function()
		if bicycles[source] then
			bicycles[source].streamed = nil

			if rendering then
				local anyStreamed = false

				for _, data in pairs(bicycles) do
					if data.streamed then
						anyStreamed = true
						break
					end
				end

				if not anyStreamed then
					removeEventHandler("onClientPreRender", root, showDamage)
					rendering = false
				end
			end
		end
	end
)


function tableEmpty(t)
	for _,_ in pairs(t) do
		return false
	end

	return true
end