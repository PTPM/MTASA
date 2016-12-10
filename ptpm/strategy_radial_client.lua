-- This script uses many of the functions defined in class_selection_client.lua
-- This script only provides the radial menu and Smart Pings (map markers), the voices are a seperate resource

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

local smartCommands = {
	Greet = {
		Title = "Greet",
		textLines = {
			"Hi!", "Hello!", "Hey!"
		}
	},
	Come = {
		Title = "Come",
		textLines = {
			"Help me here!", "Come here!", "Come to me!"
		}
	},
	Yes = {
		Title = "Yes",
		textLines = {
			"Yes", "Yea", "Affirmative"
		}
	},
	Thanks = {
		Title = "Thanks",
		textLines = {
			"Thank you", "Appreciate it", "Thanks!"
		}
	},
	No = {
		Title = "No",
		textLines = {
			"No", "Negatory", "No way, Jose"
		}
	},
	Taunt = {
		Title = "Taunt",
		textLines = {
			"Butt!", "Ass!", "Fuck!"
		}
	},
	Go = {
		Title = "Go",
		textLines = {
			"Go!", "Get out!", "Leave!"
		}
	}
}

local numberOfSmartCommands = 0
local step = 0


local radialMenuConfig = {
	x = screenX * 0.5,
	y = screenY * 0.5,
	radius = 150
}

-- Step one: draw a radial menu
-- scaleFont without globalScalar
function sf_(value)
	return ((value * uiScale) / font.scalar)
end

function drawStrategyRadial()
	if (numberOfSmartCommands==0 or numberOfSmartCommands==nil) then return end
	
	-- Dim screen
	dxDrawRectangle(0, 0, screenX, screenY, tocolor(0, 0, 0, 130))
	
	local i = 0
	
	-- Calculate the absolute position of SmartCommands if not done already
	for k,smartCommand in pairs(smartCommands) do
		if not smartCommand.x or not smartCommand.y then
			smartCommand.x, smartCommand.y = getPointOnCircle(s(radialMenuConfig.radius), ((i) * step) - 90)
		end
	
		-- Draw the SmartCommands
		dxDrawText ( smartCommand.Title, radialMenuConfig.x + smartCommand.x, radialMenuConfig.y + smartCommand.y, radialMenuConfig.x + smartCommand.x, radialMenuConfig.y + smartCommand.y, tocolor ( 255, 255, 255, 255 ), sf_(1.5), font.base, "center", "center", false, false, false, true, false ) 
		
		i=i+1
	end
end

-- Step 2: handle mouse over
function getSelectedRadialOption(_, _, cursorX, cursorY)
	local imaginaryRadius = getDistanceBetweenPoints2D(cursorX, cursorY, radialMenuConfig.x ,radialMenuConfig.y )
	
	-- im stumped
end



addEventHandler( "onClientCursorMove", getRootElement( ), getSelectedRadialOption)


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
		
	end
)


addEventHandler("onClientRender", root, drawStrategyRadial)