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



function periodicalUploadOfAllUserAccounts()
	userAccounts = exports.ptpm_accounts:getBulkAccounts()
	sendAPIRequest("bulkUsers", userAccounts)
end

--setTimer ( periodicalUploadOfAllUserAccounts, 15000, 0 )
--periodicalUploadOfAllUserAccounts()