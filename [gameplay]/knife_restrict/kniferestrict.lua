﻿function normalizeAngles(degrees)
	degrees = degrees % 360
	if degrees < 360 then
		degrees = degrees + 360
	end
	return degrees
end

function knifeRestrict(victim)
	-- for readability:
	local killer = source
	
	-- A knife instakill is only allowed in some cases...
	
	-- 1) Distance between players < 1 meter
	vicX,vicY,vicZ = getElementPosition(victim)
	killerX,killerY,killerZ = getElementPosition(killer)
	if getDistanceBetweenPoints3D(vicX,vicY,vicZ, killerX,killerY,killerZ) > 1 then 
		outputDebugString(getPlayerName(killer) .. " Knife kill prevented: distance too big", 1)
		cancelEvent() 
	end
	
	-- 2) Victim and killer must be facing same direction (killer is facing back of victim, with a 45° leniency)
	-- Not implemented
	_,_,vicRot = getElementRotation(victim)
	_,_,killerRot = getElementRotation(killer)
	
	local minKillerAngle = normalizeAngles(vicRot - 90)
	local maxKillerAngle = normalizeAngles(vicRot + 90)
	
	if killerRot < minKillerAngle or killerRot > maxKillerAngle then
		outputDebugString(getPlayerName(killer) .. " Knife kill prevented: killerRot " .. killerRot .. " not in range of vicRot " .. vicRot , 1)
		cancelEvent()
	end
	
	-- 3) Victim must be standing still
	vicSpeedX, vicSpeedY, vicSpeedZ = getElementVelocity(victim)
	if math.sqrt(vicSpeedX^2 + vicSpeedY^2 + vicSpeedZ^2) > 1 then 
		outputDebugString(getPlayerName(killer) .. " Knife kill prevented: vic not standing still", 1)
		cancelEvent() 
	end
	
	
	
end
addEventHandler("onPlayerStealthKill", getRootElement(), knifeRestrict)