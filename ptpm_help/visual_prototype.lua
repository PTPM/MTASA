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

local displayProperties = {
	container = {
		width = screenX / 3,	-- i think one-third for 4:3 and one-fourth for widescreen
		height = screenY * 0.1, -- placeholder, should be based on padding + lineHeight * max lines (probably 5)
		
		x = screenX - displayProperties.container.width,
		y = screenY * 0.8
	},
	
	iconContainer = {
		width = 100,			-- placeholder
		height = 100,			-- placeholder
		
		x = 0,					-- placeholder
		y = 0					-- placeholder
	},
	
	textContainer = {
		width = displayProperties.container.width,
		heigth = displayProperties.container.height,
		
		x = displayProperties.container.height
		
	}
}

local backgroundImageSize = radialMenuConfig.radius * 2 * 1.1
local cancelZoneImageSize = radialMenuConfig.radius * 2 * 0.1 --cancel zone is visualized one-tenth of radialMenuConfig.radius
local requestedStrategyRadialMenu = nil
local mainMenuActive = false
local bindCache = {}