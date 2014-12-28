classColours = {
	["psycho"] = { 255, 128, 0 },
	["terrorist"] = { 255, 0, 175 },
	["terroristm"] = { 255, 64, 207 },
	["pm"] = { 255, 255, 64 },
	["bodyguard"] = { 0, 128, 0 },
	["bodyguardm"] = { 80, 176, 80 },
	["police"] = { 80, 80, 207 },
	["policem"] = { 128, 128, 239 }
}

class_selection_text = {}
interfaceToggle = true
descriptionClass = nil
 
function updateClassSelectionScreen( action, classID, classType, isMedic, isFull, weapons, objectives )
	if action == "create" or action == "sync" then
		if action == "create" and class_selection_text then
			removeEventHandler("onClientRender",root,renderClassSelectionInfo)
			removeEventHandler("onClientRender",root,renderClassSelectionDescription)	
			
			if class_selection_text.timer then
				if isTimer(class_selection_text.timer) then
					killTimer(class_selection_text.timer)
				end
				class_selection_text.timer = nil
			end
		end
	
		local weaponsSplit = {}
		
		if weapons then
			tokens = split(weapons,string.byte(';'))
			
			if tokens then
				for i,t in ipairs(tokens) do
					local id = tonumber( gettok( t, 1, 44 ) )
					local ammo = tonumber( gettok( t, 2, 44 ) )
					
					if id and ammo and id ~= 0 and ammo ~= 0 then
						weaponsSplit[i] = "- ".. getWeaponNameFromID( id ) .. " (" .. ammo .. ")\n"
					else
						weaponsSplit[i] = "- (none)\n"
					end
				end
			end
		end
	
		local types = { ["psycho"] = "Psychopath", ["bodyguard"] = "Bodyguard", ["police"] = "Police", ["pm"] = "Prime Minister", ["terrorist"] = "Terrorist" }
		
		class_selection_text.information = "Use left and right arrow keys to select a class.\nHold ctrl and press the arrow keys to select the next team.\nPress SHIFT or ENTER when ready to spawn.\n\nClass " .. classID .. " Weapons:\n" .. table.concat(weaponsSplit,"")
		class_selection_text.classtype = types[classType] .. (isMedic == true and " (Medic)" or "")
		class_selection_text.classtypecolour = classColours[(isMedic == true and classType .. "m" or classType)]
		class_selection_text.availability = (isFull == true and "NOT AVAILABLE" or "AVAILABLE")
		class_selection_text.description = getClassDescription((isMedic == true and classType .. "m" or classType),objectives)
		
		interfaceToggle = true
		
		if action == "create" then
			addEventHandler("onClientRender", root, renderClassSelectionInfo )
			addEventHandler("onClientRender", root, renderClassSelectionDescription )
		end
		
		descriptionClass = classID
	elseif action == "clear" then
		removeEventHandler("onClientRender",root,renderClassSelectionInfo)
		class_selection_text.timer = setTimer(function()
			removeEventHandler("onClientRender",root,renderClassSelectionDescription)
			class_selection_text = {}
			descriptionClass = nil
			class_selection_text.timer = nil
		end,10000,1)
	end	
end
addEvent( "updateClassSelectionScreen", true )
addEventHandler( "updateClassSelectionScreen", root, updateClassSelectionScreen )



function renderClassSelectionInfo()
	if interfaceToggle then
	-- dxDrawText ( string text, int left, int top [, int right=left, int bottom=top, int color=white, float scale=1, string font="default", string alignX="left", string alignY="top", bool clip=false, bool wordBreak=false, bool postGUI] )
		local scale = 1.0
		if screenX < 900 then
			scale = screenX/900
		end
		local s = function( value )
			return value*scale
		end
	
		local right = (dxGetTextWidth( class_selection_text.availability, s(2), "bankgothic" ) > dxGetTextWidth( class_selection_text.classtype, s(1.5), "bankgothic" ) and
							dxGetTextWidth( class_selection_text.availability, s(2), "bankgothic" ) or dxGetTextWidth( class_selection_text.classtype, s(1.5), "bankgothic" ) ) + s(5)
		local bottom = dxGetFontHeight( s(1.5), "bankgothic" ) + dxGetFontHeight( s(2), "bankgothic" ) + (dxGetFontHeight( s(1), "default" )*8) + s(5)
	
		-- render black boxes behind the text to give some contrast on particularly bright areas of the map
		dxDrawRectangle( s(25), screenY-s(265), right, bottom, tocolor( 0, 0, 0, 100 ), false )
		dxDrawText( class_selection_text.classtype, s(30), screenY-s(260), s(250), s(150), tocolor( unpack( class_selection_text.classtypecolour ) ), s(1.5), "bankgothic", "left", "top", false, false, false )
		dxDrawText( class_selection_text.availability, s(30), screenY-s(220), s(250), s(150), tocolor( unpack( class_selection_text.classtypecolour ) ), s(2), "bankgothic", "left", "top", false, false, false )
		dxDrawText( class_selection_text.information, s(30), screenY-s(160), s(250), s(150), tocolor( 255, 255, 255 ), s(1), "default", "left", "top", false, false, false )
	end
end


function renderClassSelectionDescription()
	if interfaceToggle then
		local scale = 1.0
		if screenX < 900 then
			scale = screenX/900
		end
		local s = function( value )
			return value*scale
		end
	
		dxDrawRectangle( screenX-s(305), screenY-s(265), s(295), s(255), tocolor( 0, 0, 0, 100 ), false )	
		dxDrawText( class_selection_text.description, screenX-s(300), screenY-s(260), screenX-s(10), screenY-s(10), tocolor( 255, 255, 255 ), s(1), "default", "center", "center", false, true, false )
	end
end


function toggleClassSelectionInterface(toggle)
	interfaceToggle = toggle
end

function getClassDescription(team, objectives)
	local description = ""
	if team == "psycho" then
		description = "Nobody wants to be your friend.\nSo trust noone.\nKill them all."
	elseif team == "terrorist" or team == "terroristm" then
		description = "Your role is to try and kill the Prime Minister (yellow) before the timer runs out. You must work with the other terrorists (pink) as a team.\n\nAvoid the cops (blue), they will hunt you.\n\nBeware of psychopaths (orange), they will kill anyone."
		
		if objectives then
			description = description .. "\n\nThe Prime Minister will be visiting areas of the city (red). You should try and ambush him on his way there, siege him when he is there, and drive him away.\nIf the Prime Minister achieves his objectives then you lose the game."
		end
		
	elseif team == "pm" then
		if objectives then
			description = "Your role is to visit and each of the objectives in order (red). You must defend the objective for the set time before the next objective will be revealed. Terrorists (pink) and psychopaths (orange) will try to kill you. If you die, the terrorists win."
		else
			description = "Your role is to avoid being killed by terrorists (pink) or psychopaths (orange) until the timer runs out."
		end
		
		description = description .. "\n\nYour loyal bodyguards (green) will protect you.\n\nCo-operate with the local police (blue), they will hunt the terrorists."
	
	elseif team == "bodyguard" or team == "bodyguardm" then
		description = "Your duty is to protect the Prime Minister (yellow) from harm.\n\nTerrorists (pink) will soon try and murder him. Also beware of psychopaths (orange).\n\nCo-operate with the local police (blue), they will hunt the terrorists."
		
		if objectives then
			description = description .. "\n\nThe Prime Minister will be visiting areas of the city (red). The terrorists know where he needs to go, so you must prevent them from harming the Prime Minister.\nIf he is killed, you lose the game."
		end
	
	elseif team == "police" or team == "policem" then
		description = "Your orders are to kill the terrorists (pink) without harming the bodyguards (green) or the Prime Minister (yellow).\n\nAlso beware of psychopaths (orange).\nProtect the Prime Minister!"
		
		if objectives then
			description = description .. "\n\nThe Prime Minister will be visiting areas of the city (red). You should focus your efforts there, clean out the terrorists so that the Prime Minister can go in. Defend the area until he is done."
		end
	end
	
	if team == "terroristm" or team == "policem" or team == "bodyguardm" then
		description = description .. "\n\nYou are also a medic, you can heal people with /heal"
	end
	
	--[[
	if options.safehouse.enabled then
		outputChatBox( "Only terrorists and bodyguards may fly the hydra or seasparrow. The Prime Minister's safehouse (red) is a hydra/seasparrow", thePlayer, unpack( colourPersonal ) )
		outputChatBox( "free zone.", thePlayer, unpack( colourPersonal ) )
	end]]
	
	return description
end


addEventHandler( "onClientElementDataChange", localPlayer,
	function( name, oldValue )
		if name == "ptpm.classID" then
			if descriptionClass then
				if descriptionClass ~= getElementData( localPlayer, "ptpm.classID" ) then
					if class_selection_text.timer then
						if isTimer( class_selection_text.timer ) then 
							killTimer( class_selection_text.timer ) 
						end
					
						removeEventHandler( "onClientRender", root, renderClassSelectionDescription )
						class_selection_text = {}
						descriptionClass = nil
						class_selection_text.timer = nil	
					end
				end
			end
		end
	end
)