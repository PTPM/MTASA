local driver = false
local helpDisplay = {
	text = nil,
	animation = nil,
	animationTimer = nil,
	hideTimer = nil
}

previousWeaponSlot = 0
local drivebyActive = false
settings = {}

local firingStatus = {
	block = false,
	firing = false,
	continuousFireTimer = nil
}


--Tell the server the clientside script was downloaded and started
addEventHandler("onClientResourceStart", resourceRoot,
	function()
		bindKey("mouse2", "down", "Toggle Driveby", "")
		bindKey("e", "down", "Next driveby weapon", "1")
		bindKey("q", "down", "Previous driveby weapon", "-1")
		toggleControl("vehicle_next_weapon", false)
		toggleControl("vehicle_previous_weapon", false)

		triggerServerEvent("driveby_clientScriptLoaded", localPlayer)

		helpDisplay.text = dxText:create("", 0.5, 0.85)
		helpDisplay.text:scale(1)
		helpDisplay.text:type("stroke", 1)
	end
)


addEventHandler("onClientResourceStop", resourceRoot,
	function()
		toggleControl("vehicle_next_weapon", true)
		toggleControl("vehicle_previous_weapon", true)

		if drivebyActive then
			disableDriveby()
		end
	end
)


--Get the settings details from the server, and act appropriately according to them
addEvent("doSendDriveBySettings", true)
addEventHandler("doSendDriveBySettings", localPlayer,
	function(newSettings)
		settings = newSettings

		--We change the blocked vehicles into an indexed table that's easier to check
		local newTable = {}
		for key, vehicleID in ipairs(settings.blockedVehicles) do
			newTable[vehicleID] = true
		end
		settings.blockedVehicles = newTable	
	end
)


--This function simply sets up the driveby upon vehicle entry
local function setupDriveby(player, seat)
	--If his seat is 0, store the fact that he's a driver
	if seat == 0 then 
		driver = true
	else
		driver = false
	end
	--By default, we set the player's equiped weapon to nothing.
	setPedWeaponSlot(localPlayer, 0)

	if settings.autoEquip then
		toggleDriveby()
	end
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, setupDriveby)



--[[ slots:
	0 -- hand
	1 -- melee
	2 -- handguns
	3 -- shotguns
	4 -- submachine guns
	5 -- assault rifles
	6 -- rifles
	7 -- heavy weapons
	8 -- projectiles
	9 -- special 1 (spray, extinguisher, camera)
	10 -- gifts (cane, flowers, etc)
	11 -- special 2 (night vision, infrared, parachute)
	12 -- detonator
]]
function isValidSlot(slot) 
	-- valid slots: 2, 3, 4, 5, 6, 7
	return slot >= 2 and slot <= 7
end

function isAllowedSlot(slot, allowedWeapons)
	if not isValidSlot(slot) then
		return false
	end
	
	for _, weaponID in ipairs(allowedWeapons) do
		if getSlotFromWeapon(weaponID) == slot then
			return true
		end
	end	

	return false
end

function isAllowedWeapon(id, allowedWeapons)
	for _, weaponID in ipairs(allowedWeapons) do
		if weaponID == id then
			return true
		end
	end

	return false
end


--This function handles the driveby toggling key (turns driveby on and off)
function toggleDriveby()
	--If he's not in a vehicle dont bother
	if not isPedInVehicle(localPlayer) then 
		return
	end

	--If its a blocked vehicle dont allow it
	local vehicleID = getElementModel(getPedOccupiedVehicle(localPlayer))
	if settings.blockedVehicles[vehicleID] then 
		return 
	end

	if isPedDoingGangDriveby(localPlayer) or drivebyActive then
		disableDriveby()
	else
		enableDriveby()
	end
end
addCommandHandler("Toggle Driveby", toggleDriveby)

function enableDriveby()
	local allowedWeapons = settings.driver

	if (not driver) then 
		allowedWeapons = settings.passenger 
	end

	-- at this point we can assume we are currently on weapon slot 0
	--We need to get the nextValidSlot weapon by finding any valid IDs
	local nextValidSlot, nextValidWeapon
	local previousSlotAmmo = getPedTotalAmmo(localPlayer, previousWeaponSlot)

	-- use our previous one if it is valid
	if previousSlotAmmo and previousSlotAmmo > 0 and isAllowedSlot(previousWeaponSlot, allowedWeapons) then
		local previousWeapon = getPedWeapon(localPlayer, previousWeaponSlot)

		if previousWeapon > 0 and isAllowedWeapon(previousWeapon, allowedWeapons) then
			nextValidSlot = previousWeaponSlot
			nextValidWeapon = previousWeapon
		end
	end

	-- favour the submachine gun slot over everything else
	if not nextValidSlot then
		local smg = getPedWeapon(localPlayer, 4)

		if smg > 0 and isAllowedWeapon(smg, allowedWeapons) and getPedTotalAmmo(localPlayer, 4) > 0 then
			nextValidSlot = 4
			nextValidWeapon = smg
		end
	end

	-- previous weapon is invalid, find a new one
	if not nextValidSlot then
		nextValidSlot, nextValidWeapon = getNextDrivebyWeapon(0, allowedWeapons, 1)
	end

	--If a valid weapon was not found, dont set anything.
	if not nextValidSlot then 
		return 
	end

	drivebyActive = true

	setPedDoingGangDriveby(localPlayer, true)
	setPedWeaponSlot(localPlayer, nextValidSlot)

	--Setup our driveby limiter
	limitDrivebySpeed(nextValidWeapon)

	--Disable look left/right keys, they seem to become accelerate/decelerate (carried over from PS2 version)
	toggleControl("vehicle_look_left", false)
	toggleControl("vehicle_look_right", false)
	toggleControl("vehicle_secondary_fire", false)

	local vehicleID = getElementModel(getPedOccupiedVehicle(localPlayer))
	disableTurningKeys(vehicleID)

	-- getBoundKeys get a table of all the binds, next gets the first in the table
	local prevWeaponKey, nextWeaponKey = next(getBoundKeys("Previous driveby weapon")), next(getBoundKeys("Next driveby weapon"))
	if prevWeaponKey and nextWeaponKey then
		if animation then 
			Animation:remove() 
		end

		helpDisplay.text:text("Press '" .. prevWeaponKey .. "' or '" .. nextWeaponKey .. "' to change weapon")
		fadeHelpInOut(true)
		helpDisplay.hideTimer = setTimer(fadeHelpInOut, 10000, 1, false)
	end
end


function disableDriveby()
	if isPedDoingGangDriveby(localPlayer) then
		setPedDoingGangDriveby(localPlayer, false)
		setPedWeaponSlot(localPlayer, 0)
	end

	if not isControlEnabled("vehicle_look_left") then
		toggleControl("vehicle_look_left", true)
		toggleControl("vehicle_look_right", true)
		toggleControl("vehicle_secondary_fire", true)
	end

	toggleControl("vehicle_left", true)
	toggleControl("vehicle_right", true)

	fadeHelpInOut(false)

	removeDrivebySpeedLimit()

	drivebyActive = false
end

addEventHandler("onClientPlayerVehicleExit", localPlayer,
	function(vehicle, seat)
		if isPedDoingGangDriveby(localPlayer) or drivebyActive then
			disableDriveby()
		end
	end
)

addEventHandler("onClientVehicleStartExit", root,
	function(player, seat, door)
		if player ~= localPlayer then
			return
		end

		if isPedDoingGangDriveby(localPlayer) then
			disableDriveby()
		end
	end
)

addEventHandler("onClientPlayerWasted", localPlayer, 
	function()
		if isPedDoingGangDriveby(localPlayer) then
			disableDriveby()
		end	
	end
)


addEventHandler("onClientPlayerWeaponSwitch", localPlayer, 
	function(prevSlot, curSlot)
		if isPedDoingGangDriveby(localPlayer) then	
			limitDrivebySpeed(getPedWeapon(localPlayer, curSlot))
		end
	end
)

addEvent("onClientVehicleModelChange", true)
addEventHandler("onClientVehicleModelChange", resourceRoot,
	function(newModel)
		if drivebyActive then
			disableDriveby()
		end
	end
)


--This function handles the driveby switch weapon key
function switchDrivebyWeapon(key, direction)
	direction = tonumber(direction)
	if not direction then 
		return 
	end

	--If the fire button is being pressed dont switch
	if firingStatus.firing then 
		return 
	end

	--If he's not in a vehicle dont bother
	if (not isPedInVehicle(localPlayer)) or (not isPedDoingGangDriveby(localPlayer)) then 
		return 
	end

	local currentWeapon = getPedWeapon(localPlayer)
	local currentSlot = getPedWeaponSlot(localPlayer)

	local allowedWeapons = settings.driver

	if (not driver) then 
		allowedWeapons = settings.passenger 
	end

	local switchToSlot, switchToWeapon = getNextDrivebyWeapon(currentWeapon, allowedWeapons, direction)

	--If a valid weapon was not found, dont set anything.
	if not switchToSlot then 
		return
	end

	previousWeaponSlot = switchToSlot
	setPedWeaponSlot(localPlayer, switchToSlot)
	limitDrivebySpeed(switchToWeapon)
end
addCommandHandler("Next driveby weapon", switchDrivebyWeapon)
addCommandHandler("Previous driveby weapon", switchDrivebyWeapon)


-- allowedWeapons is a table (array) of allowed weapon ids, direction is 1 or -1
function getNextDrivebyWeapon(currentWeaponID, allowedWeapons, direction)
	if (not direction) or (not tonumber(direction)) then
		direction = 1
	end

	if (not isAllowedWeapon(currentWeaponID, allowedWeapons)) then
		currentWeaponID = 0
	end

	local currentIndex = 0

	for i, weaponID in ipairs(allowedWeapons) do
		if weaponID == currentWeaponID then
			currentIndex = i
			break
		end
	end

	for i = 0, #allowedWeapons - 1 do
		local nextIndex = ((i * direction) + currentIndex) % #allowedWeapons
		nextIndex = nextIndex + direction

		if nextIndex <= 0 then
			nextIndex = #allowedWeapons + nextIndex
		end

		local nextWeaponID = allowedWeapons[nextIndex]
		local slot = getSlotFromWeapon(nextWeaponID)
		local weapon = getPedWeapon(localPlayer, slot)

		if weapon == nextWeaponID and getPedTotalAmmo(localPlayer, slot) > 0 then
			return slot, weapon
		end
	end

	return
end




--Here lies the stuff that limits shooting speed (so slow weapons dont shoot ridiculously fast)
function limitDrivebySpeed(weaponID)
	local speed = settings.shotdelay[tostring(weaponID)]

	if not speed then 
		removeDrivebySpeedLimit()
	else
		if isControlEnabled("vehicle_fire") then 
			toggleControl("vehicle_fire", false)
			bindKey("vehicle_fire", "both", limitedKeyPress, speed)
		end
	end
end

function removeDrivebySpeedLimit()
	if not isControlEnabled("vehicle_fire") then 
		toggleControl("vehicle_fire", true)
	end

	unbindKey("vehicle_fire", "both", limitedKeyPress)

	-- if we get out of the vehicle while holding down fire, we need to forcibly clear the timer
	clearFiringStatus()
end


function limitedKeyPress(key, keyState, speed)
	if keyState == "down" then
		if firingStatus.block then 
			return 
		end

		firingStatus.firing = true		
		firingStatus.block = true

		pressKey("vehicle_fire")

		-- don't allow any firing for the next [speed] ms
		setTimer(
			function() 
				firingStatus.block = false 
			end, 
		speed, 1)

		firingStatus.continuousFireTimer = setTimer(pressKey, speed, 0, "vehicle_fire")
	else
		clearFiringStatus()
	end
end

function clearFiringStatus()
	firingStatus.firing = false

	if firingStatus.continuousFireTimer and isTimer(firingStatus.continuousFireTimer) then
		killTimer(firingStatus.continuousFireTimer)
	end

	firingStatus.continuousFireTimer = nil
end

function pressKey(controlName)
	setControlState(controlName, true)
	setTimer(setControlState, 50, 1, controlName, false)
end

---Left/right toggling
function disableTurningKeys(vehicleID)
	local vehicleType = getVehicleType(vehicleID)

	if (not vehicleType) or #vehicleType == 0 then
		return
	end

	if vehicleType == "Bike" or vehicleType == "BMX" then
		if not settings.steerBikes then
			toggleControl("vehicle_left", false)
			toggleControl("vehicle_right", false)
		end
	else
		if not settings.steerCars then
			toggleControl("vehicle_left", false)
			toggleControl("vehicle_right", false)
		end
	end
end
	

function fadeHelpInOut(fadingIn)
	removeHelp()

	local _, _, _, a = helpDisplay.text:color()

	-- are we already in the state we want to be in?
	if (fadingIn and a == 255) or ((not fadingIn) and a == 0) then 
		return 
	end

	if fadingIn then
		helpDisplay.animation = Animation.createAndPlay(helpDisplay.text, Animation.presets.dxTextFadeIn(300))
	else
		helpDisplay.animation = Animation.createAndPlay(helpDisplay.text, Animation.presets.dxTextFadeOut(300))
	end

	helpDisplay.animationTimer = setTimer(
		function()
			helpDisplay.text:color(255, 255, 255, fadingIn and 255 or 0) 
		end,
	300, 1)
end

function removeHelp()
	if helpDisplay.animation then
		helpDisplay.animation:remove()
	end

	if helpDisplay.animationTimer and isTimer(helpDisplay.animationTimer) then
		killTimer(helpDisplay.animationTimer)
		helpDisplay.animationTimer = nil
	end

	if helpDisplay.hideTimer and isTimer(helpDisplay.hideTimer) then
		killTimer(helpDisplay.hideTimer)
		helpDisplay.hideTimer = nil
	end
end