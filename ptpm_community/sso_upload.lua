local apiConfig = false

if exports.ptpm:isRunning("ptpm_accounts") then
	apiConfig = exports.ptpm_accounts:loadApiConfig()
else
	outputDebugString( "PTPM_COMMUNITY: ptpm_accounts not running", 1 )
	stopResource(getThisResource())
end

if not apiConfig["publicApiKey"] or #apiConfig["publicApiKey"] < 8 then
	outputDebugString( "PTPM_COMMUNITY: could not load publicApiKey from ptpm_accounts API config", 1 )
	stopResource(getThisResource())
end

function generateSignature()
	-- Not an ideal way to do it, but totally fine
	return apiConfig["publicApiKey"]
end

function sendAPIRequest(action,postDataTable)
    fetchRemote ( "https://ptpm.uk/api/api.php?action=" .. action .. "&signature=" .. generateSignature(), 1, 3000, function(data,err,arg) end, toJSON(postDataTable,true), false)
end

function scoreboardUpload()
	local playersStats = {}
			
	local players = getElementsByType( "player" )
	for _, p in ipairs( players ) do
		if p and isElement(p) then
			table.insert(playersStats, {
				["username"] = 		exports.ptpm_accounts:getSensitiveUserdata(p, "username") or ("GUEST_" .. getPlayerName(p)),
				["roundsWon"] = 	exports.ptpm_accounts:getPlayerStatistic(p, "roundswon" ),
				["roundsLost"] = 	exports.ptpm_accounts:getPlayerStatistic(p, "roundslost" ),
				["pmWon"] = 		exports.ptpm_accounts:getPlayerStatistic(p, "pmvictory" ),
				["pmLost"] = 		exports.ptpm_accounts:getPlayerStatistic(p, "pmlosses" ),
				["pmKills"] = 		exports.ptpm_accounts:getPlayerStatistic(p, "pmkills" ),
				["hpHealed"] = 		exports.ptpm_accounts:getPlayerStatistic(p, "hphealed" ),
				["kills"] = 		exports.ptpm_accounts:getPlayerStatistic(p, "kills" ),
				["deaths"] = 		exports.ptpm_accounts:getPlayerStatistic(p, "deaths" )
			})
		end
	end
	
	sendAPIRequest("updatePersistentScoreboard", playersStats)
end

function periodicalUploadOfAllUserAccounts()
	userAccounts = exports.ptpm_accounts:getRecentBulkAccounts()
	sendAPIRequest("bulkUsers", userAccounts)
end

-- update sso every 15 minutes
setTimer( periodicalUploadOfAllUserAccounts, 15 * 60 * 1000, 0 )
periodicalUploadOfAllUserAccounts()

-- update scoreboard every 30 seconds
setTimer( scoreboardUpload, 30 * 1000, 0 )
scoreboardUpload()