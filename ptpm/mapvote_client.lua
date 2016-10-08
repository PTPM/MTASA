local screenWidth,screenHeight = guiGetScreenSize() 

local containerMaxWidth = screenHeight * 1.3333333333 
local containerOffsetFromLeft = (screenWidth - containerMaxWidth) / 2

local voteButtonMarginX = containerMaxWidth/3 * 0.05		-- where 3 is the number of voting buttons
local voteButtonWidth = containerMaxWidth/3 * 0.95
local voteButtonHeight = voteButtonWidth / 1.6992481203007518796992481203008 --preserving aspect ratio

local voteCounterWidth = voteButtonWidth * 0.15
local voteCounterHeight = voteCounterWidth / 1.666 

local containerOffsetFromTop = screenHeight - (voteButtonHeight * 1.1) -- keep 10% margin at bottom
local isMapVoteRunning = false
local voteButtonsAbsolutePos = {}


function renderMapVote ( )

	maps = {}
	table.insert( maps, {
		name = "Area 51",
		image = "mapvoteimages/map-pic-A51.png",
		votes = 0,
		youVoted = false,
		hasWon = false
	})
	table.insert( maps, {
		name = "Los Santos",
		image = "mapvoteimages/map-pic-LS.png",
		votes = 1,
		youVoted = true,
		hasWon = false
	})
	table.insert( maps, {
		name = "Random Map",
		image = "mapvoteimages/map-pic-_randomMap.png",
		votes = 4,
		youVoted = false,
		hasWon = true
	})

	for key,value in pairs(maps) do 
		local i = tonumber(key)-1
		local xPosImage = containerOffsetFromLeft + (i * (voteButtonMarginX + voteButtonWidth)) + (voteButtonMarginX /2)
		local yPosImage = containerOffsetFromTop
		
		local xPosVoteCounter = xPosImage + voteButtonWidth * 0.03
		local yPosVoteCounter = yPosImage + voteButtonHeight - voteCounterHeight - voteButtonWidth * 0.03
		local voteColor = 0xBB000000
		
		if value.hasWon then
			voteColor = 0xBB317400
		elseif value.youVoted then
			voteColor = 0xBB004D45
		end
		
		voteButtonsAbsolutePos[key] = { startX = xPosImage, startY = yPosImage, endX = xPosImage+voteButtonWidth, endY = yPosImage+voteButtonHeight }
		
		dxDrawImage (  xPosImage , yPosImage, voteButtonWidth, voteButtonHeight, value.image )
		dxDrawRectangle ( xPosVoteCounter , yPosVoteCounter , voteCounterWidth, voteCounterHeight, voteColor )
		dxDrawText ( value.votes, xPosVoteCounter , yPosVoteCounter ,xPosVoteCounter + voteCounterWidth , yPosVoteCounter + voteCounterHeight , 0xFFFFFFFF , 1.5, "default-bold", "center", "center", true )
		dxDrawText ( value.name, xPosVoteCounter + (voteCounterWidth * 1.09) , yPosVoteCounter , xPosImage + (voteButtonWidth * 0.97) , yPosVoteCounter + voteCounterHeight , 0xFFFFFFFF , 1.5, "default", "left", "center", true )
		
	end
end

function startMapVote()
	showCursor ( true )
	isMapVoteRunning = true
	
	addEventHandler("onClientRender", getRootElement(), renderMapVote)
	addEventHandler ( "onClientClick", getRootElement(), countMapVote )
end

function endMapVote()
	showCursor ( false )
	isMapVoteRunning = false
	
	removeEventHandler("onClientRender", getRootElement(), renderMapVote)
	removeEventHandler ( "onClientClick", getRootElement(), countMapVote )
end

function countMapVote ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
    if isMapVoteRunning and state=="up" then
		for k,v in ipairs(voteButtonsAbsolutePos) do
			if absoluteX > v.startX and absoluteX < v.endX and absoluteY > v.startY and absoluteY < v.endY then
				-- OK, voted for {k}
				outputChatBox("Voted for map #" .. k)
			end
		end
	end
end


addEventHandler("onClientResourceStart",resourceRoot, startMapVote)