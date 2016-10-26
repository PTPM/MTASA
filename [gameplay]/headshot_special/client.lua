function clientHeadshot(attacker, weapon, bodypart, loss)
	if attacker == getLocalPlayer() then
		if bodypart == 9 then
			triggerServerEvent("onClientsideHeadshot", source, attacker, weapon, bodypart, loss)
		end
	end
end
addEventHandler("onClientPlayerDamage", getRootElement(), clientHeadshot)
