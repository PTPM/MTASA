local playerPingWarnings = {}
local pingLimit = 700
local maxPingWarnings = 3

function kickPing()
	for i, player in ipairs(getElementsByType("player")) do
		local playerPing = getPlayerPing(player)
		if (playerPing > pingLimit) then
		
			if playerPingWarnings[player] then
				playerPingWarnings[player] = playerPingWarnings[player] + 1
			else 
				playerPingWarnings[player] = 1
			end
		
			if playerPingWarnings[player] < maxPingWarnings then
				outputChatBox( "Your ping is too high, and you will be kicked.", player, 255, 25, 25, true )
			else
				kickPlayer(player, "Your ping is too high (measured: " .. playerPing .. ", limit: ".. pingLimit ..")")
			end
		end
	end
end
setTimer(kickPing, 10000, 0)

-- Reset ping warnings each map start
addEventHandler( "onGamemodeMapStart", root, function() 
	playerPingWarnings = {}
end )