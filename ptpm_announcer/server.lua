function pickRandomAssetOutOfTable(theTable)
	return "assets/".. theTable[math.random(#theTable)]
end

local planSpamBlock = false
local planSpamTimer = nil

function reallowPlanLine()
	if isTimer(planSpamTimer) then killTimer(planSpamTimer) end
	planSpamBlock = false
end
addEventHandler("onGamemodeMapStart", getRootElement(), reallowPlanLine)


-- Events:
--	roundEnd(bool pmVictory)
function roundEnd(pmVictory)
	local randomCache = {}

	for _, player in ipairs(getElementsByType("player")) do
		if player and isElement(player) then
		
			local playerTeam = getPlayerTeam(player)
			if playerTeam then
				local teamName = getTeamName(playerTeam)
				if teamName=="Good guys" then
					if not randomCache[teamName] then --Use the same voice line for all players on this team
						if pmVictory then
							randomCache[teamName] = pickRandomAssetOutOfTable({ "win_pm.mp3", "win_victory.mp3" }, 300)		
						else
							randomCache[teamName] = pickRandomAssetOutOfTable({ "win_terrorists.mp3", "win_defeat.mp3" }, 1000)						
						end
					end
					
					triggerClientEvent ( player, "playAnnouncer", player, randomCache[teamName])
					
				elseif teamname=="Bad guys" then
					if not randomCache[teamName] then
						if pmVictory then
							randomCache[teamName] = pickRandomAssetOutOfTable({ "win_pm.mp3", "win_pm2.mp3", "win_defeat.mp3" }, 1000)					
						else
							randomCache[teamName] = pickRandomAssetOutOfTable({ "win_terrorists.mp3", "win_victory.mp3" }, 300)
						end
					end
					
					triggerClientEvent ( player, "playAnnouncer", player, randomCache[teamName])
				end
			else
				-- No team, that means psycho or unspawned
				-- Always use neutral announcements
				if pmVictory then
					-- pickRandomAssetOutOfTable({ "win_pm.mp3", "win_pm2.mp3"})
					triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "win_pm.mp3", "win_pm2.mp3"}), 300)
					
				else
					-- [win_terrorists.mp3]
					triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "win_terrorists.mp3"}), 1000)
				end
			end
		end
	end
end


-- pmObjectiveSecure
function objectiveSecured()
	for _, player in ipairs(getElementsByType("player")) do
		if player and isElement(player) then
		
			local playerTeam = getPlayerTeam(player)
			if playerTeam then
				triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "obj.mp3","obj2.mp3","obj3.mp3" }))
			end
		end
	end
end


-- pmTaskSecure
function taskSecured()
	for _, player in ipairs(getElementsByType("player")) do
		if player and isElement(player) then
		
			if getPlayerTeam(player) then
				-- [task2.mp3]
				triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "task2.mp3" }))
			end
		end
	end
end



-- pmPlanSet
function pmSetPlan()
	if not planSpamBlock then
		for _, player in ipairs(getElementsByType("player")) do
			if player and isElement(player) then
			
				local playerTeam = getPlayerTeam(player)
				if playerTeam then
					local teamName = getTeamName(playerTeam)
					if teamName=="Good guys" then
						-- [plan2.mp3]
						triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "plan2.mp3" }))
					end
				end
			end
		end
		
		-- It will be allowed again in one minute and after next round start
		planSpamBlock = true
		planSpamTimer = setTimer(reallowPlanLine, 60000, 1)
	end
end



-- playerHasSuperweapon
-- TODO: integrate with PTPM
function pickedUpSuperweapon(uppickerTeam)
	for _, player in ipairs(getElementsByType("player")) do
		if player and isElement(player) then
		
			local playerTeam = getPlayerTeam(player)
			if playerTeam then
				local teamName = getTeamName(playerTeam)
				if teamName==uppickerTeam and uppickerTeam~="" then
					-- "An ally has the minigun."
					-- (Sound files haven't been delivered yet)
				else
					-- "An enemy has the minigun."
					-- (Sound files haven't been delivered yet)
				end
			end
		end
	end
end
