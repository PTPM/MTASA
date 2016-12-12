function handleIncomingStrategyRadialCommand(command, text, x, y, z)
	if isPlayerMuted( client ) then
		outputChatBox( "You are muted.", client, unpack( colourPersonal ) )
		return
	end
	
	if spam.resource and getResourceState(spam.resource) == "running" then
		local allow, wasPunished = exports.antiflood:shouldAllowMessage(client)
		if not allow then
			return
		end
	end
	
	sendTeamChatMessage( client, text )
end


addEvent( "ptpmStrategyRadialRelay", true )
addEventHandler( "ptpmStrategyRadialRelay", resourceRoot, handleIncomingStrategyRadialCommand )