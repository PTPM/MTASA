staticText = {}

local options = {}
classes = {}
currentPM = nil
currentMapName = ""

addEventHandler( "onClientResourceStart", root,
	function(res)
		if res == resource then
			triggerServerEvent( "onClientReady", resourceRoot )

			classSelectionSetup()
		end

		createTransitionImage(res)
	end
)

addEvent("onClientMapStart", true)
addEventHandler("onClientMapStart", root,
	function(mapName)
		currentMapName = mapName
		setupTransition(mapName)

		currentPM = nil
	end
)

addEvent("onClientMapStarted", true)
addEventHandler("onClientMapStarted", root,
	function(class, distpm)
		hideTransitionImage()

		classes = class
		options.distanceToPM = distpm	

		vehicleBlipsClientMapStarted()
	end
)

addEvent("onClientMapStop", true)
addEventHandler("onClientMapStop", root, 
	function()
		vehicleBlipsClientMapStop()
	end
)

addEvent("sendClientMapData", true)
addEventHandler("sendClientMapData", root,
	function(class, current, distpm)
		classes = class
		options.distanceToPM = distpm
		currentPM = current
		
		if not options.distanceToPM then
			if options.distanceToPMTimer then
				if isTimer(options.distanceToPMTimer) then
					killTimer(options.distanceToPMTimer)
				end
				options.distanceToPMTimer = nil
							
				drawStaticTextToScreen("delete", "pmDist")
			end
		end
	end
)


function drawGameTextToScreen( text, duration, colour, font, size, valign, halign, importance )
	if not importance then importance = 1 end
	
	if drawOptions then
		if drawOptions.importance <= importance then
			removeGameTextFromScreen()
		else
			return
		end
	end
	
	drawOptions = {}
	drawOptions.text = text
	drawOptions.colour = colour or { 255, 255, 255 }
	drawOptions.font = font or "pricedown"
	drawOptions.size = size or 1.2
	drawOptions.valign = valign or "center"
	drawOptions.halign = halign or "center"
	drawOptions.importance = importance
	
	drawOptions.colour[4] = 0
	
	drawOptions.x = (screenX/2) - 300
	drawOptions.y = (screenY/8) - 300
	drawOptions.r = (screenX/2) + 300
	drawOptions.b = (screenY/8) + 300
	
	if drawOptions.y < 0 then drawOptions.y = 0 end
	if drawOptions.b > screenY then drawOptions.b = screenY end
	
	addEventHandler( "onClientRender", root, drawFunction )
	addEventHandler( "onClientRender", root, drawFadeIn )
	
	drawTimer = setTimer(
		function() 
			removeEventHandler( "onClientRender", root, drawFadeIn )
			addEventHandler( "onClientRender", root, drawFadeOut )
		end,
	duration, 1 )
end
addEvent( "drawGameTextToScreen", true )
addEventHandler( "drawGameTextToScreen", root, drawGameTextToScreen )


function removeGameTextFromScreen( )
	if drawOptions then
		removeEventHandler( "onClientRender", root, drawFunction )
		removeEventHandler( "onClientRender", root, drawFadeOut )
		removeEventHandler( "onClientRender", root, drawFadeIn )
		
		if isTimer( drawTimer ) then
			killTimer( drawTimer )
		end
		drawTimer = nil
		drawOptions = nil
	end
end


function drawFunction( )
--	dxDrawText( drawOptions.text, screenX/2-298, screenY/2-298, screenX/2+302, screenY/2+302, tocolor( 0, 0, 0, drawOptions.colour[4] ), drawOptions.size, drawOptions.font, drawOptions.halign, drawOptions.valign, false, true, false )
--	dxDrawText( drawOptions.text, screenX/2-300, screenY/2-300, screenX/2+300, screenY/2+300, tocolor( unpack(drawOptions.colour) ), drawOptions.size, drawOptions.font, drawOptions.halign, drawOptions.valign, false, true, false )
	dxDrawText( drawOptions.text, drawOptions.x+2, drawOptions.y+2, drawOptions.r+2, drawOptions.b+2, tocolor( 0, 0, 0, drawOptions.colour[4] ), drawOptions.size, drawOptions.font, drawOptions.halign, drawOptions.valign, false, true, false )
	dxDrawText( drawOptions.text, drawOptions.x, drawOptions.y, drawOptions.r, drawOptions.b, tocolor( unpack(drawOptions.colour) ), drawOptions.size, drawOptions.font, drawOptions.halign, drawOptions.valign, false, true, false )
end

function drawFadeIn()
	drawOptions.colour[4] = drawOptions.colour[4] + 7
	if drawOptions.colour[4] >= 255 then
		if drawOptions.colour[4] > 255 then drawOptions.colour[4] = 255 end
		
		removeEventHandler( "onClientRender", root, drawFadeIn)
	end
end


function drawFadeOut()
	drawOptions.colour[4] = drawOptions.colour[4] - 7
	if drawOptions.colour[4] <= 0 then
		if drawOptions.colour[4] < 0 then drawOptions.colour[4] = 0 end
		
		removeGameTextFromScreen()
	end
end


function drawStaticTextToScreen( option, textID, text, x, y, width, height, colour, size, font, valign, halign )
	valign = valign or "center"
	halign = halign or "center"

	if option == "draw" then
		if type( x ) == "string" then
			local pX, a = tostring( string.gsub( x, "screenX", tostring( screenX ) ) )
			a, x = pcall( loadstring( "return " .. pX ) )
		end
		if type( y ) == "string" then
			local pY = tostring( string.gsub( y, "screenY", tostring( screenY ) ) )
			a, y = pcall( loadstring( "return " .. pY ) )
		end
		if type( width ) == "string" then
			local pX = tostring( string.gsub( width, "screenX", tostring( screenX ) ) )
			a, width = pcall( loadstring( "return " .. pX ) )
		end
		if type( height ) == "string" then
			local pY = tostring( string.gsub( height, "screenY", tostring( screenY ) ) )
			a, height = pcall( loadstring( "return " .. pY ) )
		end
		
		if staticText[textID] then drawStaticTextToScreen( "delete", textID ) end
		staticText[textID] = {}
		staticText[textID].func = 	function( )
										local outline = math.min( 2, size )
										for offsetX=-outline, outline, outline do
											for offsetY=-outline, outline, outline do
												if not (offsetX == 0 and offsetY == 0) then
													dxDrawText( text, x+offsetX, y+offsetY, x+width+offsetX, y+height+offsetY, tocolor( 0, 0, 0, 150 ), size, font, halign, valign, true, true, false )
												end
											end
										end
										--dxDrawText( text, x+1, y+1, x+width+1, y+height+1, tocolor( 0, 0, 0 ), size, font, halign, valign, true, true, false )
										dxDrawText( text, x, y, x+width, y+height, tocolor( unpack( colour ) ), size, font, halign, valign, true, true, false )
									end
		addEventHandler( "onClientRender", root, staticText[textID].func )
	elseif option == "update" then
		if staticText[textID] then
			if type( x ) == "string" then
				local pX, a = tostring( string.gsub( x, "screenX", tostring( screenX ) ) )
				a, x = pcall( loadstring( "return " .. pX ) )
			end
			if type( y ) == "string" then
				local pY = tostring( string.gsub( y, "screenY", tostring( screenY ) ) )
				a, y = pcall( loadstring( "return " .. pY ) )
			end
			if type( width ) == "string" then
				local pX = tostring( string.gsub( width, "screenX", tostring( screenX ) ) )
				a, width = pcall( loadstring( "return " .. pX ) )
			end
			if type( height ) == "string" then
				local pY = tostring( string.gsub( height, "screenY", tostring( screenY ) ) )
				a, height = pcall( loadstring( "return " .. pY ) )
			end
			
			--staticText[textID] = {}
			removeEventHandler( "onClientRender", root, staticText[textID].func )
			staticText[textID].func = 	function( )
											local outline = math.min( 3, size )
											for offsetX=-outline, outline, outline do
												for offsetY=-outline, outline, outline do
													if not (offsetX == 0 and offsetY == 0) then
														dxDrawText( text, x+offsetX, y+offsetY, x+width+offsetX, y+height+offsetY, tocolor( 0, 0, 0, 150 ), size, font, halign, valign, true, true, false )
													end
												end
											end
											--dxDrawText( text, x+1, y+1, x+width+1, y+height+1, tocolor( 0, 0, 0 ), size, font, halign, valign, true, true, false )
											dxDrawText( text, x, y, x+width, y+height, tocolor( unpack( colour ) ), size, font, halign, valign, true, true, false )
										end
			addEventHandler( "onClientRender", root, staticText[textID].func )
		end
	elseif option == "delete" then
		if staticText[textID] and staticText[textID].func then
			removeEventHandler( "onClientRender", root, staticText[textID].func )
			staticText[textID] = nil
		end
	end
end
addEvent( "drawStaticTextToScreen", true )
addEventHandler( "drawStaticTextToScreen", root, drawStaticTextToScreen )



---------------------------------------------------------------------------
-- transition images shown between rounds
---------------------------------------------------------------------------
local transition = false
local transitionMap

function setupTransition(mapName)
	hideTransitionImage()
	transitionMap = mapName
end

function createTransitionImage(res)
	if getResourceName(res) == transitionMap then
		local mapName = "images/ptpm-default.png"
		local x, y = 640, 538

		if fileExists(":" .. currentMapName .. "/" .. currentMapName .. ".png") then
			x, y = 500, 500
			mapName = ":" .. currentMapName .. "/" .. currentMapName .. ".png"
		end

		transition = guiCreateStaticImage( screenX/2-(x/2), screenY/2-(y/2) - 15, x, y, mapName, false )			

		showHelpMessage(((screenY / 2) - (y / 2)) + y)
	end
end

function hideTransitionImage()
	if transition then
		destroyElement( transition )
		transition = nil
	end

	transitionMap = nil

	hideHelpMessage()
end


addEventHandler("onClientPlayerQuit", root,
	function()
		if source == currentPM then
			currentPM = nil
		end

		removePlayerBlip(source)
	end
)


addEventHandler( "onClientElementDataChange", root,
	function( dataName, oldValue )
		if dataName == "ptpm.classID" then
			if getElementType( source ) == "player" then
				local classID = getElementData( source, "ptpm.classID" )
				
				if classID and classes[classID] == "pm" then
					currentPM = source
				end
				
				if source == localPlayer then
					if options.distanceToPM then
						if classID and classes[classID] == "terrorist" then
							if options.distanceToPMTimer then
								drawStaticTextToScreen( "update", "pmDist", "Distance to Prime Minister:\n" .. getDistanceToPM(), "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, { 255, 0, 0 }, 1, "clear", "top", "center" )
							else
								drawStaticTextToScreen( "draw", "pmDist", "Distance to Prime Minister:\n" .. getDistanceToPM(), "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, { 255, 0, 0 }, 1, "clear", "top", "center" )
								options.distanceToPMTimer = setTimer(
									function()
										drawStaticTextToScreen( "update", "pmDist","Distance to Prime Minister:\n" .. getDistanceToPM(), "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, { 255, 0, 0 }, 1, "clear", "top", "center" )
									end,
								50, 0 )
							end	
						else
							if options.distanceToPMTimer then
								if isTimer( options.distanceToPMTimer ) then
									killTimer( options.distanceToPMTimer )
								end
								options.distanceToPMTimer = nil
								
								drawStaticTextToScreen( "delete", "pmDist" )
							end
						end
					else
						if options.distanceToPMTimer then
							if isTimer( options.distanceToPMTimer ) then
								killTimer( options.distanceToPMTimer )
							end
							options.distanceToPMTimer = nil
							
							drawStaticTextToScreen( "delete", "pmDist" )
						end					
					end
				end
			end
		end

		blipsElementDataChange(source, dataName, oldValue)
	end
)


function getDistanceToPM()
	if currentPM then
		local x, y, z = getElementPosition( localPlayer )
		local dist = getDistanceBetweenPoints3D( x, y, z, getElementPosition( currentPM ) )
		return (dist < 20) and "Less than 20m" or string.format( "%.2f", dist )
	else
		return "-No Prime Minister-"
	end
end

addEventHandler("onClientVehicleDamage", root,
function(attacker)
  if attacker and getElementType(attacker) == "player" then
      local driver = getVehicleController(source)
      if driver then
          local attackerTeam = getPlayerTeam(attacker)
          local driverTeam = getPlayerTeam(driver)
          if attackerTeam and driverTeam and attackerTeam == driverTeam and getTeamFriendlyFire(driverTeam) == false then
              cancelEvent()
          end
      end
  end
end)


addEventHandler("onClientPlayerSpawn", localPlayer,
	function(team)
		setupAFKTimer(team)

		blipsClientPlayerSpawn()
	end
)

--[[----------------------------------------------
	AFK timer that puts players back in the class selection
]]------------------------------------------------
local stillOnSpawn = nil
local stillOnSpawnPosition = {}

function setupAFKTimer(team)
	killAFKTimer()
	
	if team then
		stillOnSpawn = setTimer(warnAFKPlayer, 6000, 2)
		stillOnSpawnPosition = {getElementPosition(localPlayer)}
	end	
end

addEventHandler("onClientKey", root,
	function(button, pressOrRelease)
		if pressOrRelease and stillOnSpawn then
			if button == "tab" then
				return
			end
						
			killAFKTimer()
		end
	end
)

function warnAFKPlayer()
	if classSelection.visible then
		return
	end
	
	local position = {getElementPosition(localPlayer)}

	-- only check x/y, since z can change without actually moving (ie: spawning +1 from floor level and falling down)
	if (math.abs(position[1] - stillOnSpawnPosition[1]) > 1) or (math.abs(position[2] - stillOnSpawnPosition[2]) > 1) then
		killAFKTimer()
		return
	end
	
	local _, timesLeft = getTimerDetails(stillOnSpawn)

	if timesLeft > 1 then
		drawGameTextToScreen("You are AFK\nReturning to class selection\nin 5 seconds...", 4000, colour.important, "pricedown", 1.2, "center", "center", 4)
	else
		triggerServerEvent("sendPlayerToClassSelection", resourceRoot)

		killAFKTimer()
	end
end

function killAFKTimer()
	if stillOnSpawn then
		if isTimer(stillOnSpawn) then
			killTimer(stillOnSpawn)
		end
		
		stillOnSpawn = nil
	end
end

