﻿local mapvote = {
	maps = {},
	playerVotes = {},
	timer = nil,
	lastMap = nil,
	mapsOffered = {},
	-- for testing
	--mapsOffered = {["ptpm-a51"] = 10, ["ptpm-air-assault"] = 10, ["ptpm-bayside"] = 10, ["ptpm-chiliad"] = 10, ["ptpm-country"] = 10, ["ptpm-desert"] = 10, ["ptpm-factory"] = 10, ["ptpm-ls"] = 10,
	--				["ptpm-lshydra"] = 10, ["ptpm-lv"] = 10, ["ptpm-lvobj"] = 0, ["ptpm-sf"] = 0},
}


-- this happens as soon as the round ends
function setRoundEnded()
	data.roundEnded = true

	options.endGamePrepareTimer = setTimer(endGame, 3000, 1)

	for _, p in ipairs(getElementsByType("player")) do
		if p and isElement(p) and isPlayerActive(p) then
			if getElementData(p, "ptpm.inClassSelection") then
				classSelectionRemove(p)
			end

			triggerClientEvent(p, "onClientRoundEnd", p)
		end
	end

	-- if heligrab is running, we want to drop everyone from helis
	if isRunning("heligrab") then
		for _, player in ipairs(getElementsByType("player")) do
			if player and isElement(player) then
				if exports.heligrab:IsPlayerHangingFromHeli(player) then
					exports.heligrab:SetPlayerGrabbedHeli(player, false)
				end
			end
		end
	end

	if isRunning("realdriveby") then
		for _, player in ipairs(getElementsByType("player")) do
			if player and isElement(player) then
				exports.realdriveby:setDrivebyActive(player, false)
			end
		end		
	end

	if isRunning("parachute") then
		for _, player in ipairs(getElementsByType("player")) do
			if player and isElement(player) then
				exports.parachute:removeParachute(player, true)
			end
		end
	end
end

-- this happens once everyone has viewed the body for a few seconds
function endGame()
	options.endGamePrepareTimer = nil

	clearTask()
	clearObjective()
	
	if options.swapclass.target then
		if options.swapclass.timer then
			if isTimer( options.swapclass.timer ) then
				killTimer( options.swapclass.timer )
			end
		end
		drawStaticTextToScreen( "delete", options.swapclass.target, "swapText" )
		options.swapclass = {}
	end
	
	for _, p in ipairs( getElementsByType( "player" ) ) do
		if p and isElement( p ) and isPlayerActive( p ) then
			--if options.teamSpecificRadar then
			--	setElementData( p, "ptpm.blip.visibleto", false )
			--end
			
			-- Remove distance text from screen (if it exists)
			options.displayDistanceToPM = false
			triggerClientEvent( p, "sendClientMapData", p, miniClass, currentPM, options.displayDistanceToPM )
			--exports.ptpm_accounts:saveStats(p)
			
			if getElementData(p, "ptpm.inClassSelection") then
				classSelectionRemove(p)
			end
		end
	end
	
	-- Save some stats
	if isRunning("ptpm_accounts") then
		for _, player in ipairs(getElementsByType("player")) do
			if player and isElement(player) and isPlayerActive(player) then
				local beststreak = exports.ptpm_accounts:getPlayerStatistic(player, "beststreak") or 0
				local currentstreak = getElementData(player, "ptpm.consecutiveKills") or 0
				if currentstreak > beststreak then
					exports.ptpm_accounts:setPlayerStatistic(player, "beststreak", currentstreak)
				end

				exports.ptpm_accounts:incrementPlayerStatistic(player, "roundsplayed")

				if data.currentMap.hasObjectives then
					exports.ptpm_accounts:incrementPlayerStatistic(player, "objectivesplayed")
				end

				if data.currentMap.hasTasks then
					exports.ptpm_accounts:incrementPlayerStatistic(player, "tasksplayed")
				end

				if options.pmWaterDeath then
					exports.ptpm_accounts:incrementPlayerStatistic(player, "waterdeathplayed")
				end

				if options.pmAbandonedHealthPenalty then
					exports.ptpm_accounts:incrementPlayerStatistic(player, "abandonedplayed")
				end
			end
		end
	end

	if data.timer then
		exports.missiontimer:setMissionTimerFrozen( data.timer, true )
	end
	
	startEndOfRoundPTPMMapvote()
end


function getMapvoteObject( resourceName )
	if 		resourceName=="ptpm-a51" 				then return { name="Area 51", image="mapvoteimages/map-pic-A51.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-air-assault" 		then return { name="Air Assault", image="mapvoteimages/map-pic-Air.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-bayside" 			then return { name="Bayside", image="mapvoteimages/map-pic-Bay.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-chiliad" 			then return { name="Mt. Chiliad", image="mapvoteimages/map-pic-Chiliad.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-country" 			then return { name="Countryside", image="mapvoteimages/map-pic-Country.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-desert" 			then return { name="Desert", image="mapvoteimages/map-pic-Desert.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-factory" 			then return { name="Factory", image="mapvoteimages/map-pic-Factory.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-ls"					then return { name="Los Santos", image="mapvoteimages/map-pic-LS.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-lshydra" 			then return { name="Los Santos Hydra", image="mapvoteimages/map-pic-LSH.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-lsobj" 				then return { name="Los Santos Objectives", image="mapvoteimages/map-pic-LSOBJ.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-lv" 				then return { name="Las Venturas", image="mapvoteimages/map-pic-LV.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-lvobj" 				then return { name="Las Venturas Objectives", image="mapvoteimages/map-pic-LVOBJ.png", votes=0,youVoted=false,res=resourceName}
	elseif 	resourceName=="ptpm-sf" 				then return { name="San Fierro", image="mapvoteimages/map-pic-SF.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-sfobj" 				then return { name="San Fierro Objectives", image="mapvoteimages/map-pic-SFOBJ.png", votes=0,youVoted=false,res=resourceName}
	else return nil end
end

function startEndOfRoundPTPMMapvote()
	if isTimer(mapvote.timer) then
		killTimer(mapvote.timer)
		mapvote.timer = nil
	end
	
	-- Clear results from last vote
	mapvote.playerVotes = {}
	mapvote.maps = {}
	
	-- Which maps are there?
	local mapTable = {}
	for _, map in ipairs(exports.mapmanager:getMapsCompatibleWithGamemode(thisResource)) do
		local resName = getResourceName(map)
		if string.sub(resName,1,5) == "ptpm-" then
			table.insert(mapTable, resName)
		end
	end
	
	-- Map 1: Any random map (but NOT the same map that we had just now or the one before that)
	local randomMap = getMapOffer(mapTable, {runningMapName, mapvote.lastMap})
	table.insert(mapvote.maps, getMapvoteObject(randomMap))
	mapvote.mapsOffered[randomMap] = (mapvote.mapsOffered[randomMap] or 0) + 1
	
	-- Map 2: Rematch OR new random map that is NOT map 1
	local map2 = nil
	if runningMapName == mapvote.lastMap then
		map2 = getMapOffer(mapTable, {runningMapName, mapvote.lastMap, randomMap})
		table.insert(mapvote.maps, getMapvoteObject(map2))	
		mapvote.mapsOffered[map2] = (mapvote.mapsOffered[map2] or 0) + 1
	else
		map2 = runningMapName
		local mapObj = getMapvoteObject(runningMapName)
		mapObj.name = mapObj.name .. " (Rematch)"
		table.insert(mapvote.maps, mapObj)
		mapvote.mapsOffered[runningMapName] = (mapvote.mapsOffered[runningMapName] or 0) + 1
		mapvote.lastMap = runningMapName
	end
	
	-- Map 3: Any other random map
	local randomMap3 = getMapOffer(mapTable, {runningMapName, mapvote.lastMap, randomMap, map2})
	table.insert(mapvote.maps, getMapvoteObject(randomMap3))	
	mapvote.mapsOffered[randomMap3] = (mapvote.mapsOffered[randomMap3] or 0) + 1
	
	--outputDebugString(randomMap .. " / " .. map2 .. " / " .. randomMap3)

	-- Trigger client event
	for _, p in ipairs(getElementsByType("player")) do
		if p and isElement(p) and isPlayerActive(p) then
			triggerClientEvent(p, "ptpmStartMapVote", p, mapvote.maps)	
		end
	end
	
	-- Close the vote in 12 seconds (although it will say 10 seconds, by design)
	mapvote.timer = setTimer(
		function() 
			closePTPMMapVote() 
		end, 
	12 * 1000, 1)
end

-- get a map offer to put on the vote screen
-- based on how often each map has been visibly offered as a choice
function getMapOffer(mapTable, exclusions_)
	local leastSeenMaps = {}
	local leastSeenAmount = nil
	local exclusions = {}

	-- filter out nils
	for _, e in ipairs(exclusions_) do
		if e then
			exclusions[e] = true
		end
	end

	-- find the least seen maps and put them into a table
	for _, map in ipairs(mapTable) do
		if not exclusions[map] then
			if (not leastSeenAmount) or ((mapvote.mapsOffered[map] or 0) < leastSeenAmount) then
				leastSeenAmount = mapvote.mapsOffered[map] or 0
				leastSeenMaps = {map}
			elseif leastSeenAmount and (mapvote.mapsOffered[map] or 0) == leastSeenAmount then
				table.insert(leastSeenMaps, map)	
			end
		end
	end
	
	-- backup
	if #leastSeenMaps == 0 then
		return mapTable[math.random( 1, #mapTable )]
	end

	return leastSeenMaps[math.random(1, #leastSeenMaps)]
end

function closePTPMMapVote()
	-- Set next map
	local highestVoteCount = -1
	local highestVoteMap = nil
	
	for mapVoteId, map in ipairs(mapvote.maps) do
		-- By design, if there is a tie between map[1] (new map) and map[2] (rematch) then map[1] will win. This is intentional.
		if map.votes > highestVoteCount then 
			highestVoteCount = map.votes
			highestVoteMap = map.res
		end
	end
	
	-- Trigger client event
	for _, p in ipairs(getElementsByType("player")) do
		if p and isElement(p) then
			if isPlayerActive(p) then
				triggerClientEvent(p, "ptpmEndMapVote", p)	
			end

			if mapvote.playerVotes[p] then
				setElementData(p, "ptpm.lastMapVote", mapvote.maps[mapvote.playerVotes[p]].res, false)
			else
				setElementData(p, "ptpm.lastMapVote", nil, false)
			end
		end
	end
	
	-- Absolute final fallback
	if highestVoteMap == nil or getResourceFromName(highestVoteMap) == false then 
		outputDebugString("ERROR LOADING MAP: " .. highestVoteMap);
		highestVoteMap = "ptpm-sf" 
	end
	outputDebugString("Loading map: " .. highestVoteMap);

	if data.silentRestart then
		for _, player in ipairs(getElementsByType("player")) do
			if player and isElement(player) and isPlayerOp(player) then
				outputChatBox("SERVER: Gamemode silently restarting...", player, unpack(colour.global))
			end
		end

		-- these are resources that totally need to be restarted when ptpm does, so force it to happen
		-- even though they are includes in the meta they can be skipped by mta if anyone has restarted them manually
		for resName in pairs(dependantIncludes) do
			local res = getResourceFromName(resName)

			if res then
				stopResource(res)
			end
		end
		
		exports.mapmanager:changeGamemodeByName("ptpm", highestVoteMap, true)
		data.silentRestart = nil
	else
		exports.mapmanager:changeGamemodeMap(getResourceFromName(highestVoteMap), thisResource) 
	end
end

function handleIncomingVote(mapVoteId)
	if mapvote.playerVotes[client] ~= nil then 
		-- The player voted already and is changing their vote
		mapvote.maps[mapvote.playerVotes[client]].votes = mapvote.maps[mapvote.playerVotes[client]].votes-1
	end

	-- Register the (new) vote
	mapvote.playerVotes[client] = mapVoteId
	mapvote.maps[mapVoteId].votes = mapvote.maps[mapVoteId].votes+1
		
	-- Update everyones screen
	for _, p in ipairs(getElementsByType("player")) do
		if p and isElement(p) and isPlayerActive(p) then
			triggerClientEvent(p, "ptpmUpdateMapVoteResults", p, mapvote.maps)	
		end
	end
end

addEvent("ptpmMapVoteResult", true)
addEventHandler("ptpmMapVoteResult", resourceRoot, handleIncomingVote)
