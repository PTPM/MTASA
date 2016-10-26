function initDrawtagBC()
	if initialized then return end
	initialized = true
	addCommandHandler("tspray",modeDraw)
	addCommandHandler("terase",modeErase)
	addCommandHandler("tsize",changeSize)
	addEvent("drawtag_bc:copyTag",true)
	addEventHandler("drawtag_bc:copyTag",root,copyTag)
	loadTagsFromFile()
	local all_players = getElementsByType("player")
	for plnum,player in ipairs(all_players) do
		exports.drawtag:setPlayerTagSize(player,1.5)
	end
	addEventHandler("onPlayerJoin",root,setDefaultTagSize)
end

function uninitDrawtagBC()
	if not initialized then return end
	initialized = nil
	removeCommandHandler("tspray",modeDraw)
	removeCommandHandler("terase",modeErase)
	removeCommandHandler("tsize",changeSize)
	removeEventHandler("drawtag_bc:copyTag",root,copyTag)
	saveTagsToFile()
	removeEventHandler("onPlayerJoin",root,setDefaultTagSize)
end

function initOnStart(resource)
	if getResourceName(resource) == "drawtag" then
		initDrawtagBC()
	elseif source == resourceRoot and getResourceState(getResourceFromName("drawtag")) == "running" then
		initDrawtagBC()
	end
end

function uninitOnStop(resource)
	if getResourceName(resource) == "drawtag" then
		uninitDrawtagBC()
	elseif source == resourceRoot and getResourceState(getResourceFromName("drawtag")) == "running" then
		uninitDrawtagBC()
	end
end

addEventHandler("onResourceStart",root,initOnStart)
addEventHandler("onResourceStop",root,uninitOnStop)

function setDefaultTagSize()
	exports.drawtag:setPlayerTagSize(source,1.5)
end


function identifyPlayer(player)
	return player and getPlayerName(player) or "Unknown player"
end

function modeDraw(player)
	exports.drawtag:setPlayerSprayMode(player,"draw")
	outputChatBox("Spraying mode: draw",player)
end

function modeErase(player)
	exports.drawtag:setPlayerSprayMode(player,"erase")
	outputChatBox("Spraying mode: erase",player)
end

function changeSize(player,cmdname,size)
	size = tonumber(size)
	if not size or math.abs(size) > 1000 then return end
	if not exports.drawtag:setPlayerTagSize(player,size) then return end
	outputChatBox("Tag size changed to "..size,player)
end

function copyTag()
	local png = exports.drawtag:getTagTexture(source)
	exports.drawtag:setPlayerTagTexture(client,png)
	outputChatBox("Tag texture copied",client)
end

