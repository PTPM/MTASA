-- Original author: "uhm" from the MTASA Community 
-- Date: 30 August 2016
-- Description: Check player state: if in water, lower FPS limit so player can swim faster.
-- Released under MIT License ©2016 uhm

local maxFPS = getFPSLimit() 	--get regular FPS limit, might be 100 (strafing is glitched), might be 60 (recommended), might be 36 (mta default)
local minFPS = 25 				--initial value, will be adjusted
local timerChecker = 500		--parameter for client performance

local rootElement = getRootElement()
local cachedState = isElementInWater(localPlayer)

-- Send request to get server defined FPS Limit in water
triggerServerEvent ( "getMinFPS", resourceRoot )

addEvent( "setMinFPS", true )
addEventHandler( "setMinFPS", localPlayer, function ( fpsValue )
    outputDebugString( "MinFPS is set to " .. fpsValue .. " by server")
	minFPS = fpsValue
end )

-- Check periodically if player is in water
-- State is cached, so setFPSLimit is not called every 500ms
addEventHandler ("onClientResourceStart", resourceRoot, function()
	setTimer(function()	
		local stateNow = isElementInWater( localPlayer )
		if cachedState ~= stateNow then
			if stateNow then
				outputDebugString( "Water! " .. minFPS .." fps")
				setFPSLimit( minFPS )
				cachedState = stateNow
			 else 
				outputDebugString( "Dry! " .. maxFPS .." fps")
				setFPSLimit( maxFPS )
				cachedState = stateNow
			 end
		end
	end, timerChecker, 0 )
end) 