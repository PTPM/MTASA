local width = 60
local height = 60
local buy_distance = 1.8
local using_machine = false
local using_machine_sound = nil
local using_machine_timers = {}

local local_player = getLocalPlayer()

addEvent("onClientPlayerUseVendingMachine",false)
addEvent("onClientPlayerUsedVendingMachine",false)


local machine_info = {
["vendmachfd"] = {price = 1, health = 30, marker = false}, 
["vendmach"] = {price = 1, health = 30, marker = false},
["vendin3"] = {price = 1, health = 30, marker = false},
["CJ_SPRUNK1"] = {price = 1, health = 30, marker = false},
["CJ_CANDYVENDOR"] = {price = 1, health = 30, marker = false},
["CJ_EXT_CANDY"] = {price = 1, health = 30, marker = false},
["CJ_EXT_SPRUNK"] = {price = 1, health = 30, marker = false},
["chillidogcart"] = {price = 5, health = 40, marker = -1}, -- -1 is how much to add to the z position of the machine for creating the marker, false for no marker
["icescart_prop"] = {price = 2, health = 20, marker = -1},
["noodlecart_prop"] = {price = 5, health = 40, marker = -1}
}


-- 1309 is a blank billboard?
local machine_names = {[1302] = "vendmachfd",--[[[1309] = "vendmach",]][1977] = "vendin3",[1775] = "CJ_SPRUNK1",[1776] = "CJ_CANDYVENDOR",[956] = "CJ_EXT_CANDY",[955] = "CJ_EXT_SPRUNK",[1340] = "chillidogcart",[1341] = "icescart_prop",[1342] = "noodlecart_prop"}
-- getObjectRotation doesnt return the way the object is visually facing, so we have to correct it
local rotation_correction = {[1302] = 180,--[[[1309] = 0,]][1977] = 180,[1775] = 180,[1776] = 180,[956] = 180,[955] = 180,[1340] = -90,[1341] = -90,[1342] = -90}


addEventHandler("onClientResourceStart",resourceRoot,function()
	-- loop all the default gta vending machines (from the map file) and plot them into the grid
	for _,machine in ipairs(getElementsByType("vending_machine")) do
		if machine and isElement(machine) then
			plotMachine(machine,true)
		end
	end
	
	-- loop all vending machine objects that may have been created and plot them into the grid
	for _,object in ipairs(getElementsByType("object")) do
		if object and isElement(object) then
			if machine_names[getElementModel(object)] then
			--	outputChatBox("add object, model: "..getElementModel(object))
				plotMachine(object,true)
			end
		end
	end
	
	
	bindKey("enter_exit","down",function()
			searchVendingMachine()
	end)
	
end)


addEventHandler("onClientResourceStop",resourceRoot,function()
	if using_machine then
		stopVendingMachineAnimation(local_player)
	end
end)


function plotMachine(machine,check)
	if machine then
		-- if its an object (rather than default gta machine) check that we are allowed to plot it
		if (check and not getElementData(machine,"dont_plot_machine")) or (not check) then
			local x,y,z = tonumber(getElementData(machine,"posX")), tonumber(getElementData(machine,"posY")), tonumber(getElementData(machine,"posZ"))
			local rot = tonumber(getElementData(machine,"rotZ"))
			local name = getElementData(machine,"vending_type")
			
			-- if one of the attributes is missing, could either be an object (assumption) or broken line in machines.map, attempt to generate them
			if (not x) or (not y) or (not z) or (not rot) or (not name) then 
				local model = getElementModel(machine)
				x,y,z = getElementPosition(machine) 
				rot = getElementRotation(machine) 
				rot = (rot + rotation_correction[model])%360
					
				if not name then name = machine_names[model] end
				
				local object = machine
				machine = createElement("vending_machine")
				setElementData(machine,"posX",x,false)
				setElementData(machine,"posY",y,false)
				setElementData(machine,"posZ",z,false)		
				setElementData(machine,"rotZ",rot,false)
				setElementData(machine,"vending_type",name,false)
				
				setElementData(object,"vending_machine_element",machine,false)
				
				if (not name) then outputDebugString("Failed to plot vending machine with invalid name (could not generate from id).") return end			
			end
			
			if x and y and z and rot then		
				-- plot it onto the grid and create a marker
				setElementData(machine,"vending_grid",returnGrid(x+3000,y+3000),false)
				
				local marker = machine_info[name].marker
				if marker then		
					x = x + math.sin(-math.rad(rot))*1
					y = y + math.cos(-math.rad(rot))*1
					setElementData(machine,"vending_marker",createMarker(x,y,z+marker,"cylinder",0.5,255,0,0,200),false)
				end
			else
				outputDebugString("Failed to plot vending machine with invalid information. ("..tostring(x)..","..tostring(y)..","..tostring(z)..","..tostring(rot)..")")
			end
		end
	end
end
addEvent("plotMachineClient",true)
addEventHandler("plotMachineClient",root,plotMachine)


function disableMachine(machine)
	if machine then
		if getElementData(machine,"vending_grid") then
			setElementData(machine,"vending_grid",nil,false)
			local marker = getElementData(machine,"vending_marker")
			if marker then
				destroyElement(marker)
				setElementData(machine,"vending_marker",nil,false)
			end
		-- if its an object, get the machine element
		elseif getElementData(machine,"vending_machine_element") then
			machine = getElementData(machine,"vending_machine_element")
			
			setElementData(machine,"vending_grid",nil,false)
			local marker = getElementData(machine,"vending_marker")
			if marker then
				destroyElement(marker)
				setElementData(machine,"vending_marker",nil,false)
			end
			setElementData(machine,"vending_type",nil,false)
		end
	end
end
addEvent("disableMachineClient",true)
addEventHandler("disableMachineClient",root,disableMachine)


function isPlayerUsingVendingMachine()
	return using_machine
end


function searchVendingMachine()
	if not isPedDead(local_player) and not using_machine and not isPedInVehicle(local_player) then
		local machine = isPlayerInFrontOfVendingMachine()
		if machine then
			useVendingMachine(machine)
		end
	end
end


function isPlayerInFrontOfVendingMachine()
	local x,y,z = getElementPosition(local_player)
			
	local grid = returnGrid(x+3000,y+3000)
	local found = {}
			
	for _,machine in ipairs(getElementsByType("vending_machine")) do
		if machine then
			local machine_grid = tonumber(getElementData(machine,"vending_grid"))
			if machine_grid then
				if isWithinBorderingBlock(grid,machine_grid) then
					table.insert(found,machine)
					--outputChatBox("Found machine in grid "..getElementData(machine,"vending_grid").." ("..grid..")")
				end
			end
		end
	end
			
	--outputChatBox("Found "..#found.." vending machines ("..grid..")")
			
	if #found > 0 then
		local nearest = {dist = 9999, machine = nil}
				
		for _,machine in ipairs(found) do
			local px,py,pz = getElementData(machine,"posX"), getElementData(machine,"posY"), getElementData(machine,"posZ")
			local dist = getDistanceBetweenPoints3D(x,y,z,tonumber(px),tonumber(py),tonumber(pz))
			if dist < nearest.dist then
				nearest.dist = dist
				nearest.machine = machine
			end
		end
				
		if nearest.machine and nearest.dist < buy_distance then
			local name = getElementData(nearest.machine,"vending_type")
			if name then
				local angle = findRotation(x,y,getElementData(nearest.machine,"posX"),getElementData(nearest.machine,"posY"))
				local scope = 20
				local rot = getPedRotation(local_player)
						
				if name == "icescart_prop" or name == "noodlecart_prop" or name == "chillidogcart" then scope = 30 end
						
				if compareRotations(rot,angle) <= scope then		
				--	outputChatBox("Facing machine ("..string.format("%.2f : %.2f",rot,angle)..")")
												
					angle = (angle + 180) % 360					
					local machine_rot = getElementData(nearest.machine,"rotZ")					
					if compareRotations(machine_rot,angle) <= scope then				
					--	outputChatBox("Using machine ("..string.format("%.2f : %.2f",machine_rot,angle)..")")
					--	useVendingMachine(nearest.machine)
						return nearest.machine
					else
					--	outputChatBox("Not infront of machine ("..string.format("%.2f : %.2f",machine_rot,angle)..")")
					end
				else
				--	outputChatBox("Not facing machine ("..string.format("%.2f : %.2f",rot,angle)..")")
				end
			end
		else
		--	outputChatBox("Machine not found or is not close enough")
		end
	end
	return false
end


function useVendingMachine(machine)
	if machine then	
		local health = getElementHealth(local_player)
		if health < 100 then
	--	if math.ceil(health) < tonumber(getPedStat(local_player,24)) then -- see comment below
			local cash = tonumber(getPlayerMoney(local_player))
			local price = tonumber(machine_info[getElementData(machine,"vending_type")].price)
			if cash >= price then
				-- if it has been cancelled we do not go any further
				if triggerEvent("onClientPlayerUseVendingMachine",local_player) then
					setPlayerMoney(tonumber(cash-price))
					startVendingMachineAnimation(machine)
				end
			else
				-- cannot afford
			end		
		else
			-- nothing we can do
		end	
	end
end
addEvent("useVendingMachineClient",true)
addEventHandler("useVendingMachineClient",root,function(machine)
	if machine then
		if getElementType(machine) == "object" then
			machine = getElementData(machine,"vending_machine_element")
			if machine then
				useVendingMachine(machine)
			end
		elseif getElementType(machine) == "vending_machine" then
			useVendingMachine(machine)
		end
	end
end)


function startVendingMachineAnimation(machine)
--	outputChatBox("start animation")
	using_machine = machine
	--toggleControl("enter_exit",false)
	toggleAllControls(false,true,true)
	setElementFrozen(local_player,true)
	local name = getElementData(machine,"vending_type")
	triggerServerEvent("DoVendingMachineAnimation",local_player,name)
	triggerEvent("playVendingMachineAnimation",local_player,name)
	
	if name == "vendmachfd" or name == "vendmach" or name == "vendin3" or name == "CJ_SPRUNK1" or name == "CJ_EXT_SPRUNK" then
		using_machine_sound = playSound("sprunk.wav",false)
	elseif name == "CJ_CANDYVENDOR" or name == "CJ_EXT_CANDY" then
		using_machine_sound = playSound("food.wav",false)
	else
		using_machine_sound = playSound("eating.wav",false)
	end
end


function giveVendingMachineHealth(name)
	local health = getElementHealth(local_player)
	if not isPedDead(local_player) then
		local heal = machine_info[name].health
		if health+heal > 100 then
		-- MAX_HEALTH stat defaults to 569 which fucks this up (there are also other problems with setting the MAX_HEALTH) so leave this out for now
	--	if health+heal > tonumber(getPedStat(local_player,24)) then
			setElementHealth(local_player,100)
		--	setElementHealth(local_player,tonumber(getPedStat(local_player,24)))
		else
			setElementHealth(local_player,health+heal)
		end		
	end
	
	stopVendingMachineAnimation(local_player)
end


function playVendingMachineAnimation(name)
--	outputChatBox("play animation "..tostring(source))
-- setPedAnimation ( ped thePed [, string block=nil, string anim=nil, int time=-1, bool loop=true, bool updatePosition=true, bool interruptable=true] 
	if name and source then		
		if source == local_player then
			local x,y,z = getElementPosition(source)
			setElementPosition(source,x,y,z)	
		end
		--setPedAnimation(source)
		
		using_machine_timers[source] = {}
		
		if name == "chillidogcart" or name == "icescart_prop" or name == "noodlecart_prop" then
			setPedAnimation(source,"VENDING","vend_eat1_P",4100,false,false,false)
			using_machine_timers[source][1] = setTimer(setPedAnimation,4150,1,source,nil)
			
			if source == local_player then
				using_machine_timers[source][2] = setTimer(giveVendingMachineHealth,4150,1,name)
			end
		elseif name == "CJ_CANDYVENDOR" or name == "CJ_EXT_CANDY" then
			setPedAnimation(source,"VENDING","VEND_Use",2500,false,false,false)
			using_machine_timers[source][1] = setTimer(setPedAnimation,2500,1,source,"VENDING","VEND_Use_pt2",-1,false,false,false)
			using_machine_timers[source][2] = setTimer(setPedAnimation,3000,1,source,"VENDING","VEND_Eat_p",-1,false,false,false)
		
			if source == local_player then
				using_machine_timers[source][3] = setTimer(giveVendingMachineHealth,4500,1,name)
			end			
		else
			setPedAnimation(source,"VENDING","VEND_Use",2500,false,false,false)
			using_machine_timers[source][1] = setTimer(setPedAnimation,2500,1,source,"VENDING","VEND_Use_pt2",-1,false,false,false)
			using_machine_timers[source][2] = setTimer(setPedAnimation,3000,1,source,"VENDING","VEND_Drink_P",-1,false,false,false)
			
			if source == local_player then
				using_machine_timers[source][3] = setTimer(giveVendingMachineHealth,4400,1,name)
			end
		end	
	end
end
addEvent("playVendingMachineAnimation",true)
addEventHandler("playVendingMachineAnimation",root,playVendingMachineAnimation)


function stopVendingMachineAnimation(player,external)
--	outputChatBox("stop animation "..tostring(player))
	if player then
		if using_machine_timers and using_machine_timers[player] then
			for i,timer in ipairs(using_machine_timers[player]) do
				if timer and isTimer(timer) then
					killTimer(timer)
				end
				using_machine_timers[player][i] = nil
			end
			using_machine_timers[player] = nil
		end
		
		setPedAnimation(player)		
		setElementFrozen(player,false)
		
		if player == local_player then
		--	toggleControl("enter_exit",true)	
			toggleAllControls(true,true,true)
			-- if stopVending... is triggered from the server (ie: by another resource) we dont want the player to then tell everyone else (again) that they have stopped
			if not external then 
				triggerServerEvent("stopVendingMachineAnimationServer",local_player)	
			end
			using_machine = false		
			if using_machine_sound then
				stopSound(using_machine_sound)
				using_machine_sound = nil
			end
			triggerEvent("onClientPlayerUsedVendingMachine",local_player)
		end
	end
end
addEvent("stopVendingMachineAnimation",true)
addEventHandler("stopVendingMachineAnimation",root,stopVendingMachineAnimation)


addEventHandler("onClientVehicleStartEnter",local_player,function(player)
	if using_machine then 
		-- stop the player entering the vehicle and reapply the animation
		local x,y,z = getElementPosition(player)
		setElementPosition(player,x,y,z)
			
		local machine = using_machine
		stopVendingMachineAnimation(player)
		startVendingMachineAnimation(machine)
	end
end)


addEventHandler("onClientPlayerWasted",local_player,function()
	if using_machine then
		stopVendingMachineAnimation(local_player)
	end
end)


addEventHandler("onClientPlayerSpawn",local_player,function()
	if using_machine then
		stopVendingMachineAnimation(local_player)
	end
end)


-- remove the vending functionality from mta created vending machine objects when they are removed
addEventHandler("onClientElementDestroy",root,function()
	if source and isElement(source) and getElementType(source) == "object" then
		if machine_names[getElementModel(source)] then
			disableMachine(source)
		end
	end
end)


function compareRotations(rot1,rot2)
	return math.abs((tonumber(rot1) + 180 -  tonumber(rot2)) % 360 - 180)
end


function returnGrid(x,y)
	return (math.floor((x/width)) + ( math.floor((y/height)) * 100 )) + 1
end


function findRotation(x1,y1,x2,y2) 
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	if t < 0 then t = t + 360 end
	return t
end


function isWithinBorderingBlock(player_grid,vending_grid)
	if (vending_grid >= (player_grid - 1) and vending_grid <= (player_grid + 1)) or -- same line
		(vending_grid >= (player_grid - 101) and vending_grid <= (player_grid - 99)) or -- line below
		(vending_grid >= (player_grid + 99) and vending_grid <= (player_grid + 101)) then -- line above
		return true
	end
	return false
end


--[[
local counter = 1
addCommandHandler("vend",function()
	local machines = getElementsByType("vending_machine")
	
	local x,y,z = getElementData(machines[counter],"posX"), getElementData(machines[counter],"posY"), getElementData(machines[counter],"posZ")
	
	setElementPosition(getLocalPlayer(),x,y,z+4)
	
	outputChatBox("Warped to machine "..counter)
	
	counter = counter + 1
end)

addCommandHandler("setvend",function(cmd,vend)
	counter = tonumber(vend)
end)
]]

--[[
addCommandHandler("cash",function() setPlayerMoney(getPlayerMoney(local_player)+1000) end)
addCommandHandler("health",function() setElementHealth(local_player,5) end)
]]