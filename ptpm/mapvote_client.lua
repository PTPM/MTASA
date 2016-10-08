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
local playerHasJustVoted = false
local voteButtonsAbsolutePos = {}
local mapsClientCache = {}
local thisClientVotedFor = nil
local voteCountDown = 10


function renderMapVote ( )
	for key,value in pairs(mapsClientCache) do 
		local i = tonumber(key)-1
		local xPosImage = containerOffsetFromLeft + (i * (voteButtonMarginX + voteButtonWidth)) + (voteButtonMarginX /2)
		local yPosImage = containerOffsetFromTop
		
		local xPosVoteCounter = xPosImage + voteButtonWidth * 0.03
		local yPosVoteCounter = yPosImage + voteButtonHeight - voteCounterHeight - voteButtonWidth * 0.03
		local voteColor = 0xBB000000
		
		if thisClientVotedFor==key then
			 voteColor = 0xBB004D45
		 end
		
		voteButtonsAbsolutePos[key] = { startX = xPosImage, startY = yPosImage, endX = xPosImage+voteButtonWidth, endY = yPosImage+voteButtonHeight }
		
		local x = "seconds"
		if voteCountDown==1 then x = "second" end
		
		dxDrawText ( "Click to vote for the next map (" .. voteCountDown .. " " .. x .." left)", containerOffsetFromLeft , containerOffsetFromTop * 0.90 ,containerOffsetFromLeft + containerMaxWidth , containerOffsetFromTop , 0xFFFFFFFF , 1.8, "default", "center", "center", true )
		
		dxDrawImage (  xPosImage , yPosImage, voteButtonWidth, voteButtonHeight, value.image )
		dxDrawRectangle ( xPosVoteCounter , yPosVoteCounter , voteCounterWidth, voteCounterHeight, voteColor )
		dxDrawText ( value.votes, xPosVoteCounter , yPosVoteCounter ,xPosVoteCounter + voteCounterWidth , yPosVoteCounter + voteCounterHeight , 0xFFFFFFFF , 1.5, "default-bold", "center", "center", true )
		dxDrawText ( value.name, xPosVoteCounter + (voteCounterWidth * 1.09) , yPosVoteCounter , xPosImage + (voteButtonWidth * 0.97) , yPosVoteCounter + voteCounterHeight , 0xFFFFFFFF , 1.5, "default", "left", "center", true )
		
	end
end

function startMapVote( maps )
	
	mapsClientCache = maps
	thisClientVotedFor = nil
	
	showCursor ( true )
	isMapVoteRunning = true
	setPlayerHudComponentVisible ( "radar" , false )
	
	addEventHandler("onClientRender", getRootElement(), renderMapVote)
	addEventHandler ( "onClientClick", getRootElement(), countMapVote )
	
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
	
	mapsClientCache = nil
end

function countMapVote ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	if playerHasJustVoted then return nil end
    if isMapVoteRunning and state=="up" then
		for k,v in ipairs(voteButtonsAbsolutePos) do
			if absoluteX > v.startX and absoluteX < v.endX and absoluteY > v.startY and absoluteY < v.endY then
				-- OK, voted for {k}
				triggerServerEvent ( "ptpmMapVoteResult", resourceRoot, k )
				
				-- Unset youVoted for all maps
				thisClientVotedFor = k
				
				-- Prevent vote spam, 2 seconds until next vote is allowed
				playerHasJustVoted = true
				setTimer(function() playerHasJustVoted = false end, 2000, 1 )
			end
		end
	end
end



addEvent( "ptpmStartMapVote", true )
addEventHandler( "ptpmStartMapVote", localPlayer, startMapVote )

addEvent( "ptpmEndMapVote", true )
addEventHandler( "ptpmEndMapVote", localPlayer, endMapVote )

addEvent( "ptpmUpdateMapVoteResults", true )
addEventHandler( "ptpmUpdateMapVoteResults", localPlayer, updateMapVoteResults )