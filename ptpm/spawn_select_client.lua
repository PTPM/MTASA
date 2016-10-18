local screenWidth,screenHeight = guiGetScreenSize() 

local containerMaxWidth = screenHeight * 1.3333333333 
local containerOffsetFromLeft = (screenWidth - containerMaxWidth) / 2

local voteButtonMarginX = containerMaxWidth/3 * 0.05		-- where 3 is the number of voting buttons
local voteButtonWidth = containerMaxWidth/3 * 0.95
local voteButtonHeight = voteButtonWidth / 1.6992481203007518796992481203008 --preserving aspect ratio (of 452*266 px)

local voteCounterWidth = voteButtonWidth * 0.15
local voteCounterHeight = voteCounterWidth / 1.666 

local containerOffsetFromTop = screenHeight - (voteButtonHeight * 1.1) -- keep 10% margin at bottom
local isMapVoteRunning = false
local playerHasJustVoted = false
local voteButtonsAbsolutePos = {}
local mapsClientCache = {}
local thisClientVotedFor = nil
local voteCountDown = 15


function renderSpawnSelect ( )
	
end

addEventHandler("onClientRender", getRootElement(), renderSpawnSelect)