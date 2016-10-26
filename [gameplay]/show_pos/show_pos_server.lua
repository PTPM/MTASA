local eof = nil

function saveCoords( x, y, z, rot, comment )
    local fhnd = nil
    if fileOpen( "saved_coords.txt" ) then
        fhnd = fileOpen( "saved_coords.txt" )
        eof = fileGetSize( fhnd )
        fileSetPos( fhnd, eof )
    else
        fhnd = fileCreate( "saved_coords.txt" )
    end
    local str = tostring( x ) .. ", " .. tostring( y ) .. ", " .. tostring( z ) .. ", " .. tostring( rot ) .. " ";
    if string.len( comment ) > 0 then
        str = str .. "// ".. comment
    end
    str = str .. "\r\n"
    eof = fileWrite( fhnd, str )
    fileSetPos( fhnd, eof )
    fileClose( fhnd )
    outputChatBox( "Position saved...", source )
end

function savePos( player, command, ... )
    local _x, _y, _z = getElementPosition( player )
    local _rot = getPedRotation( player )
    local comment = table.concat( arg, " " )
    saveCoords( _x, _y, _z, _rot, comment )
end
addCommandHandler( "/", savePos )