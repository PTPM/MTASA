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

--local allowedSkinsGood = {141,164,166,276,281,285,288,275}
--local allowedSkinsTerrorists = {181,183,191,111,73,100,179,274}
local spawnSelect2Classes = {}

local roundCountDownOffsetFromTop = teamsContainerOffsetFromTop + teamsContainerHeight * 1.06
local roundCountDownFontSize = chooseButtonFontSize

-- Class for dxClickableElement
local dxClickableElementsNames = {}

local dxClickableElements = {}
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
	
	return el
end

function dxClickableElement:setAbsPos(x1,y1,x2,y2)
	self.startX = x1
	self.startY = y1
	self.endX = x2
	self.endY = y2
	
	return self
end


function renderSpawnSelect ( )
	local skinButtonVar = "spawnselectimages/asset_choosebutton_neutral.png"

	-- General backgrounds
	dxDrawRectangle ( 0,0, screenWidth,screenHeight, 0x99000000)

	-- PM
	dxDrawImage ( containerOffsetFromLeft, pmContainerOffsetFromTop, containerMaxWidth, containerMaxWidth / widthToHeightRatios.asset_background_pm, "spawnselectimages/asset_background_pm.png")
	
	dxDrawImage ( pmContainerOffsetFromLeft, pmContainerOffsetFromTop, pmCircleSize, pmCircleSize, "spawnselectimages/asset_white_circle.png")
	dxDrawImage ( pmContainerOffsetFromLeft, pmContainerOffsetFromTop, pmSkinPortraitSize, pmSkinPortraitSize, "spawnselectimages/ptpm-skins-147.png")
	dxDrawImage ( pmContainerOffsetFromLeft, pmContainerOffsetFromTop, pmCircleSize, pmCircleSize, "spawnselectimages/asset_circle_border_pm.png")
	
	dxClickableElements["pmFace"]:setAbsPos(pmContainerOffsetFromLeft, pmContainerOffsetFromTop,pmContainerOffsetFromLeft+pmCircleSize,pmContainerOffsetFromTop+pmCircleSize)
	dxClickableElements["pmButton"]:setAbsPos(pmTextOffsetFromLeft, pmButtonOffsetFromTop, pmTextOffsetFromLeft+chooseButtonWidth, pmButtonOffsetFromTop+chooseButtonHeight )
	
	if dxClickableElements["pmButton"].selected then
		skinButtonVar = "spawnselectimages/asset_choosebutton_pm.png"
	end
	
	if dxClickableElements["pmButton"].hovered then
		dxDrawImage ( pmTextOffsetFromLeft, pmButtonOffsetFromTop, chooseButtonWidth, chooseButtonHeight, skinButtonVar, 180)
	else
		dxDrawImage ( pmTextOffsetFromLeft, pmButtonOffsetFromTop, chooseButtonWidth, chooseButtonHeight, skinButtonVar)
	end
	
	dxDrawText ( "Choose", pmTextOffsetFromLeft, pmButtonOffsetFromTop, pmTextOffsetFromLeft+chooseButtonWidth, pmButtonOffsetFromTop + chooseButtonHeight, 0xFFFFFFFF, chooseButtonFontSize, "default-bold", "center", "center", true)
	
	dxDrawText ( "The Prime Minister", pmTextOffsetFromLeft , pmTextOffsetFromTop, nil, nil, 0xFFFFFFFF, pmTextFontSize, "default-bold")
	dxDrawText ( "You and two others are in the election of this round.", pmTextOffsetFromLeft , pmTextElectionOffsetFromTop, nil, nil, 0xFFDDDDDD, pmElectionTextHeight, "default")
	 
	-- Good Guys
	dxDrawText("PROTECT", containerOffsetFromLeft, teamHeaderOffsetFromTop, containerOffsetFromLeft + teamsContainerWidth, nil, 0xFFFFFFFF, teamHeaderFontSize, "default-bold", "center") 
	dxDrawImage ( containerOffsetFromLeft, teamsContainerOffsetFromTop, teamsContainerWidth, teamsContainerHeight, "spawnselectimages/asset_background_classes.png")
	
	local i = 1
	for k,sc in ipairs(spawnSelect2Classes) do
		if sc.classType=="bodyguard" or sc.classType=="police" then
			
			local col = (i-1)%4
			local row = math.floor((i-1)/4)
			local thisButtonId = "goodGuyFace-" .. i
			
			if sc.classType=="bodyguard" then skinBorder = "spawnselectimages/asset_circle_border_bg.png" end
			if sc.classType=="police" then skinBorder = "spawnselectimages/asset_circle_border_cop.png" end
			
			local x = skinButtonsOffsetFromLeft + (skinCircleSize * col) + (skinButtonMargin * col)
			local y = skinButtonsOffsetFromTop + (skinCircleSize * row) + (skinButtonMargin * row)
			local colorOverlay = 0xFFFFFFFF
			
			if dxClickableElements[thisButtonId].selected then
				colorOverlay = 0xFFC4FEFF
			elseif dxClickableElements[thisButtonId].hovered then
				colorOverlay = 0xFFE1FFFF
			end
			
			dxDrawImage ( x,y, skinCircleSize, skinCircleSize, "spawnselectimages/asset_white_circle.png", 0, 0, 0, colorOverlay)
			dxDrawImage ( x,y, skinPortraitSize, skinPortraitSize, "spawnselectimages/ptpm-skins-" .. sc.skin .. ".png")
			dxDrawImage ( x,y, skinCircleSize, skinCircleSize, skinBorder)
			
			dxClickableElements[thisButtonId]:setAbsPos(x, y, x+skinCircleSize, y+skinCircleSize)
			
			i = i+1
			
		end
	end
	
	dxDrawText("May Lana", skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop, nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default-bold") 
	dxDrawText("Silenced Pistol\nSpraycan\nParachute", skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop + dxGetFontHeight ( skinDetailsFontSize, "default-bold" ), nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default") 
	
	local playerCountInTeamOffsetFromTop = skinDetailsOffsetFromTop
	local chooseButtonGoodGuysX = skinButtonsOffsetFromLeft + skinButtonsCalculatedWidth - chooseButtonWidth
	local chooseButtonGoodGuysY = playerCountInTeamOffsetFromTop + (dxGetFontHeight ( skinDetailsFontSize, "default-bold" ) * 1.2)
	
	dxDrawText("3 players", chooseButtonGoodGuysX, playerCountInTeamOffsetFromTop, chooseButtonGoodGuysX + chooseButtonWidth, playerCountInTeamOffsetFromTop +  dxGetFontHeight ( skinDetailsFontSize, "default-bold" ), 0xFFFFFFFF, skinDetailsFontSize, "default", "center", "top" ) 
	
	skinButtonVar = "spawnselectimages/asset_choosebutton_neutral.png"
	if dxClickableElements["goodGuyButton"].selected then
		skinButtonVar = "spawnselectimages/asset_choosebutton_goodguy.png"
	end
	
	if dxClickableElements["goodGuyButton"].hovered then
		dxDrawImage ( chooseButtonGoodGuysX, chooseButtonGoodGuysY, chooseButtonWidth, chooseButtonHeight, skinButtonVar, 180)
	else
		dxDrawImage ( chooseButtonGoodGuysX, chooseButtonGoodGuysY, chooseButtonWidth, chooseButtonHeight, skinButtonVar)
	end
	dxDrawText ( "Choose", chooseButtonGoodGuysX, chooseButtonGoodGuysY, chooseButtonGoodGuysX+chooseButtonWidth, chooseButtonGoodGuysY + chooseButtonHeight, 0xFFFFFFFF, chooseButtonFontSize, "default-bold", "center", "center", true)
	
	dxClickableElements["goodGuyButton"]:setAbsPos( chooseButtonGoodGuysX, chooseButtonGoodGuysY, chooseButtonGoodGuysX+chooseButtonWidth, chooseButtonGoodGuysY+chooseButtonHeight)
	
	--[[ Terrorists
	dxDrawText("ATTACK", containerOffsetFromLeft + containerMaxWidth - teamsContainerWidth, teamHeaderOffsetFromTop, containerOffsetFromLeft + containerMaxWidth, nil, 0xFFFFFFFF, teamHeaderFontSize, "default-bold", "center") 
	dxDrawImage ( containerOffsetFromLeft + containerMaxWidth, teamsContainerOffsetFromTop, -teamsContainerWidth, teamsContainerHeight, "spawnselectimages/asset_background_classes.png")
	
	for k,skinId in ipairs(allowedSkinsTerrorists) do
		local col = (k-1)%4
		local row = math.floor((k-1)/4)
		local thisButtonId = "badGuyFace-" .. k		
		
		local x = containerMaxWidth - teamsContainerWidth + skinButtonsOffsetFromLeft + (skinCircleSize * col) + (skinButtonMargin * col)
		local y = skinButtonsOffsetFromTop + (skinCircleSize * row) + (skinButtonMargin * row)
		local colorOverlay = 0xFFFFFFFF
		
		if dxClickableElements[thisButtonId].selected then
			colorOverlay = 0xFFFCD4FC
		elseif dxClickableElements[thisButtonId].hovered then
			colorOverlay = 0xFFFFE8FF
		end
		
		dxDrawImage ( x,y, skinCircleSize, skinCircleSize, "spawnselectimages/asset_white_circle.png", 0, 0, 0, colorOverlay)
		dxDrawImage ( x,y, skinPortraitSize, skinPortraitSize, "spawnselectimages/ptpm-skins-" .. skinId .. ".png")
		dxDrawImage ( x,y, skinCircleSize, skinCircleSize, "spawnselectimages/asset_circle_border_terrorist.png")
		
		dxClickableElements[thisButtonId]:setAbsPos(x, y, x+skinCircleSize, y+skinCircleSize)
	end
	
	dxDrawText("Token Black", containerMaxWidth - teamsContainerWidth +skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop, nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default-bold") 
	dxDrawText("Silenced Pistol\nSpraycan\nParachute", containerMaxWidth - teamsContainerWidth +skinButtonsOffsetFromLeft, skinDetailsOffsetFromTop + dxGetFontHeight ( skinDetailsFontSize, "default-bold" ), nil, nil, 0xFFFFFFFF, skinDetailsFontSize, "default") 
	
	local chooseButtonBadGuysX = containerMaxWidth - teamsContainerWidth + skinButtonsOffsetFromLeft + skinButtonsCalculatedWidth - chooseButtonWidth
	local chooseButtonBadGuysY = playerCountInTeamOffsetFromTop + (dxGetFontHeight ( skinDetailsFontSize, "default-bold" ) * 1.2)
		
	dxDrawText("3 players", chooseButtonBadGuysX, playerCountInTeamOffsetFromTop, chooseButtonBadGuysX + chooseButtonWidth, playerCountInTeamOffsetFromTop +  dxGetFontHeight ( skinDetailsFontSize, "default-bold" ), 0xFFFFFFFF, skinDetailsFontSize, "default", "center", "top" ) 
	
	
	skinButtonVar = "spawnselectimages/asset_choosebutton_neutral.png"
	if dxClickableElements["badGuyButton"].selected then
		skinButtonVar = "spawnselectimages/asset_choosebutton_terrorist.png"
	end
	
	if dxClickableElements["badGuyButton"].hovered then
		dxDrawImage ( chooseButtonBadGuysX, chooseButtonBadGuysY, chooseButtonWidth, chooseButtonHeight, skinButtonVar, 180)
	else
		dxDrawImage ( chooseButtonBadGuysX, chooseButtonBadGuysY, chooseButtonWidth, chooseButtonHeight, skinButtonVar)
	end
	dxDrawText ( "Choose", chooseButtonBadGuysX, chooseButtonBadGuysY, chooseButtonBadGuysX+chooseButtonWidth, chooseButtonBadGuysY + chooseButtonHeight, 0xFFFFFFFF, chooseButtonFontSize, "default-bold", "center", "center", true)
	
	dxClickableElements["badGuyButton"]:setAbsPos( chooseButtonBadGuysX, chooseButtonBadGuysY, chooseButtonBadGuysX+chooseButtonWidth, chooseButtonBadGuysY+chooseButtonHeight)
	]]--
	
	-- Countdown
	dxDrawText("Assemble your teams! Round starts in 15 seconds.", containerOffsetFromLeft, roundCountDownOffsetFromTop, containerOffsetFromLeft + containerMaxWidth, nil, 0xFFFFFFFF, roundCountDownFontSize, "default", "center") 
end

function clearSelection()
	for k2,v2 in pairs(dxClickableElements) do
		if k2~="pmButton" then 
			v2.selected = false
		end
	end
end

function findSelectedFace(k)
	for k2,v2 in pairs(dxClickableElements) do
		if (k=="badGuyButton" and string.match(k2,"badGuyFace") and v2.selected) or (k=="goodGuyButton" and string.match(k2,"goodGuyFace") and v2.selected) then 
			return k2
		end
	end
	return nil
end

function onClickHandler ( button, state, absoluteX, absoluteY )
	if playerHasJustClicked then return nil end
    if isStartOfRoundSpawnSelectRunning and state=="up" then
		for k,v in pairs(dxClickableElements) do
			if absoluteX > v.startX and absoluteX < v.endX and absoluteY > v.startY and absoluteY < v.endY then

			-- If player clicked any face, then also select the appropriate Team Choose Button AND clear 
				if string.match(k, "goodGuyFace") then
					clearSelection()
					dxClickableElements["goodGuyButton"].selected = true
					v.selected = true
					
				elseif string.match(k, "badGuyFace") then
					clearSelection()
					dxClickableElements["badGuyButton"].selected = true
					v.selected = true
					
				-- If player uses the Choose (Team) Button, then clear all other buttons EXCEPT if they chose a face from that team				
				elseif k=="badGuyButton" or k=="goodGuyButton" then
					local b = findSelectedFace(k)
					clearSelection()
					if b then dxClickableElements[b].selected = true end
					v.selected = true
				
				-- pmFace is an alias for pmButton				
				elseif k=="pmFace" or k=="pmButton" then
					
					-- Toggle if you want 
					dxClickableElements["pmButton"].selected = not dxClickableElements["pmButton"].selected
					
				end
				
				playerHasJustClicked = true
				setTimer(function() playerHasJustClicked = false end, 200, 1 )
				
				return
			end
		end
	end
end

function onMouseOverHandler ( _, _, absoluteX, absoluteY )

	if isStartOfRoundSpawnSelectRunning then
		for k,v in pairs(dxClickableElements) do
			dxClickableElements[k].hovered = false
			
			if absoluteX > v.startX and absoluteX < v.endX and absoluteY > v.startY and absoluteY < v.endY then
				dxClickableElements[k].hovered = true
			end
		end
	end
end

function startSpawnSelect( _spawnSelect2Classes )

	spawnSelect2Classes = _spawnSelect2Classes
	
	dxClickableElementsNames = {"pmButton","pmFace","goodGuyButton","badGuyButton"}
	for i=1,8 do
		table.insert(dxClickableElementsNames,"badGuyFace-"..i)
		table.insert(dxClickableElementsNames,"goodGuyFace-"..i)
	end
	
	for _,v in ipairs(dxClickableElementsNames) do
		dxClickableElements[v] = dxClickableElement.create(v)
	end
	
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


addEvent( "ptpmSpawnSelect", true )
addEventHandler( "ptpmSpawnSelect", localPlayer, startSpawnSelect )

--addEventHandler( "onClientResourceStart", getRootElement( ), startSpawnSelect)