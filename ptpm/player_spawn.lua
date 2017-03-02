balance = {
	value = 0,
	teamPlayers = {pm = 0, terrorist = 0, bodyguard = 0, police = 0, psycho = 0},
	totalTeamPlayers = 0,
	full = {pm = false, terrorist = false, bodyguard = false, police = false, psycho = false},

	reset = 
		function()
			balance.value = 0
			balance.teamPlayers = {pm = 0, terrorist = 0, bodyguard = 0, police = 0, psycho = 0}
			balance.totalTeamPlayers = 0
			balance.full = {pm = false, terrorist = false, bodyguard = false, police = false, psycho = false}
		end,
}

function calculateBalance()
	local playersInATeam = {pm = 0, terrorist = 0, bodyguard = 0, police = 0, psycho = 0}
	
	-- current team players
	for _, player in ipairs(getElementsByType("player")) do
		if player and isElement(player) then
			if getPlayerClassID(player) then
				local team = classes[getPlayerClassID(player)].type

				playersInATeam[team] = (playersInATeam[team] or 0) + 1
			end

			if election.active and getElementData(player, "ptpm.electionClass") then
				local team = classes[getElementData(player, "ptpm.electionClass")].type

				playersInATeam[team] = (playersInATeam[team] or 0) + 1
			end
		end
	end

	-- override for testing
	--playersInATeam = {pm = 0, terrorist = 0, bodyguard = 4, police = 100, psycho = 0}

	balance.value = getBalanceValue(playersInATeam.bodyguard, playersInATeam.police, playersInATeam.terrorist)
	balance.teamPlayers = playersInATeam
	balance.totalTeamPlayers = playersInATeam.bodyguard + playersInATeam.police + playersInATeam.terrorist

	balance.full.pm = not isBalanced("pm")
	balance.full.bodyguard = not isBalanced("bodyguard")
	balance.full.police = not isBalanced("police")
	balance.full.terrorist = not isBalanced("terrorist")
end

function getBalanceValue(totalBodyguards, totalPolice, totalTerrorists)
	-- a bodyguard is worth 2 cops
	-- psychos & pm do not affect balancedness
	local balanceValue = 0

	balanceValue = balanceValue + (0.42 * totalBodyguards)
	balanceValue = balanceValue + (0.28 * totalPolice)
	balanceValue = balanceValue + (-0.28 * totalTerrorists)

	return math.abs(balanceValue) * 100 / (totalBodyguards + totalPolice + totalTerrorists)
end

function isBalanced(proposedClassId, oldClassId)
	local proposedTeam

	-- allows us to pass in team names ("pm", "police", etc) to check for team availability
	if type(proposedClassId) == "string" then
		proposedTeam = proposedClassId
	else
		proposedTeam = classes[proposedClassId].type
	end

	-- always allow psychos
	if proposedTeam == "psycho" then
		--outputDebugString("isBalanced(" ..proposedTeam..") always allow psycho [true]")
		return true
	end

	-- can't have more than 1 pm, otherwise pm is always allowed
	if proposedTeam == "pm" then
		--outputDebugString("isBalanced(" ..proposedTeam..":"..tostring(balance.teamPlayers[proposedTeam])..") only 1 pm [" .. tostring(balance.teamPlayers.pm == 0) .."]")
		return balance.teamPlayers.pm == 0
	end

	-- for testing
	-- if proposedTeam == "terrorist" and balance.teamPlayers.terrorist > 0 and (not oldClassId or classes[oldClassId].type ~= "terrorist") then
	-- 	return false
	-- end

	-- with 5 or less players we allow anything
	if balance.totalTeamPlayers <= 5 then
		--outputDebugString("isBalanced(" ..proposedTeam..":"..tostring(balance.teamPlayers[proposedTeam])..") too few team players [true]")
		return true
	end

	local oldTeam = oldClassId and classes[oldClassId].type or nil

	-- bodyguards are hard capped at 30% of team players
	if proposedTeam == "bodyguard" and oldTeam ~= "bodyguard" and ((balance.teamPlayers.bodyguard * 100) / balance.totalTeamPlayers) > 30 then 
		--outputDebugString("isBalanced(" ..proposedTeam..":"..tostring(balance.teamPlayers[proposedTeam])..") hard capped [false]")
		return false 
	end	

	local totalBodyguards = balance.teamPlayers.bodyguard
	local totalPolice = balance.teamPlayers.police
	local totalTerrorists = balance.teamPlayers.terrorist

	if proposedTeam == "bodyguard" then
		totalBodyguards = totalBodyguards + 1
	elseif proposedTeam == "police" then
		totalPolice = totalPolice + 1
	elseif proposedTeam == "terrorist" then
		totalTerrorists = totalTerrorists + 1
	end

	if oldClassId then
		if classes[oldClassId].type == "bodyguard" then
			totalBodyguards = totalBodyguards - 1
		elseif classes[oldClassId].type == "police" then
			totalPolice = totalPolice - 1
		elseif classes[oldClassId].type == "terrorist" then
			totalTerrorists = totalTerrorists - 1
		end
	end

	local newBalance = getBalanceValue(totalBodyguards, totalPolice, totalTerrorists)

	--local balanceLow = newBalance <= 8
	--local balanceBetter = newBalance < balance.value
	--outputDebugString(string.format("isBalanced(%s:%d) check balance value (new: %.4f, old: %.4f) [%s or %s]", proposedTeam, balance.teamPlayers[proposedTeam], newBalance, balance.value, tostring(balanceLow), tostring(balanceBetter)))

	return (newBalance <= 8) or (newBalance < balance.value)
end

-- addCommandHandler("bt", 
-- 	function(player, cmd, bg, cop, terror, pm)
-- 		bg = tonumber(bg) or 0
-- 		cop = tonumber(cop) or 0
-- 		terror = tonumber(terror) or 0
-- 		pm = tonumber(pm) or 0

-- 		-- calculate new
-- 		balance.value = getBalanceValue(bg, cop, terror)
-- 		balance.teamPlayers = {pm = pm, terrorist = terror, bodyguard = bg, police = cop, psycho = 0}
-- 		balance.totalTeamPlayers = bg + cop + terror
	
-- 		outputDebugString(string.format("Balanced: bg: %s, cop: %s, terror: %s (new: %.1f, old: %.1f)", tostring(isBalanced("bodyguard")), tostring(isBalanced("police")), tostring(isBalanced("terrorist")), getBalanceValue(bg, cop, terror), balance.value))

-- 	end
-- )

-- this handles setting class element data, tracking current pm and giving reclass messages
-- is triggered every time someone reclasses
function setPlayerClass( thePlayer, class )
	local playerName = getPlayerName( thePlayer )
	local currentClassID = getPlayerClassID(thePlayer)

	if currentClassID then
		if classes[currentClassID].type == "pm" then 
			currentPM = nil
			
			local interiorBlip = getElementData( thePlayer, "ptpm.interiorBlip" )
			if interiorBlip then
				destroyElement( interiorBlip )
				setElementData( thePlayer, "ptpm.interiorBlip", nil, false )
			end	
			--if playerInfo and playerInfo[thePlayer] and playerInfo[thePlayer].interiorBlip then
			--	destroyElement(playerInfo[thePlayer].interiorBlip)
			--	playerInfo[thePlayer].interiorBlip = nil
			--end
		end
	
		local teamName = teamMemberName[classes[getPlayerClassID( thePlayer )].type]

		if #getElementsByType( "player" ) <= 8 or (classes[currentClassID].type == "pm") then
			local r, g, b = getPlayerColour( thePlayer )
			outputChatBox( playerName .. " is nolonger " .. teamName .. ".", root, r, g, b, false )
		end
	end


	setElementData( thePlayer, "ptpm.classID", class )
	
	setElementData( thePlayer, "ptpm.consecutiveKills", 0, false )
	--playerInfo[thePlayer].consecutiveKills = 0
	
	if class == false then return end

	resetPlayerColour( thePlayer )
	
	if doesPedHaveJetPack( thePlayer ) then unbindKey( thePlayer, "enter_exit", "down", jetPackHandler ) end
	
	-- NOTE: why is this in setPlayerClass? why is eveyone's team set again when one player classes?
	for _, value in ipairs( getElementsByType( "player" ) ) do
		if value and isElement( value ) then
			local c = getPlayerClassID( value )
			if c and teams["badGuys"][classes[c].type] == true then
				setPlayerTeam( value, teams.badGuys.element )
			elseif c and teams["goodGuys"][classes[c].type] == true then
				setPlayerTeam( value, teams.goodGuys.element )
			else
				setPlayerTeam( value, nil )
			end
		end
	end


	if classes[class].type == "pm" then 
		currentPM = thePlayer 
	end

	if isRunning("ptpm_accounts") then
		if classes[class].type == "pm" then
			exports.ptpm_accounts:incrementPlayerStatistic(thePlayer, "pmcount")
		elseif classes[class].type == "bodyguard" then
			exports.ptpm_accounts:incrementPlayerStatistic(thePlayer, "bgcount")
		elseif classes[class].type == "terrorist" then
			exports.ptpm_accounts:incrementPlayerStatistic(thePlayer, "terrorcount")
		elseif classes[class].type == "police" then
			exports.ptpm_accounts:incrementPlayerStatistic(thePlayer, "policecount")
		end

		if classes[class].medic then
			exports.ptpm_accounts:incrementPlayerStatistic(thePlayer, "mediccount")
		end
	end
	
	local teamName = teamMemberName[classes[class].type]

	if #getElementsByType( "player" ) <= 8 or classes[class].type == "pm" then
		local r, g, b = getPlayerColour( thePlayer );
		outputChatBox( playerName .. " is now " .. teamName .. ".", root, r, g, b, false )
	end

	-- if heligrab is running, we want to drop from the heli when we reclass
	if isRunning( "heligrab" ) then
		if exports.heligrab:IsPlayerHangingFromHeli(thePlayer) then
			exports.heligrab:SetPlayerGrabbedHeli(thePlayer,false)
		end
	end

	if isRunning("parachute") then
		exports.parachute:removeParachute(thePlayer, true)
	end

	-- recalculate the balance situation every time somebody spawns
	calculateBalance()
	
	makePlayerSpawn( thePlayer )
end

-- compcheck
-- handles spawn information
function makePlayerSpawn( thePlayer )	
	if data and data.roundEnded then return end

	local class = getPlayerClassID( thePlayer )
	
	if not class then return end
	
	local classType = classes[class].type
	local randomSpawn = teamSpawns[classType]:getRandomSpawn()

	-- generate a position (can't access directly because lines/areas/etc don't have a spawn point)
	local position = teamSpawns[classType].spawns[randomSpawn].position

	setElementData(thePlayer, "ptpm.goodX", position.x, false)
	setElementData(thePlayer, "ptpm.goodY", position.y, false)
	setElementData(thePlayer, "ptpm.goodZ", position.z, false)

	spawnPlayer(thePlayer, position.x, position.y, position.z, teamSpawns[classType].spawns[randomSpawn].rotation, classes[class].skin, teamSpawns[classType].spawns[randomSpawn].interior, 0)

	setPedGravity( thePlayer, 0.008 )
	setElementFrozen(thePlayer, false)
	setCameraTarget( thePlayer, thePlayer )
	setTimer( setCameraTarget, 100, 1, thePlayer, thePlayer ) -- ok timer

	for _, pair in ipairs(classes[class].weapons) do
		if pair[1] and pair[2] and pair[1] ~= 0 and pair[2] >= 0 then
			giveWeapon(thePlayer, pair[1], pair[2])
		end
	end

	if classType == "pm" then
		setElementData( thePlayer, "ptpm.currentInterior", teamSpawns[classType].spawns[randomSpawn].interior, false )
		options.plan = false
		setPedArmor( thePlayer, 100 )
	else
		setPedArmor( thePlayer, 0 )
	end
	
	
	setPlayerMoney( thePlayer, options.pocketMoney )
	setElementHealth( thePlayer, classes[class].initialHP )
	

	if classes[class].type == "bodyguard" or classes[class].type == "police" then
		if options.plan then 
			showPlan( thePlayer ) 
		end
	end
	
	setPlayerControllable( thePlayer, true )
	
	-- Ignore this tricky check, required if ptpm_accounts is running
	--if isPlayerFrozen( thePlayer ) then
	--	setElementFrozen( thePlayer, true )
	--end
	
	createPlayerBlip( thePlayer )
		
	setElementData( thePlayer, "ptpm.score.class", teamMemberFriendlyName[classType] .. (classes[class].medic == true and " Medic" or "")	)

	
	if data.currentMap.hasObjectives then
		clearObjectiveTextFor(thePlayer)
	
		showActiveObjectiveFor(thePlayer)
		
		if data.objectives and data.objectives.activeObjective and data.objectives.pmOnObjective then
			if teams["goodGuys"][classes[class].type] then
				setupObjectiveTextFor(thePlayer)
			end
		end
	end	
	
	if data.currentMap.hasTasks then
		clearTaskTextFor(thePlayer)

		showTasksFor(thePlayer)
		
		if data.tasks and data.tasks.activeTask then
			if classes[class].type ~= "psycho" then
				setupTaskTextFor(p)
			end
		end
	end
	
	for _, value in ipairs( getElementsByType( "pickup", runningMapRoot ) ) do
		if data.pickups[value] and data.pickups[value].lastPickup[thePlayer] then
			data.pickups[value].lastPickup[thePlayer] = nil
		end
	end
	
	helpSystemPlayerSpawn(thePlayer, class)	
end


function onPlayerWasted( totalAmmo, killer, killerWeapon, bodypart )	
	if not killer or not isElement(killer) then 
		killer = source 
	end
	
	local classID = getPlayerClassID( source )
	
	if getElementType( killer ) == "vehicle" then 
		killer = getVehicleController( killer ) or source 
	end
	
	if classes and classID and classes[classID].type == "pm" then
		local deathCause, killerTeam = "", ""

		killerTeam = (getElementType(killer) == "player" and classes[getPlayerClassID( killer )].type or "")

		if killer ~= source then
			local pmKills = getElementData(killer, "ptpm.pmKills") or 0

			if isRunning( "ptpm_accounts" ) then
				pmKills = (exports.ptpm_accounts:getPlayerStatistic( killer, "pmkills" ) or pmKills) + 1
				exports.ptpm_accounts:setPlayerStatistic( killer, "pmkills", pmKills )
			else
				pmKills = pmKills + 1
			end

			setElementData( killer, "ptpm.score.pmKills", string.format( "%d", pmKills ) )
			setElementData( killer, "ptpm.pmKills", pmKills, false )
		end

		local pmLosses = getElementData( source, "ptpm.pmLosses" ) or 0

		if isRunning( "ptpm_accounts" ) then
			pmLosses = (exports.ptpm_accounts:getPlayerStatistic( source, "pmlosses" ) or pmLosses) + 1
			exports.ptpm_accounts:setPlayerStatistic( source, "pmlosses", pmLosses )
		else
			pmLosses = pmLosses + 1
		end

		setElementData( source, "ptpm.score.pmLosses", string.format( "%d", pmLosses ) )
		setElementData( source, "ptpm.pmLosses", pmLosses, false)

		clearTask()
		clearObjective()

		if not data.roundEnded then
			if killerTeam == "pm" then deathCause = "The Prime Minister was killed in an accident!"
			elseif killerTeam == "bodyguard" then deathCause = "The Prime Minister was killed by his treacherous bodyguards!"
			elseif killerTeam == "police" then deathCause = "The Prime Minister was killed by the cops!"
			elseif killerTeam == "terrorist" then deathCause = "The Prime Minister was killed by the terrorists!"
			elseif killerTeam == "psycho" then deathCause = "The Prime Minister was killed by a psycho!"
			else printConsole( "ERROR: Invalid team on PM death" )
			end

			data.pmDead = true

			local r, g, b = getPlayerColour( killer )
			sendGameText( root, deathCause, 7000, {r, g, b}, nil, 1.4, nil, nil, 3 )

			everyoneViewsBody( killer, source, getElementInterior( source ) )

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
						elseif classes[classID].type == "pm" or classes[classID].type == "bodyguard" or classes[classID].type == "police" then
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
			setRoundEnded()
		end
	end	

	if doesPedHaveJetPack( source ) then 
		unbindKey( source, "enter_exit", "down", jetPackHandler ) 
	end

	--if playerInfo and playerInfo[source] then
	local activeCamera = getElementData( source, "ptpm.activeCamera" )
	if activeCamera then
		--if playerInfo[source].activeCamera then
		setCameraTarget( source, source )

		setElementData( source, "ptpm.activeCamera", nil, false )
		setElementData( source, "ptpm.currentCameraID", nil, false )
		setElementData( source, "ptpm.currentCameraID", true, false )
		--playerInfo[source].activeCamera = nil
		--playerInfo[source].currentCameraID = nil
		--playerInfo[source].gettingOffCamera = true

		local gettingOffCamera = setTimer(
			function( player )
				if player and isElement( player ) then
					setElementData( player, "ptpm.gettingOffCamera", nil, false )
					--playerInfo[player].gettingOffCamera = nil
				end
			end,
		200, 1, source )

		setElementData( source, "ptpm.gettingOffCamera", gettingOffCamera, false )

		clearCameraFor( source )	
	end		

	if isRunning( "ptpm_accounts" ) then
		local beststreak = exports.ptpm_accounts:getPlayerStatistic( source, "beststreak" ) or 0
		local currentstreak = getElementData( source, "ptpm.consecutiveKills" ) or 0

		if currentstreak > beststreak then
			exports.ptpm_accounts:setPlayerStatistic( source, "beststreak", currentstreak )
		end
	end

	setElementData( source, "ptpm.consecutiveKills", 0, false )
	--playerInfo[source].consecutiveKills = 0

	--local deaths = exports.ptpm_accounts:getPlayerAccountData(source,"deaths")
	--if deaths then
	--	exports.ptpm_accounts:setPlayerAccountData(source,{["deaths"] = tonumber(deaths) + 1})
	--end

	local deaths = getElementData( source, "ptpm.deaths" ) or 0


	-- fixes annoying case when you get killed in accident after pm dies (by fredro & snowy)
	if killer == source and data.roundEnded == true and classes[getPlayerClassID( killer )].type ~= "pm" then
		-- do nothing, it was an accident that the player couldn't prevent
	else    
		local deaths = getElementData( source, "ptpm.deaths" ) or 0

		if isRunning( "ptpm_accounts" ) then
			deaths = (exports.ptpm_accounts:getPlayerStatistic( source, "deaths" ) or deaths) + 1
			exports.ptpm_accounts:setPlayerStatistic( source, "deaths", deaths )
		else
			deaths = deaths + 1
		end

		setElementData( source, "ptpm.score.deaths", string.format( "%d", deaths ) )
		setElementData( source, "ptpm.deaths", deaths, false )      
	end

	--playerInfo[source].roundDeaths = (playerInfo[source].roundDeaths or 0) + 1
	--setElementData( source, "deaths", string.format("%d (%d)",(deaths and deaths + 1 or 0),playerInfo[source].roundDeaths))

	if killer ~= source and getElementType(killer) == "player" and classes[getPlayerClassID( killer )] then
		local playerTeam = classes[classID].type
		local killerTeam = classes[getPlayerClassID( killer )].type		

		--local kills = exports.ptpm_accounts:getPlayerAccountData(killer,"kills")
		--if kills then
		--	exports.ptpm_accounts:setPlayerAccountData(killer,{["kills"] = tonumber(kills) + 1})
		--end	

		local consecutiveKills = getElementData( killer, "ptpm.consecutiveKills" )
		local kills = getElementData( killer, "ptpm.kills" ) or 0

		if isPlayerInSameTeam( source, killer ) and playerTeam ~= "psycho" then
			consecutiveKills = consecutiveKills - 1
			--playerInfo[killer].consecutiveKills = playerInfo[killer].consecutiveKills - 1
		else				
			--playerInfo[killer].roundKills = (playerInfo[killer].roundKills or 0) + 1
			--setElementData( killer, "kills", string.format("%d (%d)",(kills and kills + 1 or 0),playerInfo[killer].roundKills))

			if isRunning( "ptpm_accounts" ) then
				kills = (exports.ptpm_accounts:getPlayerStatistic( killer, "kills" ) or kills) + 1
				exports.ptpm_accounts:setPlayerStatistic( killer, "kills", kills )     

				if currentPM and currentPM == killer then
					local killsaspm = exports.ptpm_accounts:getPlayerStatistic( killer, "killsaspm" ) or 0
					exports.ptpm_accounts:setPlayerStatistic( killer, "killsaspm", killsaspm + 1 )
				end
			else
				kills = kills + 1
			end

			setElementData( killer, "ptpm.score.kills", string.format( "%d", kills ) )
			setElementData( killer, "ptpm.kills", kills, false )
		end
			
		
		if killerTeam ~= "psycho" and not isPlayerInSameTeam( source, killer ) then
			consecutiveKills = consecutiveKills + 1
			--playerInfo[killer].consecutiveKills = playerInfo[killer].consecutiveKills + 1
			
			local smgAmmo, rifleAmmo, pistolAmmo, throwAmmo, shotgunAmmo, sniperAmmo, text
			local killerName = getPlayerName( killer )
			if consecutiveKills == 4 then
			--if playerInfo[killer].consecutiveKills == 4 then
				smgAmmo = 50
				rifleAmmo = 50
				pistolAmmo = 10
				throwAmmo = 2
				shotgunAmmo = 20
				sniperAmmo = 4
				text = killerName .. " is on a rampage!"
			elseif consecutiveKills == 7 then
			--elseif playerInfo[killer].consecutiveKills == 7 then
				smgAmmo = 130
				rifleAmmo = 130
				pistolAmmo = 20
				throwAmmo = 3
				shotgunAmmo = 40
				sniperAmmo = 6
				text = killerName .. " is unstoppable!"
			elseif consecutiveKills == 10 then
			--elseif playerInfo[killer].consecutiveKills == 10 then
				smgAmmo = 200
				rifleAmmo = 200
				pistolAmmo = 30
				throwAmmo = 4
				shotgunAmmo = 60
				sniperAmmo = 8
				text = killerName .. " is godlike!"
			elseif consecutiveKills > 10 and consecutiveKills % 4 == 0 then
				smgAmmo = 130
				rifleAmmo = 130
				pistolAmmo = 20
				throwAmmo = 3
				shotgunAmmo = 40
				sniperAmmo = 6
				text = killerName .. " is legendary!"
			end
			
			if text then
				outputChatBox( text, root, unpack( colour.achievement ) )
				outputChatBox( "Your ammo has been increased!", killer, unpack( colour.achievement ) )
				
				local slots = { [2] = pistolAmmo, [3] = shotgunAmmo, [4] = smgAmmo, [5] = rifleAmmo, [6] = sniperAmmo, [8] = throwAmmo }
				
				for key, value in pairs( slots ) do
					local weaponID = getPedWeapon( killer, key )
					
					if weaponID and getPedTotalAmmo( killer, key ) > 0 then
						giveWeapon( killer, weaponID, value )
					end
				end					
			end
		end
		setElementData( killer, "ptpm.consecutiveKills", consecutiveKills, false )
		setElementData( killer, "ptpm.kills", kills, false )
	end
		
	if not data.pmDead then
		local classSelectAfterDeath = getElementData( source, "ptpm.classSelectAfterDeath" )
		if classSelectAfterDeath then
			setElementData( source, "ptpm.classSelectAfterDeath", nil, false )
		--if playerInfo and playerInfo[source] and playerInfo[source].classAfterDeath == true then
		--	playerInfo[source].classAfterDeath = nil
			local afterDeathTimer = setTimer(
				function( player )
					if player and isElement( player ) then
						initClassSelection( player, true )
						setElementData( player, "ptpm.afterDeathTimer", nil, false )
					end
				end,
			5000, 1, source )
			setElementData( source, "ptpm.afterDeathTimer", afterDeathTimer, false )
		else
			local afterDeathTimer = setTimer(
				function( player )
					if player and isElement( player ) then
						makePlayerSpawn( player )
						setElementData( player, "ptpm.afterDeathTimer", nil, false )
					end
				end,
			5000, 1, source )
			setElementData( source, "ptpm.afterDeathTimer", afterDeathTimer, false )
		end
	end	
	
	local watching = getElementData( source, "ptpm.watching" )
	if watching then
	--if playerInfo[source].watching then
		exports.spectator:spectateStop(source)
	
		setElementData( source, "ptpm.watching", nil, false )
		--playerInfo[source].watching = nil
	end
end
addEventHandler( "onPlayerWasted", root, onPlayerWasted )



-- function loadKillDeathStats()
	-- local deaths = exports.ptpm_accounts:getPlayerAccountData(source,"deaths")
	
	-- setElementData( source, "deaths", string.format("%d (%d)",(deaths or 0),playerInfo[source] and playerInfo[source].roundDeaths or 0))	

	-- local kills = exports.ptpm_accounts:getPlayerAccountData(source,"kills")
		
	-- setElementData( source, "kills", string.format("%d (%d)",(kills or 0),playerInfo[source] and playerInfo[source].roundKills or 0))			
-- end
-- addEventHandler("onPtpmPlayerLogin",root,loadKillDeathStats)


-- addEventHandler("onResourceStart",root,
	-- function(res)
		-- if getResourceName(res) == "ptpm_accounts" then
			-- addEventHandler("onPtpmPlayerLogin",root,loadKillDeathStats)
		-- end
	-- end
-- )

-- addEventHandler("onResourceStop",root,
	-- function(res)
		-- if res then
			-- if getResourceName(res) == "ptpm_accounts" then
				-- removeEventHandler("onPtpmPlayerLogin",root,loadKillDeathStats)
			-- end		
		-- end
	-- end
-- )