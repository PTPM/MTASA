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


local isStartOfRoundSpawnSelectRunning = false
local playerHasJustClicked = false
local spawnTimeCountDown = 15

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
local chooseButtonHeight = chooseButtonWidth / widthToHeightRatios.asset_choosebutton

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

-- Class for dxClickableElement
local dxClickableElement = {}
dxClickableElement.__index = dxClickableElement
function dxClickableElement.create(elementId)
	local el = {}
	setmetatable(el, dxClickableElement)
	el.id = elementId
	el.startX = -1
	el.startY = -1
	el.endX = -1
	el.endY = -1
	el.hovered = false
	el.selected = false
end

function dxClickableElement:setAbsPos(x1,y1,x2,y2)
	self.startX = x1
	self.startY = x1
	self.endX = x2
	self.endY = x2
end


function renderSpawnSelect ( )
	-- General backgrounds
	dxDrawRectangle ( 0,0, screenWidth,screenHeight, 0x99000000)

	-- PM
	dxDrawImage ( containerOffsetFromLeft, pmContainerOffsetFromTop, containerMaxWidth, containerMaxWidth / widthToHeightRatios.asset_background_pm, "spawnselectimages/asset_background_pm.png")
	
	dxClickableElement["pmButton"] =   { startX = pmTextOffsetFromLeft, startY = pmButtonOffsetFromTop, endX = pmTextOffsetFromLeft+chooseButtonWidth, endY = pmButtonOffsetFromTop+chooseButtonHeight }
	dxDrawImage ( pmContainerOffsetFromLeft, pmContainerOffsetFromTop, pmCircleSize, pmCircleSize, "spawnselectimages/asset_white_circle.png")
	dxDrawImage ( pmContainerOffsetFromLeft, pmContainerOffsetFromTop, pmSkinPortraitSize, pmSkinPortraitSize, "spawnselectimages/ptpm-skins-147.png")
	dxDrawImage ( pmContainerOffsetFromLeft, pmContainerOffsetFromTop, pmCircleSize, pmCircleSize, "spawnselectimages/asset_circle_border_pm.png")
	
	dxClickableElement["pmFace"] = { startX = pmContainerOffsetFromLeft, startY = pmContainerOffsetFromTop, endX = pmContainerOffsetFromLeft+pmCircleSize, endY = pmContainerOffsetFromTop+pmCircleSize }
	
	--outputDebugString("pmButton.isHovered " .. (dxClickableElement["pmButton"].isHovered and "true" or "false"))
	
	-- if dxClickableElementtates["pmButton"].isHovered then
		-- outputDebugString("is hovered")
		-- dxDrawImage ( pmTextOffsetFromLeft, pmButtonOffsetFromTop, chooseButtonWidth, chooseButtonHeight, "spawnselectimages/asset_choosebutton_neutral.png", 90)
	-- else
		dxDrawImage ( pmTextOffsetFromLeft, pmButtonOffsetFromTop, chooseButtonWidth, chooseButtonHeight, "spawnselectimages/asset_choosebutton_neutral.png")
	-- end
	
	dxDrawText ( "Choose", pmTextOffsetFromLeft, pmButtonOffsetFromTop, pmTextOffsetFromLeft+chooseButtonWidth, pmButtonOffsetFromTop + chooseButtonHeight, 0xFFFFFFFF, chooseButtonFontSize, "default-bold", "center", "center", true)
	
	dxDrawText ( "The Prime Minister", pmTextOffsetFromLeft , pmTextOffsetFromTop, nil, nil, 0xFFFFFFFF, pmTextFontSize, "default-bold")
	dxDrawText ( "You and two others are in the election of this round.", pmTextOffsetFromLeft , pmTextElectionOffsetFromTop, nil, nil, 0xFFDDDDDD, pmElectionTextHeight, "default")
	 
	-- Good Guys
	dxDrawText("PROTECT", containerOffsetFromLeft, teamHeaderOffsetFromTop, containerOffsetFromLeft + teamsContainerWidth, nil, 0xFFFFFFFF, teamHeaderFontSize, "default-bold", "center") 
	dxDrawImage ( containerOffsetFromLeft, teamsContainerOffsetFromTop, teamsContainerWidth, teamsContainerHeight, "spawnselectimages/asset_background_classes.png")
	
	for k,skinId in ipairs(allowedSkinsGood) do
		local col = (k-1)%4
		local row = math.floor((k-1)/4)
		
		local skinBorder = "spawnselectimages/asset_circle_border_bg.png"
		if row > 0 then skinBorder = "spawnselectimages/asset_circle_border_cop.png" end
		
		local x = skinButtonsOffsetFromLeft + (skinCircleSize * col) + (skinButtonMargin * col)
		local y = skinButtonsOffsetFromTop + (skinCircleSize * row) + (skinButtonMargin * row)
		
		dxDrawImage ( x,y, skinCircleSize, skinCircleSize, "spawnselectimages/asset_white_circle.png")
		dxDrawImage ( x,y, skinPortraitSize, skinPortraitSize, "spawnselectimages/ptpm-skins-" .. skinId .. ".png")
		dxDrawImage ( x,y, skinCircleSize, skinCircleSize, skinBorder)
		
		dxClickableElement["goodGuyFace-" .. k] = { startX = x, startY = y, endX = x+skinCircleSize, endY = y+skinCircleSize }
	end
	
	dxDrawText("May Lana", skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop, nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default-bold") 
	dxDrawText("Silenced Pistol\nSpraycan\nParachute", skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop + dxGetFontHeight ( skinDetailsFontSize, "default-bold" ), nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default") 
	
	local chooseButtonGoodGuysX = skinButtonsOffsetFromLeft + skinButtonsCalculatedWidth - chooseButtonWidth
	local chooseButtonGoodGuysY = skinDetailsOffsetFromTop
	
	dxDrawImage ( chooseButtonGoodGuysX, chooseButtonGoodGuysY, chooseButtonWidth, chooseButtonHeight, "spawnselectimages/asset_choosebutton_neutral.png")
	dxDrawText ( "Choose", chooseButtonGoodGuysX, chooseButtonGoodGuysY, chooseButtonGoodGuysX+chooseButtonWidth, chooseButtonGoodGuysY + chooseButtonHeight, 0xFFFFFFFF, chooseButtonFontSize, "default-bold", "center", "center", true)
	
	dxClickableElement["goodGuyButton"] = { startX = chooseButtonGoodGuysX, startY = chooseButtonGoodGuysY, endX = chooseButtonGoodGuysX+chooseButtonWidth, endY = chooseButtonGoodGuysY+chooseButtonHeight }
	
	-- Terrorists
	dxDrawText("ATTACK", containerOffsetFromLeft + containerMaxWidth - teamsContainerWidth, teamHeaderOffsetFromTop, containerOffsetFromLeft + containerMaxWidth, nil, 0xFFFFFFFF, teamHeaderFontSize, "default-bold", "center") 
	dxDrawImage ( containerOffsetFromLeft + containerMaxWidth, teamsContainerOffsetFromTop, -teamsContainerWidth, teamsContainerHeight, "spawnselectimages/asset_background_classes.png")
	
	for k,skinId in ipairs(allowedSkinsTerrorists) do
		local col = (k-1)%4
		local row = math.floor((k-1)/4)
		
		local x = containerMaxWidth - teamsContainerWidth + skinButtonsOffsetFromLeft + (skinCircleSize * col) + (skinButtonMargin * col)
		local y = skinButtonsOffsetFromTop + (skinCircleSize * row) + (skinButtonMargin * row)
				
		dxDrawImage ( x,y, skinCircleSize, skinCircleSize, "spawnselectimages/asset_white_circle.png")
		dxDrawImage ( x,y, skinPortraitSize, skinPortraitSize, "spawnselectimages/ptpm-skins-" .. skinId .. ".png")
		dxDrawImage ( x,y, skinCircleSize, skinCircleSize, "spawnselectimages/asset_circle_border_terrorist.png")
		
		dxClickableElement["badGuyFace-" .. k] = { startX = x, startY = y, endX = x+skinCircleSize, endY = y+skinCircleSize }
	end
	
	dxDrawText("Token Black", containerMaxWidth - teamsContainerWidth +skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop, nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default-bold") 
	dxDrawText("Silenced Pistol\nSpraycan\nParachute", containerMaxWidth - teamsContainerWidth +skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop + dxGetFontHeight ( skinDetailsFontSize, "default-bold" ), nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default") 
	
	local chooseButtonBadGuysX = containerMaxWidth - teamsContainerWidth + skinButtonsOffsetFromLeft + skinButtonsCalculatedWidth - chooseButtonWidth
	local chooseButtonBadGuysY = skinDetailsOffsetFromTop
	local xSpecial = containerMaxWidth - teamsContainerWidth +chooseButtonBadGuysX+chooseButtonWidth --I... forgot why not just chooseButtonBadGuysX + chooseButtonWidth

	
	dxDrawImage ( chooseButtonBadGuysX, chooseButtonBadGuysY, chooseButtonWidth, chooseButtonHeight, "spawnselectimages/asset_choosebutton_neutral.png")
	dxDrawText ( "Choose", chooseButtonBadGuysX, chooseButtonBadGuysY, chooseButtonBadGuysX+chooseButtonWidth, chooseButtonBadGuysY + chooseButtonHeight, 0xFFFFFFFF, chooseButtonFontSize, "default-bold", "center", "center", true)
	
	dxClickableElement["badGuyButton"] = { startX = chooseButtonBadGuysX, startY = chooseButtonBadGuysX, endX = chooseButtonBadGuysX+chooseButtonWidth, endY = chooseButtonBadGuysX+chooseButtonHeight }
	
	-- Countdown
	
	dxDrawText("Assemble your teams! Round starts in 15 seconds.", containerOffsetFromLeft, roundCountDownOffsetFromTop, containerOffsetFromLeft + containerMaxWidth, nil, 0xFFFFFFFF, roundCountDownFontSize, "default", "center") 
end

function onClickHandler ( button, state, absoluteX, absoluteY )
	if playerHasJustClicked then return nil end
    if isStartOfRoundSpawnSelectRunning and state=="up" then
		for k,v in pairs(dxClickableElement) do
			if absoluteX > v.startX and absoluteX < v.endX and absoluteY > v.startY and absoluteY < v.endY then
		
				outputChatBox("Clicked: " .. k)
				-- dxClickableElementtates
				
				playerHasJustClicked = true
				setTimer(function() playerHasJustClicked = false end, 500, 1 )
			end
		end
	end
end

function onMouseOverHandler ( _, _, absoluteX, absoluteY )

	-- if isStartOfRoundSpawnSelectRunning then
		-- for k,v in pairs(dxClickableElement) do
			-- if absoluteX > v.startX and absoluteX < v.endX and absoluteY > v.startY and absoluteY < v.endY then
				-- dxClickableElementtates[k].isHovered = true
			-- end
		-- end
	-- end
end

function startSpawnSelect(  )
	
	if source~= getResourceRootElement(getThisResource()) then do return end end
	
	
	showCursor ( true )
	isStartOfRoundSpawnSelectRunning = true
	setPlayerHudComponentVisible ( "all" , false )
	
	addEventHandler("onClientRender", getRootElement(), renderSpawnSelect)
	addEventHandler ( "onClientClick", getRootElement(), onClickHandler )
	addEventHandler ( "onClientCursorMove", getRootElement(), onMouseOverHandler )
	
	spawnTimeCountDown = 15
	setTimer(function() 
		spawnTimeCountDown = spawnTimeCountDown-1
		if spawnTimeCountDown<0 then spawnTimeCountDown = 0 end
	end, 1000, spawnTimeCountDown )
end


addEventHandler( "onClientResourceStart", getRootElement( ), startSpawnSelect)