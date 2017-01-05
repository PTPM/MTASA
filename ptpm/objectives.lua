addEvent( "onObjectiveEnter", false )
addEventHandler( "onObjectiveEnter", root,
	function( thePlayer )
		if classes[getPlayerClassID( thePlayer )].type == "pm" then
			local objective = getElementParent( source )
			
			if objective == data.objectives.activeObjective then
				data.objectives.pmOnObjective = true
				
				data.objectives[objective].enterTime = getTickCount()
				
				for _, p in ipairs( getElementsByType( "player" ) ) do
					if p and isElement( p ) then
						-- if theyre a good guy
						if getPlayerClassID( p ) and teams["goodGuys"][classes[getPlayerClassID( p )].type] then
							drawStaticTextToScreen( "draw", p, "objText", "Defend checkpoint for " .. data.objectives[objective].time/1000 .. " seconds.", "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, colour.important, 1, "clear", "top", "center" )
							drawStaticTextToScreen( "draw", p, "objDesc", "Objective description:\n" .. data.objectives[objective].desc, "screenX*0.775", "screenY*0.28+40", "screenX*0.179", 120, colour.important, 1, "clear", "top", "center")					
						end
					end
				end

				if data.objectives.finished < 3 then
					triggerHelpEvent(thePlayer, "OBJECTIVE_ENTER")
				end

				if data.objectives.helpTimer then
					killTimer(data.objectives.helpTimer)
					data.objectives.helpTimer = nil
				end
			end
		end		
	end
)


addEvent( "onObjectiveLeave", false )
addEventHandler( "onObjectiveLeave", root,
	function( thePlayer )
		if classes[getPlayerClassID( thePlayer )].type == "pm" then
			local objective = getElementParent( source )
			
			if objective == data.objectives.activeObjective then
				data.objectives.pmOnObjective = nil
				
				data.objectives[objective].enterTime = nil
				
				for _,p in ipairs( getElementsByType( "player" ) ) do
					if p and isElement( p ) then
						-- if theyre a good guy
						if getPlayerClassID( p ) and teams["goodGuys"][classes[getPlayerClassID( p )].type] then
							clearObjectiveTextFor( p )
						end
					end
				end

				if data.objectives.helpTimer then
					killTimer(data.objectives.helpTimer)
				end

				setupObjectiveHelpPromptTimer()
			end
		end		
	end
)


addEvent("onObjectiveComplete", false)
addEventHandler("onObjectiveComplete", root,
	function(thePlayer)
		for _, p in ipairs(getElementsByType("player")) do
			if p and isElement(p) then
				if getPlayerClassID(p) and teams["goodGuys"][classes[getPlayerClassID(p)].type] == true then
					clearObjectiveTextFor(p)	
				end
			end
		end	
		
		data.objectives.finished = data.objectives.finished + 1

		-- completed all the objectives, or there are fewer objectives in the map file than required to pass map
		-- this works because once an objective is completed it gets destroyed and removed from the table		
		if (options.objectivesToFinish == data.objectives.finished) or (tableSize(data.objectives) == 1) then
			everyoneViewsBody(thePlayer, thePlayer, getElementInterior(thePlayer))

			sendGameText(root, "The Prime Minister completed objectives!", 7000, classColours["pm"], nil, 1.4, nil, nil, 3)

			local pmWins = getElementData(thePlayer, "ptpm.pmWins") or 0

			if isRunning("ptpm_accounts") then
				pmWins = (exports.ptpm_accounts:getPlayerStatistic(thePlayer, "pmvictory") or pmWins) + 1
				exports.ptpm_accounts:setPlayerStatistic(thePlayer, "pmvictory", pmWins)
			else
				pmWins = pmWins + 1
			end

			setElementData(thePlayer, "ptpm.score.pmWins", string.format("%d", pmWins))
			setElementData(thePlayer, "ptpm.pmWins", pmWins, false)
				
			for _, p in ipairs(getElementsByType("player")) do
				if p and isElement(p) and isPlayerActive(p) then
					local classID = getPlayerClassID(p)
					if classID then
						if classes[classID].type == "pm" or classes[classID].type == "bodyguard" or classes[classID].type == "police" then
							local roundsWon = getElementData(p, "ptpm.roundsWon") or 0

							if isRunning("ptpm_accounts") then        
								roundsWon = (exports.ptpm_accounts:getPlayerStatistic(p, "roundswon") or roundsWon) + 1
								exports.ptpm_accounts:setPlayerStatistic(p, "roundswon", roundsWon)
							else
								roundsWon = roundsWon + 1
							end

							setElementData(p, "ptpm.score.roundsWon", string.format("%d", roundsWon))
							setElementData(p, "ptpm.roundsWon", roundsWon, false)
						elseif classes[classID].type == "terrorist" then
							local roundsLost = getElementData(p, "ptpm.roundsLost") or 0

							if isRunning("ptpm_accounts") then        
								roundsLost = (exports.ptpm_accounts:getPlayerStatistic(p, "roundslost") or roundsLost) + 1
								exports.ptpm_accounts:setPlayerStatistic(p, "roundslost", roundsLost)
							else
								roundsLost = roundsLost + 1
							end

							setElementData(p, "ptpm.score.roundsLost", string.format("%d", roundsLost))
							setElementData(p, "ptpm.roundsLost", roundsLost, false)
						end
					end
				end
			end

			setRoundEnded()
		else
			if data.timer and isRunning("missiontimer") then
				local timeRemaining = exports.missiontimer:getMissionTimerTime(data.timer)

				if timeRemaining and timeRemaining > 0 then
					-- add 3 more minutes to the timer
					exports.missiontimer:setMissionTimerTime(data.timer, timeRemaining + ((1000 * 60) * 3))
					options.roundtime = options.roundtime + ((1000 * 60) * 3)
				end
			end

			if data.objectives.finished <= 3 then
				triggerHelpEvent(thePlayer, "OBJECTIVE_COMPLETE")
			end

			setupNewObjective()
		end

		data.objectives.pmOnObjective = nil
	end
)

-- addCommandHandler("hurry",
-- 	function()
-- 		if not data.roundEnded and currentPM and data.objectives.pmOnObjective then
-- 			data.objectives[data.objectives.activeObjective].enterTime = data.objectives[data.objectives.activeObjective].enterTime - 5000
-- 		end
-- 	end
-- )


function checkObjectives( players, tick )
	if not data.roundEnded and currentPM and data.objectives.pmOnObjective then
		if tick - data.objectives[data.objectives.activeObjective].enterTime < data.objectives[data.objectives.activeObjective].time then
			for _, p in ipairs( players ) do
				if p and isElement( p ) then
					if getPlayerClassID(p) and teams["goodGuys"][classes[getPlayerClassID(p)].type] == true then
						drawStaticTextToScreen( "update", p, "objText", "Defend checkpoint for " .. math.floor((data.objectives[data.objectives.activeObjective].time - (tick - data.objectives[data.objectives.activeObjective].enterTime))/1000) .. " seconds.", "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, colour.important, 1, "clear", "top", "center" )				
					end
				end
			end
		else
			triggerEvent("onObjectiveComplete", data.objectives.activeObjective, currentPM)
		end
	end	
end


function clearObjectiveTextFor( thePlayer )
	drawStaticTextToScreen( "delete", thePlayer, "objText" )
	drawStaticTextToScreen( "delete", thePlayer, "objDesc" )	
end


function setupObjectiveTextFor( thePlayer )
	drawStaticTextToScreen( "draw", thePlayer, "objText", "", "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, colour.important, 1, "clear", "top", "center" )
	drawStaticTextToScreen( "draw", thePlayer, "objDesc", "", "screenX*0.775", "screenY*0.28+40", "screenX*0.179", 120, colour.important, 1, "clear", "top", "center")					
end


function setupActiveObjectiveFor( thePlayer )
	if data and data.objectives.activeObjective and data.objectives[data.objectives.activeObjective] then
		if not getPlayerClassID( thePlayer ) or classes[getPlayerClassID( thePlayer )].type == "psycho" then return end
		
		local desc = data.objectives[data.objectives.activeObjective].desc or "-NO DESCRIPTION-"
		
		sendGameText( thePlayer, "PM Objective: " .. desc .. "\nObjectives left: " .. (options.objectivesToFinish - data.objectives.finished), 10000, sampTextdrawColours.w, nil, 1.2, nil, nil, 2 )
		
		setElementVisibleTo( data.objectives[data.objectives.activeObjective].blip, thePlayer, true )
		setElementVisibleTo( data.objectives[data.objectives.activeObjective].marker, thePlayer, true )
	end
end


function setupNewObjective()
	if data.objectives.activeObjective then
		local removeID
		
		for i=1, #data.objectiveRandomizer, 1 do
			if data.objectiveRandomizer[i] == data.objectives.activeObjective then
				removeID = i
				break
			end
		end
		
		table.remove(data.objectiveRandomizer,removeID)
		
		destroyElement( data.objectives.activeObjective )
		
		data.objectives[data.objectives.activeObjective] = nil
	end
	
	local randomObjective = math.random( 1, #data.objectiveRandomizer )
	data.objectives.activeObjective = data.objectiveRandomizer[randomObjective]
	
	for _, value in ipairs( getElementsByType( "player" ) ) do
		if value and isElement( value ) and isPlayerActive( value ) then
			setupActiveObjectiveFor( value ) 
		end 
	end
end


function clearObjective()
	if data.objectives and data.objectives.pmOnObjective then
		data.objectives[data.objectives.activeObjective].enterTime = nil
		data.objectives.pmOnObjective = nil
		
		for _, p in ipairs( getElementsByType( "player" ) ) do
			if p and isElement( p ) and getPlayerClassID( p ) and teams["goodGuys"][classes[getPlayerClassID( p )].type] == true then
				clearObjectiveTextFor( p )	
			end
		end	
	end
end

function setupObjectiveHelpPromptTimer()
	if data.objectives.helpTimer and isTimer(data.objectives.helpTimer) then
		killTimer(data.objectives.helpTimer)
	end

	data.objectives.helpTimer = setTimer(
		function()
			if currentPM and isElement(currentPM) then
				triggerHelpEvent(currentPM, "OBJECTIVE_NUDGE")
			end
		end,
	60000, 0)
end