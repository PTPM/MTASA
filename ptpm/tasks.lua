﻿taskDesc = {
	["hpPenalty"] = "Investigate the Fleischberg beer factory",
	["weapons"] = "Investigate reports of illegal weapons smuggling",
	["radar"] = "Meet with an anonymous contact about a possible donation",
	["keys"] = "Investigate a tip about a set of keys",
	["accelerateTime"] = "Meet with an undercover agent regarding information about the terrorists",
	["mini"] = "Investigate an anonymous tip about a small weapons stash",
	["medic"] = "Attend the hospital to learn a new skill",
	["safehouse"] = "Activate the defences around the military base",
	["hpBonus"] = "Investigate reports of a new mysterious herb",
	["blastDoor"] = "Trigger the blast door mechanism"
}


taskFinishText = {
	["hpPenalty"] = "It has been discovered that the terrorists have been drinking out-of-date beer from the Fleischberg brewery, as a result they have contracted an illness.",
	["weapons"] = "The Prime Minister has intercepted an import of illegal weaponry.",
	["radar"] = "The Prime Minister's recent meeting with an unknown client has resulted in an increase in funding. The PM has temporarily evaded the terrorist and psychopathic forces.",
	["keys"] = "After an anonymous tip, the PM has discovered a buried set of keys gaining him access to all the vehicles on the map.",
	["accelerateTime"] = "A meeting with an undercover agent has given the PM some vital information about the terrorists' movements. They must act faster if they are to eliminate the PM.",
	["mini"] = "The PM has discovered a small ammunition stash.",
	["medic"] = "The PM has learnt the skills of a medic.",
	["safehouse"] = "The PM has enabled the SAM sites that guard the no-fly-zone.",
	["hpBonus"] = "The PM has discovered some medicinal herbs that allow him to regenerate faster.",
	["blastDoor"] = "The PM has triggered the blast door, sealing the main corridor."
} 

addEvent("onTaskEnter", false)
addEventHandler("onTaskEnter", root,
	function(thePlayer)
		if classes[getPlayerClassID(thePlayer)].type == "pm" and #getElementsByType("task", runningMapRoot) > 0 then
			local taskElement = getElementParent(source)
			
			if source == data.tasks[taskElement].taskArea then
				data.tasks.activeTask = taskElement
				
				data.tasks[taskElement].enterTime = getTickCount()
				
				setBlipColor(data.tasks[taskElement].blip, 0, 150, 0, 255)
					
				for _, p in ipairs(getElementsByType("player")) do
					if p and isElement(p) then
						local classID = getPlayerClassID(p)

						if classID then
							if classes[classID].type ~= "psycho" then
								drawStaticTextToScreen("draw", p, "taskText", data.tasks[taskElement].time/1000 .. " seconds until PM\'s task is complete.", "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, colour.important, 1, "clear", "top", "center")
								drawStaticTextToScreen("draw", p, "taskDesc", "Task description:\n" .. data.tasks[taskElement].desc, "screenX*0.775", "screenY*0.28+40", "screenX*0.179", 120, colour.important, 1, "clear", "top", "center") 						
							end
							
							if classes[classID].type == "terrorist" then
								setTaskVisibleToPlayer(p, taskElement, true)
								sendGameText(p, "The Prime Minister is attempting to complete a task!\nStop him before it is too late!", 5000, colour.sampRed, gameTextOrder.global)
							end
						end
					end
				end

				-- triggerHelpEvent(thePlayer, "TASK_ENTER")

				if data.tasks.helpTimer then
					killTimer(data.tasks.helpTimer)
					data.tasks.helpTimer = nil
				end
			end
		else
			local classID = getPlayerClassID(thePlayer)

			if teams.goodGuys[classes[classID].type] and classes[classID] ~= "pm" then
				-- triggerHelpEvent(thePlayer, "TASK_EXPLAIN")
			end
		end
	end
)


addEvent("onTaskLeave", false)
addEventHandler("onTaskLeave", root,
	function(thePlayer)
		if classes[getPlayerClassID(thePlayer)].type == "pm" and #getElementsByType("task", runningMapRoot) > 0 then
			local taskElement = getElementParent(source)
			
			if data.tasks.activeTask then -- there is an active task
				if data.tasks[taskElement].taskArea == source then -- left task area
					data.tasks.activeTask = nil
					data.tasks[taskElement].enterTime = nil
					drawStaticTextToScreen("delete", root, "taskText")
					drawStaticTextToScreen("delete", root, "taskDesc")

					setBlipColor(data.tasks[taskElement].blip, 255, 0, 0, 170)

					setupTaskHelpPromptTimer()

					for _, p in ipairs(getElementsByType("player")) do
						if p and isElement(p) then
							local classID = getPlayerClassID(p)

							if classID and classes[classID].type == "terrorist" then
								setTaskVisibleToPlayer(p, taskElement, false)
							end
						end
					end
				end
			end
		end	
	end
)



function checkTasks(players)
	if data.tasks.activeTask then
		if not data.roundEnded then
			if data.tasks[data.tasks.activeTask].time >= 0 then
				-- dont want to show this to psychos
				for _, p in ipairs(players) do
					if p and isElement(p) then
						if getPlayerClassID(p) and classes[getPlayerClassID(p)].type ~= "psycho" then
							drawStaticTextToScreen("update", p, "taskText", data.tasks[data.tasks.activeTask].time/1000 .. " seconds until PM\'s task is complete.", "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, colour.important, 1, "clear", "top", "center")
						end
					end
				end
				data.tasks[data.tasks.activeTask].time = data.tasks[data.tasks.activeTask].time - 1000
			else
				finishedTask(data.tasks.activeTask)
			end
		end
	end
end



function finishedTask(theTask)
	drawStaticTextToScreen("delete", root, "taskText")
	drawStaticTextToScreen("delete", root, "taskDesc")
	
	if isRunning("ptpm_announcer") then
		exports.ptpm_announcer:taskSecured()
	end
	
	for _, p in ipairs(getElementsByType("player")) do
		if p and isElement(p) then
			local classID = getPlayerClassID(p)
			if classID then
				if classes[classID].type ~= "psycho" then
					drawStaticTextToScreen("draw", p, "taskFinish", "PM has completed his task.\n\n" .. data.tasks[theTask].finishText, "screenX*0.775", "screenY*0.28+40", "screenX*0.179", 120, colour.important, 1, "clear", "top", "center")						
				end
			end
		end
	end
		
	setTimer(drawStaticTextToScreen, 10000, 1, "delete", root, "taskFinish") -- ok timer

	data.tasks.finished = data.tasks.finished + 1
	
	if currentPM then
		-- triggerHelpEvent(currentPM, "TASK_COMPLETE")

		setElementHealth(currentPM, 100.0)
		setPedArmor(currentPM, 100.0)
		
		local taskType = data.tasks[theTask].type
		
		if taskType == "mini" then
			giveWeapon(currentPM, 38, 30, not getPedOccupiedVehicle(currentPM) and true or false)
		elseif taskType == "hpPenalty" then
			for i = 1, #classes, 1 do
				if classes[i] and classes[i].type == "terrorist" then
					classes[i].initialHP = 50.0
				end
			end
		elseif taskType == "weapons" then
			local isNotInVehicle = not getPedOccupiedVehicle(currentPM) and true or false
			giveWeapon(currentPM, 24, 15, isNotInVehicle) -- deagle
			giveWeapon(currentPM, 32, 120, isNotInVehicle) -- tec9
			giveWeapon(currentPM, 30, 80, isNotInVehicle)
		elseif taskType == "keys" then
			data.tasks.keys = true
		elseif taskType == "radar" then
			data.tasks.pmRadarTime = 60
			removePlayerBlip(currentPM)
		elseif taskType == "accelerateTime" then
			local timePassed = getTickCount() - data.roundStartTime
			local newTimePassed = timePassed + 240000
			if newTimePassed >= options.roundtime then
				data.roundStartTime = getTickCount() - (options.roundtime - 1000)
			else
				data.roundStartTime = data.roundStartTime - 240000
			end
			
			local time = exports.missiontimer:getMissionTimerTime(data.timer)
			
			exports.missiontimer:setMissionTimerTime(data.timer, ((time - 240000) > 0) and time - 240000 or 1000)
		elseif taskType == "medic" then
			classes[getPlayerClassID(currentPM)].medic = true
		elseif taskType == "safehouse" then
			for _, zone in pairs(getElementsByType("safezone", runningMapRoot)) do
				enableSafezone(zone)
			end
		elseif taskType == "hpBonus" then
			data.pmHealthBonus = 3
		elseif taskType == "blastDoor" then
			local objects = getElementsByType("object", runningMapRoot)
			for _, value in ipairs(objects) do
				if getElementData(value, "blastDoor") == "true" then -- if it's a blast door object
					moveObject(value, tonumber(getElementData(value, "speed")), tonumber(getElementData(value, "endX")), tonumber(getElementData(value, "endY")), tonumber(getElementData(value, "endZ")))
				end
			end
		end
	end

	-- destroy the markers/blips	
	destroyElement(data.tasks[data.tasks.activeTask].taskArea) 
	data.tasks[data.tasks.activeTask].taskArea = nil
	destroyElement(data.tasks[data.tasks.activeTask].marker) 
	data.tasks[data.tasks.activeTask].marker = nil
	destroyElement(data.tasks[data.tasks.activeTask].blip) 
	data.tasks[data.tasks.activeTask].blip = nil
	
	data.tasks[data.tasks.activeTask] = nil
	data.tasks.activeTask = nil
end


function clearTaskTextFor(thePlayer)
	drawStaticTextToScreen("delete", thePlayer, "taskText")
	drawStaticTextToScreen("delete", thePlayer, "taskDesc")
	drawStaticTextToScreen("delete", thePlayer, "taskFinish")
end


function setupTaskTextFor(thePlayer)
	drawStaticTextToScreen("draw", thePlayer, "taskText", "", "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, colour.important, 1, "clear", "top", "center")
	drawStaticTextToScreen("draw", thePlayer, "taskDesc", "", "screenX*0.775", "screenY*0.28+40", "screenX*0.179", 120, colour.important, 1, "clear", "top", "center") 						
end


function clearTask()
	if data.tasks and data.tasks.activeTask then
		data.tasks.activeTask = nil
		
		drawStaticTextToScreen("delete", root, "taskText")
		drawStaticTextToScreen("delete", root, "taskDesc")
		drawStaticTextToScreen("delete", root, "taskFinish")
	end
end

function showTasksFor(player)
	local classID = getPlayerClassID(player)
	local visible = true

	if (not classID) or classes[classID].type == "psycho" or classes[classID].type == "terrorist" then 
		visible = false
	end

	for task, info in pairs(data.tasks) do
		if isElement(task) and info.blip and info.marker then
			if task == data.tasks.activeTask then
				setTaskVisibleToPlayer(player, task, classes[classID].type ~= "psycho")
			else
				setTaskVisibleToPlayer(player, task, visible)
			end
		end
	end
end

function setTaskVisibleToPlayer(player, task, visible)
	if visible == nil then
		visible = true
	end

	setElementVisibleTo(data.tasks[task].blip, player, visible)
	setElementVisibleTo(data.tasks[task].marker, player, visible)
end

function setupTaskHelpPromptTimer()
	if data.tasks.helpTimer and isTimer(data.tasks.helpTimer) then
		killTimer(data.tasks.helpTimer)
	end

	data.tasks.helpTimer = setTimer(
		function()
			if currentPM and isElement(currentPM) then
				-- triggerHelpEvent(currentPM, "TASK_NUDGE")
			end
		end,
	math.random(1, 4) * 60000, 0)
end
