-- PTPM NoSQL data mining

-- File management
local files = { 
	geo = 			"geo3.log",
	deaths = 		"deaths2.log",
	performance = 	"performance2.log"
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


-- Round Management
function createRandomRoundID()-- Round Round ID: 16 chars with 26*2 possibilities (52^16 possibilities)
	local s = ""
	for i = 1, 16 do
		if math.random(1,2)==1 then
			s = s .. string.char(math.random(65, 90))
		else
			s = s .. string.char(math.random(97, 122))
		end
	end
	return s
end

currentRound = createRandomRoundID()

function updateCurrentRoundIdentifier(startedMap)
	currentRound = createRandomRoundID()
end

addEventHandler("onGamemodeMapStart", getRootElement(), updateCurrentRoundIdentifier)


function now()
	local t = getRealTime( )
	return t.timestamp
end

-- Geo logging (at 10 second interval)
-- datetime,playername,class=> skinid,x,y,z,interior
setTimer (function() 
	local fileHandle = fileOpen(files.geo)

	if not fileHandle then
		return
	end

	for _, p in ipairs(getElementsByType("player")) do
		if p and isElement(p) then
			local playerName = getPlayerName(p)
			local x,y,z = getElementPositionTwoDecimals(p)
			local interior = getElementInterior(p)
			local playerSkin = getElementModel(p)
			local currentMap = getMapName()
			
			appendToFile(fileHandle, "geo", currentRound .. "¶" .. now() .. "¶" .. playerName .. "¶" .. playerSkin .. "¶" .. x.. "¶" .. y.. "¶" .. z.. "¶" .. interior.. "¶" .. currentMap)
		end
	end

	fileClose(fileHandle)
end, 10000, 0)

-- Log player deaths (on death)
-- datetime,playerName[vic],skin[vic],x,y,z,interior,playerName[attacker],skin[attacker],weapon,bodypart
addEventHandler("onPlayerWasted", getRootElement(),
	function ( _, attacker, weapon, bodypart)
		local playerName = getPlayerName(source)
		local x,y,z = getElementPositionTwoDecimals(source)
		local interior = getElementInterior(source)
		local playerSkin = getElementModel(source)
		
		local attackerData = "¶¶¶"-- Four empty cols if there is no attacker
		if (isElement(attacker) and  getElementType ( attacker ) == "player" ) then
			local aPlayerName = getPlayerName(attacker)
			local attackerSkin = getElementModel ( attacker )
			attackerData = aPlayerName .. "¶" .. attackerSkin .. "¶" .. weapon .. "¶" .. bodypart
		end
		openAndAppendToFile("deaths", currentRound .. "¶" .. now() .. "¶" .. playerName .. "¶" .. playerSkin .. "¶" .. x .. "¶" .. y .. "¶" .. z.. "¶" .. interior .. "¶" .. attackerData)
	end
)


-- Log performance data (30 seconds after join)
-- datetime,playerName,ping,mtaVersion,screenWidth,screenHeight, dxGetStatus:VideoCardName,dxGetStatus:VideoCardRAM,dxGetStatus:VideoCardName,dxGetStatus:SettingWindowed,dxGetStatus:SettingDrawDistance,dxGetStatus:Setting32BitColor,dxGetStatus:SettingFOV
addEvent( "logClientData", true )
addEventHandler( "logClientData", resourceRoot, function ( dxData )
	local playerName = getPlayerName(client)
	openAndAppendToFile("performance", now() .. "¶" .. playerName .. "¶" ..  getPlayerPing ( client )  .. "¶" .. getPlayerVersion ( client)  .. "¶" .. dxData)
end )