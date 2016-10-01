-- Original author: "uhm" from the MTASA Community 
-- Date: 30 August 2016
-- Description: Check player state: if in water, lower FPS limit so player can swim faster.
-- Released under MIT License ©2016 uhm

addEvent( "getMinFPS", true )
addEventHandler( "getMinFPS", resourceRoot, function ( message )
	triggerClientEvent ( client, "setMinFPS", client, get("fpsLimitInWater"))
end )