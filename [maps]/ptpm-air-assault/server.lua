local colours = {
	psycho = { 255, 128, 0, 255, 128, 0 },
	terrorist = { 124, 27, 68, 124, 27, 68 },
	pm = { 215, 142, 16, 142, 140, 70 },
	bodyguard = { 46, 91, 32, 46, 91, 32 },
	police = { 14, 49, 109, 14, 49, 109 },
}

local fastTravelDist = 2000
local startTick = 0
local fastTimers = {}
local ptpmColour

local defaultColours = {}

addEventHandler("onResourceStart", resourceRoot,
	function()
		startTick = getTickCount()

		ptpmColour = exports.ptpm:getColour("ptpm") or {255, 0, 0}

		for _, v in ipairs(getElementsByType("vehicle")) do
			local r1, g1, b1, r2, g2, b2 = getVehicleColor(v, true)

			defaultColours[v] = {r1, g1, b1, r2, g2, b2}
		end		

		if isRunning("world_draw") then
			setTimer(
				function()
					for _, v in ipairs(getElementsByType("vehicle")) do
						exports.world_draw:attach3DDraw(v, "hb", "healthbar", nil, {"getVehicleOccupant"})
					end
				end,
			1000, 1)
		end
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		if isRunning("world_draw") then
			for _, v in ipairs(getElementsByType("vehicle")) do
				exports.world_draw:detach3DDraw(v, "hb")
			end
		end
	end
)

-- high priority so that we can read freshness before ptpm removes it
addEventHandler("onVehicleEnter", root,
	function(player, seat, jacked)
		local class = exports.ptpm:getPlayerClassType(player)

		if class and colours[class] then
			setVehicleColor(source, unpack(colours[class]))

			if class ~= "pm" and class ~= "psycho" and getElementData(source, "ptpm.vehicle.fresh") then
				-- attempt fast travel
				killFastTimer(player)

				-- 1min 30s for pm to get his shit together
				if fastTravelDist == 2000 and (getTickCount() - startTick) > 90000 then
					fastTravelDist = 800
				end

				local currentPM = exports.ptpm:getCurrentPM()

				if not currentPM then
					return
				end

				local x, y, z = getElementPosition(currentPM)
				--local x, y, z = 0, 0, 0
				local px, py, pz = getElementPosition(player)

				if getDistanceBetweenPoints3D(x, y, z, px, py, pz) <= fastTravelDist then
					return
				end

				fadeCamera(player, false, 2)
				exports.ptpm:sendGameText(player, "Travelling closer to\nthe Prime Minister...", 3000, ptpmColour, 2)
				fastTimers[player] = setTimer(travelToPM, 2000, 1, player, source)
			end
		end
	end,
true, "high")


addEventHandler("onVehicleRespawn", root,
	function()
		vehicleRespawned(source)
	end
)

addEventHandler("onVehicleIdleRespawn", root,
	function()
		vehicleRespawned(source)
	end
)

function vehicleRespawned(vehicle)
	if not defaultColours[vehicle] then
		return
	end
	
	setVehicleColor(vehicle, unpack(defaultColours[vehicle]))
end


function killFastTimer(player)
	if fastTimers[player] then
		if isTimer(fastTimers[player]) then
			killTimer(fastTimers[player])
			fadeCamera(player, true, 0)
		end

		fastTimers[player] = nil
	end
end

function travelToPM(player, originalVehicle)
	if player and isElement(player) then
		fadeCamera(player, true, 1)

		local vehicle = getPedOccupiedVehicle(player)

		if not vehicle or vehicle ~= originalVehicle then
			return
		end

		local currentPM = exports.ptpm:getCurrentPM()

		if not currentPM then
			return
		end

		local x, y, z = getElementPosition(currentPM)
		--local x, y, z = 0, 0, 0
		local px, py, pz = getElementPosition(player)

		local vx = px - x
		local vy = py - y

		local max = math.max(math.abs(vx), math.abs(vy))

		vx = vx / max
		vy = vy / max

		local randomOffset = math.random(0, 50) - 25
		local travelX = x + (vx * (fastTravelDist + randomOffset))
		local travelY = y + (vy * (fastTravelDist + randomOffset))

		local angle = (180 - math.deg(math.atan2(vx, vy))) % 360

		-- highest point in sa (chiliad) is around 526
		-- todo: maybe do some better height stuff, like detecting being over chiliad and only going really high then
		setElementPosition(vehicle, travelX, travelY, 540 + math.random(10, 60))
		setElementRotation(vehicle, 0, 0, angle)

		setElementVelocity(vehicle, (vx * -1) / 3, (vy * -1) / 3, 0)
	end	
end


addEventHandler("onPlayerWasted", root,
	function(ammo, killer, killerWeapon, bodypart, stealth)
		killFastTimer(source)
	end
)

addEventHandler("onVehicleExit", root,
	function(player, seat, jacker)
		killFastTimer(player)
	end
)

function isRunning(resourceName)
	local resource = getResourceFromName(resourceName)

	if resource then
		if getResourceState(resource) == "running" then
			return true
		end
	end

	return false
end