addEvent( "getMyWeaponSlot", true )
addEventHandler( "getMyWeaponSlot", resourceRoot, function()
	triggerClientEvent ( client, "returnMyWeaponSlot", client, getPedWeaponSlot(client))
end )


-- File management
local files = { 
	ds = 			"desync_log.log"
}

local filePointers = {}

for id,fileName in pairs(files) do
	if fileExists(fileName) then
		-- Set up append
		local fh = fileOpen ( fileName , true )
		filePointers[id] = fileGetSize(fh)
		fileClose(fh)
	else
		-- Create file
		local newFile = fileCreate(fileName)
		if not newFile then
			outputDebugString("FATAL: Can't create file " .. filename)
			-- die()
		end
		filePointers[id] = 0
	end
end

function openAndAppendToFile(fileID, theString)
	local fileName = files[fileID]
	local fileHandle = fileOpen(fileName)

	if not fileHandle then
		return
	end

	appendToFile(fileHandle, fileID, theString)

	fileClose(fileHandle)
end

function appendToFile(fileHandle, fileID, theString)
	fileSetPos(fileHandle, filePointers[fileID])
	fileWrite(fileHandle, theString .. "\n")
	filePointers[fileID] = fileGetPos(fileHandle)
end

function getElementPositionTwoDecimals(p)
	x,y,z = getElementPosition(p)
	return math.floor(x*100)/100,math.floor(y*100)/100,math.floor(z*100)/100
end

function now()
	local t = getRealTime( )
	return t.timestamp
end


-- Log
addEvent( "logDesyncEvent", true )
addEventHandler( "logDesyncEvent", resourceRoot, function(freeText)
	local playerName = getPlayerName(client)
	openAndAppendToFile("ds", now() .. "¶" .. playerName .. "¶" .. freeText)
end )
