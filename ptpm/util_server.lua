function printConsole( message )
	outputServerLog( "PTPM: " .. message )
end


function tableSize( t )
	local c = 0
	for _,_ in ipairs( t ) do c = c + 1 end
	return c
end


function resetPlayerColour( thePlayer )
	local r, g, b, a = getPlayerColour( thePlayer )
	setPlayerNametagColor( thePlayer, r, g, b )
end


function getPlayerColour( thePlayer )	
	if not getPlayerClassID( thePlayer ) then return 96, 96, 96, 0 end
	local classType = classes[getPlayerClassID( thePlayer )].type 
	local colourR, colourG, colourB, colourA = 0, 0, 0, 255
	--if classType == "terrorist" then
	--	colourA = 96
	--elseif classType == "bodyguard" then
	--	colourA = 72
	--elseif classType == "police" or classType == "psycho" then
	--	colourA = 80
	--elseif classType == "pm" and data.tasks.pmRadarTime and data.tasks.pmRadarTime > 0 then
	--	colourA = 0
	--end
	
	colourR, colourG, colourB = unpack( classColours[classType .. (classes[tonumber(getPlayerClassID( thePlayer ))].medic == true and "m" or "")] )
	return colourR, colourG, colourB, colourA
end


function getPlayerFromNameSection( name )
	if not name then return nil end
	
	local resultPlayer, c = false, 0
	
	for _, player in ipairs( getElementsByType( "player" ) ) do
		if player and isElement( player ) then
			if string.find( string.lower(getPlayerName( player )), string.lower(name) ) then
				resultPlayer = player
				c = c + 1
			end
		end
	end
	
	if not resultPlayer then return nil
	elseif c > 1 then return false	
	else return resultPlayer end
end	


-- removes the blip from the player
function removePlayerBlip( thePlayer )
	setElementData( thePlayer, "ptpm.blip", nil )
end

-- creates a blip for the player (or if one already exists, resets it to its default colour/order)
function createPlayerBlip( thePlayer )
	if not getPlayerClassID( thePlayer ) then 
		return 
	end
	
	local x, y, z = getElementPosition( thePlayer )
	local r, g, b, a = getPlayerColour( thePlayer )
	
	local classType, ordering, blipSize = classes[tonumber(getPlayerClassID( thePlayer ))].type, 1, 2

	if classType == "psycho" or classType == "police" then 
		ordering = 1 -- psychos and cops are least important
	elseif classType == "terrorist" or classType == "bodyguard" then 
		ordering = 2 -- terrorists and bodyguards are equal
  	elseif classType == "pm" then
    	ordering = 3 -- pm is the most important
    	blipSize = 3
	end

	setElementData( thePlayer, "ptpm.blip", { r, g, b, a, ordering, blipSize, getElementInterior(thePlayer) } )
	
	if options.teamSpecificRadar then
		setupTeamSpecificRadar( thePlayer )
	else
		setElementData( thePlayer, "ptpm.blip.visibleto", nil )
	end
end


function setupTeamSpecificRadar( p )
	local visibleTo = {}
	local team = getPlayerTeam( p )
	
	if team == teams.goodGuys.element then		
		for i, v in ipairs( classes ) do
			local name = v.type .. (v.medic == true and "m" or "")
			
			if name == "pm" or name == "police" or name == "policem" or name == "bodyguard" or name == "bodyguardm" then
				visibleTo[#visibleTo+1] = i
			end	
		end	
	elseif team == teams.badGuys.element then
		for i, v in ipairs( classes ) do
			local name = v.type .. (v.medic == true and "m" or "")
			
			if name == "terrorist" or name == "terroristm" then
				visibleTo[#visibleTo+1] = i
			end	
		end		
	else
		for i,_ in ipairs( classes ) do
			visibleTo[#visibleTo+1] = i
		end			
	end
	setElementData( p, "ptpm.blip.visibleto", visibleTo )
end


function formatTimeLeft()
	if not options or not data or not data.roundStartTime then return "00:00" end

	local timeLeft = options.roundtime - (getTickCount() - data.roundStartTime)
	if timeLeft >= 0 then
		local timeSeconds = timeLeft % 60000
		local timeMinutes = (timeLeft - timeSeconds) / 60000
		timeSeconds = math.floor(timeSeconds / 1000)
		return string.format( "%02d:%02d", timeMinutes, timeSeconds )
	else 
		return "00:00" 
	end
end

function timeLeft( thePlayer )
	outputChatBox( "Time left: " .. formatTimeLeft(), thePlayer, unpack( colourPersonal ) )
end
addCommandHandler( "timeleft", timeLeft )

-- compcheck
-- defaults: _, _, _, {255,255,255}, "pricedown", 1.2, "top", "center", _
function sendGameText( toWho, string, duration, colour, font, size, valign, halign, importance )
	if options and not options.roundEnded then
		if toWho and isElement( toWho ) then
			if getElementType( toWho ) == "root" then
				for _, p in ipairs( getElementsByType( "player" ) ) do
					if p and isElement( p ) and isPlayerActive( p ) then
						triggerClientEvent( p, "drawGameTextToScreen", root, string, duration, colour, font, size, valign, halign, importance )
					end
				end	
			elseif getElementType( toWho ) == "player" then
				if isPlayerActive( toWho ) then
					triggerClientEvent( toWho, "drawGameTextToScreen", root, string, duration, colour, font, size, valign, halign, importance )
				end
			end
		end
	end
end

-- compcheck
function drawStaticTextToScreen( option, toWho, textID, text, x, y, width, height, colour, size, font, valign, halign )
	if options and not options.roundEnded then
		if toWho and isElement( toWho ) then
			if getElementType( toWho ) == "root" then
				for _, p in ipairs( getElementsByType( "player" ) ) do
					if p and isElement( p ) and isPlayerActive( p ) then
						triggerClientEvent( p, "drawStaticTextToScreen", root, option, textID, text, x, y, width, height, colour, size, font, valign, halign )
					end
				end	
			elseif getElementType( toWho ) == "player" then
				if isPlayerActive( toWho ) then
					triggerClientEvent( toWho, "drawStaticTextToScreen", root, option, textID, text, x, y, width, height, colour, size, font, valign, halign )
				end
			end
		end
	end
end



function everyoneViewsBody(killer, bodyPM, interiorID)
	-- Prevent dead people from respawning
	for _, p in ipairs(getElementsByType("player")) do
		if p and isElement(p) then
			local afterDeathTimer = getElementData(p, "ptpm.afterDeathTimer")
			if afterDeathTimer then
				if isTimer(afterDeathTimer) then
					killTimer(afterDeathTimer)
				end
				setElementData(p, "ptpm.afterDeathTimer", nil, false)
			end
		end
	end

	local kX, kY, kZ = getElementPosition(killer)
	local bX, bY, bZ = getElementPosition(bodyPM)
	
	if bX and bY and bZ and kX and kY and kZ then
		local vX, vY, vZ = kX - bX, kY - bY, kZ - bZ
		local d = getDistanceBetweenPoints3D(vX, vY, vZ, 0, 0, 0)

		if d > 5 then
			-- normalise to unit vector, take distance of 5m and add 1.5 to height
			vX = vX / d * 5
			vY = vY / d * 5
			vZ = vZ / d * 5 + 1.5
		else
			-- if two players are on top of each other then just go 10m upwards
			vX = 0
			vY = 0
			vZ = 10
		end
		
		for _, player in ipairs(getElementsByType("player")) do
			if player and isElement(player) and isPlayerActive(player) then
				setPlayerControllable(player, false)

				setCameraMatrix(player, bX + vX, bY + vY, bZ + vZ, bX, bY, bZ)
				setCameraInterior(player, interiorID)
				setElementInterior(player, interiorID)

				if currentPM then
					setElementDimension(player, getElementDimension(currentPM))
				end
			end
		end
	end
end



function changeHealth( thePlayer, howMuch )	
	local oldHealth = getElementHealth( thePlayer )
	local newHealth = (oldHealth + howMuch) > 100 and 100 or oldHealth + howMuch
	newHealth = newHealth < 0 and 0 or newHealth
	
	if oldHealth ~= newHealth then 
		setElementHealth( thePlayer, newHealth ) 
	end
end


function changeArmor( thePlayer, howMuch )
	local oldArmor = getPedArmor( thePlayer )
	local newArmor = (oldArmor + howMuch) > 100 and 100 or oldArmor + howMuch
	newArmor = newArmor < 0 and 0 or newArmor
	
	if oldArmor ~= newArmor then 
		setPedArmor( thePlayer, newArmor ) 
	end
end


function playerHealPlayer( medic, patient, distance )
	if not getPlayerClassID( medic ) or not getPlayerClassID( patient ) then return end
	
	if not classes[getPlayerClassID( medic )].medic then
		return outputChatBox( "You are not a medic!", medic, unpack( colourPersonal ) )
	end
	
	if medic == patient then
		return outputChatBox( "Physicians may not heal themselves.", medic, unpack( colourPersonal ) )
	end
	
	local effectiveness, radius = 2, 2
	
	if getPedOccupiedVehicle( medic ) and getPedOccupiedVehicle( medic ) == 416 then -- ambulance
		effectiveness, radius = 4, 7
	end
	
	if not distance then
		local pX, pY, pZ = getElementPosition( patient )
		local mX, mY, mZ = getElementPosition( medic )
		distance = getDistanceBetweenPoints3D( pX, pY, pZ, mX, mY, mZ )
	end
	
	if distance > radius and distance < 25 then
		if not getPedOccupiedVehicle( medic ) or not getPedOccupiedVehicle( patient ) or getPedOccupiedVehicle( medic ) ~= getPedOccupiedVehicle( patient ) then
			return outputChatBox( string.format("You are too far from '%s' (%.1fm).", getPlayerName( patient ) , distance ), medic, unpack( colourPersonal ) )
		end
	end
	
	local patientHealth = getElementHealth( patient )
	local medicHealth = getElementHealth( medic )
	
	-- medicine is what the medic loses, medicine * effectiveness is what the patient gains
	local medicine = ( 100 - patientHealth ) / effectiveness
	if medicine > ( medicHealth - 1 ) then medicine = medicHealth - 1 end
	
	if medicine <= 0 then
		return outputChatBox( "There is nothing you can do.", medic, unpack( colourPersonal ) )
	end

	local hpHealed = getElementData( medic, "ptpm.hpHealed" ) or 0

	if isRunning( "ptpm_accounts" ) then
		hpHealed = (exports.ptpm_accounts:getPlayerStatistic( medic, "hphealed" ) or hpHealed) + medicine*effectiveness
		exports.ptpm_accounts:setPlayerStatistic( medic, "hphealed", hpHealed )
	else
		hpHealed = hpHealed + medicine*effectiveness
	end

	setElementData( medic, "ptpm.score.hpHealed", string.format( "%d", hpHealed ) )
	setElementData( medic, "ptpm.hpHealed", hpHealed, false )
	
	--local text = string.format("Initial health - Medic: %.3f, Patient: %.3f, Medicine: %.3f", medicHealth, patientHealth, medicine)
	--outputChatBox( text, medic, unpack( colourPersonal ) )
	--outputChatBox( text, patient, unpack( colourPersonal ) )	
	
	setElementHealth( medic, medicHealth - medicine )
	setElementHealth( patient, patientHealth + medicine*effectiveness )
	local healthDiff = string.format("%.1f", medicine*effectiveness)
	outputChatBox( "Gave " .. healthDiff .. " health to patient.", medic, unpack( colourPersonal ) )
	outputChatBox( "You were healed by " .. healthDiff .. " health.", patient, unpack( colourPersonal ) )
end

function isPlayerInSameTeam( thePlayer, otherPlayer )
	if not getPlayerClassID( thePlayer ) or not getPlayerClassID( otherPlayer ) then return false end
	
	local playerTeam = getPlayerTeam( thePlayer )
	local otherTeam = getPlayerTeam( otherPlayer )
	
	if not playerTeam or not otherTeam then return false end
	
	return playerTeam == otherTeam 
end


function changeWeather()
	local hour = getTime()
	
	local randomWeather = options.weathers[math.random( 1, #options.weathers )]
	
	if options.mapType == "city" then
		if randomWeather == 24 and ((hour > 19 and hour < 25) or hour == 0) then
			return changeWeather() -- bad weather
		elseif randomWeather == 9 and hour == 21 then
			return changeWeather()
		end
	elseif options.mapType == "desert" then
		if (randomWeather == 308 or randomWeather == 320) then
			if hour > 17 and hour < 25 then
				return changeWeather() -- bad weather
			end
		elseif randomWeather == 19 then
			if hour == 21 then
				return changeWeather()
			end
		end
	end
	
	--setWeather( randomWeather )
	setWeatherBlended( randomWeather )
	options.currentWeather = randomWeather
	
	--outputDebugString("Changing weather to "..randomWeather)
end


function getWeather( thePlayer )
	if options and options.currentWeather then
		local hour, minute = getTime()
		outputChatBox( "Map type: " .. options.mapType .. ", Id: " .. options.currentWeather .. " - " .. hour .. ":" .. minute, thePlayer, unpack( colourPersonal ) )
	end
end
addCommandHandler( "getweather", getWeather )


addEvent( "onPlayerInteriorHit", false )
addEventHandler( "onPlayerInteriorHit", root,
	function( interior, _, id )
		if currentPM and source == currentPM then
			-- moving into an interior from outside
			local destinationInterior = getInteriorPair( interior, id )
			
			if destinationInterior then
				local destinationInteriorID = tonumber( getElementData( destinationInterior, "interior" ) )
				local pmInterior = getElementData( currentPM, "ptpm.currentInterior" )

				if destinationInteriorID ~= 0 and pmInterior == 0 then
					-- show new marker
					local x, y, z = getElementPosition( currentPM )
					local r, g, b, a = getPlayerColour( currentPM )
					local interiorBlip = getElementData( currentPM, "ptpm.interiorBlip" )
					if interiorBlip then
						destroyElement( interiorBlip )
					end
					-- x, y, z, icon, size, r, g, b, a, ordering, visibleDistance, visibleTo
					interiorBlip = createBlip( x, y, z, 0, 4, r, g, b, a, 4, 99999.0, root )
					setElementID(interiorBlip, "ptpm.blip.interior")
					setElementData( currentPM, "ptpm.interiorBlip", interiorBlip, false )

					setElementData( currentPM, "ptpm.currentInterior", destinationInteriorID, false )
					
					-- hide pm blip
					--local blip = getElementData( currentPM, "ptpm.blip" )
					--setElementData( currentPM, "ptpm.blip", { blip[1], blip[2], blip[3], 0, blip[5], blip[6] } )

				-- moving back outside from an interior
				elseif destinationInteriorID == 0 and pmInterior ~= 0 then
					-- hide new marker
					setElementData( currentPM, "ptpm.currentInterior", 0, false )

					local interiorBlip = getElementData( currentPM, "ptpm.interiorBlip" )
					if interiorBlip then
						destroyElement( interiorBlip )
						setElementData( currentPM, "ptpm.interiorBlip", nil, false )

						-- re-show the pm blip
						--local r, g, b, a = getPlayerColour( currentPM )
						--setElementData( currentPM, "ptpm.blip", { r, g, b, a, 3, 3 } )	
					end
				end
			end
		end		
	end
)


addEventHandler("onPlayerInteriorWarped", root,
	function()
		local blipData = getElementData(source, "ptpm.blip")

		if blipData then
			blipData[7] = getElementInterior(source)
			setElementData(source, "ptpm.blip", blipData)
		end
	end
)
 
 
function getInteriorPair( interior, id )
	if isElement( interior ) then
		local type = getElementType( interior )
		local revertedName = { ["interiorEntry"] = "interiorReturn", ["interiorReturn"] = "interiorEntry" }
		local revertedID = { ["interiorEntry"] = "refid", ["interiorReturn"] = "id" }
		local interiors = getElementsByType( revertedName[type] )
		if interiors then
			for k, otherInterior in ipairs( interiors ) do
				local refid = getElementData( otherInterior, revertedID[type] )
				if refid and refid == id then
					return otherInterior
				end
			end
		end
	end
end



function jetPackHandler( thePlayer )
	if isPedDead( thePlayer ) then return end
	
	if not doesPedHaveJetPack( thePlayer ) then return unbindKey( thePlayer, "enter_exit", "down", jetPackHandler ) end
	
	local rz = (getPedRotation( thePlayer ) + 180) % 360
	local x,y,z = getElementPosition( thePlayer )
	
	x = x + ( math.cos ( math.rad ( rz+90 ) ) * 3)
	y = y + ( math.sin ( math.rad ( rz+90 ) ) * 3)		
	
	local jetpack = createPickup( x, y, z, 3, 370 )
	
	data.pickups[jetpack] = {}
	data.pickups[jetpack].synced = false
	data.pickups[jetpack].respawn = false
	data.pickups[jetpack].destroy = true	
	setElementData( jetpack, "jetpack", "true" )
	
	removePedJetPack( thePlayer )
	
	data.pickups[jetpack].timer = setTimer(
		function( j )
			if data.pickups[j] then
				destroyPickup( j )
			end
		end,
	10000, 1, jetpack )
end



function explainRole( thePlayer )
	if not getPlayerClassID( thePlayer ) then return end
	
	local team = classes[getPlayerClassID( thePlayer )].type

	if team == "psycho" then
		outputChatBox( "Nobody wants to be your friend. So trust noone. Kill them all.", thePlayer, unpack( colourPersonal ) )
	elseif team == "terrorist" then
		outputChatBox( "Your role is to try and kill the Prime Minister(yellow) before the timer runs out. You must work with the other terrorists(pink)", thePlayer, unpack( colourPersonal ) )
		outputChatBox( "as a team. You must avoid the cops(blue) as they will hunt you. Beware of psychopaths(orange), they will kill anyone.", thePlayer, unpack( colourPersonal ) )
		if #data.objectives > 0 then
			outputChatBox( "The Prime Minister and his bodyguards will be visiting areas of the city. These are red on the radar. You should try and ambush", thePlayer, unpack( colourPersonal ) )
			outputChatBox( "him on his way there, siege him when he is there, and drive him away. If the Prime Minister achieves his objectives then", thePlayer, unpack( colourPersonal ) )
			outputChatBox( "you lose the game.", thePlayer, unpack( colourPersonal ) )
		end
	elseif team == "pm" then
		if #data.objectives > 0 then
			outputChatBox( "Your role is to visit and each of the objectives in order. You must defend the objective for the specified time before", thePlayer, unpack( colourPersonal ) )
			outputChatBox( "the next objective will be revealed. Terrorists(pink) and psychopaths(orange) will try to kill you. If you die, the", thePlayer, unpack( colourPersonal ) )
			outputChatBox( "terrorists win.", thePlayer, unpack( colourPersonal ) )
		else
			outputChatBox( "Your role is to avoid being killed by terrorists(pink) or psychopaths(orange) until the timer runs out. Use /timeleft to", thePlayer, unpack( colourPersonal ) )
			outputChatBox( "find out how long there is left.", thePlayer, unpack( colourPersonal ) )
		end
		outputChatBox( "You must work with your loyal bodyguards(green), they will protect you. You are to co-operate with the local police(blue), who", thePlayer, unpack( colourPersonal ) )
		outputChatBox( "will hunt the terrorists.", thePlayer, unpack( colourPersonal ) )
	elseif team == "bodyguard" then
		outputChatBox( "Your duty is to stay with the Prime Minister(yellow) and protect him from harm. Terrorists(pink) will soon try and murder him.", thePlayer, unpack( colourPersonal ) )
		outputChatBox( "Also beware of psychopaths(orange). You are to co-operate with the local police(blue), who will hunt the terrorists.", thePlayer, unpack( colourPersonal ) )
		if #data.objectives > 0 then
			outputChatBox( "The Prime Minister will be visiting areas of the city. These are red on the radar. The terrorists know where he needs to go,", thePlayer, unpack( colourPersonal ) )
			outputChatBox( "so you must prevent them from ambusing or successfully sieging the Prime Minister. If he is killed, you lose the game.", thePlayer, unpack( colourPersonal ) )
		end
	elseif team == "police" then
		outputChatBox( "Your orders are to kill the terrorists(pink) without harming the bodyguards(green) or the Prime Minister(yellow). Also beware", thePlayer, unpack( colourPersonal ) )
		outputChatBox( "of psychopaths(orange). Protect the Prime Minister!", thePlayer, unpack( colourPersonal ) )
		if #data.objectives > 0 then
			outputChatBox( "The Prime Minister and his bodyguards will be visiting areas of the city. These are red on the radar. You should focus your", thePlayer, unpack( colourPersonal ) )
			outputChatBox( "efforts there, clean out the terrorists so that the Prime Minister can go in. Then defend the area until he is done.", thePlayer, unpack( colourPersonal ) )
		end
	end
	
	if classes[getPlayerClassID( thePlayer )].medic then
		outputChatBox( "You are a medic, you can heal people with /heal!", thePlayer, unpack( colourPersonal ) )
	end
	if tableSize(data.safezone) > 0 then
		outputChatBox( "Only terrorists and bodyguards may fly the hydra or seasparrow. The Prime Minister's safehouse (red) is a hydra/seasparrow", thePlayer, unpack( colourPersonal ) )
		outputChatBox( "free zone.", thePlayer, unpack( colourPersonal ) )
	end
end
addCommandHandler( "duty", explainRole )


function showOps( thePlayer )
	for _, p in ipairs( getElementsByType( "player" ) ) do
		local sOps = ""
		if p and isElement( p ) and isPlayerOp( p ) then
			local name = getPlayerName( p ) or ""
			sOps = sOps .. name .. ", "
		end
		outputChatBox( "Online operator(s): " .. sOps, thePlayer, unpack( colourPersonal ) )
	end
end
--addCommandHandler( "ops", showOps )
--addCommandHandler( "admins", showOps )


function attach(ob1,ob2,x1,y1,z1,rx1,ry1,rz1,x2,y2,z2,rx2,ry2,rz2)
	-- taken from 'glue' by uPrell
	local sx = x1 - x2
	local sy = y1 - y2
	local sz = z1 - z2
				
	local t = math.rad(rx2)
	local p = math.rad(ry2)
	local f = math.rad(rz2)
				
	local ct = math.cos(t)
	local st = math.sin(t)
	local cp = math.cos(p)
	local sp = math.sin(p)
	local cf = math.cos(f)
	local sf = math.sin(f)
				
	local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
	local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
	local y = st*sz - sf*ct*sx + cf*ct*sy
				
	local orx = rx1 - rx2
	local ory = ry1 - ry2
	local orz = rz1 - rz2
	
	attachElements(ob1,ob2,x,y,z,orx,ory,orz)	
end


function isPlayerActive( player )
	if player and isElement( player ) then
		return getElementData( player, "ptpm.ready" ) or false
	end
	return false
end


function getPlayerClassID( player )
	if player and isElement( player ) --and isPlayerActive( player )
	then
		return getElementData( player, "ptpm.classID" ) or false
	end
	return false
end


function isPlayerOp( player )
	if isRunning( "ptpm_accounts" ) then
		if player and isElement( player ) and isPlayerActive( player ) then
			return exports.ptpm_accounts:getSensitiveUserdata( player, "operator" ) or false
		end
	end
	return false
end


function getPlayerUsername( player )
	if isRunning( "ptpm_accounts" ) then
		if player and isElement( player ) and isPlayerActive( player ) then
			return exports.ptpm_accounts:getSensitiveUserdata( player, "username" ) or false
		end
	end
	return false
end


_isPlayerMuted = isPlayerMuted
function isPlayerMuted( player )
	if isRunning( "ptpm_accounts" ) then
		if player and isElement( player ) and isPlayerActive( player ) then -- Note: is isPlayerActive good here?
			return exports.ptpm_accounts:getSensitiveUserdata( player, "muted" ) or false
		end
		return false
	else
		return _isPlayerMuted( player )
	end
end


_setPlayerMuted = setPlayerMuted
function setPlayerMuted( player, muted )
	if isRunning( "ptpm_accounts" ) then
		if player and isElement( player ) and isPlayerActive( player ) then -- Note: is isPlayerActive good here?
			return exports.ptpm_accounts:setSensitiveUserdata( player, "muted", muted ) or false
		end
		return false
	else
		return _setPlayerMuted( player, muted )
	end
end


function isPlayerFrozen( player )
	if isRunning( "ptpm_accounts" ) then
		if player and isElement( player ) and isPlayerActive( player ) then -- Note: is isPlayerActive good here?
			return exports.ptpm_accounts:getSensitiveUserdata( player, "frozen" ) or false
		end
		return false
	else
		return isElementFrozen( player )
	end
end


function setPlayerFrozen( player, frozen )
	if isRunning( "ptpm_accounts" ) then
		if player and isElement( player ) and isPlayerActive( player ) then -- Note: is isPlayerActive good here?
			setElementFrozen( player, frozen )
			return exports.ptpm_accounts:setSensitiveUserdata( player, "frozen", frozen ) or false
		end
		return false
	else
		return setElementFrozen( player, frozen )
	end
end


-- compcheck
function setPlayerControllable( player, trueOrFalse )
	if player and isElement( player ) then 
		toggleAllControls( player, trueOrFalse, true, false )
		setElementData( player, "ptpm.controllable", trueOrFalse, false )
		return true
	end
	return false
end


function isPlayerControllable( player )
	if player and isElement( player ) then 
		return getElementData( player, "ptpm.controllable" ) or false
	end
	return false
end