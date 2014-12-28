function setLoginScreenForPlayer( player )
	-- this function is called every map change for all not-logged in players and for new people joining
	-- check prevents double creation of login screen is active over a map change
	if getElementData( player, "ptpm.loggingIn" ) then return end
	
	setElementData( player, "ptpm.loggingIn", true )
	setElementData( player, "ptpm.ready", false, false )
	
	-- HERE QUERY SERVER FOR PLAYER INFO BY SERIAL
	-- 1. CHECK IF ALREADY IN DATABASE
	--   - IF DOES, QUERY FOR AUTOLOGIN AND SAVED PASSWORD, BASED ON PLAYER SERIAL AND IP
	--   - IF AUTOLOGIN, SKIP WHOLE SHIT
	-- 2. SEND SAVED PASSWORD TO CLIENT
	-- 3. PROPABLY CHANGE GUEST/LOGIN BUTTON PLACEMENT DEPENDING ON INFO?
	
	local autologin, info = exports.ptpm_accounts:searchDatabaseForPlayer( player )
	
	if autologin then
		triggerClientEvent( player, "prepareClientLoginGUI", resourceRoot, false )
	elseif info then
		triggerClientEvent( player, "prepareClientLoginGUI", resourceRoot, true, info )
	else
		triggerClientEvent( player, "prepareClientLoginGUI", resourceRoot, true )
	end
end

addEvent( "checkValidRegistration", true )
function checkRegistration( username, password, length ) -- NOTE: ADD MD5 HASH TO PASSWORDS, HUIJAA PASSWORD REMEMBER JUTTUA, NEVER HAVE NON MD5 PASSWORD SERVERSIDE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	local success, reason = exports.ptpm_accounts:registerUsername( client, username, password, length )
	if not success then
		triggerClientEvent( client, "sendRegistrationResponse", resourceRoot, false, reason )
	else
		triggerClientEvent( client, "sendRegistrationResponse", resourceRoot, true )
	end
end
addEventHandler( "checkValidRegistration", root, checkRegistration )

addEvent( "checkValidLogin", true )
function checkLogin( username, password, rememberPw, autoLogin )
	local success, reason = exports.ptpm_accounts:loginUsername( client, username, password, rememberPw, autoLogin )
	if not success then
		triggerClientEvent( client, "sendLoginResponse", resourceRoot, false, reason )
	else
		triggerClientEvent( client, "sendLoginResponse", resourceRoot, true )
	end
end
addEventHandler( "checkValidLogin", root, checkLogin )

function removeIllegalCharacters( text )
	return string.gsub( text, "[^A-Za-z0-9_%-]", "" ) or ""
end

function clearLogin()
	local players = getElementsByType( "player" )
	-- local running = false
	-- local ptpm = getResourceFromName( "ptpm" )
	-- if ptpm then
		-- if getResourceState( ptpm ) == "running" then
			-- running = true
		-- end
	-- end
	
	for _, p in ipairs( players ) do
		if p and isElement( p ) then
			--if running then
				if getElementData( p, "ptpm.loggingIn" ) then
					setElementData( p, "ptpm.loggingIn", nil )
					triggerClientEvent( p, "onClientAvailable", p )
					triggerEvent( "onClientAvailable", p )
				end
			--end
			setElementData( p, "ptpm.loggedIn", nil )
		end
	end
end
addEventHandler( "onResourceStop", resourceRoot, clearLogin )