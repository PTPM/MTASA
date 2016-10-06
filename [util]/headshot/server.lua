headshot = {}
headshot.allowedWeapons = get("allowedWeapons") or {"34","33"}

addEventHandler("onSettingChange", getRootElement(), function(setting, oldV, newV)
	local resName = getResourceName(getThisResource())
	if setting == "*"..resName..".allowedWeapons" then
		headshot.allowedWeapons = newV
	end
end)

function findNumber(table, number)
	for i, num in ipairs(table) do
		if tonumber(num) == tonumber(number) then
			return true
		end
	end
	return false
end

function makeHeadshot(attacker, weapon, bodypart, loss)
	if findNumber(headshot.allowedWeapons, weapon) then
		killPed(source, attacker, weapon, 9)
		setPedHeadless(source, true)
		setTimer(setPedHeadless, 900, 1, source, false)
	end
end
addEvent("onClientsideHeadshot", true)
addEventHandler("onClientsideHeadshot", getRootElement(), makeHeadshot)
addEventHandler("onPlayerDamage", getRootElement(), makeHeadshot)

function outputHeadshot(killer, weapon, bodypart)
	if bodypart == 9 and findNumber(headshot.allowedWeapons, weapon) then
		cancelEvent()
		local r2, g2, b2 = getTeamColor(getPlayerTeam(killer))
		local r1, g1, b1 = getTeamColor(getPlayerTeam(source))
		exports.killmessages:outputMessage({getPlayerName(killer), {"padding", width=3}, {"icon", id=weapon}, {"padding", width=3}, {"icon", id=256}, {"padding", width=3}, {"color", r=r1, g=g1, b=b1}, getPlayerName(source)}, getRootElement(), r2, g2, b2)
	end
end
addEventHandler("onPlayerKillMessage", getRootElement(), outputHeadshot)


addCommandHandler("c", function(player,cmd)
	local x, y, z = getElementPosition(player)
	createPed(0, x, y, z)
end)