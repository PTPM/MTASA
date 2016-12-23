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

local overwriteDisableStrategyRadial = true
local numberOfSmartCommands = 0
local cursorState = false
local smartPingWorldX, smartPingWorldY, smartPingWorldZ = 0,0,0

local radialMenuConfig = {
	x = screenX * 0.5,
	y = screenY * 0.5,
	radius = (0.7 * screenY) / 2
}

local backgroundImageSize = radialMenuConfig.radius * 2 * 1.1
local cancelZoneImageSize = radialMenuConfig.radius * 2 * 0.1 --cancel zone is visualized one-tenth of radialMenuConfig.radius
local requestedStrategyRadialMenu = nil

local smartCommands =  {
	{
		commandBind = "radial_social",
		suggestedKey = "n",
		step = 0,
		linesPosCache = {},
		commands = {
			{
				Title = "Hello",
				textLines = {
					"Hi!", 
					"Hello!", 
					"Hey!"
				}
			}, {
				Title = "Yes",
				textLines = {
					"Yes", 
					"Yea", 
					"Affirmative"
				}
			}, {
				Title = "Thanks",
				textLines = {
					"Thank you", 
					"Appreciate it", 
					"Thanks!"
				}
			}, {
				Title = "Good job",
					textLines = {
						"Good job!", 
						"Nice!", 
						"Well done!"
					}
			},{
				Title = "Sorry",
					textLines = {
						"Sorry!"
					}
			}, {
				Title = "No",
				textLines = {
					"No", 
					"Negatory", 
					"No way, Jose"
				}
			}
		}
	},
	{
		commandBind = "radial_instructions",
		suggestedKey = "b",
		step = 0,
		linesPosCache = {},
		commands = {
			{
				Title = "Help!",
				textLines = {
					"Help me here!", 
					"Come here!", 
					"Come help me!"
				}
			}, {
				Title = "Go",
				textLines = {
					"Go! Go! Go!", 
					"Let's get out of here!"
				}
			}, {
				Title = "Attack",
				textLines = {
					"Attack now!", 
					"Let's kill them!", 
					"Go on the attack!"
				}
			}, {
				Title = "Heal me",
					textLines = {
						"I need a medic!", 
						"Doctor!", 
						"I need healing!"
					}
			},{
				Title = "Defend",
					textLines = {
						"Stay close to defend!", 
						"Go on defence!"
					}
			}, {
				Title = "Wait",
				textLines = {
					"Hold up!", 
					"Wait!"
				}
			}
		}
	}
}

function sf_(value)
	return ((value * uiScale) / font.scalar)
end

function getPointOnCircle(radius, rotation)
	return radius * math.cos(math.rad(rotation)), radius * math.sin(math.rad(rotation))
end

-- Step 1: draw a radial menu

function drawStrategyRadial()
	--if (numberOfSmartCommands==0 or numberOfSmartCommands==nil) then return end
	
	local i = 0
	
	-- Background image
	dxDrawImage(radialMenuConfig.x - backgroundImageSize/2,radialMenuConfig.y- backgroundImageSize/2, backgroundImageSize, backgroundImageSize, "backgroundShade.png")
	
	-- The cursor "safe zone" (mouseover for "cancel"-area)
	dxDrawImage(radialMenuConfig.x - cancelZoneImageSize/2,radialMenuConfig.y- cancelZoneImageSize/2, cancelZoneImageSize, cancelZoneImageSize, "backgroundShade.png")
		
	-- Calculate the absolute position of SmartCommands if not done already
	for ks,strategyRadialMenu in pairs(smartCommands) do
		if requestedStrategyRadialMenu==strategyRadialMenu.commandBind then
			for k,smartCommand in pairs(strategyRadialMenu.commands) do
				-- Draw divider lines between the options
				if not strategyRadialMenu.linesPosCache[k] then
					strategyRadialMenu.linesPosCache[k] = { x1=0,y1=0,x2=0,y2=0 }
					smartCommands[ks].linesPosCache[k].x1,smartCommands[ks].linesPosCache[k].y1 = getPointOnCircle(radialMenuConfig.radius * 0.1, smartCommands[ks].step/2 + ((i) * smartCommands[ks].step) - 90)
					smartCommands[ks].linesPosCache[k].x2,smartCommands[ks].linesPosCache[k].y2 = getPointOnCircle(radialMenuConfig.radius, smartCommands[ks].step/2 + ((i) * smartCommands[ks].step) - 90)		
					
					smartCommands[ks].linesPosCache[k].x1,smartCommands[ks].linesPosCache[k].y1 = smartCommands[ks].linesPosCache[k].x1 + radialMenuConfig.x,smartCommands[ks].linesPosCache[k].y1 + radialMenuConfig.y
					smartCommands[ks].linesPosCache[k].x2,smartCommands[ks].linesPosCache[k].y2 = smartCommands[ks].linesPosCache[k].x2 + radialMenuConfig.x,smartCommands[ks].linesPosCache[k].y2 + radialMenuConfig.y
				end
			
				if not smartCommand.x or not smartCommand.y then
					relX,relY = getPointOnCircle(radialMenuConfig.radius/4*3, ((i) * smartCommands[ks].step) - 90)
					smartCommands[ks].commands[k].x, smartCommands[ks].commands[k].y = relX+radialMenuConfig.x,relY+radialMenuConfig.y
				end
				
				-- Draw line between options
				dxDrawLine( smartCommands[ks].linesPosCache[k].x1,smartCommands[ks].linesPosCache[k].y1, smartCommands[ks].linesPosCache[k].x2,smartCommands[ks].linesPosCache[k].y2, tocolor(0,0,0,50), 2 )
			
				-- Draw the SmartCommands
				local fontSize = 1.5
				
				if smartCommands[ks].commands[k].selected then
					fontSize = 2.2
				end
				
				dxDrawSmartCommandTitle(smartCommand.Title,smartCommands[ks].commands[k].x, smartCommands[ks].commands[k].y,tocolor ( 255, 255, 255, 255 ), sf_(fontSize)) 
						
				i=i+1
			
			end
		end
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
		local selectedStrategyRadial = nil
		
		for ks,strategyRadialMenu in pairs(smartCommands) do
			if requestedStrategyRadialMenu==strategyRadialMenu.commandBind then
				for k,smartCommand in pairs(strategyRadialMenu.commands) do
					smartCommands[ks].commands[k].selected = false
					
					local thisDistance = getDistanceBetweenPoints2D(cursorX, cursorY, smartCommand.x, smartCommand.y )
					
					if thisDistance < closestDistance then
						closestCommandKey = k
						closestDistance = thisDistance
						selectedStrategyRadial = ks
					end
				end 
			end
		end
		
		smartCommands[selectedStrategyRadial].commands[closestCommandKey].selected = true
		smartPingWorldX, smartPingWorldY, smartPingWorldZ = worldX, worldY, worldZ
	
	else 
		for ks,strategyRadialMenu in pairs(smartCommands) do
			if requestedStrategyRadialMenu==strategyRadialMenu.commandBind then
				for k,smartCommand in pairs(strategyRadialMenu.commands) do
					smartCommands[ks].commands[k].selected = false
				end
			end
		end
	end
end

-- Step 3: Handle the logic
function showStrategicRadialMenu(_,whichStrategyRadialMenu_commandBind)
	-- Was cursor showing before Strategy Radial was called?
	cursorState = isCursorShowing()

	-- Ensure it is allowed
	if overwriteDisableStrategyRadial then return end
	
	-- is player alive?
	if math.ceil(getElementHealth ( localPlayer ))== 0 then return end
	
	-- is menu already open?
	if requestedStrategyRadialMenu~=nil then return end 

	-- Unset select state
	for ks,strategyRadialMenu in pairs(smartCommands) do
		for k,smartCommand in pairs(strategyRadialMenu.commands) do
			smartCommands[ks].commands[k].selected = false
		end
	end	
	setCursorPosition( radialMenuConfig.x, radialMenuConfig.y )
	
	requestedStrategyRadialMenu = whichStrategyRadialMenu_commandBind

	addEventHandler("onClientRender", root, drawStrategyRadial)
	addEventHandler( "onClientCursorMove", getRootElement( ), getSelectedRadialOption)
	
	-- Enable cursor + allow movement, but don't overwrite movement permission
	if not cursorState then 
		showCursor ( true, false )
	end
end

function executeStrategicRadialMenu()

	removeEventHandler("onClientRender", root, drawStrategyRadial)
	removeEventHandler( "onClientCursorMove", getRootElement( ), getSelectedRadialOption)
	
	if not cursorState then
		showCursor ( false, false )
	end
		
	if  not overwriteDisableStrategyRadial then 
		for ks,strategyRadialMenu in pairs(smartCommands) do
			if requestedStrategyRadialMenu==strategyRadialMenu.commandBind then
				for k,smartCommand in pairs(strategyRadialMenu.commands) do
					if smartCommands[ks].commands[k].selected then
						-- play sound
						playSoundFrontEnd(38)
					
						-- get a random line
						local line = smartCommands[ks].commands[k].textLines[math.random(1,#smartCommands[ks].commands[k].textLines)]
						triggerServerEvent ( "ptpmStrategyRadialRelay", resourceRoot, smartCommands[ks].commands[k].Title, line, smartPingWorldX, smartPingWorldY, smartPingWorldZ )
					end
				end
			end
		end
	end
	
	requestedStrategyRadialMenu = nil
end


addEventHandler( "ptpmStartMapVote", localPlayer, function() overwriteDisableStrategyRadial = true end )
addEventHandler( "enterClassSelection", localPlayer,  function() overwriteDisableStrategyRadial = true end ) 
addEventHandler( "leaveClassSelection", localPlayer,  function() overwriteDisableStrategyRadial = false end )

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		outputDebugString("strategy_radial started")
	
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
		
		for k,strategyRadialMenu in pairs(smartCommands) do
			if #smartCommands[k].commands==0 then
				smartCommands[k] = nil
			else
				smartCommands[k].step = 360 / #smartCommands[k].commands
				
				addCommandHandler("sr_show", showStrategicRadialMenu)
				addCommandHandler("sr_exec", executeStrategicRadialMenu)
				
				-- oh cool, this doesnt work, its always 0: <
				if #getFunctionsBoundToKey(strategyRadialMenu.suggestedKey)==0 then
					-- />
					bindKey ( strategyRadialMenu.suggestedKey, "down", "sr_show" , strategyRadialMenu.commandBind )
					
					-- no this is completely cool, the up event doesnt show in the standardized UI so if you change the bind itll never close the menu
					bindKey ( strategyRadialMenu.suggestedKey, "up",   "sr_exec" )
					
				else
					outputChatBox(strategyRadialMenu.commandBind .. " was not bound to " .. strategyRadialMenu.suggestedKey .. ": key in use",255,0,0)
				end
				
			end
		end 
	
		cursorState = isCursorShowing()
		
	end
)
