--  Description:
--  Every 15 seconds League, Rank and Donator status are downloaded	

--  TODO: Authentication based on something else rather than just playername

currentScoreboard = nil

function parseScoreboardAPIResponse(responseData, errno) 
	if errno == 0 then
		-- responseData sample: { players : [{"playerName":"FuzzyBackpack18","playerLeague":"Unranked","dono":"0"},{"playerName":"mostafa_alex","playerLeague":"Silver","dono":"0"}] }
		-- due to how fromJSON() works, a top level object is required (instead of directly using responseData as a table)
		-- only players that have been online in the past 30 minutes are returned by the API
		
		thisResult = fromJSON(responseData)
		thisResult = thisResult.players
		if #thisResult>0 then
			currentScoreboard = thisResult	
		else
			-- sometimes the API will incorrectly return 0 rows
			-- just don't overwrite the last result when that happens
		end
		
		if currentScoreboard then
			for rowId,playerData in pairs(currentScoreboard) do
				-- for each returned row, check if player is online
				-- attach data to playerelement
				
				local thePlayer = getPlayerFromUsername ( playerData.playerName )
				
				if thePlayer then
					
					setElementData ( thePlayer, "playerLeague", playerData.playerLeague )
					setElementData ( thePlayer, "playerDono", tonumber(playerData.dono) or 0)
					setElementData ( thePlayer, "playerRanks", tonumber(playerData.playerRanks) or 2375)
					
				end
			end
		end
		
	else
		outputDebugString("Updating CommunityAPI error #" .. errno, 2)
	end
end

function getPlayerFromUsername(username)
	for _, p in ipairs( getElementsByType( "player" ) ) do
		if p and isElement(p) then
			if exports.ptpm_accounts:getSensitiveUserdata(p, "username")==username then
				return p
			end
		end
	end
	return nil
end

function testCommunityData( source )
	outputChatBox( "You are " ..  getElementData ( source, "playerLeague" ) .. " with " .. getElementData ( source, "playerRanks" ) .. " ranks. Your donator status is: ".. getElementData ( source, "playerDono" ) , source )
end
addCommandHandler ( "debugcommunity", testCommunityData )


function updatePTPMCommunityInfo()
	if #getElementsByType("player") > 0 then
		fetchRemote ( "https://ptpm.uk/stats/CommunityAPI.json.php", 1, parseScoreboardAPIResponse )
	end
end


updatePTPMCommunityInfo()
setTimer ( updatePTPMCommunityInfo, 15000, 0 )