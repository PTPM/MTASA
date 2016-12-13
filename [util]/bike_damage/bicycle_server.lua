local bicycles = {}
local state = {
	fine = 0,
	damaged = 1,
	onFire = 2,
	dead = 3,
}

addEvent("onClientBicycleReady", true)
addEvent("onBicycleDamageStateChange", false)

addEventHandler("onResourceStart", resourceRoot,
	function()
		for _, vehicle in ipairs(getElementsByType("vehicle")) do
			if getVehicleType(vehicle) == "BMX" then
				if getElementHealth(vehicle) < 650 then
					processBicycleHealth(vehicle, getElementHealth(vehicle), true)
				end
			end
		end

		-- bike check, 1, 2. is this thing on?
		setTimer(bikeCheck, 400, 0)
	end
)

-- send the clients all the currently tracked bicycles
-- we rely entirely on the server to determine bicycle states, since the clients cannot be trusted
addEventHandler("onClientBicycleReady", resourceRoot,
	function()
		triggerClientEvent(client, "onClientBicycleSync", resourceRoot, bicycles)
	end
)

addEventHandler("onVehicleDamage", root, 
	function()
		if getVehicleType(source) == "BMX" then
			processBicycleHealth(source, getElementHealth(source))
		end

		--outputDebugString(getElementHealth(source) .. " server")
	end
)

addEventHandler("onVehicleRespawn", root, 
	function()
		if bicycles[source] then
			setBicycleState(source, state.fine)
			stopTrackingBicycle(source)
		end
	end
)

addEventHandler("onElementDestroy", root, 
	function()
		if bicycles[source] then
			stopTrackingBicycle(source)
		end
	end
)


function stopTrackingBicycle(bicycle)
	if bicycles[bicycle].blowTimer then
		killTimer(bicycles[bicycle].blowTimer)
	end

	bicycles[bicycle] = nil
end

function processBicycleHealth(bicycle, health, blockClient)
	if health >= 650 then
		if bicycles[bicycle] then
			setBicycleState(bicycle, state.fine)
			stopTrackingBicycle(bicycle)
		end

		return
	end

	-- default state
	if not bicycles[bicycle] then
		bicycles[bicycle] = {
			state = state.fine
		}
	end

	if health <= 0 then
		if not bicycles[bicycle].blowTimer then
			setBicycleState(bicycle, state.dead, blockClient)
		end
	elseif health < 260 then
		setBicycleState(bicycle, state.onFire, blockClient)
	elseif health < 650 then
		setBicycleState(bicycle, state.damaged, blockClient)
	end
end

function setBicycleState(bicycle, damageState, blockClient)
	if bicycles[bicycle].state == damageState then
		return
	end

	local oldState = bicycles[bicycle].state

	--outputDebugString("set damage state " .. tostring(damageState) .. " on the server")

	bicycles[bicycle].state = damageState

	triggerEvent("onBicycleDamageStateChange", bicycle, oldState, damageState)

	-- tell the client that we have changed state
	if not blockClient then
		triggerClientEvent(root, "onBicycleDamageStateChange", bicycle, oldState, damageState)
	end
end

-- we can't reliably catch every change to a vehicles health 
-- (e.g. if someone else does setElementHealth in another resource)
-- so just check on a timer to catch any secret changes
function bikeCheck()
	for bicycle, data in pairs(bicycles) do
		local health = getElementHealth(bicycle)

		if data.state == state.fine then
			if health < 650 then
				processBicycleHealth(bicycle, health)
			end
		elseif data.state == state.damaged then
			if health >= 650 then
				processBicycleHealth(bicycle, health)
			elseif health < 260 then
				processBicycleHealth(bicycle, health)
			end
		elseif data.state == state.onFire then
			if health >= 650 then
				processBicycleHealth(bicycle, health)
			elseif health > 260 then
				if data.blowTimer then
					killTimer(data.blowTimer)
					data.blowTimer = nil
				end

				processBicycleHealth(bicycle, health)
			end
		elseif data.state == state.dead then
			if health > 0 then
				processBicycleHealth(bicycle, health)
			end
		end
	end
end


addEventHandler("onBicycleDamageStateChange", root, 
	function(oldState, newState)
		if (not source) or (not isElement(source)) or (not bicycles[source]) then
			return
		end

		--outputDebugString("state changed to "..tostring(newState).. " on server")

		if newState == state.onFire then
			if bicycles[source].blowTimer then
				return
			end

			bicycles[source].blowTimer = setTimer(blowBicycle, 5000, 1, source)
		end	
	end
)

function blowBicycle(bicycle)
	if (not bicycle) or (not isElement(bicycle)) then
		return
	end

	bicycles[bicycle].blowTimer = nil

	local driver = getVehicleOccupant(bicycle, 0)

	if driver then
		removePedFromVehicle(driver)
	end

	local x, y, z = getElementPosition(bicycle)
	-- small explosion
	createExplosion(x, y, z, 12)

	--setElementHealth(bicycle, 0)
	blowVehicle(bicycle, false)

	setBicycleState(bicycle, state.dead)
end


-- don't let people get on to "dead" bicycles
addEventHandler("onVehicleStartEnter", root,
	function(player, seat, jacked, door)
		if (not bicycles[source]) or bicycles[source].state ~= state.dead then
			return
		end

		cancelEvent()
	end
)