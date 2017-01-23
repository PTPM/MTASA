local killer = getLocalPlayer()

function knifeRestrict(victim)
	
	-- A knife instakill is only allowed in some cases...
	
	-- 1) Distance between players < 1 meter
	vicX,vicY,vicZ = getElementPosition(victim)
	killerX,killerY,killerZ = getElementPosition(killer)
	if getDistanceBetweenPoints3D(vicX,vicY,vicZ, killerX,killerY,killerZ) > 1 then cancelEvent() end
	
	-- 2) Victim and killer must be facing same direction (killer is facing back of victim, with a 45° leniency)
	-- Not implemented
	
	-- 3) Victim must be standing still
	vicSpeedX, vicSpeedY, vicSpeedZ = getElementVelocity(victim)
	if math.sqrt(vicSpeedX^2 + vicSpeedY^2 + vicSpeedZ^2) > 1 then cancelEvent() end
	
	
	
end
addEventHandler("onClientPlayerStealthKill", getLocalPlayer(), knifeRestrict)