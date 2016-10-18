local screenWidth,screenHeight = guiGetScreenSize() 
local fontModifier = screenHeight / 720

local containerMaxWidth = screenHeight * 1.3333333333 
local containerOffsetFromLeft = (screenWidth - containerMaxWidth) / 2
local containerOffsetFromTop = screenHeight * 0.06

local widthToHeightRatios = {
	asset_background_pm = 1440/181,
	asset_choosebutton = 202/46,
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
local pmSkinPortraitSize = pmCircleSize * 0.95
local pmContainerWidth = containerMaxWidth * 0.6666
local pmContainerOffsetFromLeft = containerOffsetFromLeft + ((containerMaxWidth * 0.3333)/2) -- 0.3333 is the automatic margin
local pmContainerOffsetFromTop = containerOffsetFromTop - (containerMaxWidth / widthToHeightRatios.asset_background_pm * 0.05)
local pmTextOffsetFromLeft = pmContainerOffsetFromLeft + (pmCircleSize * 1.1)
local pmTextOffsetFromTop = pmContainerOffsetFromTop * 1.28
local pmTextFontSize = 2.6 * fontModifier
local pmElectionTextHeight = 1 * fontModifier
local pmTextElectionOffsetFromTop = pmTextOffsetFromTop + dxGetFontHeight ( pmTextFontSize, "default-bold" )
local pmButtonOffsetFromTop = pmTextOffsetFromTop + dxGetFontHeight ( pmTextFontSize, "default-bold" ) + (dxGetFontHeight ( pmElectionTextHeight, "default" ) * 1.4) -- margin-bottom of 1.4em, so to speak

local chooseButtonFontSize = 1.2 * fontModifier
local chooseButtonWidth = containerMaxWidth * 0.13

local teamsContainerWidth = containerMaxWidth * 0.48 -- is 50% minus margin
local teamsContainerHeight = teamsContainerWidth / widthToHeightRatios.asset_background_classes
local teamsContainerOffsetFromTop = pmContainerOffsetFromTop + (containerMaxWidth / widthToHeightRatios.asset_background_pm) * 1.1 

local teamHeaderOffsetFromTop = teamsContainerOffsetFromTop * 1.1
local teamHeaderFontSize = pmTextFontSize * fontModifier

local skinButtonsOffsetFromTop = teamsContainerOffsetFromTop + teamsContainerHeight * 0.25
local skinButtonsOffsetFromLeft = containerOffsetFromLeft + teamsContainerWidth * 1/9
local skinButtonsCalculatedWidth = teamsContainerWidth * 7/9

local skinCircleSize = teamsContainerWidth * 1/6
local skinPortraitSize = skinCircleSize * 0.95
local skinButtonMargin = (teamsContainerWidth * 1/9) / 4 -- where 4 is the number of icons per row; and 2/9 is the fixed margin left and right 

local skinDetailsFontSize = 1 * fontModifier
local skinDetailsOffsetFromTop = skinButtonsOffsetFromTop + (skinPortraitSize+skinButtonMargin) * 2 + dxGetFontHeight ( skinDetailsFontSize, "default-bold" ) * 2

local allowedSkinsGood = {141,164,166,276,281,285,288,275}
local allowedSkinsTerrorists = {181,183,191,111,73,100,179,274}

local roundCountDownOffsetFromTop = teamsContainerOffsetFromTop + teamsContainerHeight * 1.06
local roundCountDownFontSize = chooseButtonFontSize


function renderSpawnSelect ( )
	-- General backgrouns
	dxDrawRectangle ( 0,0, screenWidth,screenHeight, 0x99000000)

	-- PM
	dxDrawImage ( containerOffsetFromLeft, pmContainerOffsetFromTop, containerMaxWidth, containerMaxWidth / widthToHeightRatios.asset_background_pm, "spawnselectimages/asset_background_pm.png")
	
	dxDrawImage ( pmContainerOffsetFromLeft, pmContainerOffsetFromTop, pmCircleSize, pmCircleSize, "spawnselectimages/asset_white_circle.png")
	dxDrawImage ( pmContainerOffsetFromLeft, pmContainerOffsetFromTop, pmSkinPortraitSize, pmSkinPortraitSize, "spawnselectimages/ptpm-skins-147.png")
	dxDrawImage ( pmContainerOffsetFromLeft, pmContainerOffsetFromTop, pmCircleSize, pmCircleSize, "spawnselectimages/asset_circle_border_pm.png")
	
	dxDrawText ( "The Prime Minister", pmTextOffsetFromLeft , pmTextOffsetFromTop, nil, nil, 0xFFFFFFFF, pmTextFontSize, "default-bold")
	dxDrawText ( "You and two others are in the election of this round.", pmTextOffsetFromLeft , pmTextElectionOffsetFromTop, nil, nil, 0xFFDDDDDD, pmElectionTextHeight, "default")
	
	dxDrawImage ( pmTextOffsetFromLeft, pmButtonOffsetFromTop, chooseButtonWidth, chooseButtonWidth / widthToHeightRatios.asset_choosebutton, "spawnselectimages/asset_choosebutton_neutral.png")
	dxDrawText ( "Choose", pmTextOffsetFromLeft, pmButtonOffsetFromTop, pmTextOffsetFromLeft+chooseButtonWidth, pmButtonOffsetFromTop + chooseButtonWidth / widthToHeightRatios.asset_choosebutton, 0xFFFFFFFF, chooseButtonFontSize, "default-bold", "center", "center", true)
	
	-- Good Guys
	dxDrawText("PROTECT", containerOffsetFromLeft, teamHeaderOffsetFromTop, containerOffsetFromLeft + teamsContainerWidth, nil, 0xFFFFFFFF, teamHeaderFontSize, "default-bold", "center") 
	dxDrawImage ( containerOffsetFromLeft, teamsContainerOffsetFromTop, teamsContainerWidth, teamsContainerHeight, "spawnselectimages/asset_background_classes.png")
	
	for k,skinId in ipairs(allowedSkinsGood) do
		local col = (k-1)%4
		local row = math.floor((k-1)/4)
		
		local skinBorder = "spawnselectimages/asset_circle_border_bg.png"
		if row > 0 then skinBorder = "spawnselectimages/asset_circle_border_cop.png" end
		
		dxDrawImage ( skinButtonsOffsetFromLeft + (skinCircleSize * col) + (skinButtonMargin * col), skinButtonsOffsetFromTop + (skinCircleSize * row) + (skinButtonMargin * row), skinCircleSize, skinCircleSize, "spawnselectimages/asset_white_circle.png")
		dxDrawImage ( skinButtonsOffsetFromLeft + (skinCircleSize * col) + (skinButtonMargin * col), skinButtonsOffsetFromTop + (skinCircleSize * row) + (skinButtonMargin * row), skinPortraitSize, skinPortraitSize, "spawnselectimages/ptpm-skins-" .. skinId .. ".png")
		dxDrawImage ( skinButtonsOffsetFromLeft + (skinCircleSize * col) + (skinButtonMargin * col), skinButtonsOffsetFromTop + (skinCircleSize * row) + (skinButtonMargin * row), skinCircleSize, skinCircleSize, skinBorder)
	end
	
	dxDrawText("May Lana", skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop, nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default-bold") 
	dxDrawText("Silenced Pistol\nSpraycan\nParachute", skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop + dxGetFontHeight ( skinDetailsFontSize, "default-bold" ), nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default") 
	
	dxDrawImage ( skinButtonsOffsetFromLeft + skinButtonsCalculatedWidth - chooseButtonWidth, skinDetailsOffsetFromTop, chooseButtonWidth, chooseButtonWidth / widthToHeightRatios.asset_choosebutton, "spawnselectimages/asset_choosebutton_neutral.png")
	dxDrawText ( "Choose", skinButtonsOffsetFromLeft + skinButtonsCalculatedWidth - chooseButtonWidth, skinDetailsOffsetFromTop, skinButtonsOffsetFromLeft + skinButtonsCalculatedWidth - chooseButtonWidth+chooseButtonWidth, skinDetailsOffsetFromTop + chooseButtonWidth / widthToHeightRatios.asset_choosebutton, 0xFFFFFFFF, chooseButtonFontSize, "default-bold", "center", "center", true)
	
	-- Terrorists
	dxDrawText("ATTACK", containerOffsetFromLeft + containerMaxWidth - teamsContainerWidth, teamHeaderOffsetFromTop, containerOffsetFromLeft + containerMaxWidth, nil, 0xFFFFFFFF, teamHeaderFontSize, "default-bold", "center") 
	dxDrawImage ( containerOffsetFromLeft + containerMaxWidth, teamsContainerOffsetFromTop, -teamsContainerWidth, teamsContainerHeight, "spawnselectimages/asset_background_classes.png")
	
	for k,skinId in ipairs(allowedSkinsTerrorists) do
		local col = (k-1)%4
		local row = math.floor((k-1)/4)
				
		dxDrawImage ( containerMaxWidth - teamsContainerWidth + skinButtonsOffsetFromLeft + (skinCircleSize * col) + (skinButtonMargin * col), skinButtonsOffsetFromTop + (skinCircleSize * row) + (skinButtonMargin * row), skinCircleSize, skinCircleSize, "spawnselectimages/asset_white_circle.png")
		dxDrawImage ( containerMaxWidth - teamsContainerWidth +skinButtonsOffsetFromLeft + (skinCircleSize * col) + (skinButtonMargin * col), skinButtonsOffsetFromTop + (skinCircleSize * row) + (skinButtonMargin * row), skinPortraitSize, skinPortraitSize, "spawnselectimages/ptpm-skins-" .. skinId .. ".png")
		dxDrawImage ( containerMaxWidth - teamsContainerWidth +skinButtonsOffsetFromLeft + (skinCircleSize * col) + (skinButtonMargin * col), skinButtonsOffsetFromTop + (skinCircleSize * row) + (skinButtonMargin * row), skinCircleSize, skinCircleSize, "spawnselectimages/asset_circle_border_terrorist.png")
	end
	
	dxDrawText("Token Black", containerMaxWidth - teamsContainerWidth +skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop, nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default-bold") 
	dxDrawText("Silenced Pistol\nSpraycan\nParachute", containerMaxWidth - teamsContainerWidth +skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop + dxGetFontHeight ( skinDetailsFontSize, "default-bold" ), nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default") 
	
	dxDrawImage ( containerMaxWidth - teamsContainerWidth +skinButtonsOffsetFromLeft + skinButtonsCalculatedWidth - chooseButtonWidth, skinDetailsOffsetFromTop, chooseButtonWidth, chooseButtonWidth / widthToHeightRatios.asset_choosebutton, "spawnselectimages/asset_choosebutton_neutral.png")
	dxDrawText ( "Choose", containerMaxWidth - teamsContainerWidth +skinButtonsOffsetFromLeft + skinButtonsCalculatedWidth - chooseButtonWidth, skinDetailsOffsetFromTop, containerMaxWidth - teamsContainerWidth +skinButtonsOffsetFromLeft + skinButtonsCalculatedWidth - chooseButtonWidth+chooseButtonWidth, skinDetailsOffsetFromTop + chooseButtonWidth / widthToHeightRatios.asset_choosebutton, 0xFFFFFFFF, chooseButtonFontSize, "default-bold", "center", "center", true)
	
	
	-- Countdown
	
	dxDrawText("Assemble your teams! Round starts in 15 seconds.", containerOffsetFromLeft, roundCountDownOffsetFromTop, containerOffsetFromLeft + containerMaxWidth, nil, 0xFFFFFFFF, roundCountDownFontSize, "default", "center") 
end

addEventHandler("onClientRender", getRootElement(), renderSpawnSelect)