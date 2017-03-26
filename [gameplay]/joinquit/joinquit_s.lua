addEventHandler ( "onPlayerQuit", getRootElement(), function(quitType, reason, responsibleElement)
	-- outputChatBox("JQ qt:" .. quitType .. " r:".. reason)

	if quitType=="Banned" or quitType=="Kicked" then
		
		responsibleName = getPlayerName(responsibleElement) or "Console"
		reason = reason or ""
		responsibilitySuffix = ""
		
		if responsibleName~="Console" then
			responsibilitySuffix = " by " .. responsibleName
		end
		
		for _, v in ipairs( getElementsByType( "player" ) ) do
			if v and isElement( v ) then
				outputChatBox('* ' .. getPlayerName(source) .. ' was ' .. quitType:lower() .. responsibilitySuffix .. '. (' .. reason .. ')', v, 255, 100, 100)
			end
		end
	
	end
end )

