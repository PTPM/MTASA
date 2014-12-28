local specs = {}

function spectateStart( player, target, savePos )
	triggerClientEvent( player, "spectateStart", player, target, savePos )
	specs[player] = true
end


function spectateStop( player, ignoreSaves )
	triggerClientEvent( player, "spectateStop", player, ignoreSaves )
	specs[player] = false
end	


function setTarget( player, target )
	triggerClientEvent( player, "setTarget", player, target )
end


function setSpectateList( player, list )
	triggerClientEvent( player, "setSpectateList", player, list )
end


function isPlayerSpectating( player )
	return specs[player]
end


addEventHandler( "onPlayerQuit", root,
	function()
		specs[source] = nil
	end
)


addEvent( "specinfotest", true )
addEventHandler( "specinfotest", root,
	function( tar )
		outputChatBox( "(s) Target: " .. tostring( getElementDimension( tar ) ) .. ", " .. tostring( getElementInterior( tar ) ), client )
		outputChatBox( "(s) Local: " .. tostring( getElementDimension( client ) ) .. ", " .. tostring( getElementInterior( client ) ) .. ", " .. tostring( getCameraInterior( client ) ), client )
	end
)