local sensitiveUserdata = {}

function prepareUserDatabase()
	-- User data
	prepareDatabase( "users" )
	addColumnToDatabase( "users", "password", "VARCHAR(128)" )
	addColumnToDatabase( "users", "pwlength", "TINYINT UNSIGNED" )
	addColumnToDatabase( "users", "autologin", "TINYINT UNSIGNED" )
	addColumnToDatabase( "users", "rememberpw", "TINYINT UNSIGNED" )
	addColumnToDatabase( "users", "serial", "VARCHAR(100)" )
	addColumnToDatabase( "users", "ip", "VARCHAR(15)" )
	addColumnToDatabase( "users", "operator", "TINYINT UNSIGNED", 0 )
	addColumnToDatabase( "users", "muted", "TINYINT UNSIGNED", 0 )
	addColumnToDatabase( "users", "frozen", "TINYINT UNSIGNED", 0 )
	addColumnToDatabase( "users", "salt", "VARCHAR(8)" )
	addColumnToDatabase( "users", "lastlogon", "BIGINT UNSIGNED" )
		
	-- Player stats
	prepareDatabase( "playerstats" )
	---- Combat
	addColumnToDatabase( "playerstats", "kills", "INT UNSIGNED", 0 )
	addColumnToDatabase( "playerstats", "deaths", "INT UNSIGNED", 0 )
	addColumnToDatabase( "playerstats", "damage", "BIGINT UNSIGNED", 0 )
  	addColumnToDatabase( "playerstats", "damagetaken", "BIGINT UNSIGNED", 0 )
	addColumnToDatabase( "playerstats", "beststreak", "INT UNSIGNED", 0 )
  	addColumnToDatabase( "playerstats", "hphealed", "BIGINT UNSIGNED", 0 )

	---- Prime Minister
	addColumnToDatabase( "playerstats", "pmcount", "INT UNSIGNED", 0 )
	addColumnToDatabase( "playerstats", "pmkills", "INT UNSIGNED", 0 )
	addColumnToDatabase( "playerstats", "pmvictory", "INT UNSIGNED", 0 )
	addColumnToDatabase( "playerstats", "pmlosses", "INT UNSIGNED", 0 )
	addColumnToDatabase( "playerstats", "killsaspm", "INT UNSIGNED", 0 )
	---- Rounds
	addColumnToDatabase( "playerstats", "roundsplayed", "INT UNSIGNED", 0 )
	addColumnToDatabase( "playerstats", "roundswon", "INT UNSIGNED", 0 )
	addColumnToDatabase( "playerstats", "roundslost", "INT UNSIGNED", 0 )
	---- Other	
	addColumnToDatabase( "playerstats", "joindate", "BIGINT UNSIGNED", 0 )
	addColumnToDatabase( "playerstats", "timeplaying", "INT UNSIGNED", 0 )
	addColumnToDatabase( "playerstats", "longestsession", "INT UNSIGNED", 0 )

	addColumnToDatabase( "playerstats", "terrorcount", "INT UNSIGNED", 0 ) -- number of times played as terror
	addColumnToDatabase( "playerstats", "policecount", "INT UNSIGNED", 0 ) -- number of times played as police
	addColumnToDatabase( "playerstats", "bgcount", "INT UNSIGNED", 0 ) -- number of times played as bodyguard
	addColumnToDatabase( "playerstats", "mediccount", "INT UNSIGNED", 0 ) -- number of times played as medic

	addColumnToDatabase( "playerstats", "objectivesplayed", "INT UNSIGNED", 0 ) -- number of maps with objectives played
	addColumnToDatabase( "playerstats", "tasksplayed", "INT UNSIGNED", 0 ) -- number of maps with tasks played
	addColumnToDatabase( "playerstats", "waterdeathplayed", "INT UNSIGNED", 0 ) -- number of maps with pm water death option played
	addColumnToDatabase( "playerstats", "abandonedplayed", "INT UNSIGNED", 0 ) -- number of maps with the pm abandoned penalty option played

	addColumnToDatabase( "playerstats", "hphealedpassive", "BIGINT UNSIGNED", 0 ) -- hp passively healed in other players
	addColumnToDatabase( "playerstats", "hcount", "INT UNSIGNED", 0 ) -- times used /h
	addColumnToDatabase( "playerstats", "reclasscount", "INT UNSIGNED", 0 ) -- times used /reclass
	addColumnToDatabase( "playerstats", "rccount", "INT UNSIGNED", 0 ) -- times used /rc
	addColumnToDatabase( "playerstats", "swapclasscount", "INT UNSIGNED", 0 ) -- times used /swapclass
	addColumnToDatabase( "playerstats", "plancount", "INT UNSIGNED", 0 ) -- times used /plan
	addColumnToDatabase( "playerstats", "leaveclasscount", "INT UNSIGNED", 0 ) -- times used f4
	addColumnToDatabase( "playerstats", "safezonecount", "INT UNSIGNED", 0 ) -- number of safe zones entered

	addColumnToDatabase( "playerstats", "eventambulancecount", "INT UNSIGNED", 0 ) -- number of ambulance help events seen

	--addColumnToDatabase( "playerstats", "", "INT UNSIGNED", 0 )
end
addEventHandler( "onResourceStart", resourceRoot, prepareUserDatabase )

function closeUserDatabase()
	--if db then
	--	mysql_close(db)
	--end
end
addEventHandler( "onResourceStop", resourceRoot, closeUserDatabase )


function generateSalt()
	local s = ""
	for i = 1, 8 do
		if math.random(1,2)==1 then
			s = s .. string.char(math.random(65, 90))
		else
			s = s .. string.char(math.random(97, 122))
		end
	end
	return s
end

function loadApiConfig()
	local xml = xmlLoadFile("api-config.xml")
	if not xml then
		outputDebugString( "PTPM_ACCOUNTS: api-config.xml missing or invalid.", 1 )
		stopResource(getThisResource())
	else
		local allNodes = xmlNodeGetChildren(xml)
		apiConfig = {} 
		for i,node in ipairs(allNodes) do 
			if xmlNodeGetName(node)=="serverSecret" then
				apiConfig["serverSecret"] = xmlNodeGetValue(node)
			end
			if xmlNodeGetName(node)=="publicApiKey" then
				apiConfig["publicApiKey"] = xmlNodeGetValue(node)
			end
		end
		xmlUnloadFile(xml) 
		
		if not apiConfig["serverSecret"] or #apiConfig["serverSecret"] < 8 then
			outputDebugString( "PTPM_ACCOUNTS: Misconfiguration, no serverSecret given.", 1 )
			stopResource(getThisResource())
		end
		
		return apiConfig
	end
end

apiConfig = loadApiConfig()

function userChangePassword(user, passwordPlainText)
	
	-- old password was: md5(password)
	-- new password is:  md5(salt .. password .. serverSecret)
	local newSalt = generateSalt()
	local newPassword = buildEncodedPassword(newSalt, passwordPlainText)
	
	executeSQLQuery( "UPDATE users SET password='" .. newPassword .. "', salt='".. newSalt .."', pwlength=9999 WHERE username = '" .. user .. "'" )
	
end

function buildEncodedPassword(salt, passwordPlainText)
	return md5(salt .. passwordPlainText .. apiConfig["serverSecret"]) 
end

function getRecentBulkAccounts()
	return executeSQLQuery("SELECT username,password,salt FROM users WHERE pwlength=9999 AND lastlogon>" ..  (getRealTime().timestamp - 1 * 60 * 60))
end


function searchDatabaseForPlayer( thePlayer )
	-- Check if the player matches exactly to userdata, allowing for autologin and stuff
	local result = executeSQLQuery( "SELECT username,password,pwlength,autologin,rememberpw FROM users WHERE serial = '" .. escapeStr( getPlayerSerial( thePlayer ) ) .."' AND ip = '" .. escapeStr( getPlayerIP( thePlayer ) ) .."'" )
	if result then
		if #result > 0 then
			local autologin = result[1].autologin == 1
			if autologin then
				loginPlayer( thePlayer, result[1].username )
				return true
			end
			
			local info = {
				["username"] = result[1].username,
			}
			if result[1].rememberpw == 1 then
				info["password"] = result[1].password
				info["pwLength"] = 8 --result[1].pwlength or 6
				info["pwHashed"] = true
			end
			return false, info
		else
			-- Is there any entry for our player? Recognize players that have visited the server before by nickname
			local name = getPlayerName( thePlayer ) or ""
			result = executeSQLQuery( "SELECT username FROM users WHERE username = '" .. escapeStr( removeIllegalCharacters( name ) ) .. "'" )
			if result then
				if #result > 0 then
					local info = {
						["username"] = result[1].username
					}
					return false, info
				end
			end
		end
	end
	return false
end

-- ACCOUNT LOGIN

function loginUsername( thePlayer, username, password, rememberPw, autoLogin )
	local result = executeSQLQuery( "SELECT username,pwlength,salt FROM users WHERE username = '" .. escapeStr( username ) .."'" )
	local hasAccountBeenUpgraded = false
	local userSalt = ""
	
	if result then
		if #result <= 0 then
			return false, "noAccount"
		else 
			if result[1].pwlength~=9999 then
				hasAccountBeenUpgraded = false
			else
				hasAccountBeenUpgraded = true
				userSalt = result[1].salt
			end
		end
	end
	
	local result = false
	
	if not hasAccountBeenUpgraded then
		result = executeSQLQuery( "SELECT pwlength FROM users WHERE username = '" .. escapeStr( username ) .. "' AND password = '" .. md5(password) .. "'" )
	else
		result = executeSQLQuery( "SELECT pwlength FROM users WHERE username = '" .. escapeStr( username ) .. "' AND password = '" .. buildEncodedPassword(userSalt,password) .. "'" )
	end
	
	if result then
		if #result > 0 then
			if not hasAccountBeenUpgraded then
				userChangePassword(escapeStr(username), escapeStr(password))
				--outputChatBox("Your account security has been upgraded.", thePlayer, 255, 0, 0)
			end
		
			loginPlayer( thePlayer, username )
			
			setUserdata( username, "rememberpw", rememberPw )
			setUserdata( username, "autologin", autoLogin )
			setUserdata( username, "serial", getPlayerSerial( thePlayer ) )
			setUserdata( username, "ip", getPlayerIP( thePlayer ) )
			setUserdata( username, "lastlogon", tostring( getRealTime().timestamp ) )
			return true
		else
			return false, "wrongPw"
		end
	else
		return false
	end
end

function loginPlayer( thePlayer, username )
	loadPlayerStats( thePlayer, username )
	
	sensitiveUserdata[thePlayer] = {}
	sensitiveUserdata[thePlayer]["username"] = username
	
	local operator = getUserdata( username, "operator" )
	if type( operator ) == "number" and tonumber( operator ) == 1 then
		operator = true
	else operator = false end
	sensitiveUserdata[thePlayer]["operator"] = operator
	
	local muted = getUserdata( username, "muted" )
	if type( muted ) == "number" and tonumber( muted ) == 1 then
		muted = true
	else muted = false end
	sensitiveUserdata[thePlayer]["muted"] = muted
	
	local frozen = getUserdata( username, "frozen" )
	if type( frozen ) == "number" and tonumber( frozen ) == 1 then
		frozen = true
	else frozen = false end
	sensitiveUserdata[thePlayer]["frozen"] = frozen
end

function logoutPlayer( thePlayer, saveStats )
	if saveStats == nil then saveStats = true end
	local username = getSensitiveUserdata( thePlayer, "username" )
	if username then
		if saveStats then
			savePlayerStats( thePlayer, username )
		end
		unloadPlayerStats( thePlayer )
	end
	sensitiveUserdata[thePlayer] = nil
	setElementData( thePlayer, "ptpm.loggedIn", nil ) -- NOTE: Monitor if this causes problems
end

-- ACCOUNT CREATION

function registerUsername( thePlayer, username, password, length )
	
	-- Check that the account does not exist
	local result = executeSQLQuery( "SELECT * FROM users WHERE username = '" .. escapeStr( username ) .. "'" )
	
	if result then
		if #result > 0 then
			return false, "notAvailable"
		end
	else
		return false
	end
	
	if createUserAccount( thePlayer, username, password, length ) then
		if exports.ptpm:isRunning("nickshield") then
			exports.nickshield:registerNickshieldRaw(getPlayerName(thePlayer):lower(), username, getPlayerSerial(thePlayer))
		end
		return true
	else
		return false, "creationFailed"
	end
	return false
end

function createUserAccount( thePlayer, username, password, length )

	local joindate = tostring( getRealTime().timestamp )
	local result = executeSQLQuery( "INSERT INTO `users` (username, serial, ip) VALUES ('" .. escapeStr( username ) .. "', '" .. escapeStr( getPlayerSerial( thePlayer ) ) .. "', '" .. escapeStr( getPlayerIP( thePlayer ) ) .. "')")
	local result2 = executeSQLQuery( "INSERT INTO `playerstats` (username, joindate) VALUES ('" .. escapeStr( username ) .. "', '" .. escapeStr( joindate ) .. "')" )
	
	if result and result2 then	
		userChangePassword(escapeStr(username), escapeStr(password))
		return true
	else
		return false
	end
end

-- SENSITIVE DATA

function getSensitiveUserdata( thePlayer, data )
	if sensitiveUserdata[thePlayer] then
		return sensitiveUserdata[thePlayer][data] or false
	end
	return false
end

function setSensitiveUserdata( thePlayer, data, value )
	if sensitiveUserdata[thePlayer] then
		if data ~= "username" then
			sensitiveUserdata[thePlayer][data] = value
			return setUserdata( sensitiveUserdata[thePlayer]["username"], data, value )
		end
	end
	return false
end

-- CLEANUP

function clearPlayers()
	for _, player in ipairs( getElementsByType( "player" ) ) do
		if player and isElement( player ) then
			logoutPlayer( player )
		end
	end
end
addEventHandler( "onResourceStop", resourceRoot, clearPlayers )

function clearPlayer()
	logoutPlayer( source ) -- ptpm already saves stats on player quit
end
addEventHandler( "onPlayerQuit", root, clearPlayer )