function serverLogEvent(freeText)
	triggerServerEvent ( "logDesyncEvent", resourceRoot , freeText )
end

-- 
local desyncDetected = false
local desyncDetectionTime = 0

function now()
	local t = getRealTime( )
	return t.timestamp
end

-- Check client weapon with server every 5s
setTimer(function()
	triggerServerEvent ( "getMyWeaponSlot", resourceRoot )
end, 5000, 0)

local delayedDesyncNotifierTimer = nil

-- Notify player of desync and log incident
addEvent( "returnMyWeaponSlot", true )
addEventHandler( "returnMyWeaponSlot", localPlayer, function ( serverClaim )
	local clientClaim = getPedWeaponSlot(localPlayer)
	
	if serverClaim~=clientClaim and not desyncDetected then
		
		-- Let's just set their weapon to what we think it is, that way the player can take appropriate measure
		setPedWeaponSlot ( localPlayer, serverClaim )
		
		outputDebugString("localPlayer weapon desync detected.")
		serverLogEvent("DESYNC START"  .. "¶" .. clientClaim .. "¶" .. serverClaim .. "¶")
		desyncDetected = true
		desyncDetectionTime = now()
		
		delayedDesyncNotifierTimer = setTimer(function()
			outputChatBox("Your weapon has been desynced for 15 seconds. You may need to type /reconnect", 230, 30, 30, false)
			delayedDesyncNotifierTimer = nil
		end, 15000, 1)
	
	elseif serverClaim==clientClaim and desyncDetected  then
		
		outputDebugString("localPlayer weapon desync resolved.")
		serverLogEvent("RESOLVED"  .. "¶" .. clientClaim .. "¶" .. serverClaim .. "¶" .. desyncDetectionTime)
		desyncDetected = false
		
		if isTimer(delayedDesyncNotifierTimer) then 
			-- The desync was short enough not to notify the player
			killTimer(delayedDesyncNotifierTimer) 
		else
			outputChatBox("Your weapon is synced again. You do not need to /reconnect", 230, 30, 30, false)
		end
	
	end
end )






