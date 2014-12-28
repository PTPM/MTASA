function balancedness( proposedclassid, oldclassid )
	local playersInATeamCount, dualpm, toomanybg = 0, false, false
	local playersInATeam = {}
	
	for _, value in ipairs( getElementsByType( "player" ) ) do
		if value and isElement( value ) and getPlayerClassID( value ) then
			local team = classes[getPlayerClassID( value )].type
			if not playersInATeam[team] then playersInATeam[team] = 0 end
			playersInATeam[team] = playersInATeam[team] + 1
			if team ~= "pm" and team ~= "psychopath" then playersInATeamCount = playersInATeamCount + 1 end
		end
	end

	if proposedclassid ~= false then
		local team = classes[proposedclassid].type
		if not playersInATeam[team] then playersInATeam[team] = 0 end
		playersInATeam[team] = playersInATeam[team] + 1
	   	if team ~= "pm" and team ~= "psycho" then playersInATeamCount = playersInATeamCount + 1 end
	end

	if oldclassid ~= false then
		local team = classes[oldclassid].type
		if not playersInATeam[team] then playersInATeam[team] = 0 end
		playersInATeam[team] = playersInATeam[team] - 1
	   	if team ~= "pm" and team ~= "psycho" then playersInATeamCount = playersInATeamCount + 1 end
	end

	if playersInATeam["pm"] and playersInATeam["pm"] > 1 then dualpm = true end
	if playersInATeamCount == 0 then return false, dualpm, toomanybg end

	-- a bodyguard is worth 2 cops
	-- psychos & pm do not affect balancedness
	local balancednessx = 0.0
	if not playersInATeam["bodyguard"] then playersInATeam["bodyguard"] = 0 end
	if not playersInATeam["police"] then playersInATeam["police"] = 0 end
	if not playersInATeam["terrorist"] then playersInATeam["terrorist"] = 0 end
	balancednessx = balancednessx + 0.42 * playersInATeam["bodyguard"]
	balancednessx = balancednessx + 0.28 * playersInATeam["police"]
	balancednessx = balancednessx + -0.28 * playersInATeam["terrorist"]

	local pain = math.abs( balancednessx ) * 100 / playersInATeamCount
	if (playersInATeam["bodyguard"] * 100 / playersInATeamCount) > 30 then toomanybg = true end

	return pain, dualpm, toomanybg
end



function vetoPlayerClass( classid, oldclassid )
	local prebalancedness, postbalancedness, dualpm, toomanybg
	prebalancedness, dualpm, toomanybg = balancedness( false, false )
	postbalancedness, dualpm, toomanybg = balancedness( classid, oldclassid )
	local playerCount = 0

	
	for _, value in ipairs( getElementsByType( "player" ) ) do
		if value and isElement( value ) and getPlayerClassID( value ) then
			local team = classes[getPlayerClassID( value )].type
			if team ~= "pm" and team ~= "psycho" then playerCount = playerCount + 1 end
		end
	end

	if not dualpm and ( playerCount <= 5 or postbalancedness <= 10 or postbalancedness < prebalancedness ) and ( not toomanybg or classes[classid].type ~= "bodyguard" or playerCount <= 5 ) then
		-- everything ok
		return classid
	end

	-- otherwise choice vetoed
	if classes[classid].type == "psycho" then
		return classid
	elseif classes[classid].type == "terrorist" then
		local randomPsychos = {}
		for i=0, #classes, 1 do
			if classes[i] and classes[i].type == "psycho" then
				randomPsychos[#randomPsychos+1] = i
			end
		end
		return randomPsychos[math.random(1, #randomPsychos)]
	elseif classes[classid].type == "pm" then
		-- spawning as pm always works unless theres already a pm
		if not dualpm then return classid end
		
		local randomBodyguards = {}
		for i=0, #classes, 1 do
			if classes[i] and classes[i].type == "bodyguard" then
				randomBodyguards[#randomBodyguards+1] = i
			end
		end
		return vetoPlayerClass( randomBodyguards[math.random(1, #randomBodyguards)], oldclassid )
	elseif classes[classid].type == "bodyguard" then
		-- spawning as bodyguard only works if team balancing is ok, and !toomanybg
		local randomCops = {}
		for i=0, #classes, 1 do
			if classes[i] and classes[i].type == "police" then
				randomCops[#randomCops+1] = i
			end
		end
		return vetoPlayerClass( randomCops[math.random(1, #randomCops)], oldclassid )
	elseif classes[classid].type == "police" then
		local randomPsychos = {}
		for i=0, #classes, 1 do
			if classes[i] and classes[i].type == "psycho" then
				randomPsychos[#randomPsychos+1] = i
			end
		end
		return randomPsychos[math.random(1, #randomPsychos)]
	end
	return classid
end



-- this handles setting class element data, tracking current pm and giving reclass messages
-- is triggered every time someone reclasses
function setPlayerClass( thePlayer, class )
	local playerName = getPlayerName( thePlayer )
	
	if getPlayerClassID( thePlayer ) then
		if classes[getPlayerClassID( thePlayer )].type == "pm" then 
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

		if tableSize( getElementsByType( "player" ) ) <= 8 or (class and classes[class].type == "pm") then
			outputChatBox( playerName .. " is nolonger " .. teamName .. ".", root, getPlayerColour( thePlayer ) )
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
		--exports.ptpm_accounts:setPlayerAccountData(thePlayer,{["pmCount"] = ">+1"})
		if isRunning( "ptpm_accounts" ) then
			local pmcount = exports.ptpm_accounts:getPlayerStat( thePlayer, "pmcount" ) or 0
			exports.ptpm_accounts:setPlayerStat( thePlayer, "pmcount", pmcount + 1 )
		end
	end
	
	local teamName = teamMemberName[classes[class].type]
	local string = "You are " .. teamName .. "\n".. (currentPM == thePlayer and "/swapclass" or "/reclass") .. " to change"
	local classType = classes[class].type .. (classes[class].medic and "m" or "")
	sendGameText( thePlayer, string, 7000, --[[sampTextdrawColours.y]] classColours[classType], nil, 1.3, nil, nil, 3 )
	
	if #getElementsByType( "player" ) <= 8 or classes[class].type == "pm" then
		outputChatBox( playerName .. " is now " .. teamName .. ".", root, getPlayerColour( thePlayer ) )
	end

	-- if heligrab is running, we want to drop from the heli when we reclass
	if isRunning( "heligrab" ) then
		if exports.heligrab:IsPlayerHangingFromHeli(thePlayer) then
			exports.heligrab:SetPlayerGrabbedHeli(thePlayer,false)
		end
	end
	
	makePlayerSpawn( thePlayer )
end

-- compcheck
-- handles spawn information
function makePlayerSpawn( thePlayer )	
	if data and data.roundEnded then return end

	local class = getPlayerClassID( thePlayer )
	
	if not class then return end
	
	local classType = classes[class].type
	local randNum = math.random( 0, #randomSpawns[classType] )
	local x,y,z =  randomSpawns[classType][randNum].posX, randomSpawns[classType][randNum].posY, randomSpawns[classType][randNum].posZ
	
	setElementData( thePlayer, "ptpm.goodX", x, false )
	setElementData( thePlayer, "ptpm.goodY", y, false )
	setElementData( thePlayer, "ptpm.goodZ", z, false )
	--playerInfo[thePlayer].goodX = x
	--playerInfo[thePlayer].goodY = y
	--playerInfo[thePlayer].goodZ = z
	
	spawnPlayer( thePlayer, x, y, z, randomSpawns[classType][randNum].rot, getElementData( classes[class].class, "skin" ), randomSpawns[classType][randNum].interior, 0 )

	setPedGravity( thePlayer, 0.008 )
	setCameraTarget( thePlayer, thePlayer )
	setTimer( setCameraTarget, 100, 1, thePlayer, thePlayer ) -- ok timer
	
	local weapons = getElementData( classes[class].class, "weapons" )

	if weapons then
		tokens = split(weapons,string.byte(';'))
			
		if tokens then
			for _,t in ipairs(tokens) do
				local id = tonumber( gettok( t, 1, 44 ) )
				local ammo = tonumber( gettok( t, 2, 44 ) )
					
				if id and ammo and id ~= 0 and ammo ~= 0 then
					giveWeapon( thePlayer, id, ammo )
				end
			end
		end
	end	
	
	
	if classType == "pm" then
		setElementData( thePlayer, "ptpm.currentInterior", randomSpawns[classType][randNum].interior, false )
		--playerInfo[thePlayer].currentInterior = randomSpawns[classType][randNum].interior
		options.plan = false
	end
	
	
	setPlayerMoney( thePlayer, options.pocketMoney )
	setElementHealth( thePlayer, classes[class].initialHP )
	setPedArmor( thePlayer, 0 )


	if classes[class].type == "bodyguard" or classes[class].type == "police" then
		if options.plan then 
			showPlan( thePlayer ) 
		end
	end
	
	setPlayerControllable( thePlayer, true )
	
	-- Ignore this tricky check, required if ptpm_accounts is running
	if isPlayerFrozen( thePlayer ) then
		setPedFrozen( thePlayer, true )
	end
	
	createPlayerBlip( thePlayer )
		
	setElementData( thePlayer, "ptpm.score.class", teamMemberFriendlyName[classType] .. (classes[class].medic == true and " Medic" or "")	)

	
	if tableSize( getElementsByType( "objective", runningMapRoot ) ) > 0 then
		clearObjectiveTextFor( thePlayer )
	
		setupActiveObjectiveFor( thePlayer )
		
		if data.objectives and data.objectives.activeObjective and data.objectives.pmOnObjective then
			if teams["goodGuys"][classes[class].type] then
				setupObjectiveTextFor( thePlayer )
			end
		end
	end	
	
	if tableSize( getElementsByType( "task", runningMapRoot ) ) > 0 then
		clearTaskTextFor( thePlayer )
		
		if data.tasks and data.tasks.activeTask then
			if classes[class].type ~= "psycho" then
				setupTaskTextFor( p )
			end
		end
	end
	
	for _, value in ipairs( getElementsByType( "pickup", runningMapRoot ) ) do
		if data.pickups[value] and data.pickups[value].lastPickup[thePlayer] then
			data.pickups[value].lastPickup[thePlayer] = nil
		end
	end
	
end



function onPlayerWasted( totalAmmo, killer, killerWeapon, bodypart )	
	if not killer or not isElement(killer) then killer = source end
	
	local classID = getPlayerClassID( source )
	
	if getElementType( killer ) == "vehicle" then killer = getVehicleController( killer ) or source end
	
	if classes and classID and classes[classID].type == "pm" then
		local deathCause, killerTeam = "", ""
		
		killerTeam = (getElementType(killer) == "player" and classes[getPlayerClassID( killer )].type or "")
		
		if killer ~= source then
			if isRunning( "ptpm_accounts" ) then
				local pmkills = exports.ptpm_accounts:getPlayerStat( killer, "pmkills" ) or 0
				exports.ptpm_accounts:setPlayerStat( killer, "pmkills", pmkills + 1 )
			end
		end
		
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
			
			if isRunning( "ptpm_accounts" ) then
				local players = getElementsByType( "player" )
				for _, p in ipairs( players ) do
					if p and isElement( p ) and isPlayerActive( p ) then
						local classID = getPlayerClassID( p )
						if classID then
							if classes[classID].type == "terrorist" then
								local roundswon = exports.ptpm_accounts:getPlayerStat( p, "roundswon" ) or 0
								exports.ptpm_accounts:setPlayerStat( p, "roundswon", roundswon + 1 )
							end
						end
					end
				end
			end
			
			data.roundEnded = true
			options.endGamePrepareTimer = setTimer( endGame, 3000, 1 )
		end
	end	
	
	if doesPedHaveJetPack( source ) then unbindKey( source, "enter_exit", "down", jetPackHandler ) end
	
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
			setElementData( player, "ptpm.gettingOffCamera", gettingOffCamera, false )
			
			clearCameraFor( source )	
		end		
	
		if isRunning( "ptpm_accounts" ) then
			local beststreak = exports.ptpm_accounts:getPlayerStat( source, "beststreak" ) or 0
			local currentstreak = getElementData( source, "ptpm.consecutiveKills" )
			
			if currentstreak > beststreak then
				exports.ptpm_accounts:setPlayerStat( source, "beststreak", currentstreak )
			end
		end
		setElementData( source, "ptpm.consecutiveKills", 0, false )
		--playerInfo[source].consecutiveKills = 0

		--local deaths = exports.ptpm_accounts:getPlayerAccountData(source,"deaths")
		--if deaths then
		--	exports.ptpm_accounts:setPlayerAccountData(source,{["deaths"] = tonumber(deaths) + 1})
		--end		
		
		local roundDeaths = getElementData( source, "ptpm.roundDeaths" )
		roundDeaths = (roundDeaths or 0) + 1
		setElementData( source, "ptpm.score.deaths", string.format( "%d (%d)", (deaths and deaths + 1 or 0), roundDeaths ) )
		setElementData( source, "ptpm.roundDeaths", roundDeaths, false )
		--playerInfo[source].roundDeaths = (playerInfo[source].roundDeaths or 0) + 1
		--setElementData( source, "deaths", string.format("%d (%d)",(deaths and deaths + 1 or 0),playerInfo[source].roundDeaths))
		
		if isRunning( "ptpm_accounts" ) then
			local deaths = exports.ptpm_accounts:getPlayerStat( source, "deaths" ) or 0
			exports.ptpm_accounts:setPlayerStat( source, "deaths", deaths + 1 )
		end
		
		
		if killer ~= source and getElementType(killer) == "player" and classes[getPlayerClassID( killer )] then
			local playerTeam = classes[classID].type
			local killerTeam = classes[getPlayerClassID( killer )].type		
		
			
			--local kills = exports.ptpm_accounts:getPlayerAccountData(killer,"kills")
			--if kills then
			--	exports.ptpm_accounts:setPlayerAccountData(killer,{["kills"] = tonumber(kills) + 1})
			--end	
			
			local consecutiveKills = getElementData( killer, "ptpm.consecutiveKills" )
			local roundKills = getElementData( killer, "ptpm.roundKills" )
			
			if isPlayerInSameTeam( source, killer ) and playerTeam ~= "psycho" then
				consecutiveKills = consecutiveKills - 1
				--playerInfo[killer].consecutiveKills = playerInfo[killer].consecutiveKills - 1
			else
				roundKills = (roundKills or 0) + 1
				setElementData( killer, "ptpm.score.kills", string.format( "%d (%d)",(kills and kills + 1 or 0), roundKills ) )
				--playerInfo[killer].roundKills = (playerInfo[killer].roundKills or 0) + 1
				--setElementData( killer, "kills", string.format("%d (%d)",(kills and kills + 1 or 0),playerInfo[killer].roundKills))
				
				if isRunning( "ptpm_accounts" ) then
					local kills = exports.ptpm_accounts:getPlayerStat( killer, "kills" ) or 0
					exports.ptpm_accounts:setPlayerStat( killer, "kills", kills + 1 )
					if currentPM and currentPM == killer then
						local killsaspm = exports.ptpm_accounts:getPlayerStat( killer, "killsaspm" ) or 0
						exports.ptpm_accounts:setPlayerStat( killer, "killsaspm", killsaspm + 1 )
					end
				end
			end
			
			
			if killerTeam ~= "psycho" and not isPlayerInSameTeam( source, killer ) then
				consecutiveKills = consecutiveKills + 1
				--playerInfo[killer].consecutiveKills = playerInfo[killer].consecutiveKills + 1
				
				local smgAmmo, rifleAmmo, pistolAmmo, throwAmmo, shotgunAmmo, text
				local killerName = getPlayerName( killer )
				if consecutiveKills == 4 then
				--if playerInfo[killer].consecutiveKills == 4 then
					smgAmmo = 50
					rifleAmmo = 50
					pistolAmmo = 10
					throwAmmo = 2
					shotgunAmmo = 20
					text = killerName .. " is on a rampage!"
				elseif consecutiveKills == 7 then
				--elseif playerInfo[killer].consecutiveKills == 7 then
					smgAmmo = 130
					rifleAmmo = 130
					pistolAmmo = 20
					throwAmmo = 3
					shotgunAmmo = 40
					text = killerName .. " is unstoppable!"
				elseif consecutiveKills == 10 then
				--elseif playerInfo[killer].consecutiveKills == 10 then
					smgAmmo = 200
					rifleAmmo = 200
					pistolAmmo = 30
					throwAmmo = 4
					shotgunAmmo = 60
					text = killerName .. " is godlike!"
				end				
				
				if text then
					outputChatBox( text, root, unpack( colourAchievement ) )
					outputChatBox( "Your ammo has been increased!", killer, unpack( colourAchievement ) )
					
					local slots = { [2] = pistolAmmo, [3] = shotgunAmmo, [4] = smgAmmo, [5] = rifleAmmo, [8] = throwAmmo }
					
					for key, value in pairs( slots ) do
						local weaponID = getPedWeapon( killer, key )
						
						if weaponID and getPedTotalAmmo( killer, key ) > 0 then
							giveWeapon( killer, weaponID, value )
						end
					end					
				end
			end
			setElementData( killer, "ptpm.consecutiveKills", consecutiveKills, false )
			setElementData( killer, "ptpm.roundKills", roundKills, false )
		end	
	--end
	
	
	if not data.pmDead then
		local classSelectAfterDeath = getElementData( source, "ptpm.classSelectAfterDeath" )
		if classSelectAfterDeath then
			setElementData( source, "ptpm.classSelectAfterDeath", nil, false )
		--if playerInfo and playerInfo[source] and playerInfo[source].classAfterDeath == true then
		--	playerInfo[source].classAfterDeath = nil
			local afterDeathTimer = setTimer(
				function( player )
					if player and isElement( player ) then
						initClassSelection( player )
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