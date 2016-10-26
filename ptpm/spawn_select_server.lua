function initClassSelection( thePlayer )

	if not data	then return end	
	if data.roundEnded then return end
	local inClassSelection = getElementData( thePlayer, "ptpm.inClassSelection" )
	if not isPlayerActive( thePlayer ) or inClassSelection then return end	
	setElementData( thePlayer, "ptpm.inClassSelection", true, false )
	
	if getPlayerClassID( thePlayer ) then
		setElementData( thePlayer, "ptpm.classID", false )
	end
	
	setElementData( thePlayer, "ptpm.score.class", nil )
	setPlayerTeam( thePlayer, nil )
	resetPlayerColour( thePlayer )
	
	setPlayerControllable( thePlayer, false )
	
	-- Tell client which classes are available
	for k,v in pairs(classes) do
		debugStr(k .. ": ".. v)
	end
	
	for _, p in ipairs( getElementsByType( "player" ) ) do
		if p and isElement( p ) and isPlayerActive( p ) then
			
		end
	end
	
	
	

	local classSelectID = getElementData( thePlayer, "ptpm.classSelect.id" )
	local skin = getElementData( classes[classSelectID].class, "skin" )
	
	--fadeCamera( thePlayer, true )
	
	setCameraMatrix( thePlayer, data.wardrobe.camX,
								data.wardrobe.camY,
								data.wardrobe.camZ,
								data.wardrobe.playerX,
								data.wardrobe.playerY,
								data.wardrobe.playerZ )
	setCameraInterior( thePlayer, data.wardrobe.interior )
		
	-- local weapons = getElementData( classes[classSelectID].class, "weapons" )
	-- triggerClientEvent( thePlayer, "updateClassSelectionScreen", root, "create", 
						-- classSelectID, 
						-- classes[classSelectID].type, 
						-- classes[classSelectID].medic, 
						-- vetoPlayerClass( classSelectID, false ) ~= classSelectID,
						-- weapons,
						-- tableSize( getElementsByType( "objective", runningMapRoot ) ) > 0
					  -- )
	
	if tableSize( getElementsByType( "objective", runningMapRoot ) ) > 0 then
		clearObjectiveTextFor( thePlayer ) 
	end
	
	if tableSize( getElementsByType( "task", runningMapRoot ) ) > 0 then
		clearTaskTextFor( thePlayer )
	end
end