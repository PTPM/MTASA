local fireWeapons = {18, 37} -- molotov, flame thrower
local rd = 50 -- required distance from spawn to get the weapons
local spawnX,spawnY = 0,0,0
local lastRequest = 0

local delayedWeapons = {}

function registerSpawnArea(posX, posY)
	spawnX,spawnY = getElementPosition(source)
end
addEventHandler("onClientPlayerSpawn", getRootElement(), registerSpawnArea)


function disabledWeaponsInSpawn(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if getPlayerTeam(localPlayer)==false then return end
	
	for k,v in pairs(fireWeapons) do
		if v==weapon then
			local myPosX,myPosY = getElementPosition(localPlayer)
			if getDistanceBetweenPoints2D(spawnX,spawnY,myPosX,myPosY) < rd and getTickCount()-lastRequest > 1000 then
				triggerServerEvent ( "removeWeaponEvent", resourceRoot, weapon )
				lastRequest = getTickCount()
			end
		end
	end
end

addEventHandler("onClientPlayerWeaponFire",  getRootElement(), disabledWeaponsInSpawn)
addEventHandler("onClientResourceStart", resourceRoot,
	function()
		outputDebugString("fire_annoyance started")
	end
)