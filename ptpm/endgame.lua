local lastVoteCount = 0
local lastMap = nil
local mapVotes = {}
local maps = {}
local mapVoteTimer = nil

-- compcheck
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
			
		end
	end
	
	-- Save some stats
	if isRunning( "ptpm_accounts" ) then
		for _, p in ipairs( getElementsByType( "player" ) ) do
			if p and isElement( p ) and isPlayerActive( p ) then
				local beststreak = exports.ptpm_accounts:getPlayerStatistic( p, "beststreak" ) or 0
				local currentstreak = getElementData( p, "ptpm.consecutiveKills" ) or 0
				if currentstreak > beststreak then
					exports.ptpm_accounts:setPlayerStatistic( p, "beststreak", currentstreak )
				end
				
				local roundsplayed = exports.ptpm_accounts:getPlayerStatistic( p, "roundsplayed" ) or 0
				exports.ptpm_accounts:setPlayerStatistic( p, "roundsplayed", roundsplayed + 1 )
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
	elseif 	resourceName=="ptpm-lv" 				then return { name="Las Venturas", image="mapvoteimages/map-pic-LV.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-lvobj" 				then return { name="Las Venturas Objectives", image="mapvoteimages/map-pic-LVOBJ.png", votes=0,youVoted=false,res=resourceName} 
	elseif 	resourceName=="ptpm-sf" 				then return { name="San Fierro", image="mapvoteimages/map-pic-SF.png", votes=0,youVoted=false,res=resourceName} 
	else return nil end
end


function startEndOfRoundPTPMMapvote()
	local currentMap = getResourceName(exports.mapmanager:getRunningGamemodeMap())
	if isTimer( mapVoteTimer ) then
		killTimer( mapVoteTimer )
	end
	
	-- Clear results from last vote
	mapVotes = {}
	maps = {}
	
	-- Which maps are there?
	local mapTable = exports.mapmanager:getMapsCompatibleWithGamemode( thisResource )
	
	-- Map 1: Any random map (but NOT the same map that we had just now or the one before that)
	local randomMap = nil
	while true do
		randomMap = getResourceName(mapTable[math.random( 1, #mapTable )])	
		if randomMap ~= currentMap and randomMap ~=lastMap then break end
	end
	table.insert(maps, getMapvoteObject(randomMap))
	
	-- Map 2: Rematch OR new random map that is NOT map 1
	if currentMap==lastMap then

		local randomMap2 = nil
		while true do
			randomMap2 = getResourceName(mapTable[math.random( 1, #mapTable )])	
			if randomMap2 ~= currentMap and randomMap2 ~=lastMap and randomMap2 ~= randomMap then break end
		end
		table.insert(maps, getMapvoteObject(randomMap2))
		
	else
		local mapObj = getMapvoteObject(currentMap)
		mapObj.name = mapObj.name .. " (Rematch)"
		table.insert(maps, mapObj)
		lastMap = currentMap
	end
	
	-- Map 3: "Unknown" other random map
	local randomMap3 = nil
	while true do
		randomMap3 = getResourceName(mapTable[math.random( 1, #mapTable )])	
		if randomMap3 ~= currentMap and randomMap3 ~=lastMap and randomMap3 ~= randomMap  and randomMap3 ~= randomMap2 then break end
	end
	
	table.insert(maps, {
		name = "Random Map",
		image = "mapvoteimages/map-pic-_randomMap.png",
		votes = 0,
		youVoted = false,
		hasWon = false,
		res = randomMap3
	})
	
	-- Trigger client event
	for _, p in ipairs( getElementsByType( "player" ) ) do
		if p and isElement( p ) then
			triggerClientEvent ( p, "ptpmStartMapVote", p, maps )	
		end
	end
	
	-- Close the vote in 12 seconds (although it will say 10 seconds, by design)
	mapVoteTimer = setTimer(function() closePTPMMapVote() end, 12 * 1000, 1)
	
end

function closePTPMMapVote()
	-- Set next map
	local highestVoteCount = -1
	local highestVoteMap = nil
	
	for mapVoteId,map in ipairs(maps) do
		-- By design, if there is a tie between map[1] (new map) and map[2] (rematch) then map[1] will win. This is intentional.
		if map.votes>highestVoteCount then 
			highestVoteCount = map.votes
			highestVoteMap = map.res
		end
	end
	
	-- Trigger client event
	for _, p in ipairs( getElementsByType( "player" ) ) do
		if p and isElement( p ) then
			triggerClientEvent ( p, "ptpmEndMapVote", p )	
		end
	end
	
	-- Absolute final fallback
	if highestVoteMap == nil or getResourceFromName(highestVoteMap)==false then 
		outputDebugString("ERROR LOADING MAP: " .. highestVoteMap);
		highestVoteMap = "ptpm-sf" 
	end
	outputDebugString("Loading map: " .. highestVoteMap);
	exports.mapmanager:changeGamemodeMap( getResourceFromName ( highestVoteMap ), thisResource ) 
end

function handleIncomingVote(mapVoteId)
	if mapVotes[client]~=nil then 
		-- The player voted already and is changing their vote
		maps[mapVotes[client]].votes = maps[mapVotes[client]].votes-1
	end

	-- Register the (new) vote
	mapVotes[client] = mapVoteId
	maps[mapVoteId].votes = maps[mapVoteId].votes+1
		
	-- Update everyones screen
	for _, p in ipairs( getElementsByType( "player" ) ) do
		if p and isElement( p ) then
			triggerClientEvent ( p, "ptpmUpdateMapVoteResults", p, maps )	
		end
	end
	
end

addEvent( "ptpmMapVoteResult", true )
addEventHandler( "ptpmMapVoteResult", resourceRoot, handleIncomingVote )


-- LEGACY:
function startEndOfRoundMapvote()
	exports.votemanager:stopPoll() -- stop possible callvotes

	local mapTable = exports.mapmanager:getMapsCompatibleWithGamemode( thisResource )
	
	if #getElementsByType( "player" ) == 0 then -- votemanager fucks up when no players
		return exports.mapmanager:changeGamemodeMap( mapTable[math.random( 1, #mapTable )], thisResource )
	end
	
	local randomMaps, alreadyListed, counter = {}, {}, 1
	
	if #mapTable > 1 then 
		local pollOptions = {}
		
		for i=1, #mapTable, 1 do
			pollOptions[i] = { getResourceInfo( mapTable[i], "name" ), "nextMapResult", root, mapTable[i] }
		end

		pollOptions.title = "Vote next map:"
		pollOptions.percentage = 51
		pollOptions.timeout = 15
		pollOptions.allowchange = true
		pollOptions.maxnominations = 2
		pollOptionsvisibleTo = root
		
		exports.votemanager:startPoll(pollOptions)
		
		data.pollActive = true
		

		addEventHandler( "onPollEnd", root, chooseRandomMap )
	else 
		exports.mapmanager:changeGamemodeMap( runningMap, thisResource ) 
	end	
end


addEvent( "nextMapResult", false )
addEventHandler( "nextMapResult", root,
	function( map )
		if not exports.mapmanager:changeGamemodeMap( map ) then
			outputChatBox( "Error changing map to " .. getResourceName( map ) )
			outputChatBox( "Loading a random map..." )
			local mapTable = exports.mapmanager:getMapsCompatibleWithGamemode( thisResource )
			exports.mapmanager:changeGamemodeMap( mapTable[math.random( 1, #mapTable )], thisResource )
		end
	end
)


addEvent( "onPollEnd", false )
function chooseRandomMap(chosen)
	if not chosen then
		cancelEvent()
		math.randomseed( getTickCount() )
		exports.votemanager:finishPoll( math.random( 1, math.max( 1, lastVoteCount ) ) )
	--	outputChatBox("Draw! Chosing random map...", root, unpack(colourImportant))
	end
	removeEventHandler( "onPollEnd", root, chooseRandomMap )
end		

-- requires change to votemanager:
--	votemanager_server line 95 - send pollData with the event
addEvent( "onPollStart", false )
addEventHandler( "onPollStart", root,
	function( pollData )
		--outputChatBox("poll starting "..#pollData)
		lastVoteCount = #pollData
	end
)