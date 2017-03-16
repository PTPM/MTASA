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
	local randomCacheDelay = {}

	for _, player in ipairs(getElementsByType("player")) do
		if player and isElement(player) then
		
			local playerTeam = getPlayerTeam(player)
			if playerTeam then
				local teamName = getTeamName(playerTeam)
				if teamName=="Good guys" then
					if not randomCache[teamName] then --Use the same voice line for all players on this team
						if pmVictory then
							randomCache[teamName] = pickRandomAssetOutOfTable({ "win_pm.mp3", "win_victory.mp3" })		
							randomCacheDelay[teamName] = 300
						else
							randomCache[teamName] = pickRandomAssetOutOfTable({ "win_terrorist.mp3", "win_defeat.mp3" })
							randomCacheDelay[teamName] = 1000							
						end
					end
					
					triggerClientEvent ( player, "playAnnouncer", player, randomCache[teamName], randomCacheDelay[teamName])
					
				elseif teamname=="Bad guys" then
					if not randomCache[teamName] then
						if pmVictory then
							randomCache[teamName] = pickRandomAssetOutOfTable({ "win_pm.mp3", "win_pm2.mp3", "win_defeat.mp3" })
							randomCacheDelay[teamName] = 1000
						else
							randomCache[teamName] = pickRandomAssetOutOfTable({ "win_terrorist.mp3", "win_victory.mp3" })
							randomCacheDelay[teamName] = 300
						end
					end
					
					triggerClientEvent ( player, "playAnnouncer", player, randomCache[teamName], randomCacheDelay[teamName])
				end
			else
				-- No team, that means psycho or unspawned
				-- Always use neutral announcements
				if pmVictory then
					-- pickRandomAssetOutOfTable({ "win_pm.mp3", "win_pm2.mp3"})
					triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "win_pm.mp3", "win_pm2.mp3"}), 300)
					
				else
					-- [win_terrorist.mp3]
					triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "win_terrorist.mp3"}), 1000)
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
function pickedUpSuperweapon(theUppicker, weaponID)

	local uppickerTeam = ""
	local uppickerTeamElement = getPlayerTeam(theUppicker)
	if uppickerTeamElement then
		uppickerTeam = getTeamName(uppickerTeamElement)
	end
	
	for _, player in ipairs(getElementsByType("player")) do
		if player and isElement(player) then
		
			if theUppicker==player then return end
		
			local playerTeam = getPlayerTeam(player)
			if playerTeam then
				local teamName = getTeamName(playerTeam)
				if teamName==uppickerTeam and uppickerTeam~="" then
					-- "An ally has the minigun."
					
					if weaponID==38 then --Minigun
						triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "superwep_ally_mg.mp3", "superwep_ally_mg2.mp3" }))
					elseif weaponID==35 then --RPG
						triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "superwep_ally_rpg.mp3" }))
					elseif weaponID==36 then --Heat Seeker
						triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "superwep_ally_hs.mp3" }))
					end
				else
					-- "An enemy has the minigun."
					
					if weaponID==38 then --Minigun
						triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "superwep_enemy_mg.mp3", "superwep_enemy_mg2.mp3" }))
					elseif weaponID==35 then --RPG
						triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "superwep_enemy_rpg.mp3" }))
					elseif weaponID==36 then --Heat Seeker
						triggerClientEvent ( player, "playAnnouncer", player, pickRandomAssetOutOfTable({ "superwep_enemy_hs.mp3" }))
					end
				end
			end
		end
	end
end
