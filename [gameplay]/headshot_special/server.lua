function handleHeadshot(attacker, weapon, bodypart, loss)
	
	-- Regular sniper hits get just a hitsound
	if weapon==34 and bodypart~=9 then
		triggerClientEvent ( attacker, "playHitSound", attacker, false)
	end
	
	-- Actual sniper headshots
	if weapon==34 and bodypart==9 then
		cancelEvent()
		triggerClientEvent ( attacker, "playHitSound", attacker, true)
	
		if getPedArmor(source) > 0 then
			setPedArmor(source, 0)
		else
			killPed(source, attacker, weapon, 9)
			setPedHeadless(source, true)
		end
	end
end
addEventHandler("onPlayerDamage", root, handleHeadshot)


-- onPlayerDamage doesn't trigger if the damage kills the player, onPlayerWasted is called instead. 
addEventHandler( "onPlayerWasted", getRootElement(), function( ammo, attacker, weapon, bodypart )
	if weapon==34 and bodypart~=9 then
		triggerClientEvent ( attacker, "playHitSound", attacker, false)
	end
end )


function outputHeadshot(killer, weapon, bodypart)
	if weapon==34 and bodypart==9 then
		cancelEvent()
		local r2, g2, b2, a2 = exports.ptpm:getPlayerColour(killer)
		local r1, g1, b1, a1 = exports.ptpm:getPlayerColour(source)
		exports.killmessages:outputMessage({getPlayerName(killer), {"padding", width=3}, {"icon", id=weapon}, {"padding", width=3}, {"icon", id=256}, {"padding", width=3}, {"color", r=r1, g=g1, b=b1}, getPlayerName(source)}, getRootElement(), r2, g2, b2)
	end
end
addEventHandler("onPlayerKillMessage", root, outputHeadshot)

-- Give back the player's head regardless
addEventHandler ( "onPlayerSpawn", getRootElement(), function()
	setPedHeadless(source, false)
end )