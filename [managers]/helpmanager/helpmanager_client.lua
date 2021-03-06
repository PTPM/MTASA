﻿local rootElement = getRootElement()
local thisResourceRoot = getResourceRootElement(getThisResource())
local pagesXml

local wndHelp, tPanel, btnClose
local tab = {}
local memo = {}
local popupQueue = {}
local defaultTabName = ""
local firstTimeVisible = true

local HELP_KEY = "F9"
local HELP_COMMAND = "gamehelp"
local POPUP_TIMEOUT = 15000 --ms
local FADE_DELTA = .03 --alpha per frame
local MAX_ALPHA = .9

addEvent("doShowHelp", true)
addEvent("doHideHelp", true)
addEvent("onHelpShown")
addEvent("onHelpHidden")
addEvent("sendHelpManagerSettings", true)

addEventHandler("onClientResourceStart", thisResourceRoot, 
	function ()
		local sx, sy = guiGetScreenSize()
		
		local windowWidth = sx * .6
		local windowHeight = sy * .7
		
		-- if we have a very small resolution, expand to fill the screen instead
		if windowWidth < 800 then
			windowWidth = math.min(sx, 800)
		end
		
		if windowHeight < 600 then
			windowHeight = math.min(sy, 600)
		end
		
		wndHelp  = guiCreateWindow((sx - windowWidth) / 2, (sy - windowHeight) / 2, windowWidth, windowHeight, "Help", false)

		local buttonHeight = math.min(40, sy * .06)
		tPanel   = guiCreateTabPanel(0, 20, windowWidth, windowHeight - 20 - buttonHeight - 10, false, wndHelp)
		btnClose = guiCreateButton((windowWidth - (windowWidth * 0.25)) / 2, windowHeight - buttonHeight - 5, windowWidth * 0.25, buttonHeight, "Close", false, wndHelp)

		guiSetVisible(wndHelp, false)

		guiWindowSetSizable(wndHelp, false)

		addEventHandler("onClientGUIClick", btnClose,
			function()
				if source == this then
					clientToggleHelp(false)
				end
			end
		)
		
		pagesXml = xmlLoadFile("seen.xml")
		if not pagesXml then
			pagesXml = xmlCreateFile("seen.xml", "seen")
		end
		
		for i, resourceRoot in ipairs(getElementsByType("resource")) do --!w
			local resource = getResourceFromName(getElementID(resourceRoot))
			if resource then
				addHelpTabFromXML(resource)
			end
		end
		
		addCommandHandler(HELP_COMMAND, clientToggleHelp)
		bindKey(HELP_KEY, "down", clientToggleHelp)

		triggerServerEvent("onClientHelpManagerReady", localPlayer)
	end
)

addEventHandler("onClientResourceStop", thisResourceRoot,
	function()
		showCursor(false)
	end
)

addEventHandler("sendHelpManagerSettings", root,
	function(defaultTabName_)
		defaultTabName = defaultTabName_
	end
)

-- exports
function showHelp()
	return clientToggleHelp(true)
end
addEventHandler("doShowHelp", rootElement, showHelp)

function hideHelp()
	return clientToggleHelp(false)
end
addEventHandler("doHideHelp", rootElement, hideHelp)

function addHelpTab(resource, showPopup)

	if showPopup == nil then
		showPopup = true
	end
	
	-- block duplicates
	if tab[resource] then
		return false
	end
	
	local tabtext = getResourceName(resource)
	
	local helpnode = getResourceConfig(":" .. getResourceName(resource) .. "/help.xml")
	
	if helpnode then
	
		local nameattribute = xmlNodeGetAttribute(helpnode, "title");
		
		if nameattribute then
			tabtext = nameattribute;
		end
		
	end

	tab[resource] = guiCreateTab( tabtext , tPanel)
	
	if showPopup then
		addHelpPopup(resource)
	end
	
	return tab[resource]
end

function removeHelpTab(resource)
	if not tab[resource] then
		return false
	end
	
	if memo[resource] then
		destroyElement(memo[resource])
		memo[resource] = nil
	end
	
	guiDeleteTab(tab[resource], tPanel)
	tab[resource] = nil
	
	return true
end
addEventHandler("onClientResourceStop", rootElement, removeHelpTab)

--private
function addHelpTabFromXML(resource)
	-- block duplicates
	if tab[resource] then
		return false
	end
		
	local helpnode = getResourceConfig(":"..getResourceName(resource).."/help.xml")
	if helpnode then
		local helptext = xmlNodeGetValue(helpnode)
		local showPopup = not (xmlNodeGetAttribute(helpnode, "popup") == "no")
		if helptext then
			addHelpTab(resource, showPopup)
			memo[resource] = guiCreateMemo(.05, .05, .9, .9, helptext, true, tab[resource])
			guiMemoSetReadOnly(memo[resource], true)
		end
	end
end
addEventHandler("onClientResourceStart", rootElement, addHelpTabFromXML)

function clientToggleHelp(state)
	if state ~= true and state ~= false then
		state = not guiGetVisible(wndHelp)
	end
	guiSetVisible(wndHelp, state)

	if state == true then
		triggerEvent("onHelpShown", localPlayer)
		guiBringToFront(wndHelp)
		showCursor(true)

		-- the first time we open the help window try and auto select the tab that is defined in the settings (if we can find a match)
		if firstTimeVisible and defaultTabName and #defaultTabName > 0 then
			for i, tab in ipairs(getElementsByType("gui-tab", tPanel)) do
				if guiGetText(tab) == defaultTabName then
					guiSetSelectedTab(tPanel, tab)
					break
				end
			end
		end

		firstTimeVisible = false
	else
		triggerEvent("onHelpHidden", localPlayer)
		showCursor(false)
	end
	return true
end

local function fadeIn(wnd)
	local function raiseAlpha()
		local newAlpha = guiGetAlpha(wnd) + FADE_DELTA
		if newAlpha <= MAX_ALPHA then
			guiSetAlpha(wnd, newAlpha)
		else
			removeEventHandler("onClientRender", rootElement, raiseAlpha)
		end
	end
	addEventHandler("onClientRender", rootElement, raiseAlpha)
end

local function fadeOut(wnd)
	local function lowerAlpha()
		local newAlpha = guiGetAlpha(wnd) - FADE_DELTA
		if newAlpha >= 0 then
			guiSetAlpha(wnd, newAlpha)
		else
			removeEventHandler("onClientRender", rootElement, lowerAlpha)
			destroyElement(wnd)
			
			table.remove(popupQueue, 1)
			if #popupQueue > 0 then
				showHelpPopup(popupQueue[1])
			end
		end
	end
	addEventHandler("onClientRender", rootElement, lowerAlpha)
end

function addHelpPopup(resource)
	local xmlContents = xmlNodeGetValue(pagesXml)
	local seenPages = split(xmlContents, string.byte(','))
	local resourceName = getResourceName(resource)
	for i, page in ipairs(seenPages) do
		if page == resourceName then
			return
		end
	end
	xmlNodeSetValue(pagesXml, xmlContents..resourceName..",")
	xmlSaveFile(pagesXml)

	table.insert(popupQueue, resource)
	if #popupQueue == 1 then
		showHelpPopup(resource)
	end
end

function showHelpPopup(resource)
	local screenX, screenY = guiGetScreenSize()
	local wndPopup = guiCreateWindow(0, screenY - 20, screenX, 0, '', false) --350
	
	local restitle = getResourceName(resource)
	local helpnode = getResourceConfig(":" .. getResourceName(resource) .. "/help.xml")
	
	if helpnode then
	
		local nameattribute = xmlNodeGetAttribute(helpnode, "title");
		
		if nameattribute then
			restitle = nameattribute;
		end
		
	end
	
	local text =
		"Help page available for ".. restitle .."! "..
		"Press "..HELP_KEY.." or type /"..HELP_COMMAND.." to read it."
		
	guiSetText(wndPopup, text)
	guiSetAlpha(wndPopup, 0)
	guiWindowSetMovable(wndPopup, false)
	guiWindowSetSizable(wndPopup, false)
	
	fadeIn(wndPopup)
	setTimer(fadeOut, POPUP_TIMEOUT, 1, wndPopup)
end
