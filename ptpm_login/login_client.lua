local GUI = {}

-- avoid account creation spam by limiting registration button
local accountRegistered = false

addEvent( "prepareClientLoginGUI", true )
function prepareGUI( createGUI, info )
	if not createGUI then
		-- AUTO-LOGIN ENABLED
		setElementData( localPlayer, "ptpm.loggedIn", true )
		setElementData( localPlayer, "ptpm.loggingIn", false )
		triggerServerEvent( "onClientAvailable", localPlayer )
		triggerEvent( "onClientAvailable", localPlayer )
		createControlPanel()
		outputChatBox( "ptpm_login: Automatically logged in.", 128, 128, 255 )
	else
		if not info then -- A NEWCOMER
			GUI.userinfo = {
				["username"] = removeIllegalCharacters( getPlayerName( localPlayer ) or "" )
			}
			createLoginGUI( true )
		else
			GUI.userinfo = info
			createLoginGUI( false )
		end
		startLoginScenery()
		
		setTimer( fadeGUI, 2000, 1, "In" )
		showCursor( true )
	end
end
addEventHandler( "prepareClientLoginGUI", resourceRoot, prepareGUI )

--

function fadeGUI( fadeType )
	guiSetProperty( GUI.window, "Disabled", "True" )
	guiSetVisible( GUI.window, true )

	if fadeType == "In" then
		guiSetAlpha( GUI.window, 0 )
	else
		guiSetAlpha( GUI.window, 1 )
	end

	GUI.anim = {}
	GUI.anim.startTime = getTickCount()
	GUI.anim.endTime = GUI.anim.startTime + 500
	GUI.anim.easingFunction = "Linear"
	GUI.anim.type = fadeType
	addEventHandler( "onClientRender", root, fadeGUIRender )
end

function fadeGUIRender()
	local now = getTickCount()
	local elapsedTime = now - GUI.anim.startTime
	local duration = GUI.anim.endTime - GUI.anim.startTime
	local progress = elapsedTime / duration
 
	local alpha = getEasingValue( progress, GUI.anim.easingFunction )
 
	if GUI.anim.type == "In" then
		guiSetAlpha( GUI.window, alpha )
	else
		guiSetAlpha( GUI.window, 1-alpha )
	end
	
	if now > GUI.anim.endTime then
		if GUI.anim.type == "Out" then
			guiSetVisible( GUI.window, false )
		end
		guiSetProperty( GUI.window, "Disabled", "False" )
		removeEventHandler( "onClientRender", root, fadeGUIRender )
	end
end

function createLoginGUI( newComer )
	
	-- Scale down the login window resolution isn't high enough
	-- (window transitions fail to draw correctly on lower resolutions without this)
	GUI.scale = 1.0
	if screenX < 1320 then
		GUI.scale = math.max( (screenX/1320), 0.815 )
	end
	GUI.s = function ( value )
		return GUI.scale*value
	end
	
	local tFont = guiCreateFont( "resources/tahoma.ttf", math.ceil( GUI.s(8) ) )
	local bFont = guiCreateFont( "resources/tahomabd.ttf", math.ceil( GUI.s(9) ) )
	
	local windowWidth, windowHeight = GUI.s(440), GUI.s(255)
	local left, top = screenX/2 - windowWidth/2, screenY/2 - windowHeight/2
	
	GUI.window = guiCreateWindow( left, top, windowWidth, windowHeight, "Welcome!", false )
	guiSetFont( GUI.window, bFont )
	guiWindowSetSizable( GUI.window, false )
	
	GUI.pane = guiCreateLabel( 0, 0, windowWidth, windowHeight, "", false, GUI.window )
	GUI.pane2 = guiCreateLabel( 0, 0, windowWidth, windowHeight, "", false, GUI.window )
	GUI.pane3 = guiCreateLabel( 0, 0, windowWidth, windowHeight, "", false, GUI.window )
	
	-- MAIN WINDOW
	GUI.main = {}
	GUI.current = "main"
	
	if newComer then
		GUI.main.guestButton = guiCreateButton( GUI.s(10), GUI.s(75), GUI.s(421), GUI.s(101), "Play as a Guest", false, GUI.pane )
		GUI.main.loginButton = guiCreateButton( GUI.s(221), GUI.s(185), GUI.s(210), GUI.s(31), "Login...", false, GUI.pane )
	else
		GUI.main.guestButton = guiCreateButton( GUI.s(221), GUI.s(185), GUI.s(210), GUI.s(31), "Play as a Guest", false, GUI.pane )
		GUI.main.loginButton = guiCreateButton( GUI.s(10), GUI.s(75), GUI.s(421), GUI.s(101), "Login...", false, GUI.pane )
	end
	
	guiSetFont( GUI.main.guestButton, bFont )
	addEventHandler( "onClientMouseEnter", GUI.main.guestButton, buttonEnter, false )
	addEventHandler( "onClientMouseLeave", GUI.main.guestButton, buttonLeave, false )
	addEventHandler( "onClientGUIClick", GUI.main.guestButton, pressGuestButton, false )
	
	guiSetFont( GUI.main.loginButton, bFont )
	addEventHandler( "onClientMouseEnter", GUI.main.loginButton, buttonEnter, false )
	addEventHandler( "onClientMouseLeave", GUI.main.loginButton, buttonLeave, false )
	addEventHandler( "onClientGUIClick", GUI.main.loginButton, pressLoginButton, false )
	
	GUI.main.registerButton = guiCreateButton( GUI.s(10), GUI.s(185), GUI.s(210), GUI.s(31), "Register...", false, GUI.pane )
	guiSetFont( GUI.main.registerButton, bFont )
	addEventHandler( "onClientMouseEnter", GUI.main.registerButton, buttonEnter, false )
	addEventHandler( "onClientMouseLeave", GUI.main.registerButton, buttonLeave, false )
	addEventHandler( "onClientGUIClick", GUI.main.registerButton, pressRegisterButton, false )
	
	GUI.main.headerText = guiCreateLabel( GUI.s(20), GUI.s(25), GUI.s(401), GUI.s(41), "Welcome to play Protect the Prime Minister!\n\nPlease select one of the following options to continue.", false, GUI.pane )
	guiSetFont( GUI.main.headerText, tFont )
	guiLabelSetHorizontalAlign( GUI.main.headerText, "center", false )
	guiLabelSetVerticalAlign( GUI.main.headerText, "top" )
	
	GUI.main.bottomText = guiCreateLabel( GUI.s(10), GUI.s(225), GUI.s(421), GUI.s(21), "", false, GUI.pane )
	guiSetFont( GUI.main.bottomText, tFont )
	guiLabelSetHorizontalAlign( GUI.main.bottomText, "center", true )
	guiLabelSetVerticalAlign( GUI.main.bottomText, "center" )
	
	guiSetVisible( GUI.window, false )
	
	-- Register
	GUI.register = {}
	
	GUI.register.backButton = guiCreateButton( GUI.s(10), GUI.s(27), GUI.s(61), GUI.s(21), "< Back", false, GUI.pane2 )
	guiSetFont( GUI.register.backButton, tFont )
	addEventHandler( "onClientMouseEnter", GUI.register.backButton, buttonEnter, false )
	addEventHandler( "onClientMouseLeave", GUI.register.backButton, buttonLeave, false )
	
	GUI.register.seperator = guiCreateEdit( GUI.s(10), GUI.s(57), GUI.s(421), GUI.s(13), "", false, GUI.pane2 )
	guiSetProperty( GUI.register.seperator, "Disabled", "True" )
	guiSetProperty( GUI.register.seperator, "Alpha", "0.3" )
	
	GUI.register.headerText = guiCreateLabel( GUI.s(90), GUI.s(25), GUI.s(331), GUI.s(21), "Registration - choose your password.", false, GUI.pane2 )
	guiSetFont( GUI.register.headerText, tFont )
	guiLabelSetHorizontalAlign( GUI.register.headerText, "left", false )
	guiLabelSetVerticalAlign( GUI.register.headerText, "center" )
	
	GUI.register.usernameFieldPrefix =  guiCreateLabel( GUI.s(20), GUI.s(86), GUI.s(81), GUI.s(21), "Username:", false, GUI.pane2 )
	guiSetFont( GUI.register.usernameFieldPrefix, tFont )
	guiLabelSetHorizontalAlign( GUI.register.usernameFieldPrefix, "left", false )
	guiLabelSetVerticalAlign( GUI.register.usernameFieldPrefix, "center" )
	
	GUI.register.pwField1Prefix = guiCreateLabel( GUI.s(20), GUI.s(115), GUI.s(81), GUI.s(21), "Password:", false, GUI.pane2 )
	guiSetFont( GUI.register.pwField1Prefix, tFont )
	guiLabelSetHorizontalAlign( GUI.register.pwField1Prefix, "left", false )
	guiLabelSetVerticalAlign( GUI.register.pwField1Prefix, "center" )
	
	GUI.register.pwField2Prefix = guiCreateLabel( GUI.s(20), GUI.s(145), GUI.s(91), GUI.s(21), "Password (again):", false, GUI.pane2 )
	guiSetFont( GUI.register.pwField2Prefix, tFont )
	guiLabelSetHorizontalAlign( GUI.register.pwField2Prefix, "left", false )
	guiLabelSetVerticalAlign( GUI.register.pwField2Prefix, "center" )
	
	local name = removeIllegalCharacters( getPlayerName( localPlayer ) or "" )
	GUI.register.usernameField = guiCreateEdit( GUI.s(120), GUI.s(85), GUI.s(161), GUI.s(21), name, false, GUI.pane2 )
	guiSetFont( GUI.register.usernameField, tFont )
	guiEditSetMaxLength( GUI.register.usernameField, 22 )
	GUI.register.usernameOK = true
	
	GUI.register.pwField1 = guiCreateEdit( GUI.s(120), GUI.s(115), GUI.s(161), GUI.s(21), "", false, GUI.pane2 )
	guiSetFont( GUI.register.pwField1, tFont )
	guiEditSetMaxLength( GUI.register.pwField1, 16 )
	guiEditSetMasked( GUI.register.pwField1, true )
	
	GUI.register.pwField2 = guiCreateEdit( GUI.s(120), GUI.s(145), GUI.s(161), GUI.s(21), "", false, GUI.pane2 )
	guiSetFont( GUI.register.pwField2, tFont )
	guiEditSetMaxLength( GUI.register.pwField2, 16 )
	guiEditSetMasked( GUI.register.pwField2, true )
	GUI.register.passwordOK = false
	
	GUI.register.okText =  guiCreateLabel( GUI.s(290), GUI.s(115), GUI.s(131), GUI.s(51), "", false, GUI.pane2 )
	guiSetFont( GUI.register.okText, tFont )
	guiLabelSetHorizontalAlign( GUI.register.okText, "center", true )
	guiLabelSetVerticalAlign( GUI.register.okText, "center" )
	
	GUI.register.registerButton = guiCreateButton( GUI.s(20), GUI.s(185), GUI.s(401), GUI.s(61), "Register", false, GUI.pane2 )
	guiSetFont( GUI.register.registerButton, bFont )
	addEventHandler( "onClientMouseEnter", GUI.register.registerButton, buttonEnter, false )
	addEventHandler( "onClientMouseLeave", GUI.register.registerButton, buttonLeave, false )
	
	guiSetProperty( GUI.pane2, "Disabled", "True" )
	guiSetVisible( GUI.pane2, false )
	
	-- Login
	GUI.login = {}
	
	GUI.login.backButton = guiCreateButton( GUI.s(10), GUI.s(25), GUI.s(61), GUI.s(21), "< Back", false, GUI.pane3 )
	guiSetFont( GUI.login.backButton, tFont )
	addEventHandler( "onClientMouseEnter", GUI.login.backButton, buttonEnter, false )
	addEventHandler( "onClientMouseLeave", GUI.login.backButton, buttonLeave, false )
	
	GUI.login.headerText = guiCreateLabel( GUI.s(90), GUI.s(25), GUI.s(331), GUI.s(21), "Login - type your password.", false, GUI.pane3 )
	guiSetFont( GUI.login.headerText, tFont )
	guiLabelSetHorizontalAlign( GUI.login.headerText, "left", false )
	guiLabelSetVerticalAlign( GUI.login.headerText, "center" )
	
	GUI.login.seperator = guiCreateEdit( GUI.s(10), GUI.s(57), GUI.s(421), GUI.s(13), "", false, GUI.pane3 )
	guiSetProperty( GUI.login.seperator, "Disabled", "True" )
	guiSetProperty( GUI.login.seperator, "Alpha", "0.3" )
	
	GUI.login.usernameFieldPrefix = guiCreateLabel( GUI.s(20), GUI.s(85), GUI.s(81), GUI.s(21), "Username:", false, GUI.pane3 )
	guiSetFont( GUI.login.usernameFieldPrefix, tFont )
	guiLabelSetHorizontalAlign( GUI.login.usernameFieldPrefix, "left", false )
	guiLabelSetVerticalAlign( GUI.login.usernameFieldPrefix, "center" )
	
	GUI.login.pwFieldPrefix = guiCreateLabel( GUI.s(20), GUI.s(115), GUI.s(81), GUI.s(21), "Password:", false, GUI.pane3 )
	guiSetFont( GUI.login.pwFieldPrefix, tFont )
	guiLabelSetHorizontalAlign( GUI.login.pwFieldPrefix, "left", false )
	guiLabelSetVerticalAlign( GUI.login.pwFieldPrefix, "center" )
	
	GUI.login.usernameField = guiCreateEdit( GUI.s(120), GUI.s(85), GUI.s(161), GUI.s(21), GUI.userinfo.username, false, GUI.pane3 )
	guiSetFont( GUI.login.usernameField, tFont )
	guiEditSetMaxLength( GUI.login.usernameField, 22 )
	GUI.login.usernameOK = true
	
	local password = ""
	GUI.login.passwordOK = false
	if GUI.userinfo.pwHashed then
		password = string.rep( "x", GUI.userinfo.pwLength )
		GUI.login.passwordOK = true
	end
	GUI.login.pwField = guiCreateEdit( GUI.s(120), GUI.s(115), GUI.s(161), GUI.s(21), password, false, GUI.pane3 )
	guiSetFont( GUI.login.pwField, tFont )
	guiEditSetMaxLength( GUI.login.pwField, 16 )
	guiEditSetMasked( GUI.login.pwField, true )
	
	
	GUI.login.rmpwCheck = guiCreateCheckBox( GUI.s(40), GUI.s(145), GUI.s(131), GUI.s(17), "Remember password", false, false, GUI.pane3 )
	guiSetFont( GUI.login.rmpwCheck, tFont )
	if GUI.userinfo.pwHashed then guiCheckBoxSetSelected( GUI.login.rmpwCheck, true ) end
	
	GUI.login.auloCheck = guiCreateCheckBox( GUI.s(200), GUI.s(145), GUI.s(131), GUI.s(17), "Auto login on connect", false, false, GUI.pane3 )
	guiSetFont( GUI.login.auloCheck, tFont )
	
	GUI.login.okText = guiCreateLabel( GUI.s(290), GUI.s(85), GUI.s(131), GUI.s(51), "", false, GUI.pane3 )
	guiSetFont( GUI.login.okText, tFont )
	guiLabelSetHorizontalAlign( GUI.login.okText, "center", true )
	guiLabelSetVerticalAlign( GUI.login.okText, "center" )
	
	GUI.login.loginButton = guiCreateButton( GUI.s(20), GUI.s(185), GUI.s(401), GUI.s(61), "Login", false, GUI.pane3 )
	guiSetFont( GUI.login.loginButton, bFont )
	addEventHandler( "onClientMouseEnter", GUI.login.loginButton, buttonEnter, false )
	addEventHandler( "onClientMouseLeave", GUI.login.loginButton, buttonLeave, false )
	
	guiSetProperty( GUI.pane3, "Disabled", "True" )
	guiSetVisible( GUI.pane3, false )
end

-- MAIN WINDOW EVENTS

function pressGuestButton( key, state )
	if key == "left" and state == "up" then
		setSoundVolume( playSound( "resources/click2.mp3" ), 0.5 )
			
		-- Just kill the GUI
		endGUI( true )
	end
end

function pressRegisterButton( key, state )
	if key == "left" and state == "up" then
		setSoundVolume( playSound( "resources/click2.mp3" ), 0.5 )
			
		-- Window changing to register window
		swapWindow( "register" )
		removeEventHandler( "onClientGUIClick", GUI.main.guestButton, pressGuestButton )
		removeEventHandler( "onClientGUIClick", GUI.main.registerButton, pressRegisterButton )
		removeEventHandler( "onClientGUIClick", GUI.main.loginButton, pressLoginButton )
			
		if guiGetText( GUI.register.usernameField ) == "" then
			local name = removeIllegalCharacters( getPlayerName( localPlayer ) or "" )
			guiSetText( GUI.register.usernameField, name )
			GUI.register.usernameOK = true
		end
	end
end

function pressLoginButton( key, state )
	if key == "left" and state == "up" then
		setSoundVolume( playSound( "resources/click2.mp3" ), 0.5 )
			
		-- Window changing to login window
		swapWindow( "login" )
		removeEventHandler( "onClientGUIClick", GUI.main.guestButton, pressGuestButton )
		removeEventHandler( "onClientGUIClick", GUI.main.registerButton, pressRegisterButton )
		removeEventHandler( "onClientGUIClick", GUI.main.loginButton, pressLoginButton )
			
		if guiGetText( GUI.login.usernameField ) == "" then
			guiSetText( GUI.login.usernameField, GUI.userinfo.username )
		end
	end
end

-- REGISTER WINDOW EVENTS

function pressRegisterAcceptButton( key, state )
	if key == "left" and state == "up" then
		local username = guiGetText( GUI.register.usernameField ) or ""
		if #username < 1 or #username > 22 then
			guiSetText( GUI.register.okText, "Invalid username!\nName length 1-22 characters." )
			guiLabelSetColor( GUI.register.okText, 200, 0, 0 )
			GUI.register.usernameOK = false
		else
			local password = guiGetText( GUI.register.pwField1 )
			local password2 = guiGetText( GUI.register.pwField1 )
			if #password < 3 or #password > 16 or #password2 < 3 or #password2 > 16 then
				guiSetText( GUI.register.okText, "Invalid password!\nPassword length 3-16 characters." )
				guiLabelSetColor( GUI.register.okText, 200, 0, 0 )
				GUI.register.passwordOK = false
			elseif GUI.register.usernameOK and GUI.register.passwordOK then
				-- Send a registration attempt, and wait for an answer
				local length = #password
				password = md5( password )
				triggerServerEvent( "checkValidRegistration", resourceRoot, username, password, length )
				guiSetProperty( GUI.pane2, "Disabled", "True" )
			elseif guiGetText( GUI.register.okText ) == "" then
				guiSetText( GUI.register.okText, "Insert a password!" )
				guiLabelSetColor( GUI.register.okText, 200, 0, 0 )
			end
		end
	end
end

function pressRegisterBackButton( key, state )
	if key == "left" and state == "up" then
		setSoundVolume( playSound( "resources/click2.mp3" ), 0.5 )
			
		-- Window changing back to guest window
		swapWindow( "main" )
		guiSetInputEnabled( false )
		removeEventHandler( "onClientGUIClick", GUI.register.backButton, pressRegisterBackButton )
		removeEventHandler( "onClientGUIClick", GUI.register.registerButton, pressRegisterAcceptButton )
		removeEventHandler( "onClientGUIChanged", GUI.register.usernameField, fieldChanged )
		removeEventHandler( "onClientGUIChanged", GUI.register.pwField1, fieldChanged )
		removeEventHandler( "onClientGUIChanged", GUI.register.pwField2, fieldChanged )
	end
end

-- LOGIN WINDOW EVENTS

function pressLoginAcceptButton( key, state )
	if key == "left" and state == "up" then
		local username = guiGetText( GUI.login.usernameField ) or ""
		if #username < 1 or #username > 22 then
			guiSetText( GUI.login.okText, "Invalid username!\nName length 1-22 characters." )
			guiLabelSetColor( GUI.login.okText, 200, 0, 0 )
			GUI.login.usernameOK = false
		else
			local password = guiGetText( GUI.login.pwField )
			if #password < 3 or #password > 16 then
				guiSetText( GUI.login.okText, "Invalid password!\nPassword length 3-16 characters." )
				guiLabelSetColor( GUI.login.okText, 200, 0, 0 )
				GUI.login.passwordOK = false
			elseif GUI.login.usernameOK and GUI.login.passwordOK then
				-- Send a login attempt, and wait for an answer
				if GUI.userinfo.pwHashed then
					password = GUI.userinfo.password
				--else
				--	password = md5( password )
				end
				local rememberPw = guiCheckBoxGetSelected( GUI.login.rmpwCheck )
				local autoLogin = guiCheckBoxGetSelected( GUI.login.auloCheck )
				
				triggerServerEvent( "checkValidLogin", resourceRoot, username, password, rememberPw, autoLogin )
				guiSetProperty( GUI.pane3, "Disabled", "True" )
			else
				guiSetText( GUI.login.okText, "Insert a password!" )
				guiLabelSetColor( GUI.login.okText, 200, 0, 0 )
			end
		end
	end
end

function pressLoginBackButton( key, state )
	if key == "left" and state == "up" then
		setSoundVolume( playSound( "resources/click2.mp3" ), 0.5 )
			
		-- Window changing back to main window
		swapWindow( "main" )
		guiSetInputEnabled( false )
		removeEventHandler( "onClientGUIClick", GUI.login.backButton, pressLoginBackButton )
		removeEventHandler( "onClientGUIClick", GUI.login.loginButton, pressLoginAcceptButton )
		removeEventHandler( "onClientGUIChanged", GUI.login.usernameField, fieldChanged )
		removeEventHandler( "onClientGUIChanged", GUI.login.pwField, fieldChanged )
		removeEventHandler( "onClientGUIClick", GUI.login.rmpwCheck, checkBoxClicked )
		removeEventHandler( "onClientGUIClick", GUI.login.auloCheck, checkBoxClicked )
	end
end

function swapWindow( swap )
	GUI.anim = {}
	GUI.anim.startTime = getTickCount()
	GUI.anim.endTime = GUI.anim.startTime + 400
	GUI.anim.easingFunction = "OutQuad"
	GUI.anim.swap = swap
	addEventHandler( "onClientRender", root, swapWindowAnim )
	
	if GUI.current == "main" then
		guiSetProperty( GUI.pane, "Disabled", "True" )
	elseif GUI.current == "register" then
		guiSetProperty( GUI.pane2, "Disabled", "True" )
	elseif GUI.current == "login" then
		guiSetProperty( GUI.pane3, "Disabled", "True" )
	end
	
	if GUI.anim.swap == "main" then
		guiSetVisible( GUI.pane, true )
		guiSetAlpha( GUI.pane, 0 )
	elseif GUI.anim.swap == "register" then
		guiSetVisible( GUI.pane2, true )
		guiSetAlpha( GUI.pane2, 0 )
	elseif GUI.anim.swap == "login" then
		guiSetVisible( GUI.pane3, true )
		guiSetAlpha( GUI.pane3, 0 )
	end
end

function swapWindowAnim()
	local now = getTickCount()
	local elapsedTime = now - GUI.anim.startTime
	local duration = GUI.anim.endTime - GUI.anim.startTime
	local progress = elapsedTime / duration
 
	local fProgress = getEasingValue( progress, GUI.anim.easingFunction )
		
	if GUI.current == "main" then
		if GUI.anim.swap == "register" then
			guiSetAlpha( GUI.pane, 1-fProgress )
			guiSetAlpha( GUI.pane2, fProgress )
		elseif GUI.anim.swap == "login" then
			guiSetAlpha( GUI.pane, 1-fProgress )
			guiSetAlpha( GUI.pane3, fProgress )
		end
	elseif GUI.current == "register" then
		if GUI.anim.swap == "main" then
			guiSetAlpha( GUI.pane2, 1-fProgress )
			guiSetAlpha( GUI.pane, fProgress )
		elseif GUI.anim.swap == "login" then
			guiSetAlpha( GUI.pane2, 1-fProgress )
			guiSetAlpha( GUI.pane3, fProgress )
		end
	elseif GUI.current == "login" then
		if GUI.anim.swap == "main" then
			guiSetAlpha( GUI.pane3, 1-fProgress )
			guiSetAlpha( GUI.pane, fProgress )
		elseif GUI.anim.swap == "register" then
			guiSetAlpha( GUI.pane3, 1-fProgress )
			guiSetAlpha( GUI.pane2, fProgress )
		end
	end
	
	if now > GUI.anim.endTime then
		if GUI.current == "main" then
			guiSetVisible( GUI.pane, false )
		elseif GUI.current == "register" then
			guiSetVisible( GUI.pane2, false )
		elseif GUI.current == "login" then
			guiSetVisible( GUI.pane3, false )
		end
		
		GUI.current = GUI.anim.swap
		removeEventHandler( "onClientRender", root, swapWindowAnim )
		
		if GUI.current == "register" then
			-- Window changed to register window, all handlers here
			guiSetProperty( GUI.pane2, "Disabled", "False" )
			guiSetInputEnabled( true )
			addEventHandler( "onClientGUIClick", GUI.register.backButton, pressRegisterBackButton, false )
			addEventHandler( "onClientGUIClick", GUI.register.registerButton, pressRegisterAcceptButton, false )
			addEventHandler( "onClientGUIChanged", GUI.register.usernameField, fieldChanged, false )
			addEventHandler( "onClientGUIChanged", GUI.register.pwField1, fieldChanged, false )
			addEventHandler( "onClientGUIChanged", GUI.register.pwField2, fieldChanged, false )
		elseif GUI.current == "login" then
			-- Window changed to register window, all handlers here
			guiSetProperty( GUI.pane3, "Disabled", "False" )
			guiSetInputEnabled( true )
			addEventHandler( "onClientGUIClick", GUI.login.backButton, pressLoginBackButton, false )
			addEventHandler( "onClientGUIClick", GUI.login.loginButton, pressLoginAcceptButton, false )
			addEventHandler( "onClientGUIChanged", GUI.login.usernameField, fieldChanged, false )
			addEventHandler( "onClientGUIChanged", GUI.login.pwField, fieldChanged, false )
			addEventHandler( "onClientGUIClick", GUI.login.rmpwCheck, checkBoxClicked, false )
			addEventHandler( "onClientGUIClick", GUI.login.auloCheck, checkBoxClicked, false )
		elseif GUI.current == "main" then
			-- Window changed to main window, all handlers here
			guiSetProperty( GUI.pane, "Disabled", "False" )
			-- Avoid account creation spam by simply blocking the button
			if not accountRegistered then
				guiSetProperty( GUI.main.registerButton, "Disabled", "False" )
			end
			addEventHandler( "onClientGUIClick", GUI.main.guestButton, pressGuestButton, false )
			addEventHandler( "onClientGUIClick", GUI.main.registerButton, pressRegisterButton, false )
			addEventHandler( "onClientGUIClick", GUI.main.loginButton, pressLoginButton, false )
		end
	end
end

function buttonEnter()
	if source == GUI.main.guestButton then
		guiSetText( GUI.main.bottomText, "Playing as a Guest allows you to play the game but none of the stats are saved." )
	elseif source == GUI.main.registerButton then
		guiSetText( GUI.main.bottomText, "Register an account." )
	elseif source == GUI.main.loginButton then
		guiSetText( GUI.main.bottomText, "Log in to an existing account." )
	end
	setSoundVolume( playSound( "resources/click.mp3" ), 0.2 )
end

function buttonLeave()
	guiSetText( GUI.main.bottomText, "" )
end

function fieldChanged()
	-- REGISTER
	if source == GUI.register.usernameField then
		local text = guiGetText( source )
		local name = removeIllegalCharacters( text ) or ""
		guiSetText( source, name )
		if #name >= 1 and #name <= 22 then
			GUI.register.usernameOK = true
		else
			GUI.register.usernameOK = false
		end
	elseif source == GUI.register.pwField1 or source == GUI.register.pwField2 then
		local password1 = guiGetText( GUI.register.pwField1 )
		local password2 = guiGetText( GUI.register.pwField2 )
		local found1 = string.find( password1, "[^A-Za-z0-9_%-]" )
		local found2 = string.find( password2, "[^A-Za-z0-9_%-]" )
			
		if found1 or found2 then
			guiSetText( GUI.register.okText, "Password contains illegal characters!\nAllowed: A-Z, a-z, 0-9, _, -" )
			guiLabelSetColor( GUI.register.okText, 200, 0, 0 )
			GUI.register.passwordOK = false
 		elseif password1 ~= "" and password2 ~= "" and password1 ~= password2 then
			guiSetText( GUI.register.okText, "Passwords are not equal!" )
			guiLabelSetColor( GUI.register.okText, 200, 0, 0 )
			GUI.register.passwordOK = false
		elseif #password1 >= 3 and #password1 <= 16 and #password2 >= 3 and #password2 <= 16 then
			guiSetText( GUI.register.okText,  "OK!" )
			guiLabelSetColor( GUI.register.okText, 0, 200, 0 )
			GUI.register.passwordOK = true
		--elseif password1 == "" or password2 == "" then
		else
			guiSetText( GUI.register.okText,  "" )
			guiLabelSetColor( GUI.register.okText, 200, 200, 200 )
			GUI.register.passwordOK = false
		end
		
	-- LOGIN
	elseif source == GUI.login.usernameField then
		local text = guiGetText( source )
		local name = removeIllegalCharacters( text ) or ""
		guiSetText( source, name )
		if #name >= 1 and #name <= 22 then
			GUI.login.usernameOK = true
		else
			GUI.login.usernameOK = false
		end
	elseif source == GUI.login.pwField then
		if GUI.userinfo.pwHashed then
			guiSetText( source, "" )
			GUI.userinfo.pwHashed = false
			GUI.login.passwordOK = false
		else
			local password = guiGetText( source )
			local found = string.find( password, "[^A-Za-z0-9_%-]" )
				
			if found then
				guiSetText( GUI.login.okText, "Password contains illegal characters!\nAllowed: A-Z, a-z, 0-9, _, -" )
				guiLabelSetColor( GUI.login.okText, 200, 0, 0 )
				GUI.login.passwordOK = false
			else
				guiSetText( GUI.login.okText,  "" )
				guiLabelSetColor( GUI.login.okText, 200, 200, 200 )
				if #password >= 3 and #password <= 16 then
					GUI.login.passwordOK = true
				else
					GUI.login.passwordOK = false
				end
			end
		end
	end
end

function checkBoxClicked( key, state )
	if key == "left" and state == "up" then
		setSoundVolume( playSound( "resources/click2.mp3" ), 0.5 )
		if source == GUI.login.auloCheck then
			local selected = guiCheckBoxGetSelected( GUI.login.auloCheck )
			if selected then
				guiCheckBoxSetSelected( GUI.login.rmpwCheck, true )
				guiSetProperty( GUI.login.rmpwCheck, "Disabled", "True" )
			else
				guiSetProperty( GUI.login.rmpwCheck, "Disabled", "False" )
			end
		end
	end
end

function removeIllegalCharacters( text )
	return string.gsub( text, "[^A-Za-z0-9_%-]", "" ) or ""
end

addEvent( "sendRegistrationResponse", true )
function registrationResponse( successful, reason )
	guiSetProperty( GUI.pane2, "Disabled", "False" )
	if not successful then
		guiLabelSetColor( GUI.register.okText, 200, 0, 0 )
		if not reason then
			guiSetText( GUI.register.okText, "Error in registration process!" )
		elseif reason == "notAvailable" then
			guiSetText( GUI.register.okText, "That nickname is not available!" )
		elseif reason == "creationFailed" then
			guiSetText( GUI.register.okText, "Account creation failed!" )
		end
	else
		-- Block account creation spam and cheat your way out of little cleanup
		accountRegistered = true
		guiSetProperty( GUI.main.registerButton, "Disabled", "True" )
		
		setSoundVolume( playSound( "resources/click2.mp3" ), 0.5 )
		
		-- Autofill fields
		guiSetText( GUI.login.usernameField, guiGetText( GUI.register.usernameField ) )
		guiSetText( GUI.login.pwField, guiGetText( GUI.register.pwField1 ) )
		guiCheckBoxSetSelected( GUI.login.rmpwCheck, false )
		guiCheckBoxSetSelected( GUI.login.auloCheck, false )
		GUI.userinfo.pwHashed = false
		GUI.login.usernameOK = true
		GUI.login.passwordOK = true
		
		swapWindow( "login" )
		removeEventHandler( "onClientGUIClick", GUI.register.backButton, pressRegisterBackButton )
		removeEventHandler( "onClientGUIClick", GUI.register.registerButton, pressRegisterAcceptButton )
		removeEventHandler( "onClientGUIChanged", GUI.register.usernameField, fieldChanged )
		removeEventHandler( "onClientGUIChanged", GUI.register.pwField1, fieldChanged )
		removeEventHandler( "onClientGUIChanged", GUI.register.pwField2, fieldChanged )
	end
end
addEventHandler( "sendRegistrationResponse", resourceRoot, registrationResponse )

addEvent( "sendLoginResponse", true )
function loginResponse( successful, reason )
	guiSetProperty( GUI.pane3, "Disabled", "False" )
	if not successful then
		guiLabelSetColor( GUI.login.okText, 200, 0, 0 )
		if not reason then
			guiSetText( GUI.login.okText, "Error in login process!" )
		elseif reason == "wrongPw" then
			guiSetText( GUI.login.okText, "Wrong password!" )
		elseif reason == "noAccount" then
			guiSetText( GUI.login.okText, "Account with that name doesn't exist!" )
		end
	else
		-- Remove all GUI
		endGUI( false )
		
		setSoundVolume( playSound( "resources/click2.mp3" ), 0.5 )
		
		guiSetInputEnabled( false )
		removeEventHandler( "onClientGUIClick", GUI.login.backButton, pressLoginBackButton )
		removeEventHandler( "onClientGUIClick", GUI.login.loginButton, pressLoginAcceptButton )
		removeEventHandler( "onClientGUIChanged", GUI.login.usernameField, fieldChanged )
		removeEventHandler( "onClientGUIChanged", GUI.login.pwField, fieldChanged )
		removeEventHandler( "onClientGUIClick", GUI.login.rmpwCheck, checkBoxClicked )
		removeEventHandler( "onClientGUIClick", GUI.login.auloCheck, checkBoxClicked )
	end
end
addEventHandler( "sendLoginResponse", resourceRoot, loginResponse )

function endGUI( guest )
	fadeGUI( "Out" )
	setTimer( destroyLoginGUI, 5000, 1 )

	clearLogin()
	
	if guest then
		outputChatBox( "ptpm_login: Logged in as a guest.", 128, 128, 255 )
	else
		outputChatBox( "ptpm_login: Logged in.", 128, 128, 255 )
		createControlPanel()
	end
	setElementData( localPlayer, "ptpm.loggedIn", true )
	setElementData( localPlayer, "ptpm.loggingIn", false )
	triggerServerEvent( "onClientAvailable", localPlayer )
	triggerEvent( "onClientAvailable", localPlayer )
end

function destroyLoginGUI( )
	destroyElement( GUI.window )
	GUI = {}
end

function clearLogin()
	stopLoginScenery()
	showCursor( false )
end

function doLoginCleanup()
	if GUI.userinfo then
		clearLogin()
	end
end
addEventHandler( "onClientResourceStop", resourceRoot, doLoginCleanup )