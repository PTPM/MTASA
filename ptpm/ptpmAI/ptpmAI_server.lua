-- PTPM AI
-- an implementation of NPC HLC by CrystalMV for PTPM

maxAI = 6--get("maxAI")
server_coldata = getResourceFromName("server_coldata")
npc_hlc = getResourceFromName("npc_hlc")
colcheck = "all"

function ptpmAiMapStart( map )

	-- When a map starts spawn all AIs
	-- the AI script operates seperately from PTPM balancedness()
	-- It just always spawns 50% good guys; 50% terrorists. Unlike in regular PTPM, bodyguards and cops hold the same weight
	runningMap = map
	runningMapName = getResourceName( map )
	initAI()

	for i=0,maxAI do
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
		local skin = tonumber(getElementData( classes[randClass].class, "skin" ))
		
		theBot = createPed ( skin, spawnX,spawnY,spawnZ,spawnRot )
		outputDebugString( "Created " .. classType .." ped with skin " .. skin )
		
		exports.npc_hlc:enableHLCForNPC(theBot, "sprint", math.random(0.5,1), 40/180)
		outputDebugString( "hlc enabled for " .. classType .."/" .. skin )
		
		--initPedRouteData(theBot)
		--addRandomNodeToPedRoute(theBot)
		outputDebugString( "init ped route data" )
		
	end
end
addEventHandler( "onGamemodeMapStart", root, ptpmAiMapStart )


function aiUtility()
	if colcheck then call(server_coldata,"generateColData",colcheck) end
end

-- A "Square" is the name for a navigable area in NPCHLC
function getSquareByPos(x,y)
	--return math.floor(x/SQUARE_SIZE),math.floor(y/SQUARE_SIZE)
end
