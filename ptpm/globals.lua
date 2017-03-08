thisResource = getThisResource()
screenX, screenY = nil, nil
do
	if getLocalPlayer then
		screenX, screenY = guiGetScreenSize()
	end
end

classColours = {
	psycho = { 255, 128, 0 },
	terrorist = { 255, 0, 175 },
	terroristm = { 255, 64, 207 },
	pm = { 255, 255, 64 },
	pmm = { 255, 255, 64 },
	bodyguard = { 0, 128, 0 },
	bodyguardm = { 80, 176, 80 },
	police = { 80, 80, 207 },
	policem = { 128, 128, 239 },

	light = {
		psycho = { 255, 217, 179 },
		terrorist = { 255, 217, 243 },
		terroristm = { 255, 217, 243 },
		pm = { 255, 255, 219 },
		bodyguard = { 180, 237, 180 },
		bodyguardm = { 180, 237, 180 },
		police = { 200, 200, 255 },
		policem = { 200, 200, 255 },
	},
}

teamMemberFriendlyName = {
	psycho = "Psychopath",
	bodyguard = "Bodyguard",
	police = "Police",
	pm = "Prime Minister",
	terrorist = "Terrorist"
}

colour = {
	important = {255, 0, 0},
	personal = {128, 128, 255},
	achievement = {94, 170, 2},
	query = {255, 220, 24},
	global = {208, 208, 255},
	ptpm = {0, 102, 204},

	white = {255, 255, 255},

	sampRed = {180, 25, 29},
	sampGreen = {53, 101, 43},
	sampYellow = {222, 188, 97},
	--b = {50, 60, 127},
	--o = {239, 141, 27},
	--o = {144, 98, 16},	
	--p = {180, 25, 180},
	--l = {10, 10, 10},

	hex = {
		ptpm = string.format("#%02x%02x%02x", 0, 102, 204),
		pm = string.format("#%02x%02x%02x", unpack(classColours.pm)),
		pmm = string.format("#%02x%02x%02x", unpack(classColours.pm)),
		bodyguard = string.format("#%02x%02x%02x", unpack(classColours.bodyguard)),
		bodyguardm = string.format("#%02x%02x%02x", unpack(classColours.bodyguardm)),
		police = string.format("#%02x%02x%02x", unpack(classColours.police)),
		policem = string.format("#%02x%02x%02x", unpack(classColours.policem)),
		terrorist = string.format("#%02x%02x%02x", unpack(classColours.terrorist)),
		terroristm = string.format("#%02x%02x%02x", unpack(classColours.terroristm)),
		psycho = string.format("#%02x%02x%02x", unpack(classColours.psycho)),
		white = string.format("#%02x%02x%02x", 255, 255, 255),
		black = string.format("#%02x%02x%02x", 0, 0, 0),
		red = string.format("#%02x%02x%02x", 255, 0, 0),
		blue = string.format("#%02x%02x%02x", 0, 0, 170),

		parse = function(s) 
			s = s:gsub("%[PTPM%]", colour.hex.ptpm)
			s = s:gsub("%[PM%]", colour.hex.pm)
			s = s:gsub("%[BODYGUARD%]", colour.hex.bodyguard)
			s = s:gsub("%[BODYGUARDM%]", colour.hex.bodyguardm)
			s = s:gsub("%[POLICE%]", colour.hex.police)
			s = s:gsub("%[POLICEM%]", colour.hex.policem)
			s = s:gsub("%[TERRORIST%]", colour.hex.terrorist)
			s = s:gsub("%[TERRORISTM%]", colour.hex.terroristm)
			s = s:gsub("%[PSYCHO%]", colour.hex.psycho)	

			s = s:gsub("%[WHITE%]", colour.hex.white)	
			s = s:gsub("%[BLACK%]", colour.hex.black)	
			s = s:gsub("%[RED%]", colour.hex.red)	
			s = s:gsub("%[BLUE%]", colour.hex.blue)	

			return s
		end,
	}
}

if localPlayer then
	colour.black = tocolor(0, 0, 0, 255)
	colour.grey = tocolor(128, 128, 128, 255)
	colour.darkGrey = tocolor(60, 60, 60, 255)
	colour.white = tocolor(255, 255, 255, 255)
else
	colour.hex.parseContextual = function(s, player) 
		local classID = getPlayerClassID(player)

		if classID then
			s = s:gsub("%[TEAM%]", colour.hex[getPlayerClassType(player, classID)])
		end

		return s
	end
end

gameTextOrder = {
	normal = 1, -- normal things
	contextual = 2, -- normal stuff that is specific to the context of the player (e.g. just entered a camera screen)
	punish = 3,
	absolve = 4,
	global = 5,
	admin = 6,
}


__DEBUG = true
function debugStr( dString )
	if __DEBUG then
		outputDebugString( "STR: " .. dString, 0, 200, 200, 200 )
	end
end

function debugFunc( name, ... )
	if __DEBUG then
		local dString = name .. "("
		local args = { ... }
		for _, v in ipairs( args ) do
			if isElement( v ) then
				local dType = getElementType( v )
				dString = dString .. " element:" .. tostring( dType )
				if dType == "player" then
					local name = getPlayerName( v )
					dString = dString .. " name:" .. tostring( name )
				elseif dType == "ped" then
				elseif dType == "vehicle" then
					local name = getVehicleName( v )
					dString = dString .. " name:" .. tostring( name )
				elseif dType == "object" then
					local model = getElementModel( v )
					dString = dString .. " model:" .. tostring( model )
				elseif dType == "pickup" then
					local pickup = getPickupType( v )
					if pickup == 0 then
						dString = dString .. " type:health"
					elseif pickup == 1 then
						dString = dString .. " type:armor"
					else
						local weapon = getPickupWeapon( v )
						dString = dString .. " type:" .. tostring( weapon )
					end
				elseif dType == "marker" then
				
				elseif dType == "colshape" then
				
				elseif dType == "blip" then
					local icon = getBlipIcon( v )
					dString = dString .. " icon:" .. tostring( icon )
				elseif dType == "radararea" then
				elseif dType == "blip" then
				elseif dType == "projectile" then
					local projectile = getProjectileType( v )
					dString = dString .. " type:" .. tostring( projectile )
				elseif dType == "team" then
					local team = getTeamName( v )
					dString = dString .. " name:" .. tostring( team )
				elseif dType == "console" then
				elseif dType == "gui-button" then
				elseif dType == "gui-checkbox" then
				elseif dType == "gui-edit" then
				elseif dType == "gui-gridlist" then
				elseif dType == "gui-memo" then
				elseif dType == "gui-progressbar" then
				elseif dType == "gui-radiobutton" then
				elseif dType == "gui-scrollbar" then
				elseif dType == "gui-scrollpane" then
				elseif dType == "gui-staticimage" then
				elseif dType == "gui-tabpanel" then
				elseif dType == "gui-tab" then
				elseif dType == "gui-label" then
				elseif dType == "gui-window" then
				elseif dType == "txd" then
				elseif dType == "dff" then
				elseif dType == "col" then
				elseif dType == "sound" then
				elseif dType == "texture" then
				elseif dType == "shader" then
				elseif dType == "dx-font" then
				elseif dType == "gui-font" then
				end
			else
				local dType = type( v )
				dString = dString .. " " .. dType
				if dType == "string" or dType == "number" or dType == "boolean" then
					dString = dString .. ":" .. tostring( v )
				elseif dType == "table" then
					local size = 0
					for _, _ in pairs( v ) do
						size = size + 1
					end
					dString = dString .. " size:" .. tostring( size )

					for key,value in pairs(v) do
						dString = dString .. "," .. key .. ":" .. tostring(value)
					end
				end
			end
			dString = dString .. ","
		end
		dString = dString .. " )"
		outputDebugString( "FUNC: " .. dString, 0, 200, 200, 200 )
	end
end