local lastVoteCount = 0

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
				local beststreak = exports.ptpm_accounts:getPlayerStat( p, "beststreak" ) or 0
				local currentstreak = getElementData( p, "ptpm.consecutiveKills" )
				if currentstreak > beststreak then
					exports.ptpm_accounts:setPlayerStat( p, "beststreak", currentstreak )
				end
				
				local roundsplayed = exports.ptpm_accounts:getPlayerStat( p, "roundsplayed" ) or 0
				exports.ptpm_accounts:setPlayerStat( p, "roundsplayed", roundsplayed + 1 )
			end
		end
	end

	if data.timer then
		exports.missiontimer:setMissionTimerFrozen( data.timer, true )
	end
	
	startEndOfRoundMapvote()
end


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