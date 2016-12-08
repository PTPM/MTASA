function makeHeadshot(attacker, weapon, bodypart, loss)
	if weapon==34 and bodypart==9 then
		cancelEvent()
		outputDebugString("Headshot victim has armor value of " .. getPedArmor (source), 3)
	
		if getPedArmor(source) > 0 then
			outputDebugString("Headshot instakill false", 3)
			setPedArmor(source, 0)
		else
			outputDebugString("Headshot instakill true", 3)
			killPed(source, attacker, weapon, 9)
			setPedHeadless(source, true)
			setTimer(setPedHeadless, 900, 1, source, false)
		end
	end
end
addEvent("onClientsideHeadshot", true)
addEventHandler("onClientsideHeadshot", getRootElement(), makeHeadshot)
addEventHandler("onPlayerDamage", getRootElement(), makeHeadshot)

function outputHeadshot(killer, weapon, bodypart)
	if weapon==34 and bodypart==9 then
		cancelEvent()
		local r2, g2, b2, a2 = exports.ptpm:getPlayerColour(killer)
		local r1, g1, b1, a1 = exports.ptpm:getPlayerColour(source)
		exports.killmessages:outputMessage({getPlayerName(killer), {"padding", width=3}, {"icon", id=weapon}, {"padding", width=3}, {"icon", id=256}, {"padding", width=3}, {"color", r=r1, g=g1, b=b1}, getPlayerName(source)}, getRootElement(), r2, g2, b2)
	end
end
addEventHandler("onPlayerKillMessage", getRootElement(), outputHeadshot)
