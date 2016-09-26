-- PTPM AI
-- an implementation of NPC HLC by CrystalMV for PTPM

maxAI = get("maxAI")
ai = {}
ai.bots = {}

function ptpmAiMapStart( map )

	-- When a map starts spawn all AIs
	-- the AI script operates seperately from PTPM balancedness()
	-- It just always spawns 50% good guys; 50% terrorists. Unlike in regular PTPM, bodyguards and cops hold the same weight
	runningMap = map
	runningMapName = getResourceName( map )

	for i=0,maxAI, 1 do
		local randClass = 0
	
		if i/maxAI<0.5 then 
			-- spawn a good guy but with a higher chance of BG so the pm doesn't feel alone
			-- just get any random classid from 13-17 and 19-27 (always +1 in rand() because it doesn't include edge values)
			-- currently medics are excluded
			
			if math.random() < 0.7 then
				randClass = math.random(13,18) -- bodyguard
			else
				randClass = math.random(19,28) -- police
			end
		else
			
			randClass = math.random(4,10) -- terrorist
		end
		
		
		-- Spawn Position
		local classType = classes[randClass].type;
		local randSpawnInt = math.random(0,#randomSpawns[classType])
		local spawnX,spawnY,spawnZ = randomSpawns[classType][randSpawnInt].posX,randomSpawns[classType][randSpawnInt].posY,randomSpawns[classType][randSpawnInt].posZ
		local spawnRot,spawnInterior = randomSpawns[classType][randSpawnInt].rot,randomSpawns[classType][randSpawnInt].interior

		-- Give weapon
		local weapons = getElementData( classes[randClass].class, "weapons" )
		local theRandomWep = 0
		if weapons then
			tokens = split(weapons,string.byte(';'))
			theRandomWep = tonumber(gettok( tokens[math.random(#tokens)], 1, 44 ))
		end
		
		-- Assign team...
		local theTeam;
		if classType ~= "terrorist" then 
			theTeam = teams.goodGuys.element;
		else 
			theTeam = teams.badGuys.element;
		end
		
		-- Spawning...
		-- theBot = exports.slothbot:spawnBot ( spawnX,spawnY,spawnZ +1, spawnRot, getElementData( classes[randClass].class, "skin" ), spawnInterior, 0, theTeam, theRandomWep, "guarding")
		table.insert(ai.bots, theBot)
		terroristAIBasicStrategy ( theBot )
		
		-- In rand() seconds... go do your thing
		
		
		
	end
end
addEventHandler( "onGamemodeMapStart", root, ptpmAiMapStart )

-- Just poll every bot every 3000 ms and update their strategy
setTimer ( function() 

	for _, theBot in ipairs( ai.bots ) do
		terroristAIBasicStrategy ( theBot )
	end

end, 3000, 0 )


function terroristAIBasicStrategy( theBot )

	-- if isPedDead( theBot ) return false
	
	local meX, meY, meZ = getElementPosition ( theBot )
	
	if currentPM then 
		local pmX, pmY, pmZ = getElementPosition ( currentPM )
		
		-- Is it far to the PM?
		if (getDistanceBetweenPoints3D(meX, meY, meZ,  pmX, pmY, pmZ) > 100) then
			-- Yes, need a vehicle
			if isPedInVehicle ( theBot ) then
				-- exports.slothbot:setBotFollow (theBot, currentPM)
			else 
				-- Find nearby vehicle
				local possibleVehs = {}
				
				for _, vehicle in ipairs( getElementsByType( "vehicle" ) ) do
					local carX, carY, carZ = getElementPosition ( vehicle )
					
					local distance = getDistanceBetweenPoints3D(meX, meY, meZ,carX, carY, carZ)
					--table.insert(possibleVehs, distance, vehicle)
				end
				
				--table.sort(possibleVehs)
				
				-- if #getVehicleOccupants(vehicle)<=getVehicleMaxPassengers(vehicle) then
			end
		
		elseif (getDistanceBetweenPoints3D(meX, meY, meZ,  pmX, pmY, pmZ) < 40) then
			-- Yes, and it's so close, will focus PM
			-- exports.slothbot:setBotChase (theBot, currentPM)
			
		else
			-- Yes, engage combat mode
			-- exports.slothbot:setBotFollow (theBot, currentPM)
		end
	
	
	
	else
		exports.slothbot:setBotHunt(theBot)
		
		-- Who is my nearest enemy?
		
		-- Is it close? Run
		
		-- Is it far? Drive
	end
	-- Basic strategy:
	--		Move to the PM
	-- 		Kill the PM
	
	-- Is there no PM? Then go hunting
	
	-- What is the distance to the PM?
	

end



function ptpmAiMapEnd( map )
	-- Remove all AIs
	table.foreach(ai.bots, function(k,v) 
		destroyElement(v)
		table.remove(ai.bots, k)
	end)
	

end
addEventHandler( "onPollEnd", root, ptpmAiMapEnd )