local playerPingWarnings = {}
local pingLimit = 700
local maxPingWarnings = 3

function isRunning(resourceName)
	local resource = getResourceFromName(resourceName)
	if resource then
		if getResourceState(resource) == "running" then
			return true
		end
	end
	return false
end

function kickPing()
	for i, player in ipairs(getElementsByType("player")) do
		local playerPing = getPlayerPing(player)
		if (playerPing > pingLimit) then
		
			if playerPingWarnings[player] then
				playerPingWarnings[player] = playerPingWarnings[player] + 1
			else 
				playerPingWarnings[player] = 1
			end
		
			if playerPingWarnings[player] <= maxPingWarnings then		
				if isRunning("ptpm") then
					exports.ptpm:sendGameText(player, "Your ping is " .. playerPing .. ", that's too high!\nPing limit: " .. pingLimit .. "\nYou will be kicked, unless you fix it.", 6000, {255, 0, 0}, 3, 1.3)
				else
					outputChatBox( "Your ping is too high and you will be kicked, unless you fix it. (measured: " .. playerPing .. ", limit: ".. pingLimit ..")", player, 255, 0, 0, true )
				end
			else
				kickPlayer(player, "Ping too high (measured: " .. playerPing .. ", limit: ".. pingLimit ..")")
			end
		end
	end
end
setTimer(kickPing, 15000, 0)

-- Reset ping warnings each map start
addEventHandler( "onGamemodeMapStart", root, function() 
	playerPingWarnings = {}
end )