local screenWidth,screenHeight = guiGetScreenSize() 

local containerMaxWidth = screenHeight * 1.3333333333 
local containerOffsetFromLeft = (screenWidth - containerMaxWidth) / 2
local containerOffsetFromTop = screenHeight * 0.1

local widthToHeightRatios = {
	asset_background_pm = 1440/181,
	asset_asset_choosebutton = 202/46,
	asset_circle = 1/1,
	asset_background_classes = 666/615
}


local voteButtonMarginX = containerMaxWidth/3 * 0.05		-- where 3 is the number of voting buttons
local voteButtonWidth = containerMaxWidth/3 * 0.95
local voteButtonHeight = voteButtonWidth / 1.6992481203007518796992481203008 --preserving aspect ratio (of 452*266 px)

local voteCounterWidth = voteButtonWidth * 0.15
local voteCounterHeight = voteCounterWidth / 1.666 

local isMapVoteRunning = false
local playerHasJustVoted = false
local voteButtonsAbsolutePos = {}
local mapsClientCache = {}
local thisClientVotedFor = nil
local voteCountDown = 15

local pmCircleSize = containerMaxWidth / widthToHeightRatios.asset_background_pm * 1.1


function renderSpawnSelect ( )
	-- PM Background
	dxDrawImage ( containerOffsetFromLeft, containerOffsetFromTop, containerMaxWidth, containerMaxWidth / widthToHeightRatios.asset_background_pm, "spawnselectimages/asset_background_pm.png")
	
	dxDrawImage ( containerOffsetFromLeft, containerOffsetFromTop, pmCircleSize, pmCircleSize, "spawnselectimages/asset_white_circle.png")
	dxDrawImage ( containerOffsetFromLeft, containerOffsetFromTop, pmCircleSize, pmCircleSize, "spawnselectimages/ptpm-skins-147.png")
	dxDrawImage ( containerOffsetFromLeft, containerOffsetFromTop, pmCircleSize, pmCircleSize, "spawnselectimages/asset_circle_border_pm.png")
end

addEventHandler("onClientRender", getRootElement(), renderSpawnSelect)