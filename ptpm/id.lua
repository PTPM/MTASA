function setupIdForPlayer( thePlayer )
	local id = findFreeId()
	setElementData( thePlayer, "ptpm.id", id )
end

function getPlayerId( thePlayer )
	return getElementData( thePlayer, "ptpm.id" )
end

function findFreeId()
	local usedIds = {}
	local players = getElementsByType( "player" )
	for _, p in ipairs( players ) do
		if p and isElement( p ) then
			local id = getElementData( p, "ptpm.id" )
			if type( id ) == "number" then
				usedIds[id] = true
			end
		end
	end
	
	local myId = 0
	for i=0, 1024, 1 do
		if not usedIds[i] then
			myId = i
		end
	end
	return myId
end