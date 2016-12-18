local fireWeapons = {[18] = true, [37] = true} -- molotov, flame thrower
local rd = 50 -- required distance from spawn to get the weapons
local spawnX,spawnY = 0,0

function registerSpawnArea()
	spawnX, spawnY = getElementPosition(localPlayer)

	toggleFireControl()
end
addEventHandler("onClientPlayerSpawn", localPlayer, registerSpawnArea)

function toggleFireControl()
	if not getPlayerTeam(localPlayer) then 
		return 
	end

	local weapon = getPedWeapon(localPlayer)

	if getPedTotalAmmo(localPlayer) == 0 then
		return
	end

	local myPosX, myPosY = getElementPosition(localPlayer)

	if fireWeapons[weapon] and getDistanceBetweenPoints2D(spawnX, spawnY, myPosX, myPosY) < rd then
		toggleControl("fire", false)
	else
		if not isControlEnabled("fire") then
			toggleControl("fire", true)
		end
	end
end
addEventHandler("onClientPlayerWeaponSwitch", localPlayer, toggleFireControl)