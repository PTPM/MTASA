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
	x = screenX * 0.5,
	y = screenY * 0.4,
	radius = 25,
	reloaderDots = 360,
	fontSize = 0.5,
	timeBetweenUpdate = 50,
	
	dotsPerUpdate = 0,
	weaponChargedDots = 0,
	step = 0,
	repetitions = 0,
	timeBetweenSteps = 0,
	hidden = true
}

local currentVehId = 0
local currentVehAmmo = 0
local shotsBeingBlocked = false
local laggardTimerOverwriteMe = nil
local prerenderEventHandled = false

local limitedVehicles = {
	[520] = {
		ammo = 50,
		reload = 2500,
		name = "Hydra",
		countPrimary = false,
		countSecondary = true
	},
	[432] = {
		ammo = 100,
		reload = 1000,
		name = "Rhino",
		countPrimary = true,
		countSecondary = false
	},
}

function sf_(value)
	return ((value * uiScale) / font.scalar)
end

function s(value)
	return value * uiScale
end

function getPointOnCircle(radius, rotation)
	return radius * math.cos(math.rad(rotation)), radius * math.sin(math.rad(rotation))
end

function drawAbilityOverlay()
		
	-- Calculate the absolute position of SmartCommands if not done already
	for i = 0,reloadWeaponsHudElement.reloaderDots do
		relX,relY = getPointOnCircle(s(reloadWeaponsHudElement.radius), ((i) * reloadWeaponsHudElement.step) - 90)		
		local colorOfDot = colours.loadedGreen
		
		if i>reloadWeaponsHudElement.weaponChargedDots then
			colorOfDot = colours.mint
		end
		
		if not reloadWeaponsHudElement.hidden then
			dxDrawText(currentVehAmmo, reloadWeaponsHudElement.x,reloadWeaponsHudElement.y,reloadWeaponsHudElement.x,reloadWeaponsHudElement.y,colours.white,sf_(1),font.base, "center","center", false, false, false, true, false)
			dxDrawChargingDot(relX+reloadWeaponsHudElement.x,relY+reloadWeaponsHudElement.y,colorOfDot, sf_(reloadWeaponsHudElement.fontSize))
		end
	end
end


addEventHandler("onClientRender", root, drawAbilityOverlay)

function dxDrawChargingDot(x,y,colour,size)
	local text = "•"
	dxDrawText(text,x,y,x,y,colour,size, font.base, "center", "center", false, false, false, true, false )
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		outputDebugString("vehicle_weapons loaded")
	
		font.scalar = (120 / 44) * uiScale
		-- the default fonts do not scale well, so load our own version at the sizes we need
		font.scalar = (120 / 44) * uiScale
		font.base = dxCreateFont("tahoma.ttf", 9 * font.scalar, false, "proof")

		-- if the user cannot load the font, default to a built-in one with the appropriate scaling
		if not font.base then
			font.base = "default"
			font.scalar = 1
		end				
	end
)

function removeVehicleFire(timeTotal)

	local theVeh = getPedOccupiedVehicle(getLocalPlayer())

	if isTimer(laggardTimerOverwriteMe) then killTimer(laggardTimerOverwriteMe) end

	toggleControl ( "vehicle_fire", false )
	toggleControl ( "vehicle_secondary_fire", false )

	reloadWeaponsHudElement.weaponChargedDots = 0
	reloadWeaponsHudElement.step = 360 / reloadWeaponsHudElement.reloaderDots
	reloadWeaponsHudElement.repetitions = timeTotal/reloadWeaponsHudElement.timeBetweenUpdate
	reloadWeaponsHudElement.timeBetweenSteps = reloadWeaponsHudElement.timeBetweenUpdate * reloadWeaponsHudElement.step
	reloadWeaponsHudElement.dotsPerUpdate = reloadWeaponsHudElement.reloaderDots / reloadWeaponsHudElement.repetitions
	reloadWeaponsHudElement.hidden = false
	
	-- Subtract vehicle ammo
	currentVehAmmo = currentVehAmmo - 1
	setElementData(theVeh, "vehAmmo", currentVehAmmo)
	
	if currentVehAmmo > 0 then 
		-- Timer for updating the visual
		setTimer(function()  
			reloadWeaponsHudElement.weaponChargedDots = reloadWeaponsHudElement.weaponChargedDots+reloadWeaponsHudElement.dotsPerUpdate 
		end, reloadWeaponsHudElement.timeBetweenSteps, reloadWeaponsHudElement.repetitions)
		
		-- Timer for actually allowing back controls
		setTimer(function()  
			toggleControl ( "vehicle_fire", true )
			toggleControl ( "vehicle_secondary_fire", true )
			laggardTimerOverwriteMe = setTimer(function()  reloadWeaponsHudElement.hidden = true end, 250, 1)
			shotsBeingBlocked = false
		end , timeTotal, 1)
	
	else
		outputChatBox ( "This " .. getVehicleNameFromModel(currentVehId) .. " has no ammo left.", 255, 0, 0 )
		reloadWeaponsHudElement.hidden = true
	end
end

function limitVehicleFire()
	if getControlState("vehicle_fire") or getControlState("vehicle_secondary_fire") then
		outputDebugString("Shots fired")
		if limitedVehicles[currentVehId] and not shotsBeingBlocked then
			shotsBeingBlocked = true
			outputDebugString("Blocking new shots for " ..limitedVehicles[currentVehId].reload.. "ms")
			removeVehicleFire(limitedVehicles[currentVehId].reload)
		end
	end
end

function removeVehicleNerf()
	reloadWeaponsHudElement.hidden = true
	prerenderEventHandled = false
	removeEventHandler ( "onClientPreRender", getRootElement(), limitVehicleFire )
	toggleControl ( "vehicle_fire", true )
	toggleControl ( "vehicle_secondary_fire", true )
	currentVehId = 0
end

addEventHandler("onClientVehicleEnter", getRootElement(),
	function ( thePlayer, seat )
		reloadWeaponsHudElement.hidden = true
		currentVehId = getElementModel(source)
		
		outputDebugString("Enter veh")
		
		if limitedVehicles[currentVehId] then
			outputDebugString("Enter restricted veh")
			
			if not getElementData(source, "vehAmmo") then
				outputDebugString("This veh had NO ammo, set to: " .. limitedVehicles[currentVehId].ammo)
				setElementData(source, "vehAmmo", limitedVehicles[currentVehId].ammo)
			end
			
			currentVehAmmo = getElementData(source, "vehAmmo")
			
			if currentVehAmmo==0 then
				shotsBeingBlocked = true
				toggleControl ( "vehicle_fire", false )
				toggleControl ( "vehicle_secondary_fire", false )
				outputChatBox ( "This " .. getVehicleNameFromModel(currentVehId) .. " has no ammo left.", 255, 0, 0 )
			else			
				shotsBeingBlocked = false
				prerenderEventHandled = true
				addEventHandler ( "onClientPreRender", getRootElement(), limitVehicleFire )
			end
		end
	end
)

addEventHandler("onClientVehicleExit", getRootElement(),removeVehicleNerf)
addEventHandler("onClientPlayerWasted", getLocalPlayer(), removeVehicleNerf)

setTimer(function() 
	-- Let's check every 2s if player is still in a vehicle, since it's pretty resource heavy
	if prerenderEventHandled then	
		local theVeh = getPedOccupiedVehicle(getLocalPlayer()) 
		if not theVeh then 
			removeVehicleNerf()
		end
	end
end, 2000, 0)
