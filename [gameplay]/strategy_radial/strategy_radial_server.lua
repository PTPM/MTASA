local resource = {
	ptpm = getResourceFromName("ptpm"),
	spam = getResourceFromName("antiflood"),
}

function handleIncomingStrategyRadialCommand(command, text, x, y, z)
	if isPlayerMuted( client ) then
		outputChatBox( "You are muted.", client, 128, 128, 255 ) --ptpm.colourPersonal
		return
	end
	
	if resource.spam and getResourceState(resource.spam) == "running" then
		local allow, wasPunished = exports.antiflood:shouldAllowMessage(client)
		if not allow then
			return
		end
	end
	
	if resource.ptpm and getResourceState(resource.ptpm) == "running" then
		exports.ptpm:sendTeamChatMessage( client, text )
	else
		outputChatBox (getPlayerName(client) ..  ":#FFFFFF " .. text, getRootElement(), unpack(getPlayerNametagColor(client)), true )
	end
end

addEventHandler("onResourceStart", root,
	function(theResource)
		if getResourceName(theResource) == "ptpm" then
			resource.ptpm = theResource
		elseif getResourceName(theResource) == "antiflood" then
			resource.spam = theResource
		end
	end
)


addEvent( "ptpmStrategyRadialRelay", true )
addEventHandler( "ptpmStrategyRadialRelay", resourceRoot, handleIncomingStrategyRadialCommand )