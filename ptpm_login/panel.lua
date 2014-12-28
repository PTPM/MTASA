addEvent( "loadPanelInfo", true )
function loadPanelInfo()
	local username = exports.ptpm_accounts:getSensitiveUserdata( client, "username" )
	if not username then
		-- response to client to remove gui (this SHOULD never happen though)
		triggerClientEvent( client, "sendPanelInfo", resourceRoot, false )
		return
	end
	
	local userdata = exports.ptpm_accounts:getUserdata( username, true )
	local playerStats = exports.ptpm_accounts:getPlayerStats( client )
	if (not userdata) or (not playerStats) then
		triggerClientEvent( client, "sendPanelInfo", resourceRoot, false )
	else
		triggerClientEvent( client, "sendPanelInfo", resourceRoot, true, userdata, playerStats )
	end
end
addEventHandler( "loadPanelInfo", root, loadPanelInfo )

addEvent( "sendNewUserSettings", true )
function saveNewUserSettings( settings )
	local username = exports.ptpm_accounts:getSensitiveUserdata( client, "username" )
	if not username then
		-- response to client to remove gui (this SHOULD never happen though)
		triggerClientEvent( client, "sendPanelSettingsResponse", resourceRoot, false )
		return
	end
	
	local success = true
	for k, v in pairs( settings ) do
		success = success and exports.ptpm_accounts:setUserdata( username, k, v )
	end
	triggerClientEvent( client, "sendPanelSettingsResponse", resourceRoot, success )
end
addEventHandler( "sendNewUserSettings", root, saveNewUserSettings )