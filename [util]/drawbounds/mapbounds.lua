cRed = tocolor( 180, 25, 29 )
boundaryCorners = {}
bigMapShader = nil
bigMapTarget = nil
radarTiles = {}
prepared = false

-- Make sure the events exist
addEvent( "onClientMapStarted", true )
addEvent( "sendClientMapData", true )
addEvent("onClientMapStop", true)

function updateBoundaryCorners()
	boundaryCorners = {}
	local boundaries = getElementsByType( "boundarycorner" )
	if not boundaries or #boundaries == 0 then
		local x, y
		table.insert( boundaryCorners, { ["x"] = 10000, ["y"] = 10000 } )
		table.insert( boundaryCorners, { ["x"] = 10000, ["y"] = -10000 } )
		table.insert( boundaryCorners, { ["x"] = -10000, ["y"] = -10000 } )
		table.insert( boundaryCorners, { ["x"] = -10000, ["y"] = 10000 } )
	else
		for _, value in ipairs( boundaries ) do
			local x = tonumber( getElementData( value, "posX" ) )
			local y = tonumber( getElementData( value, "posY" ) )
			table.insert( boundaryCorners, { ["x"] = x, ["y"] = y } )
		end
	end
	prepareMaps()
end
addEventHandler( "onClientMapStarted", root, updateBoundaryCorners )
addEventHandler( "sendClientMapData", root, updateBoundaryCorners )
--addEventHandler( "onClientResourceStart", resourceRoot, updateBoundaryCorners )

addEventHandler("onClientMapStop", root,
	function()
		prepared = false
	end
)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		-- Render boundaries to big map
		addEventHandler("onClientHUDRender", root, drawBigMap)
	end
)

function prepareMaps()
	if prepared then
		return
	end

	prepared = true

	-- Prepare boundaries on to radar
	cleanUpRadar()
	addEventHandler( "onClientHUDRender", root, prepareRadar )
end

function cleanUpRadar()
	for row = 0, 11 do
		if radarTiles[row] then
			for column = 0, 11 do
				if radarTiles[row][column] then
					if isElement( radarTiles[row][column].texture ) then
						destroyElement( radarTiles[row][column].texture )
					end
					if isElement( radarTiles[row][column].shader ) then
						local id = row*12 + column
						local tileName = string.format( "radar%02d", id )
						engineRemoveShaderFromWorldTexture( radarTiles[row][column].shader, tileName )
						destroyElement( radarTiles[row][column].shader )
						-- outputDebugString( "Removed shader from tile " .. tileName )
					end
				end
			end
		end
	end
	radarTiles = {}
end

function prepareRadar()
	removeEventHandler( "onClientHUDRender", root, prepareRadar )

	for i, corner in ipairs( boundaryCorners ) do
		local wrap = false
		local sColumn, sRow, sX, sY, eColumn, eRow, eX, eY
		if boundaryCorners[i+1] and boundaryCorners[i+1].x and boundaryCorners[i+1].y then
			sColumn, sRow, sX, sY = calculateTileAndPosition( corner.x, corner.y )
			eColumn, eRow, eX, eY = calculateTileAndPosition( boundaryCorners[i+1].x, boundaryCorners[i+1].y )
		else
			sColumn, sRow, sX, sY = calculateTileAndPosition( corner.x, corner.y )
			eColumn, eRow, eX, eY = calculateTileAndPosition( boundaryCorners[1].x, boundaryCorners[1].y )
			wrap = true
		end
		
		-- End and start points are in different texture files
		-- We need to draw in both of them
		if not (sColumn == eColumn and sRow == eRow) then
			local _, e_sX, e_sY
			if wrap then
				_, _, e_sX, e_sY = calculateTileAndPosition( boundaryCorners[1].x, boundaryCorners[1].y, sColumn, sRow )
			else
				_, _, e_sX, e_sY = calculateTileAndPosition( boundaryCorners[i+1].x, boundaryCorners[i+1].y, sColumn, sRow )
			end
			
			createRadarSlot( sRow, sColumn )
			dxSetRenderTarget( radarTiles[sRow][sColumn].texture )
			dxDrawLine( sX, sY, e_sX, e_sY, cRed, 9 )
			
			local _, _, s_eX, s_eY = calculateTileAndPosition( corner.x, corner.y, eColumn, eRow )
			
			createRadarSlot( eRow, eColumn )
			dxSetRenderTarget( radarTiles[eRow][eColumn].texture )
			dxDrawLine( s_eX, s_eY, eX, eY, cRed, 9 )
		else
			createRadarSlot( sRow, sColumn )
			dxSetRenderTarget( radarTiles[sRow][sColumn].texture )
			dxDrawLine( sX, sY, eX, eY, cRed, 9 )
		end
		
		-- Also draw on to textures that the line just passes through
		if wrap then
			drawLinePassesThrough( corner.x, corner.y, boundaryCorners[1].x, boundaryCorners[1].y, sColumn, sRow, eColumn, eRow )
		else
			drawLinePassesThrough( corner.x, corner.y, boundaryCorners[i+1].x, boundaryCorners[i+1].y, sColumn, sRow, eColumn, eRow )
		end
	end
	
	for row = 0, 11 do
		if radarTiles[row] then
			for column = 0, 11 do
				if radarTiles[row][column] then
					local id = row*12 + column
					local tileName = string.format( "radar%02d", id )
					engineApplyShaderToWorldTexture( radarTiles[row][column].shader, tileName )
					-- outputDebugString( "Applied shader to tile " .. tileName )
				end
			end
		end
	end
end

function createRadarSlot( row, column )
	local create = false
	if not radarTiles[row] then
		radarTiles[row] = {}
		radarTiles[row][column] = {}
		create = true
	elseif radarTiles[row] and not radarTiles[row][column] then
		radarTiles[row][column] = {}
		create = true
	end
	if create then 
		radarTiles[row][column].texture = dxCreateRenderTarget( 256, 256, true )
		radarTiles[row][column].shader = dxCreateShader( "draw.fx" )
		
		if not radarTiles[row][column].texture or not radarTiles[row][column].shader then
			outputDebugString( "Creating radar texture to " .. tostring( row ) .. "," .. tostring( column ) .. " failed!" )
		end
		
		dxSetShaderValue( radarTiles[row][column].shader, "gOverlay", radarTiles[row][column].texture )
	end
end

function drawLinePassesThrough( sX, sY, eX, eY, sColumn, sRow, eColumn, eRow )
	local drawn = {}
	local k = (eY-sY)/(eX-sX)
	local b = k*sX - sY
	
	for x=sX, eX, (sX < eX and 1 or -1) do
		if k == 1/0 or k == -1/0 then -- Vertical line
			for y=sY, eY, (sY < eY and 1 or -1) do
				local column, row = calculateTileAndPosition( x, y )
				if not (column == sColumn and row == sRow) and not (column == eColumn and column == eRow) then
					if drawn and drawn[row] and drawn[row][column] then
					else
						local _, _, startX, startY = calculateTileAndPosition( sX, sY, column, row )
						local _, _, endX, endY = calculateTileAndPosition( eX, eY, column, row )
						
						-- outputDebugString( "Pass at " .. column .. "," .. row )
						createRadarSlot( row, column )
						dxSetRenderTarget( radarTiles[row][column].texture )
						dxDrawLine( startX, startY, endX, endY, cRed, 9 )
						
						if not drawn[row] then drawn[row] = {} end
						drawn[row][column] = true
					end
				end
			end
			break
		else
			local y = k*x - b
			local column, row = calculateTileAndPosition( x, y )
			if not (column == sColumn and row == sRow) and not (column == eColumn and column == eRow) then
				if drawn and drawn[row] and drawn[row][column] then
				else
					local _, _, startX, startY = calculateTileAndPosition( sX, sY, column, row )
					local _, _, endX, endY = calculateTileAndPosition( eX, eY, column, row )
					
					-- outputDebugString( "Pass at " .. column .. "," .. row )
					createRadarSlot( row, column )
					dxSetRenderTarget( radarTiles[row][column].texture )
					dxDrawLine( startX, startY, endX, endY, cRed, 9 )
					
					if not drawn[row] then drawn[row] = {} end
					drawn[row][column] = true
				end
			end
		end
	end
end

function drawBigMap()
	if isPlayerMapVisible() then
		for i, corner in ipairs( boundaryCorners ) do
			local startX, startY, endX, endY
			if boundaryCorners[i+1] and boundaryCorners[i+1].x and boundaryCorners[i+1].y then
				startX, startY = calculatePositionOnBigMap( corner.x, corner.y )
				endX, endY = calculatePositionOnBigMap( boundaryCorners[i+1].x, boundaryCorners[i+1].y )
			else
				startX, startY = calculatePositionOnBigMap( corner.x, corner.y )
				endX, endY = calculatePositionOnBigMap( boundaryCorners[1].x, boundaryCorners[1].y )
			end
			dxDrawLine( startX, startY, endX, endY, cRed, 3, true )
		end
	end
end

function calculatePositionOnBigMap( x, y )
	local minX, minY, maxX, maxY = getPlayerMapBoundingBox()
	local mapWidth = maxX-minX
	local mapHeight = maxY-minY
	
	local mapX = minX + ((x + 3000)/6000) * mapWidth
	local mapY = minY + (1 - ((y + 3000)/6000)) * mapHeight
	return mapX, mapY
end

function calculateTileAndPosition( x, y, relativeToColumn, relativeToRow )
	local column = math.floor( (x + 3000)/500 )
	local row = math.floor( (6000 - (y + 3000))/500 )
	
	if relativeToColumn then
		column = relativeToColumn
		row = relativeToRow
	end
	local startX = column*500 - 3000
	local startY = 3000 - row*500
	
	local mapX, mapY = ((x - startX)/500)*256, ((startY - y)/500)*256
	return column, row, mapX, mapY
end