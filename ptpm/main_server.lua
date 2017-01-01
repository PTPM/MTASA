
-- Also using:

-- missiontimer
-- scoreboard
-- votemanager
-- drawbounds
-- namegen
-- heligrab
-- vending
-- vehicle_items	
-- ptpm_accounts
-- ptpm_login
-- spectator
-- realdriveby
-- defaultstats
-- interiors
-- mabako-services
-- parachute

-- General note: When handling with player element data, only remove element data set by that resource onResourceStop/etc.
-- This will avoid issues when restarting resources etc.

-- onClientReady (server) = ptpm resource is downloaded clientside, create a login window or hop to onClientAvailable
-- onClientAvailable (server/client) = login screen has been passed, start the gamemode for player
-- data "ready" = player is ready to play, use isPlayerActive
-- data "loggedIn" = player has passed login screen, may still be a guest
-- data "username" = holds the username player has logged in to, not available for guests
-- data "classID" = holds player's class id, only available when spawned
-- These element datas should be synced to client:
-- classID
-- loggedIn
-- loggingIn
-- blip
-- blip.visibleto
-- score.kills
-- score.deaths
-- score.class
-- id

data = {} -- holds map data (data.tasks, data.objectives, data.roundTimer, etc)
options = {} -- holds map options
settings = {}

-- if ptpm_login is running, this won't change to true until a map starts
-- it's at the map start because, if you start ptpm_login mid-game, it makes the login screen pop-up at new map start
settings.loginActive = false
-- doing "/gamemode ptpm" fast causes errors without this
do
	local ptpm_login = getResourceFromName( "ptpm_login" )
	if ptpm_login then
		if getResourceState( ptpm_login ) == "running" then
			settings.loginActive = true
		end
	end
end

mode_name = getResourceInfo( thisResource, "name" )
mode_version = getResourceInfo( thisResource, "version" )

spam = {
	resource = nil
}

motd = {
	"Welcome to " .. mode_name .. "!",
	"Forum: https://PTPM.uk"
}

teamMemberName = {
	["psycho"] = "a psychopath",
	["terrorist"] = "a terrorist",
	["pm"] = "the Prime Minister",
	["bodyguard"] = "a bodyguard",
	["police"] = "a cop"
}


-- thank you arc_
sampTextdrawColours = {
	r = {180, 25, 29},
	g = {53, 101, 43},
	b = {50, 60, 127},
	--o = {239, 141, 27},
	o = {144, 98, 16},
	w = {255, 255, 255},
	y = {222, 188, 97},
	p = {180, 25, 180},
	l = {10, 10, 10}
}


-- psychos have no team
teams = {
	["goodGuys"] = {
		["pm"] = true, ["bodyguard"] = true, ["police"] = true
	},
	["badGuys"] = {
		["terrorist"] = true
	}
}



-- Redo with element data
--playerInfo = {}

addEventHandler( "onResourceStart", resourceRoot, 
	function( resource )
		
		-- Check if mapmanager is running
		if not isRunning( "mapmanager" ) then
			outputServerLog( "mapmanager resource is not running, quitting ptpm!" )
			outputServerLog( "- to play ptpm, first start mapmanager and then use \"gamemode ptpm\"" )
			outputDebugString( "PTPM: Required resource mapmanager is not running", 1 )
			stopResource( thisResource )
			return
		end
	
		printConsole( "Protect The Prime Minister mode loaded!" )
		
		teams.goodGuys.element = createTeam( "Good guys" )
		teams.badGuys.element = createTeam( "Bad guys" )
		
		setTeamColor( teams.goodGuys.element, 220, 220, 220 )
		setTeamColor( teams.badGuys.element, 220, 220, 220 )
		
		setTeamFriendlyFire( teams.goodGuys.element, false )
		setTeamFriendlyFire( teams.badGuys.element, false )
		
		exports.scoreboard:scoreboardAddColumn( "ptpm.score.class", root, 100, "Current class", 2 )
		
		exports.scoreboard:scoreboardAddColumn( "ptpm.score.roundsWon", root, 66, "Games won", 3 )
		exports.scoreboard:scoreboardAddColumn( "ptpm.score.roundsLost", root, 63, "Games lost", 4 )    
		exports.scoreboard:scoreboardAddColumn( "ptpm.score.pmWins", root, 66, "Wins as PM", 5 )
		exports.scoreboard:scoreboardAddColumn( "ptpm.score.pmLosses", root, 79, "Losses as PM", 6 )
		exports.scoreboard:scoreboardAddColumn( "ptpm.score.pmKills", root, 88, "Times killed PM", 7 )
		exports.scoreboard:scoreboardAddColumn( "ptpm.score.hpHealed", root, 111, "HP healed as medic", 8 )
		exports.scoreboard:scoreboardAddColumn( "ptpm.score.damage", root, 79, "Damage given", 9 )
		exports.scoreboard:scoreboardAddColumn( "ptpm.score.damageTaken", root, 81, "Damage taken", 10 )
		exports.scoreboard:scoreboardAddColumn( "ptpm.score.kills", root, 35, "Kills", 11 )
		exports.scoreboard:scoreboardAddColumn( "ptpm.score.deaths", root, 39, "Deaths", 12 )
		
		exports.scoreboard:scoreboardSetColumnPriority( "name", 1 )

		setFPSLimit( 60 )
		
		setTime( math.random( 1, 24 ), 0 )
		setMinuteDuration( 3000 )
		
		local players = getElementsByType( "player" )
		for _, p in ipairs( players ) do
			setupIdForPlayer( p )
			local timestamp = getRealTime().timestamp
			setElementData( p, "ptpm.sessionjoin", timestamp, false )
		end

		spam.resource = getResourceFromName("antiflood")
		
		-- Fallback: Check if a suitable map is running (particularly for after refreshall console command)
		setTimer(function()
			if exports.mapmanager:getRunningGamemodeMap()==nil or not exports.mapmanager:isGamemodeCompatibleWithMap( resource, exports.mapmanager:getRunningGamemodeMap()) then
				local mapTable = exports.mapmanager:getMapsCompatibleWithGamemode( thisResource )
				if #mapTable==0 then
					outputServerLog( "FATAL: No PTPM compatible maps were found on the server. Stopping resource." )
					outputDebugString( "FATAL: No PTPM compatible maps were found on the server.", 1 )
					stopResource( thisResource )
				else
					local randomMap = getResourceName(mapTable[math.random( 1, #mapTable )])
					exports.mapmanager:changeGamemodeMap( getResourceFromName(randomMap), thisResource ) 
					outputDebugString( "PTPM was running no map or an incompatible map. Starting " .. randomMap .. ".", 3 )
				end
			end
		end, 2000, 1)
	end
)

addEventHandler("onResourceStart", root,
	function(resource)
		if getResourceName(resource) == "antiflood" then
			spam.resource = resource
		end
	end
)


-- clean up and try to stop the server crashing if we close it when ptpm is running
addEventHandler( "onResourceStop", resourceRoot,
	function()
	
		runningMap = nil
		runningMapRoot = nil
		runningMapName = nil
	
		if teams then
			if isElement( teams.goodGuys.element ) then
				destroyElement( teams.goodGuys.element )
			end
			if isElement( teams.badGuys.element ) then
				destroyElement( teams.badGuys.element )
			end
		end
		
		exports.scoreboard:scoreboardRemoveColumn( "ptpm.score.class" )
		exports.scoreboard:scoreboardRemoveColumn( "ptpm.score.kills" )
		exports.scoreboard:scoreboardRemoveColumn( "ptpm.score.deaths" )
		
		for _, player in ipairs( getElementsByType( "player" ) ) do
			if player and isElement( player ) then
				resetPlayer( player )
			end
		end
		--ptpmMapStop()
	end
)


addEvent( "onClientReady", true )
function checkResources()
	if not settings.loginActive then
		triggerClientEvent( client, "onClientAvailable", client )
		triggerEvent( "onClientAvailable", client )
	else
		if getElementData( client, "ptpm.loggedIn" ) then
			triggerClientEvent( client, "onClientAvailable", client )
			triggerEvent( "onClientAvailable", client )
		else
			exports.ptpm_login:setLoginScreenForPlayer( client )
		end
	end
end
addEventHandler( "onClientReady", resourceRoot, checkResources )


function onPlayerJoin()
	-- inspiring nameless people...
	if getPlayerName( source ) == "Player" then
		triggerEvent( "onNamegen", source )
	end
	
	setupIdForPlayer( source )
	local timestamp = getRealTime().timestamp
	setElementData( source, "ptpm.sessionjoin", timestamp, false )
	
	local name = getPlayerName(source)	
	local strippedName = stripColourCodes(name)

	if strippedName ~= name then
		if #strippedName > 0 then
			setPlayerName(source, strippedName)
		else
			outputChatBox("Your name contained only colour codes, reset to a random name...", source, unpack(colour.personal))

			exports.namegen:namegen(source)
			-- repeat
			-- 	local set = setPlayerName(source, "Player" .. tostring(math.random(100, 999)))
			-- until set == true
		end
	end
	
	-- silly mta bug
	setGlitchEnabled( "quickreload", false )
	setGlitchEnabled( "quickreload", true )	
end
addEventHandler( "onPlayerJoin", root, onPlayerJoin )


addEvent( "onClientAvailable", true )
addEventHandler( "onClientAvailable", root,
	function()
		-- Client is ready to play
		--setElementData( source, "ptpm.loggingIn", nil )
		setElementData( source, "ptpm.ready", true, false )
		sendMOTD( source )

		loadScoreboardStats( source )

		setPlayerBlurLevel( source, 0 )
		bindKey( source, "u", "down", "chatbox", "adminChat" )
		
		-- if the round has started (if it hasnt, loader will send them to the class selection once the map is loaded)
		if data.roundTimer then
			triggerClientEvent( source, "sendClientMapData", source, miniClass, currentPM, options.displayDistanceToPM )
		
			initClassSelection( source )
			--createPlayerBlip( source )
		end
	end
)

function loadScoreboardStats(player)
  local kills = 0
  local deaths = 0
  local pmWins = 0
  local pmKills = 0
  local hpHealed = 0
  local roundsWon = 0
  local roundsLost = 0
  local damage = 0
  local pmLosses = 0
  local damageTaken = 0
    
  if isRunning( "ptpm_accounts" ) then
    kills = (exports.ptpm_accounts:getPlayerStatistic( player, "kills" ) or 0)
    deaths = (exports.ptpm_accounts:getPlayerStatistic( player, "deaths" ) or 0)
    pmWins = (exports.ptpm_accounts:getPlayerStatistic( player, "pmvictory" ) or 0)
    pmKills = (exports.ptpm_accounts:getPlayerStatistic( player, "pmkills" ) or 0)
    hpHealed = (exports.ptpm_accounts:getPlayerStatistic( player, "hphealed" ) or 0)
    roundsWon = (exports.ptpm_accounts:getPlayerStatistic( player, "roundswon" ) or 0)
    roundsLost = (exports.ptpm_accounts:getPlayerStatistic( player, "roundslost" ) or 0)
    damage = (exports.ptpm_accounts:getPlayerStatistic( player, "damage" ) or 0)
    pmLosses = (exports.ptpm_accounts:getPlayerStatistic( player, "pmlosses" ) or 0)
    damageTaken = (exports.ptpm_accounts:getPlayerStatistic( player, "damagetaken" ) or 0)
  end
    
  setElementData( player, "ptpm.score.kills", string.format( "%d", kills ) )
  setElementData( player, "ptpm.score.deaths", string.format( "%d", deaths ) )
  setElementData( player, "ptpm.score.pmWins", string.format( "%d", pmWins ) )
  setElementData( player, "ptpm.score.pmKills", string.format( "%d", pmKills ) )
  setElementData( player, "ptpm.score.hpHealed", string.format( "%d", hpHealed ) )
  setElementData( player, "ptpm.score.roundsWon", string.format( "%d", roundsWon ) )
  setElementData( player, "ptpm.score.roundsLost", string.format( "%d", roundsLost ) )
  setElementData( player, "ptpm.score.damage", string.format( "%d", damage ) )
  setElementData( player, "ptpm.score.pmLosses", string.format( "%d", pmLosses ) )
  setElementData( player, "ptpm.score.damageTaken", string.format( "%d", damageTaken ) )
  
end

-- compcheck
addEventHandler( "onPlayerQuit", root,
	function()
		local needsRebalance = getPlayerClassID(source) or getElementData(source, "ptpm.electionClass")

		resetPlayer( source )
		-- Following are in resetPlayer()
		-- checkClassSelection( source )
		-- local pinfoTimer = getElementData( source, "ptpm.pinfoTimer" )
		-- if pinfoTimer then
			-- if isTimer( pinfoTimer ) then
				-- killTimer( pinfoTimer )
			-- end
			-- setElementData( source, "ptpm.pinfoTimer", nil, false )
		-- end
		--if playerInfo and playerInfo[source] and playerInfo[source].pinfoTimer then
		--	if isTimer(playerInfo[source].pinfoTimer) then
		--		killTimer(playerInfo[source].pinfoTimer)
		--	end
		--end
		
		clearPickupData( source )
		
		if currentPM and source == currentPM then
			clearTask()
			clearObjective()
			
			if options.swapclass.target then
				if options.swapclass.timer then
					if isTimer( options.swapclass.timer ) then
						killTimer( options.swapclass.timer )
					end
				end
				removeStaticTextFromScreen( options.swapclass.target, "swapText" )
				options.swapclass = {}
			end
			
			currentPM = nil
		end

		-- recalculate the new balance situation and notify anyone in the class selection
		if needsRebalance then
			calculateBalance()
			notifyTeamAvailability()		
		end
					
		--playerInfo[source] = nil
	end
)


function sendMOTD( thePlayer )
	for _, message in ipairs( motd ) do
		outputChatBox( message, thePlayer, unpack( colour.important ) )
	end
end
addCommandHandler( "motd", sendMOTD )


addEventHandler("onPlayerChangeNick", root,
	function(old, new)
		if stripColourCodes(new) ~= new then 
			cancelEvent() 
			outputChatBox("Names cannot contain colour codes.", source, unpack(colour.personal))
		end
	end
)


function roundTick()
	local tick = getTickCount()
	local timeLeft = options.roundtime - (tick - data.roundStartTime)
	
	--if not data.roundEnded then
	--	drawStaticTextToScreen( "update", root, "roundTimer", "Time left: " .. formatTimeLeft(), "screenX-190", 5, 180, 50, sampTextdrawColours.w, 1, "pricedown", "top" )
	--end
	
	
	if timeLeft < 0 and not data.roundEnded then
		if currentPM then 
			everyoneViewsBody( currentPM, currentPM, getElementInterior( currentPM ) ) 
		end
		
		local r, g, b = unpack(classColours["pm"])
		
		if tableSize( getElementsByType( "objective", runningMapRoot ) ) == 0 then
			sendGameText( root, "The Prime Minister survived!", 7000, {r, g, b}, nil, 1.2, nil, nil, 3 )
      
      		if currentPM then
        		local pmWins = getElementData( currentPM, "ptpm.pmWins" ) or 0
        
        		if isRunning( "ptpm_accounts" ) then
          			--exports.ptpm_accounts:setPlayerAccountData(currentPM,{["pmVictory"] = ">+1"})
          			pmWins = (exports.ptpm_accounts:getPlayerStatistic( currentPM, "pmvictory" ) or pmWins) + 1
          			exports.ptpm_accounts:setPlayerStatistic( currentPM, "pmvictory", pmWins )
        		else
          			pmWins = pmWins + 1
        		end
        
		        setElementData( currentPM, "ptpm.score.pmWins", string.format( "%d", pmWins ) )
		        setElementData( currentPM, "ptpm.pmWins", pmWins, false)
        
				local players = getElementsByType( "player" )
				for _, p in ipairs( players ) do
					if p and isElement( p ) and isPlayerActive( p ) then
						local classID = getPlayerClassID( p )

						if classID then
							if classes[classID].type == "pm" or classes[classID].type == "bodyguard" or classes[classID].type == "police" then
								local roundsWon = getElementData( p, "ptpm.roundsWon" ) or 0

								if isRunning( "ptpm_accounts" ) then        
									roundsWon = (exports.ptpm_accounts:getPlayerStatistic( p, "roundswon" ) or roundsWon) + 1
									exports.ptpm_accounts:setPlayerStatistic( p, "roundswon", roundsWon )
								else
									roundsWon = roundsWon + 1
								end

								setElementData( p, "ptpm.score.roundsWon", string.format( "%d", roundsWon ) )
								setElementData( p, "ptpm.roundsWon", roundsWon, false)
							elseif classes[classID].type == "terrorist" then
								local roundsLost = getElementData( p, "ptpm.roundsLost" ) or 0

								if isRunning( "ptpm_accounts" ) then        
									roundsLost = (exports.ptpm_accounts:getPlayerStatistic( p, "roundslost" ) or roundsLost) + 1
									exports.ptpm_accounts:setPlayerStatistic( p, "roundslost", roundsLost )
								else
									roundsLost = roundsLost + 1
								end

								setElementData( p, "ptpm.score.roundsLost", string.format( "%d", roundsLost ) )
								setElementData( p, "ptpm.roundsLost", roundsLost, false)
							end
						end
					end
				end     
			end		
		else
			sendGameText( root, "The Prime Minister fails to secure objective!", 7000, sampTextdrawColours.r, nil, 1.2, nil, nil, 3 )

	      	if currentPM then
	        	local pmLosses = getElementData( currentPM, "ptpm.pmWins" ) or 0
	        
	        	if isRunning( "ptpm_accounts" ) then
					pmLosses = (exports.ptpm_accounts:getPlayerStatistic( currentPM, "pmlosses" ) or pmLosses) + 1
					exports.ptpm_accounts:setPlayerStatistic( currentPM, "pmlosses", pmLosses )
				else
					pmLosses = pmLosses + 1
				end
	        
				setElementData( currentPM, "ptpm.score.pmLosses", string.format( "%d", pmLosses ) )
				setElementData( currentPM, "ptpm.pmLosses", pmLosses, false)

				local players = getElementsByType( "player" )
				for _, p in ipairs( players ) do
					if p and isElement( p ) and isPlayerActive( p ) then
						local classID = getPlayerClassID( p )
						if classID then
							if classes[classID].type == "terrorist" then
								local roundsWon = getElementData( p, "ptpm.roundsWon" ) or 0

								if isRunning( "ptpm_accounts" ) then        
									roundsWon = (exports.ptpm_accounts:getPlayerStatistic( p, "roundswon" ) or roundsWon) + 1
									exports.ptpm_accounts:setPlayerStatistic( p, "roundswon", roundsWon )
								else
									roundsWon = roundsWon + 1
								end

								setElementData( p, "ptpm.score.roundsWon", string.format( "%d", roundsWon ) )
								setElementData( p, "ptpm.roundsWon", roundsWon, false)
							end
						end
					end
				end
			end
		end
		setRoundEnded()
	end
	
	
	local players = getElementsByType( "player" )
	
	
	checkPlayersOutOfBounds()
	
	checkTasks( players )
	
	checkObjectives( players, tick )
	
	
	if timeLeft % 120000 < 1000 then
		changeWeather()
	end
	
	
	if currentPM then
		if data.tasks.pmRadarTime and data.tasks.pmRadarTime > 0 then
			data.tasks.pmRadarTime = data.tasks.pmRadarTime - 1
			if data.tasks.pmRadarTime == 0 then
				drawStaticTextToScreen( "draw", root, "taskFinish", "The funding has now been used, the PM is once again visible to the terrorist and psychopathic forces.", "screenX*0.775", "screenY*0.28+40", "screenX*0.179", 120, colour.important, 1, "clear", "top", "center" )
				setTimer( drawStaticTextToScreen, 10000, 1, "delete", root, "taskFinish" ) -- ok timer
				data.tasks.pmRadarTime = nil
				createPlayerBlip( currentPM )
			end
		end	
		
		-- double the amount and the tick interval to get around the health problem in mta
		-- revert if that ever gets fixed, bug #9492
		if options.pmHealthBonus and (timeLeft % 10000) < 1000 then
			if (not options.pmWaterHealthPenalty) or (not isElementInWater(currentPM)) then
				changeHealth(currentPM, options.pmHealthBonus * 2)
				--outputDebugString(string.format("tick %.4f %.4f", math.ceil(getElementHealth(currentPM)), getElementHealth(currentPM)))
			end
		end

		if options.pmWaterHealthPenalty then
			if isElementInWater(currentPM) then
				if not getElementData(currentPM, "ptpm.waterHealthPenaltyTick") then
					setElementData(currentPM, "ptpm.waterHealthPenaltyTick", tick, false)
				end

				-- -0 hp for the first 20s, then increase by 1 every 20s (-1, -2, -3, -4, etc)
				-- can survive for a little over a minute (starting with full hp) without any heals
				local enteredWater = getElementData(currentPM, "ptpm.waterHealthPenaltyTick")
				changeHealth(currentPM, -math.floor(math.max(((tick - enteredWater) / 2) / 10000, 0)))
			else
				if getElementData(currentPM, "ptpm.waterHealthPenaltyTick") then
					setElementData(currentPM, "ptpm.waterHealthPenaltyTick", nil, false)
				end				
			end
		end
		
		if options.pmAbandonedHealthPenalty and not getPedOccupiedVehicle( currentPM ) and timeLeft % (options.pmAbandonedHealthPenalty * 1000) then
			changeHealth( currentPM, -1 )
		end		
		
		if options.pmWaterDeath and isElementInWater( currentPM ) then
			killPed( currentPM, currentPM )
		end		
	end
	

	if options.medicHealthBonus then
		for _, value in ipairs(players) do
			local classID = getPlayerClassID( value )
			if value and classID and classes[classID].medic and classes[classID].type ~= "pm" then
				changeHealth( value, 1 )
			end
			
			for _, value2 in ipairs(players) do
				local ClassID2 = getPlayerClassID( value2 )
				if value2 and ClassID2 and classes[ClassID2].medic and classes[ClassID2].type ~= "pm" then
					local pX, pY, pZ = getElementPosition( value )
					local mX, mY, mZ = getElementPosition( value2 )
					if pX and pY and pZ and mX and mY and mZ then
						local d = getDistanceBetweenPoints3D( pX, pY, pZ, mX, mY, mZ )
						if d < 10 then
							if isPlayerInSameTeam( value, value2 ) then
								changeHealth( value, 1, 5 )
							end
						end
						if getPedOccupiedVehicle( value2 ) and getElementModel(getPedOccupiedVehicle( value2 )) == 416 and d < 7 then
							if isPlayerInSameTeam( value, value2 ) then
								changeHealth( value, 2 )
							end
						end
					end
				end
			end
		end
	end
end


function onColShapeHit( thePlayer, dimensionMatches )
	if not getElementType( thePlayer ) == "player" or not getPlayerClassID( thePlayer ) then return end
	
	local parent = getElementParent( source )
	
	if getElementType( parent ) == "task" then
		triggerEvent( "onTaskEnter", source, thePlayer )
	elseif getElementType( parent ) == "teleport" then
		triggerEvent( "onTeleportEnter", source, thePlayer )
	elseif getElementType( parent ) == "safezone" then
		triggerEvent( "onSafezoneEnter", source, thePlayer )
	elseif getElementType( parent ) == "objective" then
		triggerEvent( "onObjectiveEnter", source, thePlayer )
	end
end
addEventHandler( "onColShapeHit", root, onColShapeHit )


function onColShapeLeave( thePlayer, dimensionMatches )
	if not getElementType( thePlayer ) == "player" or not getPlayerClassID( thePlayer ) then return end
	
	local parent = getElementParent( source )
	
	if getElementType( parent ) == "task" then -- it's a task
		triggerEvent( "onTaskLeave", source, thePlayer )
	elseif getElementType( parent ) == "objective" then
		triggerEvent( "onObjectiveLeave", source, thePlayer )
	end
end
addEventHandler( "onColShapeLeave", root, onColShapeLeave )



function onPlayerChat( message, messageType )
	if isPlayerMuted( source ) then
		outputChatBox( "You are muted.", source, unpack( colour.personal ) )
		cancelEvent()
		return
	end
	
	if spam.resource and getResourceState(spam.resource) == "running" then
		local allow, wasPunished = exports.antiflood:shouldAllowMessage(source)
		if not allow then
			-- the punishment events will output an appropriate message
			cancelEvent()
			return
		end
	end

	if messageType == 0 then -- normal chat
		local prefix = string.sub( message, 1, 1 )
		--	if prefix == "@" then -- query
		--[[		if playerInfo[source].queryTarget then
					local text = "<" .. getPlayerName( source ) .. "> " .. string.sub( message, 2 )
					outputChatBox( text, source, unpack( colour.query ) )
				--	outputChatBox( text, playerInfo[source].queryTarget, unpack( colour.query ) )
				else
					outputChatBox( "No query established.", source, unpack( colour.personal ) )
				end
				cancelEvent()]]
		if prefix == "." and string.sub( message, 2, 2 ) ~= "." and string.sub( message, 2 ) ~= "" then -- admin chat
			adminChat(source, message)
			cancelEvent()
		else -- public chat
			message = string.gsub(message, "#%x%x%x%x%x%x", "")
			local r, g, b = getPlayerColour( source )
			outputChatBox( getPlayerName( source ) .. ":#FFFFFF " .. message, root, r, g, b, true )
			cancelEvent()
		end
			
		if gettok( message, 1, 32 ) == "t/login" or gettok( message, 1, 32 ) == "login" then 
			cancelEvent() 
		end	
	elseif messageType == 2 then -- team chat
		sendTeamChatMessage( source, message )
		cancelEvent()
	elseif messageType == 1 then -- /me
		local r, g, b = getPlayerColour( source )
		outputChatBox( "* " .. getPlayerName( source ) .. " " .. message, root, r, g, b )
		cancelEvent()
	end
end
addEventHandler( "onPlayerChat", root, onPlayerChat )


addEvent("onPlayerFloodPunished", false)
addEventHandler("onPlayerFloodPunished", root,
	function(player, data)
		if data.punishment == "mute" then
			sendGameText(player, "You have been muted for " .. tostring(data.length) .. " seconds for flooding.", 6000, sampTextdrawColours.g, nil, 1.2, nil, nil, 3)
		elseif data.punishment == "kick" then
			outputChatBox(player .. " was kicked from the server for repeated flooding.", root, unpack(colour.global))
		end
	end
)

addEvent("onPlayerFloodAbsolved", false)
addEventHandler("onPlayerFloodAbsolved", root,
	function(player, data)
		if data.punishment == "mute" then
			sendGameText(player, "You have been unmuted.", 6000, sampTextdrawColours.g, nil, 1.2, nil, nil, 2)
		end
	end
)


function adminChat( thePlayer, message )
	local myName = getPlayerName( thePlayer )
	
	for _, value in ipairs( getElementsByType( "player" ) ) do
		if value and isElement( value ) and isPlayerOp( value ) then
			outputChatBox( myName .. ": " .. message, value, unpack( colour.global ) )
		end
	end
end
--addCommandHandler( "adminChat",
--	function( thePlayer, _, ... )
--		adminChat( thePlayer, table.concat( {...}, " " ) )
--	end
--)


function sendTeamChatMessage( thePlayer, message )
	if not getPlayerClassID( thePlayer ) or not getPlayerTeam( thePlayer ) then return end

	local playerName = getPlayerName( thePlayer )
	local r, g, b = getPlayerColour( thePlayer )
	for _, value in ipairs( getElementsByType( "player" ) ) do
		if value and isElement( value ) and getPlayerClassID( value ) and isPlayerInSameTeam( thePlayer, value ) then
			outputChatBox( "(TEAM) "..playerName .. ":#FFFFFF " .. message, value, r, g, b, true )
		end
	end
end

-- compcheck
function killCommand( thePlayer )
	if not getPlayerClassID( thePlayer ) then return end
	
	if classes[getPlayerClassID( thePlayer )].type == "pm" and not isPlayerOp( thePlayer) then
		return outputChatBox( "The Prime Minister may not kill himself.", thePlayer, unpack( colour.personal ) )
	end
	
	if not isPlayerControllable( thePlayer ) or isPlayerFrozen( thePlayer ) then
	--if playerInfo[thePlayer].frozen then
		return outputChatBox( "You cannot kill yourself while frozen.", thePlayer, unpack( colour.personal ) )
	end
	
	killPed( thePlayer )
end
addCommandHandler( "kill", killCommand )

-- compcheck
function healCommand( thePlayer, commandName, otherName )
	if getElementData( thePlayer, "ptpm.watching" ) then
		return outputChatBox( "You may not heal people while you are watching.", thePlayer, unpack( colour.personal ) )
	end

	local patient = false
	
	if otherName then
		local otherPlayer = getPlayerFromNameSection( otherName )
		if otherPlayer == nil then
			return outputChatBox( "Usage: /heal (<person>)", thePlayer, unpack( colour.personal ) )
		elseif otherPlayer == false then
			return outputChatBox( "Too many matches for name '" .. otherName .. "'", thePlayer, unpack( colour.personal ) )
		end
		patient = otherPlayer
	else
		local d = 100000
		local myTeam = getPlayerTeam(thePlayer)
		local mX, mY, mZ = getElementPosition( thePlayer )
		
		for _, value in ipairs( getElementsByType( "player" ) ) do
			if value and isElement(value) and value ~= thePlayer and getPlayerClassID(value) and getPlayerTeam(value) == myTeam then
				local pHealth = getElementHealth( value )
				if math.ceil(pHealth) < 100 then
					local pX, pY, pZ = getElementPosition( value )
					
					local d2 = getDistanceBetweenPoints3D( pX, pY, pZ, mX, mY, mZ )
					if d2 < d then
						d = d2
						patient = value
					end
				end
			end
		end
	end
	
	if not patient then
		return outputChatBox( "Couldn't find anyone to heal.", thePlayer, unpack( colour.personal ) )
	end
	
	-- dont bother showing messages like this if the patient hasnt specifically been chosen
	if not getPlayerClassID( patient ) and d == 100000 then
		return outputChatBox( "Patient '" .. getPlayerName( patient ) .. "' has not yet selected class.", thePlayer, unpack( colour.personal ) )
	end
	
	playerHealPlayer( thePlayer, patient, d )
end
addCommandHandler( "heal", healCommand )
addCommandHandler( "h", healCommand )


-- compcheck
function pInfo( thePlayer, _, targetName )
	local target = getPlayerFromNameSection( targetName )
	if target == nil then
		return outputChatBox( "No matches for "..tostring(targetName)..". Usage: /pinfo <person>", thePlayer, unpack( colour.personal ) )
	elseif target == false then
		return outputChatBox( "Too many matches for name '" .. tostring(targetName) .. "'", thePlayer, unpack( colour.personal ) )
	end
	
	local exist = false
	
	local pinfoTimer = getElementData( thePlayer, "ptpm.pinfoTimer" )
	if pinfoTimer then
		if isTimer( pinfoTimer ) then
			killTimer( pinfoTimer ) 
		end
		setElementData( thePlayer, "ptpm.pinfoTimer", nil, false )
		exist = true
	end
	--if playerInfo[thePlayer].pinfoTimer then
	--	if isTimer(playerInfo[thePlayer].pinfoTimer) then
	--		killTimer(playerInfo[thePlayer].pinfoTimer) 
	--	end
	--	playerInfo[thePlayer].pinfoTimer = nil
	--	exist = true
	--end
	
	targetName = getPlayerName( target )
		
	local targetTeam = "no_team"	
	if getPlayerTeam( target ) then targetTeam = getTeamName( getPlayerTeam( target ) ) end
	
	local classID, className = getPlayerClassID( thePlayer ), "no_class"
	if classID then 
		className = classes[classID].type 
	end
	
	--local x, y, z = getElementPosition( target )
	--local pX, pY, pZ = getElementPosition( thePlayer )
	--local d = getDistanceBetweenPoints3D( x, y, z, pX, pY, pZ )
	
	local 	text = 	"Name: " .. targetName .. "\n" ..
					"Class: " .. (classID or "no_class") .. " (" .. className .. ")\n" ..
					"Team: " .. targetTeam .. "\n"
					--"Pos: " .. string.format("%.2f, %.2f, %.2f (d: %.2f)",x, y, z, d)
				
	--local vehicle = getPedOccupiedVehicle( target )
	--if vehicle then
	--	text = text .. " \nVehicle:\nModel: " ..  getElementModel( vehicle ) .. "\nName: " .. getVehicleName( vehicle )
	--end
	
  local nick = exports.ptpm_accounts:getSensitiveUserdata( target, "username" )
	if not nick then		
    text = text .. "\nAccount: Playing as guest"
	else
		text = text .. "\nAccount:\nUsername: " .. tostring( nick ) .. "\n"
	end
	
	local style = exist and "update" or "draw"
	
	drawStaticTextToScreen( style, thePlayer, "pinfo", text, 5, "screenY/3", 1000, 1000, colour.important, 1, "clear", "top", "left" )
	
	local pinfoTimer = setTimer(
		function( p )
			if p and isElement( p ) then
				drawStaticTextToScreen( "delete", p, "pinfo" )
				setElementData( p, "ptpm.pinfoTimer", nil, false )
			end
		end, 10000, 1, thePlayer )
	setElementData( thePlayer, "ptpm.pinfoTimer", pinfoTimer, false )
	--playerInfo[thePlayer].pinfoTimer = setTimer(
	--	function(p)
	--		drawStaticTextToScreen("delete", p, "pinfo")
	--		playerInfo[p].pinfoTimer = nil
	--	end,10000, 1, thePlayer)
end
addCommandHandler( "pinfo", pInfo )
addCommandHandler( "playerinfo", pInfo )


function report( thePlayer, command, victim, ... )
	if victim then
		local myName = getPlayerName( thePlayer )
		local reason = table.concat( {...}, " " )		
		if reason then
			for _, p in ipairs( getElementsByType( "player" ) ) do
				if p and isElement( p ) and isPlayerOp( p ) then
					outputChatBox( "Report by " .. myName .. ": " .. victim .. " - " .. tostring(reason) , value, unpack( colour.global ) )
				end
			end	
			outputChatBox("Thank you, your report has been sent to all available operators.",thePlayer,unpack(colour.personal))
		else
			outputChatBox("Usage: /report <player> <reason>",thePlayer,unpack(colour.personal))
		end
	else
		outputChatBox("Usage: /report <player> <reason>",thePlayer,unpack(colour.personal))
	end
end
--addCommandHandler( "report", report )



function plan( thePlayer, commandName, ... )
	if #{...} == 0 then
		if getPlayerClassID( thePlayer ) and (	classes[getPlayerClassID( thePlayer )].type == "pm" or
												classes[getPlayerClassID( thePlayer )].type == "bodyguard" or
												classes[getPlayerClassID( thePlayer )].type == "police" ) then
			showPlan( thePlayer )
		else
		--	outputChatBox( "You are not allowed to see the plan.", thePlayer, unpack( colour.personal ) )
		end
	else
		if getPlayerClassID( thePlayer ) and classes[getPlayerClassID( thePlayer )].type == "pm" then
			local newPlan = table.concat( {...}, " " )
			options.plan = newPlan
			for _, p in ipairs( getElementsByType( "player" ) ) do
				if p and isElement( p ) and getPlayerClassID( p ) and (	classes[getPlayerClassID( p )].type == "pm" or
														classes[getPlayerClassID( p )].type == "bodyguard" or
														classes[getPlayerClassID( p )].type == "police" ) then
					showPlan( p )
				end
			end
		else
		--	outputChatBox( "You are not allowed to choose the plan.", thePlayer, unpack( colour.personal ) )
		end
	end
end
addCommandHandler( "plan", plan )


function showPlan( thePlayer )
	outputChatBox( "PM's Plan: " .. (options.plan and options.plan or "The PM has not outlined a plan."), thePlayer, unpack( colour.personal ) )
end


addCommandHandler( "pm",
	function(thePlayer,cmd,targetName,...)
		local target = getPlayerFromNameSection(targetName)

		if target == nil then
			return outputChatBox( "Usage: /pm <person> <message>", thePlayer, unpack( colour.personal ) )
		elseif target == false then
			return outputChatBox( "Too many matches for name '" .. otherName .. "'", thePlayer, unpack( colour.personal ) )
		elseif target == thePlayer then
			return outputChatBox( "You can't pm yourself!", thePlayer, unpack( colour.personal ) )
		end

		
		local message = table.concat({...}," ")

		outputChatBox( "PM from "..getPlayerName(thePlayer)..": "..message, target, unpack( colour.query ) )
		outputChatBox( "PM to "..getPlayerName(target)..": "..message, thePlayer, unpack( colour.query ) )
	end
)

addEventHandler("onPlayerDamage", root,
function(attacker, weapon, bodypart, loss)
  if attacker and getElementType(attacker) == "player" and attacker ~= source then
    local damage = getElementData( attacker, "ptpm.damage" ) or 0
    local damageTaken = getElementData( source, "ptpm.damageTaken" ) or 0

    if isRunning( "ptpm_accounts" ) then        
      damage = (exports.ptpm_accounts:getPlayerStatistic( attacker, "damage" ) or damage) + loss
      exports.ptpm_accounts:setPlayerStatistic( attacker, "damage", damage )
      damageTaken = (exports.ptpm_accounts:getPlayerStatistic( source, "damagetaken" ) or damageTaken) + loss
      exports.ptpm_accounts:setPlayerStatistic( source, "damagetaken", damageTaken )
    else
      damage = damage + loss
      damageTaken = damageTaken + loss
    end
    
    setElementData( attacker, "ptpm.score.damage", string.format( "%d", damage ) )
    setElementData( attacker, "ptpm.damage", damage, false)
    setElementData( source, "ptpm.score.damageTaken", string.format( "%d", damageTaken ) )
    setElementData( source, "ptpm.damageTaken", damageTaken, false)
  end
end)


-- addCommandHandler("mo",
-- 	function(player,command,time_,x_,y_,z_,rx_,ry_,rz_)
-- 		for _,v in pairs(data.objects.attachments) do
-- 			local px,py,pz = getElementPosition(v.ob)
-- 			local time = tonumber(time_) or 10000
-- 			local x = tonumber(x_) or 0
-- 			local y = tonumber(y_) or 0
-- 			local z = tonumber(z_) or 0
-- 			local rx = tonumber(rx_) or 0
-- 			local ry = tonumber(ry_) or 0
-- 			local rz = tonumber(rz_) or 0
			
-- 			moveObject(v.ob,time,x+px,y+py,z+pz,rx,ry,rz)	
-- 		end
-- 	end
-- )