-- This script only provides the radial menu and Smart Pings (map markers), the voices are a seperate resource
local screenX, screenY = guiGetScreenSize()

local uiScale = screenY / 600
local font = {
	globalScalar = 1
}

local colours = {
	black = tocolor(0, 0, 0, 255),
	grey = tocolor(128, 128, 128, 255),
	darkGrey = tocolor(60, 60, 60, 255),
	white = tocolor(255, 255, 255, 255)
}

local overwriteDisableStrategyRadial = false
local numberOfSmartCommands = 0
local step = 0
local cursorState = false
local smartPingWorldX, smartPingWorldY, smartPingWorldZ = 0,0,0

local radialMenuConfig = {
	x = screenX * 0.5,
	y = screenY * 0.5,
	radius = (0.7 * screenY) / 2
}

local backgroundImageSize = radialMenuConfig.radius * 2 * 1.1
local safeZoneImageSize = radialMenuConfig.radius * 2 * 0.1 --safezone is visualized one-tenth of radialMenuConfig.radius

local smartCommands =  {
	{
		Title = "Hello",
		textLines = {
			"Hi!", 
			"Hello!", 
			"Hey!"
		},
		selected = false
	}, {
		Title = "Yes",
		textLines = {
			"Yes", 
			"Yea", 
			"Affirmative"
		},
		selected = false
	}, {
		Title = "Help!",
			textLines = {
				"Help me here!", 
				"Come here!", 
				"Come help me!"
			},
		selected = false
	}, {
		Title = "Good job",
			textLines = {
				"Good job!", 
				"Nice!", 
				"Well done!"
			},
		selected = false
	}, {
		Title = "Thanks",
		textLines = {
			"Thank you", 
			"Appreciate it", 
			"Thanks!"
		},
		selected = false
	}, {
		Title = "Insult",
		textLines = {
			"Bunghole!", 
			"Bozo!", 
			"Pinhead!"
		},
		selected = false
	}, {
		Title = "Go",
		textLines = {
			"Go! Go! Go!", 
			"Let's get out of here!"
		},
		selected = false
	}, {
		Title = "No",
		textLines = {
			"No", 
			"Negatory", 
			"No way, Jose"
		},
		selected = false
	}
};

function sf_(value)
	return ((value * uiScale) / font.scalar)
end

function getPointOnCircle(radius, rotation)
	return radius * math.cos(math.rad(rotation)), radius * math.sin(math.rad(rotation))
end

-- Step 1: draw a radial menu

function drawStrategyRadial()
	if (numberOfSmartCommands==0 or numberOfSmartCommands==nil) then return end
	
	local i = 0
	
	-- Background image
	dxDrawImage(radialMenuConfig.x - backgroundImageSize/2,radialMenuConfig.y- backgroundImageSize/2, backgroundImageSize, backgroundImageSize, "backgroundShade.png")
	
	-- The cursor "safe zone" (mouseover for "cancel"-area)
	dxDrawImage(radialMenuConfig.x - safeZoneImageSize/2,radialMenuConfig.y- safeZoneImageSize/2, safeZoneImageSize, safeZoneImageSize, "backgroundShade.png")
		
	-- Calculate the absolute position of SmartCommands if not done already
	for k,smartCommand in pairs(smartCommands) do
	
		-- Draw divider lines between the options
		relXEnd,relYEnd = getPointOnCircle(radialMenuConfig.radius, step/2 + ((i) * step) - 90)
		relXStart,relYStart = getPointOnCircle(radialMenuConfig.radius * 0.1, step/2 + ((i) * step) - 90)
		dxDrawLine( relXStart + radialMenuConfig.x, relYStart + radialMenuConfig.y, relXEnd+radialMenuConfig.x,relYEnd+radialMenuConfig.y, tocolor(0,0,0,50), 2 )
	
		if not smartCommand.x or not smartCommand.y then
			relX,relY = getPointOnCircle(radialMenuConfig.radius/4*3, ((i) * step) - 90)
			smartCommands[k].x, smartCommands[k].y = relX+radialMenuConfig.x,relY+radialMenuConfig.y
		end
	
		-- Draw the SmartCommands
		local fontSize = 1.5
		
		if smartCommands[k].selected then
			fontSize = 2.2
		end
		
		dxDrawSmartCommandTitle(smartCommand.Title,smartCommands[k].x, smartCommands[k].y,tocolor ( 255, 255, 255, 255 ), sf_(fontSize)) 
				
		i=i+1
	end
end

function dxDrawSmartCommandTitle(text,x,y,colour,size)

	dxDrawText(text,x-1,y-1,x-1,y-1,colours.black,size, font.base, "center", "center", false, false, false, true, false )
	dxDrawText(text,x-1,y+1,x-1,y+1,colours.black,size, font.base, "center", "center", false, false, false, true, false )
	dxDrawText(text,x+1,y-1,x+1,y-1,colours.black,size, font.base, "center", "center", false, false, false, true, false )
	dxDrawText(text,x+1,y+1,x+1,y+1,colours.black,size, font.base, "center", "center", false, false, false, true, false )
	dxDrawText(text,x,y,x,y,colour,size, font.base, "center", "center", false, false, false, true, false )

end

-- Step 2: handle mouse over
function getSelectedRadialOption(_, _, cursorX, cursorY, worldX, worldY, worldZ)

	-- Cursor has to be moved enough pixels from the center, otherwise just cancel
	if getDistanceBetweenPoints2D(cursorX, cursorY, radialMenuConfig.x, radialMenuConfig.y ) > 30 then

		local closestCommandKey = nil
		local closestDistance = 999999999999
		
		for k,smartCommand in pairs(smartCommands) do
			smartCommands[k].selected = false
			
			local thisDistance = getDistanceBetweenPoints2D(cursorX, cursorY, smartCommand.x, smartCommand.y )
			
			if thisDistance < closestDistance then
				closestCommandKey = k
				closestDistance = thisDistance
			end
		
		end 
		
		smartCommands[closestCommandKey].selected = true
		smartPingWorldX, smartPingWorldY, smartPingWorldZ = worldX, worldY, worldZ
	
	else 
		for k,smartCommand in pairs(smartCommands) do
			smartCommands[k].selected = false
		end
	end
end

-- Step 3: Handle the logic
function showStrategicRadialMenu()
	-- Ensure it is allowed
	if overwriteDisableStrategyRadial then return end
	if not (getElementData(localPlayer, "ptpm.classID") or false) then return end

	-- Unset select state
	for k,smartCommand in pairs(smartCommands) do
		smartCommands[k].selected = false
	end
	setCursorPosition( radialMenuConfig.x, radialMenuConfig.y )

	addEventHandler("onClientRender", root, drawStrategyRadial)
	addEventHandler( "onClientCursorMove", getRootElement( ), getSelectedRadialOption)
	
	-- Enable cursor + allow movement, but don't overwrite movement permission
	if not cursorState then 
		showCursor ( true, false )
	end
end

function executeStrategicRadialMenu()
	if not (getElementData(localPlayer, "ptpm.classID") or false) then return end

	removeEventHandler("onClientRender", root, drawStrategyRadial)
	removeEventHandler( "onClientCursorMove", getRootElement( ), getSelectedRadialOption)
	
	if  not overwriteDisableStrategyRadial then 
		for k,smartCommand in pairs(smartCommands) do
			if smartCommands[k].selected then
				-- get a random line
				local line = smartCommands[k].textLines[math.random(1,#smartCommands[k].textLines)]
				triggerServerEvent ( "ptpmStrategyRadialRelay", resourceRoot, smartCommands[k].Title, line, smartPingWorldX, smartPingWorldY, smartPingWorldZ )
			end
		end
		
		if not cursorState then
			showCursor ( false, false )
		end
	end
end

bindKey ( "x", "down", showStrategicRadialMenu ) 
bindKey ( "x", "up", executeStrategicRadialMenu ) 

addEventHandler( "ptpmStartMapVote", localPlayer, function() overwriteDisableStrategyRadial = true end )
addEventHandler( "ptpmEndMapVote", localPlayer, function() overwriteDisableStrategyRadial = false end )


addEventHandler("onClientResourceStart", resourceRoot,
	function()
		-- the default fonts do not scale well, so load our own version at the sizes we need
		font.scalar = (120 / 44) * uiScale
		font.base = dxCreateFont("fonts/tahoma.ttf", 9 * font.scalar, false, "proof")

		-- if the user cannot load the font, default to a built-in one with the appropriate scaling
		if not font.base then
			font.base = "default"
			font.scalar = 1
		end

		font.smallScalar = 1.2 * uiScale
		font.small = dxCreateFont("fonts/tahoma.ttf", 9 * font.smallScalar, false, "proof")

		if not font.small then
			font.small = "default"
			font.smallScalar = 1
		end
		
		for k,smartCommand in pairs(smartCommands) do
			numberOfSmartCommands = numberOfSmartCommands + 1
		end
		
		step = 360 / numberOfSmartCommands
		cursorState = isCursorShowing()
		
	end
)


