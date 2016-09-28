-- PTPM AI
-- an implementation of NPC HLC by CrystalMV for PTPM

maxAI = 16--get("maxAI")
server_coldata = getResourceFromName("server_coldata")
npc_hlc = getResourceFromName("npc_hlc")
colcheck = "all"
peds = {}


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
			
			if math.random() < 0.5 then 
				randClass = math.random(13,17) -- bodyguard
			else
				randClass = math.random(19,27) -- police
			end
		else
			randClass = math.random(4,9) -- terrorist
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
		local thisPedsName = exports.namegen:generateName()
		
		theBot = createPed ( skin, spawnX,spawnY,spawnZ,spawnRot )
		setElementData ( theBot, "lastX", spawnX)
		setElementData ( theBot, "lastY", spawnY)
		setElementData ( theBot, "lastZ", spawnZ)	
		
		setElementData ( theBot, "nameTagColor", classColours[string.lower(classType)])		
		
		outputDebugString( "Created " .. thisPedsName .." with skin " .. skin )
		
		exports.npc_hlc:enableHLCForNPC(theBot, "sprint", math.random(0.5,1), 40/180)
		
		-- Let's give them a name, for debugging purposes and fun
		setElementData ( theBot, "name", thisPedsName)
		
		-- Now they learn
		addEventHandler("npc_hlc:onNPCTaskDone", theBot, taskFinished)
		
		-- Just wait a bit, then let's go!
		setTimer ( pedGoToNearestVehicle, math.random(9000,17000), 1, theBot )
		
	end
end
addEventHandler( "onGamemodeMapStart", root, ptpmAiMapStart )

function delayTask(theBot, task, thinkingTime)
	local t = 99999
	if thinkingTime=="fast" then t = math.random(1200,3500) 
	elseif thinkingTime=="normal" then t = math.random(3200,7000) 
	elseif thinkingTime=="slow" then t = math.random(6000,12000) 
	else t = math.random(3200,7000) end
	
	setTimer(call, t, 1, npc_hlc, "addNPCTask", theBot, task)
end

function taskFinished(task) 
	-- source *is* theBot
	
	outputDebugString("Ped has finished task " .. task[1])
	local nextTask = getElementData ( source, "nextTask")
	
	if (nextTask ~= nil) then
		if string.sub(nextTask[1], 0, 4)=="ptpm" then

			-- it's a proprietary PTPM task, so handle it
			if nextTask[1]=="ptpmGetInNearestVehicle" then 					
				theVeh =  nextTask[2]
				if theVeh==nil or getVehicleOccupant(theVeh)==false then
					-- these bots only drive themselves! 
					outputDebugString( "Ped found a veh" )
					warpPedIntoVehicle(source, nextTask[2], 0) 

					-- Now that they're in a vehicle, drive to the nearest node to initiate navigation
				else 
					-- find a new vehicle
					outputDebugString( "Ped went to a vehicle but it was in use. Looking for a new one..." )
					setTimer ( pedGoToNearestVehicle, math.random(100,1200), 1, source )
				end
			end		
			
		else
			-- it's not a PTPM task, so throw it over to NPCHLC
			outputDebugString("A non-ptpm task was started")
			exports.npc_hlc:addNPCTask(source, nextTask)
		end
	else
		outputDebugString("Ped ran out of tasks")
	end
end

function pedGoToNearestVehicle( theBot )
	exports.npc_hlc:clearNPCTasks (theBot)
	
	local meX, meY, meZ = getElementPosition ( theBot )
	local closestDist = 999999
	local closestVeh = nil
	
	for _, vehicle in ipairs( getElementsByType( "vehicle" ) ) do
		if getVehicleOccupant(vehicle)==false then 
			local carX, carY, carZ = getElementPosition ( vehicle )	
			local distance = getDistanceBetweenPoints3D(meX, meY, meZ,carX, carY, carZ)
			if distance < closestDist then 
				closestDist = distance
				closestVeh = vehicle
			end
		end
	end
	
	local carX, carY, carZ = getElementPosition ( closestVeh )	
	exports.npc_hlc:addNPCTask  (theBot, {"walkToPos", carX, carY, carZ, 3})
	
	setElementData ( theBot, "nextTask", { "ptpmGetInNearestVehicle", closestVeh } )
end



function aiUtility()
	--if colcheck then call(server_coldata,"generateColData",colcheck) end
	
	-- check all bots, if they are 
	for _, theBot in ipairs( getElementsByType( "ped" ) ) do
		local ox,oy,oz = getElementData ( theBot, "lastX"), getElementData ( theBot, "lastY"), getElementData ( theBot, "lastZ")
		local nx,ny,nz = getElementPosition(theBot)
		local thisPedsName = getElementData ( theBot, "name")
		
		if not isPedInVehicle(theBot) then 
			if getDistanceBetweenPoints3D(ox,oy,oz,nx,ny,nz) < 1 then
				-- all bots are supposed to be moving, like basically constantly
				-- if theyre not, they might be stuck
				setPedAnimation ( theBot , "ped", "climb_jump", 1, false, true, true , false )
				
			end
		end
		
		setElementData ( theBot, "lastX", nx)
		setElementData ( theBot, "lastY", ny)
		setElementData ( theBot, "lastZ", nz)		
	end
end
setTimer(aiUtility, 1000, 0)

-- A "Square" is the name for a navigable area in NPCHLC
function getSquareByPos(x,y)
	--return math.floor(x/SQUARE_SIZE),math.floor(y/SQUARE_SIZE)
end
