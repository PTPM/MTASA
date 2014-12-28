local Panel = {}
Panel.visible = false
Panel.animating = false
Panel.mouse = false

function createControlPanel()
	triggerServerEvent( "loadPanelInfo", resourceRoot )
	
	local sFont = guiCreateFont( "resources/tahoma.ttf", 8 )
	local mFont = guiCreateFont( "resources/tahoma.ttf", 10 )
	local mbFont = guiCreateFont( "resources/tahomabd.ttf", 10 )
	local bFont = guiCreateFont( "resources/tahomabd.ttf", 19 )
	
	local windowWidth, windowHeight = 600, 356
	local left = screenX/2 - windowWidth/2
	
	Panel.window = guiCreateWindow( left, screenY-17, windowWidth, windowHeight, "Control panel - Press F1 to open", false )
	guiWindowSetSizable( Panel.window, false )
	guiWindowSetMovable( Panel.window, false )
	guiSetAlpha( Panel.window, 0.2 )
	
	Panel.tabs = guiCreateTabPanel( 0, 25, 591, 291, false, Panel.window )
	guiSetFont( Panel.tabs, sFont )
	
	-- Help text
	Panel.helpText = guiCreateLabel( 0, 315, 601, 21, "", false, Panel.window )
	guiLabelSetHorizontalAlign( Panel.helpText, "center", false )
	guiLabelSetVerticalAlign( Panel.helpText, "center" )
	guiSetFont( Panel.helpText, sFont )
	--guiSetVisible( Panel.helpText, false )
	
	-- OVERVIEW
	Panel.overview = {}
	Panel.overview.tab = guiCreateTab( "Overview", Panel.tabs )

	Panel.overview.infoHeader = guiCreateLabel( 10, 10, 581, 51, "This is the user control panel.\nYou can view your account information and edit its settings with this panel.\nPress m key to enable your mouse.", false, Panel.overview.tab )
	--Panel.overview.infoHeader = guiCreateLabel( 10, 10, 581, 51, "This is the user control panel.\nYou can view your statistics, account information and edit your account settings with this panel.\nPress m key to enable your mouse.", false, Panel.overview.tab )
	guiSetFont( Panel.overview.infoHeader, sFont )
	guiLabelSetHorizontalAlign( Panel.overview.infoHeader, "center", true )
	guiLabelSetVerticalAlign( Panel.overview.infoHeader, "center" )
	guiSetAlpha( Panel.overview.infoHeader, 0.5 )
	
	Panel.overview.accountHeader = guiCreateLabel( 20, 60, 271, 41, "Account information", false, Panel.overview.tab )
	guiSetFont( Panel.overview.accountHeader, bFont )
	guiLabelSetHorizontalAlign( Panel.overview.accountHeader, "left", false )
	guiLabelSetVerticalAlign( Panel.overview.accountHeader, "center" )
	
	Panel.overview.usernamePrefix = guiCreateLabel( 30, 110, 91, 20, "Username:", false, Panel.overview.tab )
	guiSetFont( Panel.overview.usernamePrefix, mFont )
	guiLabelSetHorizontalAlign( Panel.overview.usernamePrefix, "left", false )
	guiLabelSetVerticalAlign( Panel.overview.usernamePrefix, "center" )
	
	Panel.overview.passwordPrefix = guiCreateLabel( 30, 130, 91, 20, "Password:", false, Panel.overview.tab )
	guiSetFont( Panel.overview.passwordPrefix, mFont )
	guiLabelSetHorizontalAlign( Panel.overview.passwordPrefix, "left", false )
	guiLabelSetVerticalAlign( Panel.overview.passwordPrefix, "center" )
		
	Panel.overview.serialPrefix = guiCreateLabel( 30, 150, 91, 20, "Serial:", false, Panel.overview.tab )
	guiSetFont( Panel.overview.serialPrefix, mFont )
	guiLabelSetHorizontalAlign( Panel.overview.serialPrefix, "left", false )
	guiLabelSetVerticalAlign( Panel.overview.serialPrefix, "center" )
		
	Panel.overview.ipPrefix = guiCreateLabel( 30, 170, 91, 20, "IP:", false, Panel.overview.tab )
	guiSetFont( Panel.overview.ipPrefix, mFont )
	guiLabelSetHorizontalAlign( Panel.overview.ipPrefix, "left", false )
	guiLabelSetVerticalAlign( Panel.overview.ipPrefix, "center" )
		
	Panel.overview.usernameLabel = guiCreateLabel( 120, 110, 281, 20, "-", false, Panel.overview.tab )
	guiSetFont( Panel.overview.usernameLabel, mFont )
	guiLabelSetHorizontalAlign( Panel.overview.usernameLabel, "left", false )
	guiLabelSetVerticalAlign( Panel.overview.usernameLabel, "center" )
	
	Panel.overview.passwordLabel = guiCreateLabel( 120, 130, 201, 20, "-", false, Panel.overview.tab )
	guiLabelSetHorizontalAlign( Panel.overview.passwordLabel, "left", false )
	guiLabelSetVerticalAlign( Panel.overview.passwordLabel, "center" )
	guiSetFont( Panel.overview.passwordLabel, mFont )
		
	Panel.overview.serialLabel = guiCreateLabel( 120, 150, 281, 20, "-", false, Panel.overview.tab )
	guiSetFont( Panel.overview.serialLabel, mFont )
	guiLabelSetHorizontalAlign( Panel.overview.serialLabel, "left", false )
	guiLabelSetVerticalAlign( Panel.overview.serialLabel, "center" )
		
	Panel.overview.ipLabel = guiCreateLabel( 120, 170, 281, 20, "-", false, Panel.overview.tab )
	guiSetFont( Panel.overview.ipLabel, mFont )
	guiLabelSetHorizontalAlign( Panel.overview.ipLabel, "left", false )
	guiLabelSetVerticalAlign( Panel.overview.ipLabel, "center" )
		
	Panel.overview.rmpwPrefix = guiCreateLabel( 30, 190, 141, 31, "Remember password:", false, Panel.overview.tab )
	guiSetFont( Panel.overview.rmpwPrefix, mFont )
	guiLabelSetHorizontalAlign( Panel.overview.rmpwPrefix, "left", false )
	guiLabelSetVerticalAlign( Panel.overview.rmpwPrefix, "center" )
		
	Panel.overview.rmpwCheck = guiCreateCheckBox( 170, 190, 31, 31, "", false, false, Panel.overview.tab )
	addEventHandler( "onClientGUIClick", Panel.overview.rmpwCheck, panelCheckClicked, false )
		
	Panel.overview.auloPrefix = guiCreateLabel( 220, 190, 141, 31, "Auto login on connect:", false, Panel.overview.tab )
	guiSetFont( Panel.overview.auloPrefix, mFont )
	guiLabelSetHorizontalAlign( Panel.overview.auloPrefix, "left", false )
	guiLabelSetVerticalAlign( Panel.overview.auloPrefix, "center" )
		
	Panel.overview.auloCheck = guiCreateCheckBox( 360, 190, 31, 31, "", false, false, Panel.overview.tab )
	addEventHandler( "onClientGUIClick", Panel.overview.auloCheck, panelCheckClicked, false )
	
	Panel.overview.statusOp = guiCreateCheckBox( 40, 230, 81, 21, "Operator", false, false, Panel.overview.tab )
	guiSetFont( Panel.overview.statusOp, mFont )
	guiSetProperty( Panel.overview.statusOp, "Disabled", "True" )
		
	Panel.overview.statusMuted = guiCreateCheckBox( 120, 230, 81, 21, "Muted", false, false, Panel.overview.tab )
	guiSetFont( Panel.overview.statusMuted, mFont )
	guiSetProperty( Panel.overview.statusMuted, "Disabled", "True" )
	
	-- Panel.overview.sep = guiCreateButton( 440, 115, 13, 141, "", false, Panel.overview.tab )
	-- guiSetProperty( Panel.overview.sep, "Disabled", "True" )
	-- guiSetAlpha( Panel.overview.sep, 0.2 )
	
	-- Panel.overview.chpwEdit1 = guiCreateEdit( 120, 130, 151, 20, "", false, Panel.overview.tab )
	-- guiEditSetMaxLength( Panel.overview.chpwEdit1, 16 )
	-- guiSetVisible( Panel.overview.chpwEdit1, false )
		
	-- Panel.overview.chpwEdit2 = guiCreateEdit( 280, 130, 151, 20, "", false, Panel.overview.tab )
	-- guiEditSetMaxLength( Panel.overview.chpwEdit2, 16 )
	-- guiSetVisible( Panel.overview.chpwEdit2, false )
		
	-- Panel.overview.chpwButton = guiCreateButton( 460, 150, 111, 21, "Change password", false, Panel.overview.tab )
	-- guiSetFont( Panel.overview.chpwButton, sFont )
	
	-- Panel.overview.logoutButton = guiCreateButton( 460, 120, 111, 21, "Log out", false, Panel.overview.tab )
	-- guiSetFont( Panel.overview.logoutButton, sFont )
	
	-- STATS
	-- Panel.stats = {}
	-- Panel.stats.tab = guiCreateTab( "Stats", Panel.tabs )
	
	-- ACHIEVEMENTS
	-- Panel.achv = {}
	-- Panel.achv.tab = guiCreateTab( "Achievements", Panel.tabs )
	
	-- ADMIN
	-- Panel.admin = {}
	-- Panel.admin.tab = guiCreateTab( "Administration", Panel.tabs )
	
	guiSetVisible( Panel.window, false )
end

function showPanel()
	if Panel.animating then return end
	guiSetProperty( Panel.window, "Disabled", "True" )

	Panel.animating = true
	Panel.anim = {}
	Panel.anim.startTime = getTickCount()
	Panel.anim.endTime = Panel.anim.startTime + 300
	Panel.anim.easingFunction = "OutQuad"
	Panel.anim.type = fadeType
	addEventHandler( "onClientRender", root, showPanelRender )
end

function showPanelRender()
	local now = getTickCount()
	local elapsedTime = now - Panel.anim.startTime
	local duration = Panel.anim.endTime - Panel.anim.startTime
	local progress = elapsedTime / duration
 
	local alpha = getEasingValue( progress, Panel.anim.easingFunction )
 
	if not Panel.visible then
		guiSetPosition( Panel.window, screenX/2 - 300, screenY-17-(320*alpha), false )
		guiSetAlpha( Panel.window, 0.2+(alpha*0.8) )
	else
		guiSetPosition( Panel.window, screenX/2 - 300, screenY-17-(320*(1-alpha)), false )
		guiSetAlpha( Panel.window, 0.2+((1-alpha)*0.8) )
	end
	
	if now > Panel.anim.endTime then
		guiSetProperty( Panel.window, "Disabled", "False" )
		removeEventHandler( "onClientRender", root, showPanelRender )
		Panel.visible = not Panel.visible
		if Panel.visible then
			bindKey( "m", "up", mHandler )
			guiSetText( Panel.window, "Control panel" )
		else
			unbindKey( "m", "up", mHandler )
			Panel.mouse = false
			showCursor( Panel.mouse )
			guiSetText( Panel.window, "Control panel - Press F1 to open" )
		end
		Panel.animating = false
	end
end

function mHandler()
	Panel.mouse = not Panel.mouse
	showCursor( Panel.mouse )
end

addEvent( "sendPanelInfo", true )
function gotPanelInfo( successful, userdata, playerStats )
	if not successful then
		destroyElement( Panel.window )
		Panel = {}
	end

	bindKey( "F1", "down", showPanel )
	guiSetVisible( Panel.window, true )
	
	if userdata.username then guiSetText( Panel.overview.usernameLabel, userdata.username ) end
	if userdata.serial then guiSetText( Panel.overview.serialLabel, userdata.serial ) end
	if userdata.ip then guiSetText( Panel.overview.ipLabel, userdata.ip ) end
	
	if userdata.pwlength then
		guiSetText( Panel.overview.passwordLabel, string.rep( "*", tonumber( userdata.pwlength ) ) )
	end
	
	if userdata.rememberpw and userdata.rememberpw == 1 then
		guiCheckBoxSetSelected( Panel.overview.rmpwCheck, true )
	end
	if userdata.autologin and userdata.autologin == 1 then
		guiCheckBoxSetSelected( Panel.overview.auloCheck, true )
	end
	
	if userdata.operator and userdata.operator == 1 then
		guiCheckBoxSetSelected( Panel.overview.statusOp, true )
	end
	if userdata.muted and userdata.muted == 1 then
		guiCheckBoxSetSelected( Panel.overview.statusMuted, true )
	end
end
addEventHandler( "sendPanelInfo", resourceRoot, gotPanelInfo )

function panelCheckClicked( key, state )
	if key == "left" and state == "up" then
		if source == Panel.overview.rmpwCheck then
			local selected = guiCheckBoxGetSelected( Panel.overview.rmpwCheck )
			if not selected then
				guiCheckBoxSetSelected( Panel.overview.auloCheck, false )
			end
		elseif source == Panel.overview.auloCheck then
			local selected = guiCheckBoxGetSelected( Panel.overview.auloCheck )
			if selected then
				guiCheckBoxSetSelected( Panel.overview.rmpwCheck, true )
			end
		end
		
		local rmpw = guiCheckBoxGetSelected( Panel.overview.rmpwCheck )
		local aulo = guiCheckBoxGetSelected( Panel.overview.auloCheck )
		local settings = { ["rememberpw"] = rmpw, ["autologin"] = aulo }
		
		guiSetProperty( Panel.overview.rmpwCheck, "Disabled", "True" )
		guiSetProperty( Panel.overview.auloCheck, "Disabled", "True" )
		
		triggerServerEvent( "sendNewUserSettings", resourceRoot, settings )
		guiSetText( Panel.helpText, "Saving new account settings..." )
	end
end

addEvent( "sendPanelSettingsResponse", true )
function panelSettingsResponse( successful )
	if successful then
		guiSetText( Panel.helpText, "Account settings saved successfully. Disabling buttons for a while." )
		setTimer( delayEnable, 40000, 1, Panel.overview.rmpwCheck, Panel.overview.auloCheck )
	else
		guiSetText( Panel.helpText, "Saving account settings failed." )
		guiSetProperty( Panel.overview.rmpwCheck, "Disabled", "False" )
		guiSetProperty( Panel.overview.auloCheck, "Disabled", "False" )
	end
end
addEventHandler( "sendPanelSettingsResponse", resourceRoot, panelSettingsResponse )

function delayEnable( ... )
	for _, v in ipairs( { ... } ) do
		guiSetProperty( v, "Disabled", "False" )
	end
	if guiGetText( Panel.helpText ) == "Account settings saved successfully. Disabling buttons for a while." then
		guiSetText( Panel.helpText, "" )
	end
end