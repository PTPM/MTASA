--[[
	Help event:
	id
	{
		text,
		requires, -- id
		obsoletes, -- id
		importance, -- int
		condition = {
			fn,
			args,
		},
		increment, -- player data to increment when viewed
		cooldown, -- don't show this prompt again for this amount of time
		displayTime,
		force,
		linkHelpManager, -- show a help manager call to action in the prompt
	}

]]

help = {
	events = {},
	displayTime = 6000,
	cooldowns = {},
}


function helpSystemSetup()
	helpSystemCreateDefinitions()

	help.randomTimer = setTimer(randomHelpEvent, math.random(60000 * 3, 60000 * 8), 1)
end

function helpSystemPlayerSpawn(player, class)
	local events = {}

	if classes[class].type == "terrorist" then
		table.insert(events, "BASICS_TERRORIST")
	elseif classes[class].type == "pm" then
		table.insert(events, "BASICS_PM")
	elseif classes[class].type == "bodyguard" then
		table.insert(events, "BASICS_BODYGUARD")
	elseif classes[class].type == "police" then
		table.insert(events, "BASICS_POLICE")
	end

	if data.currentMap.hasObjectives then
		if classes[class].type == "pm" then
			table.insert(events, "OBJECTIVE_OVERVIEW_PM")
		else
			table.insert(events, "OBJECTIVE_OVERVIEW")
		end
	end

	if data.currentMap.hasTasks then
		if classes[class].type == "pm" then
			table.insert(events, "TASK_OVERVIEW_PM")
		else
			table.insert(events, "TASK_OVERVIEW")
		end
	end	

	if options.displayDistanceToPM and classes[class].type == "terrorist" then
		table.insert(events, "OPTION_DISTANCE_TO_PM")
	end

	if classes[class].medic then
		table.insert(events, "MEDIC_HEAL")
	end

	if classes[class].type == "pm" and options.pmWaterDeath then
		table.insert(events, "OPTION_PM_WATER_DEATH")
	end

	if classes[class].type == "pm" then
		table.insert(events, "COMMAND_PLAN")
	else
		if (classes[class].type == "bodyguard" or classes[class].type == "police") and options.plan then
			table.insert(events, "COMMAND_PLAN_SET")
		end
	end

	if options.plan and (classes[class].type == "bodyguard" or classes[class].type == "police") then
		table.insert(events, "COMMAND_PLAN_SET")
	end

	if data.currentMap.hasAmbulances and classes[class].medic then
		table.insert(events, "MEDIC_AMBULANCE")
	end

	triggerHelpEvents(player, events, true, 3)
end
	
function randomHelpEvent()
	if data.roundEnded then
		return
	end
	
	for i, player in ipairs(getElementsByType("player")) do
		local classID = getPlayerClassID(player)

		if classID and (not isPedDead(player)) then
			if classes[classID].type ~= "pm" then
				triggerHelpEvents(player, {"COMMAND_RECLASS", "COMMAND_DUTY", "BIND_F4"}, false, 1, true)
			else
				triggerHelpEvents(player, {"COMMAND_SWAPCLASS", "COMMAND_PLAN"}, false, 1, true)
			end
		end
	end

	help.randomTimer = setTimer(randomHelpEvent, math.random(60000 * 10, 60000 * 20), 1)
end


-- register an event within the help system
-- data contains everything necessary to actually display a help notification (e.g. text)
function registerHelpEvent(id, data)
	if help.events[id] then
		outputDebugString("Error: help system already contains an event with id '" .. tostring(id) .. "'")
		return
	end

	if not data.text or type(data.text) ~= "string" or #data.text == 0 then
		outputDebugString("Error: cannot register help event '" .. tostring(id) .. "' because it has no text")
		return
	end

	data.importance = data.importance or 0
	data.linkHelpManager = data.linkHelpManager ~= false
	data.text = colour.hex.parse(data.text)

	help.events[id] = data
end

-- decide whether to act on this trigger
function triggerHelpEvent(player, id, queue)
	if not help.events[id] then
		outputDebugString("Error: cannot trigger help event with id '" .. tostring(id) .. "' because it does not exist")
		return false
	end

	if data.roundEnded or getElementData(player, "ptpm.inClassSelection") then
		return false
	end

	if not queue and not help.events[id].force then
		local currentHelp = getPlayerCurrentHelpEvent(player)

		-- currently viewing a help message
		if currentHelp then
			-- new one is less important than the current one, so do not override
			if help.events[id].importance <= help.events[currentHelp].importance then
				--outputDebugString("ignoring '" .. tostring(id) .. "' because player is already viewing a help event")
				return false
			end
		end
	end

	-- reject if we are within the cooldown period
	if help.events[id].cooldown and not help.events[id].force then
		if help.cooldowns[player] and help.cooldowns[player][id] then
			if getTickCount() - help.cooldowns[player][id] <= help.events[id].cooldown then
				--outputDebugString("ignoring '" .. tostring(id) .. "' because it is within the cooldown period")
				return false
			end
		end
	end

	if not doesPlayerMeetHelpEventRequirements(player, id) then
		--outputDebugString("player does not meet requirements for '" .. tostring(id) .. "'")
		return false
	end

	showHelpEvent(player, id)

	return true
end

function triggerHelpEvents(player, events, queue, queueLimit, randomStart)
	local count = 0
	local start = 0

	if randomStart then
		start = math.random(1, #events)
	end

	--for _, e in ipairs(events) do
	for i = 1, #events do
		if triggerHelpEvent(player, events[((start + i - 1) % #events) + 1], queue) then
			count = count + 1

			if queueLimit and count == queueLimit then
				return
			end
		end
	end

	return
end

-- actually show the help event notification
function showHelpEvent(player, id)
	if not help.events[id] then
		outputDebugString("Error: cannot show help event with id '" .. tostring(id) .. "' because it does not exist")
		return
	end

	local currentHelp = getPlayerCurrentHelpEvent(player)
	local duration = help.events[id].displayTime or help.displayTime

	-- guests get a lower duration, to help limit prompt spam
	local username = getPlayerUsername(player)
	if not username then
		duration = duration * 0.7;
	end

	triggerClientEvent(player, "showHelpEvent", resourceRoot, 
		colour.hex.parseContextual(help.events[id].text, player), 
		duration, 
		help.events[id].image, 
		help.events[id].linkHelpManager and id or nil,
		help.events[id].force or currentHelp ~= nil
	)

	if help.events[id].increment and isRunning("ptpm_accounts") then
		exports.ptpm_accounts:incrementPlayerStatistic(player, help.events[id].increment)
	end

	if help.events[id].cooldown then
		if not help.cooldowns[player] then
			help.cooldowns[player] = {}
		end

		help.cooldowns[player][id] = getTickCount()
	end

	setElementData(player, "ptpm.lastHelp", id, false)
	setElementData(player, "ptpm.lastHelpTick", getTickCount(), false)
end

function hideHelpEvent(player, id)
	local currentHelp = getPlayerCurrentHelpEvent(player)

	if not currentHelp or currentHelp ~= id then
		return
	end

	triggerClientEvent(player, "hideHelpEvent", resourceRoot)

	setElementData(player, "ptpm.lastHelpTick", 0, false)
end

function doesPlayerMeetHelpEventRequirements(player, id)
	if not help.events[id] then
		return false
	end	

	if help.events[id].force then
		return true
	end

	-- does the player still need to do the required events
	if help.events[id].requires then
		if doesPlayerMeetHelpEventRequirements(player, help.events[id].requires) then
			return false
		end
	end

	if help.events[id].condition then
		if not conditionProcessor(player, help.events[id].condition.fn, help.events[id].condition.args) then
			return false
		end
	end

	return true
end

function getPlayerCurrentHelpEvent(player)
	local lastHelpTick = getElementData(player, "ptpm.lastHelpTick") or 0
	local lastHelp = getElementData(player, "ptpm.lastHelp")
	local now = getTickCount()

	-- currently viewing a help message (2000 is the animation length, 1s in + 1s out)
	if (now - lastHelpTick) < (lastHelp and help.events[lastHelp].displayTime or help.displayTime) + 2000 then
		return lastHelp
	end
end

-- parse the condition args for any special cases
function conditionProcessor(player, fn, args)
	local pArg = nil

	if (not player) or (not isElement(player)) then
		outputDebugString("Error: bad player passed to conditionProcessor ("..tostring(fn)..", "..tostring(conditionTaskExplanationComparison)..")", 1)
		return
	end

	for i, arg in ipairs(args) do
		if arg == "__player" then
			args[i] = player

			if pArg then
				outputDebugString("Error: multiple player args in conditionProcessor ("..tostring(fn)..", "..tostring(conditionTaskExplanationComparison)..")", 1)
			end

			pArg = i
		end
	end

	-- debug stuff
	for i, arg in ipairs(args) do
		if i == pArg then
			if (not arg) or (not isElement(arg)) then
				local playerName = "-error-"

				if player and isElement(player) then
					playerName = getPlayerName(player)
				end

				outputDebugString("Error: player arg substituted for bad data on player " .. tostring(playerName).." ("..tostring(fn)..", "..tostring(conditionTaskExplanationComparison)..")", 1)
			end
		end
	end	

	if fn == conditionTaskExplanationComparison then
		local eType = "-not an element-"

		if args[1] and isElement(args[1]) then
			eType = getElementType(args[1])
		end

		outputDebugString("pre-conditionTaskExplanationComparison: player: '" .. tostring(args[1]).. "', "..tostring(eType), 1)
	end

	-- call through to the actual condition comparator
	return fn(unpack(args))
end

function conditionStatNumberComparison(player, statName, greater, value)
	if not isRunning("ptpm_accounts") then
		if greater then
			return 0 > value
		else
			return 0 < value
		end
	end

	local stat = tonumber(exports.ptpm_accounts:getPlayerStatistic(player, statName)) or 0
	--local stat = tonumber(getPlayerFakeStatistic(player, statName))

	if greater then
		return stat > value
	else
		return stat < value
	end
end

function conditionStatNumberComparisons(player, ...)
	for _, comp in ipairs({...}) do
		if not conditionStatNumberComparison(player, unpack(comp)) then
			return false
		end
	end

	return true
end

function conditionTaskExplanationComparison(player)
	if (not player) or (not isElement(player)) then
		outputDebugString("Error: bad player passed to conditionTaskExplanationComparison (" .. tostring(player) .. ")", 1)
		return
	end

	if conditionStatNumberComparison(player, "tasksplayed", true, 8) then
		return false
	end

	if (not currentPM) then
		return true
	end

	local x, y, z = getElementPosition(player)

	local px, py, pz = getElementPosition(currentPM)

	return distanceSquared(x, y, z, px, py, pz) > 90000 -- 300 ^ 2
end


function getPlayerFakeStatistic(player, statName)
	if statName == "terrorcount" then
		return 2
	elseif statName == "roundsplayed" then
		return 100
	end

	return 0
end

-- addCommandHandler("sh",
-- 	function(player, cmd, event)
-- 		triggerHelpEvent(player, event)
-- 	end
-- )