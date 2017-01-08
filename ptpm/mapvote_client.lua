local screenWidth,screenHeight = guiGetScreenSize() 

local containerMaxWidth = screenHeight * 1.3333333333 
local containerOffsetFromLeft = (screenWidth - containerMaxWidth) / 2

local voteButtonMarginX = containerMaxWidth/3 * 0.05		-- where 3 is the number of voting buttons
local voteButtonWidth = containerMaxWidth/3 * 0.95
local voteButtonHeight = voteButtonWidth / 1.6992481203007518796992481203008 --preserving aspect ratio (of 452*266 px)

local voteCounterWidth = voteButtonWidth * 0.15
local voteCounterHeight = voteCounterWidth / 1.666 

local textScalingFactor = screenHeight/600

local containerOffsetFromTop = screenHeight - (voteButtonHeight * 1.1) -- keep 10% margin at bottom
local isMapVoteRunning = false
local playerHasJustVoted = false
local voteButtonsAbsolutePos = {}
local mapsClientCache = {}
local thisClientVotedFor = nil
local voteCountDown = 10
local colours = {
	voted = tocolor(0, 77, 69, 255),
	default = tocolor(0, 0, 0, 187),
	grey = tocolor(200, 200, 200, 255),
	black = tocolor(0,0,0,255),
	transparent = tocolor(0,0,0,0)
}

local showVotecounts = false


-- used for testing
-- addEventHandler("onClientRender", root,
-- 	function()
-- 		mapsClientCache = {
-- 			{ name = "Bayside", image = "mapvoteimages/map-pic-Bay.png", votes = 0, youVoted = false, res = "ptpm-bayside" },
-- 			{ name = "Mt. Chiliad", image = "mapvoteimages/map-pic-Chiliad.png", votes = 0, youVoted = false, res = "ptpm-chiliad" },
-- 			{ name = "Countryside", image = "mapvoteimages/map-pic-Country.png", votes = 0, youVoted = false, res = "ptpm-country" }
-- 		}
-- 		renderMapVote()
-- 	end
-- )

function renderMapVote ( )
	local cursorX, cursorY = getCursorPosition()

	if not cursorX or not cursorY then
		return
	end

	cursorX = cursorX * screenWidth
	cursorY = cursorY * screenHeight

	for key,value in pairs(mapsClientCache) do 
		local i = tonumber(key)-1
		local xPosImage = containerOffsetFromLeft + (i * (voteButtonMarginX + voteButtonWidth)) + (voteButtonMarginX /2)
		local yPosImage = containerOffsetFromTop
		
		local xPosVoteCounter = xPosImage + voteButtonWidth * 0.03
		local yPosVoteCounter = yPosImage + voteButtonHeight - voteCounterHeight - voteButtonWidth * 0.03

		voteButtonsAbsolutePos[key] = { startX = xPosImage, startY = yPosImage, endX = xPosImage+voteButtonWidth, endY = yPosImage+voteButtonHeight }
		
		local x = "seconds"
		if voteCountDown==1 then x = "second" end

		dxDrawTextOutline ( "Click to vote for the next map (" .. voteCountDown .. " " .. x .." left)", containerOffsetFromLeft , containerOffsetFromTop * 0.90 ,containerOffsetFromLeft + containerMaxWidth , containerOffsetFromTop , 0xFFFFFFFF , textScaling(1.85 ,2.2), "default", "center", "center", true )

		
		
		

		if showVotecounts then
			
			if (cursorX >= xPosImage) and (cursorX <= (xPosImage + voteButtonWidth)) and (cursorY >= yPosImage) and (cursorY <= (yPosImage + voteButtonHeight)) then
				dxDrawRectangle(xPosImage - 1, yPosImage - 1, voteButtonWidth + 2, voteButtonHeight + 2, colours.grey)
				dxDrawImage (  xPosImage , yPosImage, voteButtonWidth, voteButtonHeight, value.image, 0, 0, 0, tocolor(255, 255, 255, 235) )
			else
				dxDrawImage (  xPosImage , yPosImage, voteButtonWidth, voteButtonHeight, value.image )
			end
		
			dxDrawRectangle ( xPosVoteCounter , yPosVoteCounter , voteCounterWidth, voteCounterHeight, thisClientVotedFor == key and colours.voted or colours.default )
			dxDrawText ( value.votes, xPosVoteCounter , yPosVoteCounter ,xPosVoteCounter + voteCounterWidth , yPosVoteCounter + voteCounterHeight , 0xFFFFFFFF , textScaling(1.45,1.8), "default-bold", "center", "center", true )
			dxDrawText ( value.name, xPosVoteCounter + (voteCounterWidth * 1.09) , yPosVoteCounter , xPosImage + (voteButtonWidth * 0.97) , yPosVoteCounter + voteCounterHeight , 0xFFFFFFFF , textScaling(1.45,1.8), "default", "left", "center", true )		
		else
		
			if (cursorX >= xPosImage) and (cursorX <= (xPosImage + voteButtonWidth)) and (cursorY >= yPosImage) and (cursorY <= (yPosImage + voteButtonHeight)) then
				dxDrawRectangle(xPosImage - 2, yPosImage - 2, voteButtonWidth + 4, voteButtonHeight + 4, thisClientVotedFor == key and colours.voted or colours.grey)
				dxDrawImage (  xPosImage , yPosImage, voteButtonWidth, voteButtonHeight, value.image, 0, 0, 0, tocolor(255, 255, 255, 235) )
			else
				dxDrawRectangle(xPosImage - 1, yPosImage - 1, voteButtonWidth + 2, voteButtonHeight + 2, thisClientVotedFor == key and colours.voted or colours.transparent)
				dxDrawImage (  xPosImage , yPosImage, voteButtonWidth, voteButtonHeight, value.image )
			end
			
			dxDrawText ( value.name,  xPosVoteCounter  + (voteButtonWidth * 0.015) , yPosVoteCounter , xPosVoteCounter + (voteButtonWidth * 0.97) , yPosVoteCounter + voteCounterHeight , 0xFFFFFFFF , textScaling(1.45,1.8), "default", "left", "center", true )
		end
		
	end
end

function textScaling(i, maximum)
	local suggestedSize = 1.45 * textScalingFactor
	if suggestedSize > maximum then return maximum end
	return suggestedSize
end

function dxDrawTextOutline(text,x,y,x2,y2,colour,size,font,alignX,alignY,p)

	dxDrawText(text,x-1,y-1,x2-1,y2-1,colours.black,size, font,alignX,alignY,p, false, false, true, false )
	dxDrawText(text,x-1,y+1,x2-1,y2+1,colours.black,size, font,alignX,alignY,p, false, false, true, false )
	dxDrawText(text,x+1,y-1,x2+1,y2-1,colours.black,size, font,alignX,alignY,p, false, false, true, false )
	dxDrawText(text,x+1,y+1,x2+1,y2+1,colours.black,size, font,alignX,alignY,p, false, false, true, false )
	dxDrawText(text,x,y,x2,y2,colour,size, font,alignX,alignY,p, false, false, true, false )

end


function startMapVote( maps )
	
	mapsClientCache = maps
	thisClientVotedFor = nil
	
	showCursor ( true )
	isMapVoteRunning = true
	setPlayerHudComponentVisible ( "radar" , false )
	
	addEventHandler("onClientRender", getRootElement(), renderMapVote)
	addEventHandler ( "onClientClick", getRootElement(), countMapVote )
	
	-- mapvoting by keyboard
	for i=1,3 do 
		bindKey ( i, "up", localPlayerVotesFor, i )
		bindKey ( "num_" .. i, "up", localPlayerVotesFor, i )
	end
	
	voteCountDown = 10
	setTimer(function() 
		voteCountDown = voteCountDown-1
		if voteCountDown<0 then voteCountDown = 0 end
	end, 1000, voteCountDown )
end

function updateMapVoteResults( maps )
	mapsClientCache = maps
end

function endMapVote()
	showCursor ( false )
	isMapVoteRunning = false
	setPlayerHudComponentVisible ( "radar" , true )
	
	removeEventHandler("onClientRender", getRootElement(), renderMapVote)
	removeEventHandler ( "onClientClick", getRootElement(), countMapVote )
	
	-- mapvoting by keyboard
	for i=1,3 do 
		unbindKey( i, "up", localPlayerVotesFor )
		unbindKey( "num_" .. i, "up", localPlayerVotesFor )
	end
	
	mapsClientCache = nil
end

function countMapVote ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
    if isMapVoteRunning and state=="up" then
		for mapId,v in ipairs(voteButtonsAbsolutePos) do
			if absoluteX > v.startX and absoluteX < v.endX and absoluteY > v.startY and absoluteY < v.endY then
				localPlayerVotesFor(mapId)
			end
		end
	end
end

function localPlayerVotesFor(mapId)
	mapId = tonumber(mapId)
	
	if playerHasJustVoted then return nil end
    if isMapVoteRunning then
		triggerServerEvent ( "ptpmMapVoteResult", resourceRoot, mapId )
		thisClientVotedFor = mapId
		
		-- play a sound
		playSoundFrontEnd(43)
		
		-- Prevent vote spam, 200ms until next vote is allowed
		playerHasJustVoted = true
		setTimer(function() playerHasJustVoted = false end, 500, 1 )
	end
end


addEvent( "ptpmStartMapVote", true )
addEventHandler( "ptpmStartMapVote", localPlayer, startMapVote )

addEvent( "ptpmEndMapVote", true )
addEventHandler( "ptpmEndMapVote", localPlayer, endMapVote )

addEvent( "ptpmUpdateMapVoteResults", true )
addEventHandler( "ptpmUpdateMapVoteResults", localPlayer, updateMapVoteResults )