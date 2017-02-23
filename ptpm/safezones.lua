addEvent( "onSafezoneEnter", false )
addEventHandler( "onSafezoneEnter", root,
	function( thePlayer )
		if data.safezone[getElementParent( source )].enabled then
			local vehicle = getPedOccupiedVehicle( thePlayer )
			if vehicle and getElementData( vehicle, "safezone_excluded" ) == "true" then
				local x = getElementData( thePlayer, "ptpm.goodX" )
				local y = getElementData( thePlayer, "ptpm.goodY" )
				local z = getElementData( thePlayer, "ptpm.goodZ" )
				setElementPosition( vehicle, x, y, z )
				--setElementPosition( vehicle, playerInfo[thePlayer].goodX, playerInfo[thePlayer].goodY, playerInfo[thePlayer].goodZ )
				
				local rx, ry, rz = getVehicleRotation( vehicle )
				setVehicleRotation( vehicle, rx, ry, ( rz + 180 ) > 360 and ( rz + 180 ) - 360 or ( rz + 180 ) )
				
				x, y, z = getElementVelocity( vehicle )
				setElementVelocity( vehicle, x*-0.75, y*-0.75, z*-1 )
				
				if getVehicleName( vehicle ) then
					sendGameText( thePlayer, "You are not allowed in this safezone\narea with a " .. getVehicleName( vehicle ) .. "!", 3500, sampTextdrawColours.r, nil, 1.2, nil, nil, 2 )
				else
					sendGameText( thePlayer, "That vehicle is not allowed in this safezone area!", 3500, sampTextdrawColours.r, nil, 1.2, nil, nil, 2 )
				end
			end	

			triggerHelpEvent(thePlayer, "SAFE_ZONE")

			if isRunning("ptpm_accounts") then
				exports.ptpm_accounts:incrementPlayerStatistic(thePlayer, "safezonecount")
			end
		end
	end
) 


function enableSafezone( zone )
	data.safezone[zone].enabled = true
	setElementVisibleTo ( data.safezone[zone].marker, root, true )
	setElementVisibleTo ( data.safezone[zone].blip, root, true )	
end


function disableSafezone( zone )
	data.safezone[zone].enabled = false
	setElementVisibleTo ( data.safezone[zone].marker, root, false )
	setElementVisibleTo ( data.safezone[zone].blip, root, false )		
end
