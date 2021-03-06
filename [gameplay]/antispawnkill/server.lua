antispawnkill = {}
antispawnkill.Time = get("time") or 5
antispawnkill.Opacity = get("opacity") or 175
antispawnkill.Table = {}

timerTable = {}

addEventHandler("onSettingChange", getRootElement(), function(setting, oldV, newV)
	local resName = getResourceName(getThisResource())
	if setting == "*"..resName..".time" then
		antispawnkill.Time = newV
	elseif setting == "*"..resName..".opacity" then
		antispawnkill.Opacity = newV
	end
end)

function removePlayerInvulnerability(player)
	if isTimer(timerTable[player]) then killTimer(timerTable[player]) end
	
	if player and isElement(player) then
		setElementAlpha(player, 255)
		setElementData(player, "antispawnkill", false)
		antispawnkill.Table[player] = false
		return true
	end
	return false
end

addEventHandler("onPlayerSpawn", getRootElement(), function()
	if getElementDimension(source) == 0 then
		antispawnkill.Table[source] = true
		setElementAlpha(source, antispawnkill.Opacity)
		setElementData(source, "antispawnkill", true)
		timerTable[source] = setTimer(removePlayerInvulnerability, ((antispawnkill.Time)*1000), 1, source)
	end
end)

addEventHandler("onPlayerStealthKill", getRootElement(), function(player)
	if getElementData(player, "antispawnkill") then
		cancelEvent()
	end
end)


addEventHandler ( "onPlayerDamage", getRootElement (), function( attacker, weapon, bodypart, loss ) 
	if attacker and getElementData(attacker, "antispawnkill") then
		removePlayerInvulnerability(attacker)
	end
end)

