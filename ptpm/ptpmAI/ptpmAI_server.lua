-- PTPM AI
-- an implementation of NPC HLC by CrystalMV for PTPM

maxAI = 1--get("maxAI")
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
	
	-- Initialise routing by NPCHLC
	last_yield = getTickCount()
	initTrafficMap()
	loadPaths()
	calculateNodeLaneCounts()
	loadZOffsets()
	initAI()
	traffic_initialized = true
	
	-- Make the bots
	for i=1,maxAI do
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
		--setTimer ( pedGoToNearestVehicle, math.random(9000,17000), 1, theBot )
		setTimer ( pedGoToNearestVehicle, math.random(2000,6000), 1, theBot )
		
	end
end
addEventHandler( "onGamemodeMapStart", root, ptpmAiMapStart )

function delayTask(theBot, task, thinkingTime)
	local t = 99999
	if thinkingTime=="fast" then t = math.random(1200,3500) 
	elseif thinkingTime=="normal" then t = math.random(3200,7000) 
	elseif thinkingTime=="slow" then t = math.random(6000,12000) 
	elseif isint(thinkingTime) then t = thinkingTime 
	else t = math.random(3200,7000) end
	
	setTimer(call, t, 1, npc_hlc, "addNPCTask", theBot, task)
end

function taskFinished(task) 
	-- source *is* theBot
	
	
	local nextTask = getElementData ( source, "nextTask")
	local pedName = getElementData ( source, "name")
	
	outputDebugString(pedName .. " has finished task " .. task[1])
	
	if (nextTask ~= nil) then
		if string.sub(nextTask[1], 0, 4)=="ptpm" then

			-- it's a proprietary PTPM task, so handle it
			if nextTask[1]=="ptpmGetInNearestVehicle" then 					
				theVeh =  nextTask[2]
				if theVeh==nil or getVehicleOccupant(theVeh)==false then
					-- these bots only drive themselves! 
					outputDebugString( pedName .. " found a veh" )
					warpPedIntoVehicle(source, nextTask[2], 0) 
					
					-- Now that they're in a vehicle, drive to the nearest node to initiate navigation
					local nx,ny,nz = getElementPosition(source)
					local nearestNodeId,nearestNodeX,nearestNodeY,nearestNodeZ = findNearestNode(nx,ny,nz)
					exports.npc_hlc:addNPCTask(source, {"driveToPos", nearestNodeX,nearestNodeY,nearestNodeZ, 4})
					initPedRouteData(source)
					
					outputDebugString( pedName .. " is now driving to the nearest node" )
					
					-- Next task: navigate to PM
					setElementData ( source, "nextTask", {"ptpmNavigateToPM"} )
													
				else 
					-- find a new vehicle
					outputDebugString( pedName .. " went to a vehicle but it was in use. Looking for a new one..." )
					setTimer ( pedGoToNearestVehicle, math.random(100,1200), 1, source )
				end
				
			elseif nextTask[1]=="ptpmNavigateToPM" then 
				outputDebugString( pedName .. " is now ptpmNavigateToPM" )
				local nx,ny,nz = getElementPosition(source)
				generateNavigationPlan(source, nx,ny,nz, 0, 0, 0)
			else
				outputDebugString( pedName .. " is expected to do an undefined task.")
			end		
		else
			-- it's not a PTPM task, so throw it over to NPCHLC
			outputDebugString(pedName .. " completed a non-ptpm task completed and will now " .. nextTask[1])
			exports.npc_hlc:addNPCTask(source, nextTask)
		end
	else
		outputDebugString( pedName .. " ran out of tasks")
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


function isint(n)
  return n==math.floor(n)
end

-- A "Square" is the name for a navigable area in NPCHLC
function getSquareByPos(x,y)
	--return math.floor(x/SQUARE_SIZE),math.floor(y/SQUARE_SIZE)
end

function generateNavigationPlan(theBot, startX,startY,startZ,destX,destY,destZ)
	local startNode = findNearestNode(startX,startY,startZ)
	local destNode = findNearestNode(destX,destY,destZ)

	-- The very first node is a bit tricky, because the NPCHLC needs a starting node, although there is none
	local n1 = startNode
	ped_lastnode[theBot] = n1
	
	-- Keep adding nodes up to a maximum of 1000
	for i=1,1000 do
	
		local nearestNodeToDest = 0
		local nearestNodeDistToDest = 9999
		local nearestNodeToDestConnId = 0
	
		outputDebugString("there are " .. table.getn(node_conns[n1]) .." ways to go from here")
		outputDebugString("there are " .. #node_conns[n1] .." ways to go from here")
		
		-- Foreach available node from the previous node
		for n2,connid in pairs(node_conns[n1]) do	
			if n2==destNode then
				-- If the destination is an option, then just go there, dude
				nearestNodeToDest = n2
				nearestNodeDistToDest = 0
				nearestNodeToDestConnId = connid
				
				outputDebugString("n2==destNode")
			else
				local n2x,n2y,n2z = getPosFromNode(n2)
				local theDist = getDistanceBetweenPoints3D(n2x,n2y,n2z,destX,destY,destZ)
				
				-- Find the one that will get you closest to the destination (TODO: might not be correct in most cases)
				if theDist<nearestNodeDistToDest then
					nearestNodeToDest = n2
					nearestNodeDistToDest = theDist
					nearestNodeToDestConnId = connid
				end
				outputDebugString("option: conn=" .. connid .. " (n2=" .. n2 .. ")")
			end
		end
		-- Drive to it 
		outputDebugString("nav from node " .. n1 .. " to node " .. nearestNodeToDest)
		addNodeToPedRoute(theBot,nearestNodeToDest,conn_nb[nearestNodeToDestConnId])
	end
	
	
	-- local n2num = ped_lastnode[ped]
	-- local n1num,n3num = n2num-1,n2num+1
	-- local n1,n2 = ped_nodes[ped][n1num],ped_nodes[ped][n2num]
	-- local possible_turns = {}
	-- local total_density = 0
	-- local c12 = node_conns[n1][n2]
	-- for n3,connid in pairs(node_conns[n2]) do
		-- local c23 = node_conns[n2][n3]
		-- if not conn_forbidden[c12][c23] then
			-- if conn_lanes.left[connid] == 0 and conn_lanes.right[connid] == 0 then
				-- if n3 ~= n1 then
					-- local density = conn_density[connid]
					-- total_density = total_density+density
					-- table.insert(possible_turns,{n3,connid,density})
				-- end
			-- else
				-- local dirmatch1 = areDirectionsMatching(n2,n1,n2)
				-- local dirmatch2 = areDirectionsMatching(n2,n2,n3)
				-- if dirmatch1 == dirmatch2 then
					-- local density = conn_density[connid]
					-- total_density = total_density+density
					-- table.insert(possible_turns,{n3,connid,density})
				-- end
			-- end
		-- end
	-- end
	-- local n3,connid
	-- local possible_count = #possible_turns
	-- if possible_count == 0 then
		-- n3,connid = next(node_conns[n2])
	-- else
		-- local pos = math.random()*total_density
		-- local num = 1
		-- while true do
			-- num = num%possible_count+1
			-- local turn = possible_turns[num]
			-- pos = pos-turn[3]
			-- if pos <= 0 then
				-- n3,connid = turn[1],turn[2]
				-- break
			-- end
		-- end
	-- end
end

function findNearestNode(sx,sy,sz)
	local startTime = getTickCount()
	
	local nearestDist = 9999
	local nearestNodeId = 0
	local nearestNodeX,nearestNodeY,nearestNodeZ = 0,0,0
	
	if node_x ~= nil then		
		for nodeid, nodeX in ipairs(node_x) do
			local nodeY = node_y[nodeid]
			local nodeZ = node_z[nodeid]
			local theDist = getDistanceBetweenPoints3D(sx,sy,sz,nodeX,nodeY,nodeZ)
			
			if (theDist<nearestDist) then
				nearestDist = theDist
				nearestNodeId = nodeid
				nearestNodeX,nearestNodeY,nearestNodeZ = nodeX,nodeY,nodeZ
			end
		end
		--turns out to be not even that resource heavy
		--outputDebugString("Found nearest node: " .. nearestNodeId .. " (dist: " .. nearestDist..") in " .. (getTickCount()-startTime) .. " ms")
		return nearestNodeId,nearestNodeX,nearestNodeY,nearestNodeZ
	else
		outputDebugString("Node information was empty.")
	end

end

function getPosFromNode(nodeId)
	return node_x[nodeId],node_y[nodeId],node_z[nodeId]
end
