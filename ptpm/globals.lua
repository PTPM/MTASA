﻿thisResource = getThisResource()
screenX, screenY = nil, nil
do
	if getLocalPlayer then
		screenX, screenY = guiGetScreenSize()
	end
end

classColours = {
	["psycho"] = { 255, 128, 0 },
	["terrorist"] = { 255, 0, 175 },
	["terroristm"] = { 255, 64, 207 },
	["pm"] = { 255, 255, 64 },
	["bodyguard"] = { 0, 128, 0 },
	["bodyguardm"] = { 80, 176, 80 },
	["police"] = { 80, 80, 207 },
	["policem"] = { 128, 128, 239 },

	light = {
		["psycho"] = { 255, 217, 179 },
		["terrorist"] = { 255, 217, 243 },
		["terroristm"] = { 255, 217, 243 },
		["pm"] = { 255, 255, 219 },
		["bodyguard"] = { 180, 237, 180 },
		["bodyguardm"] = { 180, 237, 180 },
		["police"] = { 200, 200, 255 },
		["policem"] = { 200, 200, 255 },
	},
}

teamMemberFriendlyName = {
	["psycho"] = "Psychopath",
	["bodyguard"] = "Bodyguard",
	["police"] = "Police",
	["pm"] = "Prime Minister",
	["terrorist"] = "Terrorist"
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