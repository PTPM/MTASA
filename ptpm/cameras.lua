-- compcheck
function prepareSecurityCamera( thePlayer, theCamera )
	local activeCamera = getElementData( thePlayer, "ptpm.activeCamera" )
	if not activeCamera then
		local cameraElement = getElementParent( theCamera )
		
		if data.cameraMounts[cameraElement].message ~= "" then 
			sendGameText( thePlayer, data.cameraMounts[cameraElement].message, 3000, colour.sampYellow, gameTextOrder.contextual ) 
		end
		
		setCameraMatrix( thePlayer, data.securityCameras[tonumber(data.cameraMounts[cameraElement].usesIDs[1])].camX,
									data.securityCameras[tonumber(data.cameraMounts[cameraElement].usesIDs[1])].camY,
									data.securityCameras[tonumber(data.cameraMounts[cameraElement].usesIDs[1])].camZ,
									data.securityCameras[tonumber(data.cameraMounts[cameraElement].usesIDs[1])].pointX,
									data.securityCameras[tonumber(data.cameraMounts[cameraElement].usesIDs[1])].pointY,
									data.securityCameras[tonumber(data.cameraMounts[cameraElement].usesIDs[1])].pointZ )
									
		setElementPosition( thePlayer, data.cameraMounts[cameraElement].playerX, data.cameraMounts[cameraElement].playerY, data.cameraMounts[cameraElement].playerZ )
		
		--drawStaticTextToScreen( "draw", thePlayer, "cameraText", "WARNING: Whilst viewing a security camera you can still be attacked.\nUse the left and right arrow keys to change camera.\nType /camoff or press enter to exit the camera.", "screenX-600", "screenY-110", 590, 100, colour.important, 0.5, "bankgothic", "top", "right" )
		triggerHelpEvent(thePlayer, "CAMERA_ENTER")

		setElementData( thePlayer, "ptpm.activeCamera", cameraElement, false )
		setElementData( thePlayer, "ptpm.currentCameraID", 1, false )
		--playerInfo[thePlayer].activeCamera = cameraElement
		--playerInfo[thePlayer].currentCameraID = 1
		
		bindKey( thePlayer, "arrow_l", "down", changeCameraView, -1 )
		bindKey( thePlayer, "arrow_r", "down", changeCameraView, 1 )
		bindKey( thePlayer, "enter", "down", camOff )
	end
end

-- compcheck
function changeCameraView( thePlayer, key, keystate, direction )
	local activeCamera = getElementData( thePlayer, "ptpm.activeCamera" )
	if activeCamera then
		direction = tonumber( direction )
		if #data.cameraMounts[activeCamera].usesIDs ~= 1 then
			local currentCameraID = getElementData( thePlayer, "ptpm.currentCameraID" )
			local nextCameraID = currentCameraID + direction
			if not data.cameraMounts[activeCamera].usesIDs[nextCameraID] then
				if direction == 1 then
					nextCameraID = 1
				else
					nextCameraID = #data.cameraMounts[activeCamera].usesIDs
				end
			end	
			
			setCameraMatrix( thePlayer, data.securityCameras[tonumber(data.cameraMounts[activeCamera].usesIDs[nextCameraID])].camX,
										data.securityCameras[tonumber(data.cameraMounts[activeCamera].usesIDs[nextCameraID])].camY,
										data.securityCameras[tonumber(data.cameraMounts[activeCamera].usesIDs[nextCameraID])].camZ,
										data.securityCameras[tonumber(data.cameraMounts[activeCamera].usesIDs[nextCameraID])].pointX,
										data.securityCameras[tonumber(data.cameraMounts[activeCamera].usesIDs[nextCameraID])].pointY,
										data.securityCameras[tonumber(data.cameraMounts[activeCamera].usesIDs[nextCameraID])].pointZ )
										
			setElementPosition( thePlayer, 	data.cameraMounts[activeCamera].playerX,
											data.cameraMounts[activeCamera].playerY,
											data.cameraMounts[activeCamera].playerZ )
			
			setElementData( thePlayer, "ptpm.currentCameraID", nextCameraID, false )
			--playerInfo[thePlayer].currentCameraID = nextCamID
		end
	end
end

-- compcheck
function camOff( thePlayer )
	local activeCamera = getElementData( thePlayer, "ptpm.activeCamera" )
	if not activeCamera then
		return outputChatBox( "You are not viewing a camera.", thePlayer, unpack( colour.personal ) )
	end
	
	setElementData( thePlayer, "ptpm.activeCamera", nil, false )
	setElementData( thePlayer, "ptpm.currentCameraID", nil, false )
	--playerInfo[thePlayer].activeCamera = nil
	--playerInfo[thePlayer].currentCameraID = nil
	--playerInfo[thePlayer].gettingOffCamera = true
	
	setElementPosition( thePlayer, 	data.cameraMounts[activeCamera].posX + 3,
									data.cameraMounts[activeCamera].posY,
									data.cameraMounts[activeCamera].posZ )
	setCameraTarget( thePlayer, thePlayer )
	
	clearCameraFor( thePlayer )
	local gettingOffCamera = setTimer(
		function( player )
			if player and isElement( player ) then
				setElementData( player, "ptpm.gettingOffCamera", nil, false )
				--playerInfo[player].gettingOffCamera = nil
			end
		end,
	200, 1, thePlayer )
	setElementData( thePlayer, "ptpm.gettingOffCamera", gettingOffCamera, false )
end
addCommandHandler( "camoff", camOff )

-- compcheck
function clearCameraFor( thePlayer )
	unbindKey( thePlayer, "arrow_l", "down", changeCameraView )
	unbindKey( thePlayer, "arrow_r", "down", changeCameraView )
	unbindKey( thePlayer, "enter", "down", camOff )	

	hideHelpEvent(thePlayer, "CAMERA_ENTER")
	--drawStaticTextToScreen( "delete", thePlayer, "cameraText" )	
end