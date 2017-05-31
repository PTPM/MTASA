
local function onResourceStart ( resource )
	local players = getElementsByType ( "player" )
	for k, v in pairs ( players ) do
		setElementData ( v, "parachuting", false )
	end
end
addEventHandler ( "onResourceStart", resourceRoot, onResourceStart )

function requestAddParachute ()
	local plrs = getElementsByType("player")
	for key,player in ipairs(plrs) do
		if player == client then
			table.remove(plrs, key)
			break
		end
	end
	triggerClientEvent(plrs, "doAddParachuteToPlayer", client)
end
addEvent ( "requestAddParachute", true )
addEventHandler ( "requestAddParachute", resourceRoot, requestAddParachute )

function requestRemoveParachute(skipAnimation)
	takeWeapon ( client, 46 )
	local plrs = getElementsByType("player")
	for key,player in ipairs(plrs) do
		if player == client then
			table.remove(plrs, key)
			break
		end
	end
	triggerClientEvent(plrs, "doRemoveParachuteFromPlayer", client, skipAnimation)
end
addEvent ( "requestRemoveParachute", true )
addEventHandler ( "requestRemoveParachute", resourceRoot, requestRemoveParachute )


function removeParachute(player, skipAnimation)
	if not getElementData(player, "parachuting") then
		return
	end

	triggerClientEvent(root, "serverRemoveParachute", player, skipAnimation)
end

-- addCommandHandler("drop", 
-- 	function(player, cmd, givePara)
-- 		outputChatBox("Dropping...", player)
-- 		if givePara then
-- 			giveWeapon(player, 46)
-- 		end

-- 		local x, y, z = getElementPosition(player)
-- 		setElementPosition(player, x, y, z + 500)
-- 	end
-- )


-- addCommandHandler("p",
	-- function(player)
		-- setElementPosition(player, 1543.5, -1359.6, 329.4)
		-- setElementRotation(player, 0, 0, 270)
		-- giveWeapon(player, 46, 1, true)
		-- setElementHealth(player, 100)
	-- end
-- )

addEventHandler("onResourceStart", resourceRoot,
	function()
		for i,v in ipairs(getElementsByType("player")) do
			bindKey(v, "i", "down", toggleTimer)
		end
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		for i,v in ipairs(getElementsByType("player")) do
			unbindKey(v, "i", "down", toggleTimer)
		end
	end
)

local timer = nil
local tStart = 0
function toggleTimer()
	if timer then
		outputChatBox("Length: " .. tostring((getTickCount() - tStart) / 1000))
		timer = nil
	else
		timer = true
		tStart = getTickCount();
		outputChatBox("Timer started...")
	end
end