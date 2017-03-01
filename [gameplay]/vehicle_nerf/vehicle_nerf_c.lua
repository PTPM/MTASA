---------------------------------------------
-- VEHICLE NERFING
---------------------------------------------
local limitedVehicles = {}

triggerServerEvent ( "getLimitedVehiclesInfo", resourceRoot )
addEvent( "setLimitedVehiclesInfo", true )
addEventHandler( "setLimitedVehiclesInfo", localPlayer, function ( limitedVehiclesTable )
	limitedVehicles = limitedVehiclesTable
end )


---------------------------------------------
-- VARS AND CONFIG
---------------------------------------------

screenX,screenY = guiGetScreenSize()

local uiScale = screenY / 600
local font = {
	globalScalar = 1
}

local colours = {
	mint = tocolor(229, 255, 236, 100),
	loadedGreen = tocolor(32, 199, 40, 100),
	white = tocolor(255, 255, 255, 255),
}

local reloadWeaponsHudElement = {
	-- Configurable:
	x = screenX * 0.5,
	y = screenY * 0.4,
	radius = 25,
	reloaderDots = 360,
	fontSize = 0.5,
	timeBetweenUpdate = 50,
	
	-- Properties (set dynamically):
	dotsPerUpdate = 0,
	weaponChargedDots = 0,
	step = 0,
	repetitions = 0,
	timeBetweenSteps = 0,
	hidden = true
}

local firingStatus = {
	block = false,
	firing = false,
	continuousFireTimer = nil
}

local vehicleNerfActive = false
local laggardTimerOverwriteMe = nil
local prerenderEventHandled = false
local currentAssaultVehicle = nil

---------------------------------------------
-- UTILITY FUNCTIONS
---------------------------------------------

function sf_(value)
	return ((value * uiScale) / font.scalar)
end

function s(value)
	return value * uiScale
end

function getPointOnCircle(radius, rotation)
	return radius * math.cos(math.rad(rotation)), radius * math.sin(math.rad(rotation))
end

function dxDrawChargingDot(x,y,colour,size)
	local text = "•"
	dxDrawText(text,x,y,x,y,colour,size, font.base, "center", "center", false, false, false, true, false )
end

function drawWeaponReloaderHUD()
	if currentAssaultVehicle==nil then return end

	dxDrawText( getElementData(currentAssaultVehicle,"vehAmmo") , reloadWeaponsHudElement.x,reloadWeaponsHudElement.y,reloadWeaponsHudElement.x,reloadWeaponsHudElement.y,colours.white,sf_(1),font.base, "center","center", false, false, false, true, false)

	for i = 0,reloadWeaponsHudElement.reloaderDots do
		relX,relY = getPointOnCircle(s(reloadWeaponsHudElement.radius), ((i) * reloadWeaponsHudElement.step) - 90)		
		local colorOfDot = colours.loadedGreen
		
		if i>reloadWeaponsHudElement.weaponChargedDots then
			colorOfDot = colours.mint
		end
		
		dxDrawChargingDot(relX+reloadWeaponsHudElement.x,relY+reloadWeaponsHudElement.y,colorOfDot, sf_(reloadWeaponsHudElement.fontSize))
	end
end

function drawOutOfAmmoHUD()
	if currentAssaultVehicle==nil then return end
	
	dxDrawText( "0" , reloadWeaponsHudElement.x,reloadWeaponsHudElement.y,reloadWeaponsHudElement.x,reloadWeaponsHudElement.y,colours.white,sf_(1),font.base, "center","center", false, false, false, true, false)
	
	for i = 0,reloadWeaponsHudElement.reloaderDots do
		relX,relY = getPointOnCircle(s(reloadWeaponsHudElement.radius), ((i) * reloadWeaponsHudElement.step) - 90)			
		dxDrawChargingDot(relX+reloadWeaponsHudElement.x,relY+reloadWeaponsHudElement.y,colours.mint, sf_(reloadWeaponsHudElement.fontSize))
	end
end

---------------------------------------------
-- CORE FUNCTIONS
---------------------------------------------
function handleLaggardTimer()
	if not isTimer(firingStatus.continuousFireTimer) then	
		removeEventHandler("onClientRender", root, drawWeaponReloaderHUD)
		reloadWeaponsHudElement.hidden = true
	end
end


function startReloaderHUD(timeTotal)
	if isTimer(laggardTimerOverwriteMe) then killTimer(laggardTimerOverwriteMe) end

	reloadWeaponsHudElement.weaponChargedDots = 0
	reloadWeaponsHudElement.step = 360 / reloadWeaponsHudElement.reloaderDots
	reloadWeaponsHudElement.repetitions = timeTotal/reloadWeaponsHudElement.timeBetweenUpdate
	reloadWeaponsHudElement.timeBetweenSteps = reloadWeaponsHudElement.timeBetweenUpdate * reloadWeaponsHudElement.step
	reloadWeaponsHudElement.dotsPerUpdate = reloadWeaponsHudElement.reloaderDots / reloadWeaponsHudElement.repetitions
	
	
	-- Timer for updating the radial visual
	setTimer(function()  
		reloadWeaponsHudElement.weaponChargedDots = reloadWeaponsHudElement.weaponChargedDots+reloadWeaponsHudElement.dotsPerUpdate 
	end, reloadWeaponsHudElement.timeBetweenSteps, reloadWeaponsHudElement.repetitions)
	
	-- Timer for removing the visual
	laggardTimerOverwriteMe = setTimer(handleLaggardTimer, timeTotal + 500, 1)
	
	-- Add the visual to the screenX
	if reloadWeaponsHudElement.hidden then
		addEventHandler("onClientRender", root, drawWeaponReloaderHUD)
		reloadWeaponsHudElement.hidden = false
	end
end

function pressKey(controlName)
	setControlState(controlName, true)
	setTimer(setControlState, 50, 1, controlName, false)
end

function limitedKeyPress(key, keyState, speed)
	-- Apparently this function doesn't always get unbound correctly despite all the listed events
	-- so an additional check is needed
	if currentAssaultVehicle==nil or getElementData(currentAssaultVehicle,"vehNerfed")==false then
		leftAssaultVehicle(vehicle)
		return
	end
	
	if keyState == "down" then
		if firingStatus.block then 
			return 
		end

		firingStatus.firing = true		
		firingStatus.block = true

		-- Manage ammo
		if getElementData(currentAssaultVehicle,"vehAmmo") > 0 then
			
			pressKey(key)
			startReloaderHUD(speed)
			setElementData(currentAssaultVehicle,"vehAmmo", getElementData(currentAssaultVehicle,"vehAmmo") - 1, false) 
			
		else
			-- Play "out of ammo" sound and display "0" where the ammo count goes
			playSoundFrontEnd(42)
			addEventHandler("onClientRender", root, drawOutOfAmmoHUD)
			
			setTimer(function()
				removeEventHandler("onClientRender", root, drawOutOfAmmoHUD)
			end, 500, 1)
			
		end

		-- don't allow any firing for the next [speed] ms
		setTimer(
			function() 
				firingStatus.block = false 
			end, 
		speed, 1)

	end
end


function enterAssaultVehicle(vehicle)
	--outputDebugString("Entered restricted vehicle")
	currentAssaultVehicle = vehicle
	
	if not getElementData(vehicle, "vehNerfed") then
		initializeVehicleNerf(vehicle)
	end
		
	local vehReloadTime = getElementData(vehicle, "vehReload")
	local vehFireControl = getElementData(vehicle, "vehControl")
	
	if vehReloadTime and vehFireControl then
		for _,v in ipairs(vehFireControl) do
			toggleControl(v, false)
			bindKey(v, "both", limitedKeyPress, vehReloadTime)
		end
	end
end

function leftAssaultVehicle(vehicle)
	if not currentAssaultVehicle then return end
	
	local vehFireControl = getElementData(currentAssaultVehicle, "vehControl")

	if vehFireControl then
		for _,key in ipairs(vehFireControl) do
			toggleControl(key, true)
			unbindKey(key, "both", limitedKeyPress)
		end
	end
	
	currentAssaultVehicle = nil
end

function initializeVehicleNerf(vehicle)

	local vehId = getElementModel(vehicle)
	if limitedVehicles[vehId] then
		setElementData(vehicle, "vehAmmo", limitedVehicles[vehId].ammo, false)
		setElementData(vehicle, "vehReload", limitedVehicles[vehId].reloadTime, false)
		setElementData(vehicle, "vehControl", limitedVehicles[vehId].blockedControls, false)
		setElementData(vehicle, "vehNerfed", true, false)
	end

end



---------------------------------------------
-- BINDING
---------------------------------------------
function justPunchItAgain()
	local actualCurrentVehicle = getPedOccupiedVehicle(localPlayer)
	if not actualCurrentVehicle then 
		leftAssaultVehicle()
		return 
	end
	
	local vehId = getElementModel(actualCurrentVehicle)
	if limitedVehicles[vehId] then
		enterAssaultVehicle(actualCurrentVehicle)
	else
		leftAssaultVehicle()
	end
end

addEventHandler("onClientVehicleEnter", getRootElement(), 
	function ( thePlayer, seat ) 
		local vehId = getElementModel(source)
		if limitedVehicles[vehId] then
			enterAssaultVehicle(source)
		end
	end
)

-- Well, sometimes apparently neither onClientVehicleEnter (or onVehicleEnter) gets called, so just as a little backup...
setTimer(function()
	justPunchItAgain()
end , 5000, 0)


---------------------------------------------
-- UTILITY EVENTS
---------------------------------------------
addEventHandler("onClientResourceStart", resourceRoot,
	function()
		--outputDebugString("vehicle_nerf loaded")
	
		font.scalar = (120 / 44) * uiScale
		font.scalar = (120 / 44) * uiScale
		font.base = dxCreateFont("tahoma.ttf", 9 * font.scalar, false, "proof")

		if not font.base then
			font.base = "default"
			font.scalar = 1
		end				
	end
)


---------------------------------------------
-- UNBINDING (courtesy of realdriveby)
---------------------------------------------
-- ways to leave a vehicle: player death, vehicle death, removePedFromVehicle, spawnPlayer, normal exit, being jacked, vehicle element being destroyed

-- triggers if you leave normally, if you warp out (removePedFromVehicle) or if you get jacked
addEventHandler("onClientPlayerVehicleExit", localPlayer,
	function(vehicle, seat)
		if currentAssaultVehicle~=nil then
			leftAssaultVehicle()
		end
	end
)

-- seems like mta automatically cancels driveby when you get jacked
-- (but only on the jackers side, other guy still sees driveby, so it desyncs them)
-- cancel it ourselves here so the sync stays correct
addEventHandler("onClientVehicleStartExit", root,
	function(player, seat, door)
		if player ~= localPlayer then
			return
		end

		if currentAssaultVehicle~=nil then
			leftAssaultVehicle()
		end
	end
)


-- catches when the player dies inside the vehicle
addEventHandler("onClientPlayerWasted", localPlayer, 
	function()
		if currentAssaultVehicle~=nil then
			leftAssaultVehicle()
		end	
	end
)


addEvent("onClientVehicleModelChange", true)
addEventHandler("onClientVehicleModelChange", resourceRoot,
	function(newModel)
		if currentAssaultVehicle~=nil then
			leftAssaultVehicle()
		end
	end
)

-- handles if the vehicle is destroyed with destroyElement
addEventHandler("onClientElementDestroy", root,
	function()
		if currentAssaultVehicle~=nil then
			if source == getPedOccupiedVehicle(localPlayer) then
				leftAssaultVehicle()
			end
		end
	end
)

-- handles spawnPlayer being used while drivebying
addEventHandler("onClientPlayerSpawn", localPlayer,
	function(team)
		if currentAssaultVehicle~=nil then
			leftAssaultVehicle()
		end		
	end
)
