function isCoordInPolygon( x, y, boundaryTable, numEdges )
	numEdges = numEdges or #boundaryTable + 1
	local c, j = 0, numEdges - 1
	for i=0, numEdges - 1, 1 do
		if i ~= 0 then j = i - 1 end
		if leftIntersect( x, y, boundaryTable[i].x, boundaryTable[i].y, boundaryTable[j].x, boundaryTable[j].y ) then c = c + 1 end
	end
	if numEdges == 0 then return true end
	return ( c % 2 ) == 1
end

-- returns 1 if  x,y crosses the line on its way to -infinity,y
function leftIntersect( x, y, x1, y1, x2, y2 )
		if not ((y1 <= y and y <= y2) or ( y2 <= y and y <= y1 )) then return false end

		-- x co-ord of point on the line, at height y
		local point = ( y - y1 ) * ( x2 - x1 ) / ( y2 - y1 ) + x1
		return x > point
end

function isPointOutOfBounds( x, y )
	return not isCoordInPolygon( x, y, data.boundaryCorners, #data.boundaryCorners + 1 )
end


function checkPlayersOutOfBounds()
	if data.roundEnded then
		return
	end

	for _, value in ipairs( getElementsByType( "player" ) ) do
		if value and isElement( value ) and getPlayerClassID( value ) then
			local x, y, z = getElementPosition( value )
			if options.boundariesEnabled and z<1000 and tonumber(getElementInterior(value)) == 0 then
				if isPointOutOfBounds( x, y ) then
					sendGameText( value, "You are out of bounds!", 5000, colour.sampRed, gameTextOrder.normal )
					
					local lastX = getElementData( value, "ptpm.goodX" )
					local lastY = getElementData( value, "ptpm.goodY" )
					local lastZ = getElementData( value, "ptpm.goodZ" )
					--local lastX = playerInfo[value].goodX
					--local lastY = playerInfo[value].goodY
					--local lastZ = playerInfo[value].goodZ
					local vehicle = getPedOccupiedVehicle( value )
					
					if vehicle and getVehicleController( vehicle ) == value then
						setElementPosition( vehicle, lastX, lastY, lastZ )
						
						local rx, ry, rz = getVehicleRotation( vehicle )
						setVehicleRotation( vehicle, rx, ry, (rz + 180) % 360)
						
						x, y, z = getElementVelocity( vehicle )
						setElementVelocity( vehicle, x*-0.5, y*-0.5, z*-1 )
					else
						setElementPosition( value, lastX, lastY, lastZ )
						setElementVelocity( value, 0, 0, 0 )
					end
				else
					setElementData( value, "ptpm.goodX", x, false )
					setElementData( value, "ptpm.goodY", y, false )
					setElementData( value, "ptpm.goodZ", z, false )
					--playerInfo[value].goodX = x
					--playerInfo[value].goodY = y
					--playerInfo[value].goodZ = z
				end
			end
			
			if options.vehicleHeightLimit and z > options.vehicleHeightLimit then
				local vehicle = getPedOccupiedVehicle( value )
				
				if vehicle then
					sendGameText( value, "You are out of bounds!", 5000, colour.sampRed, gameTextOrder.normal )
					
					x, y, z = getElementVelocity( vehicle )
					setElementVelocity( vehicle, x, y, -0.25 )
				end
			end
		end
	end
end