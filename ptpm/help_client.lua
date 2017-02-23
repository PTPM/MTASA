addEvent("onClientAvailable", true)
-- from helpmanager
addEvent("onHelpShown")
addEvent("doShowHelp", true)

local helpTab
local firstHelp = true
local helpURL = ""
local browser
local dutyRedirect

addEventHandler("onClientAvailable", localPlayer,
	function()
		helpTab = exports.helpmanager:addHelpTab(thisResource)
	end
)

addEventHandler("onHelpShown", root,
	function()
		if not helpTab then
			helpTab = exports.helpmanager:addHelpTab(thisResource)
		end

		if not firstHelp then
			if browser then
				local url, untouched = getHelpURL()

				if not untouched then
					local tabPanel = getElementParent(helpTab)

					if guiGetSelectedTab(tabPanel) ~= helpTab then
						guiSetSelectedTab(tabPanel, helpTab)
					end

					loadBrowserURL(guiGetBrowser(browser), url)
				end

				setBrowserRenderingPaused(browser, false)
			end

			return
		end

		firstHelp = false
		local url, untouched = getHelpURL()
		helpURL = url

		if not untouched then
			local tabPanel = getElementParent(helpTab)

			if guiGetSelectedTab(tabPanel) ~= helpTab then
				guiSetSelectedTab(tabPanel, helpTab)
			end
		end

		local w, h = guiGetSize(helpTab, false)
		
		browser = guiCreateBrowser(0, 0, w, h, true, false, false, helpTab)

		addEventHandler("onClientBrowserCreated", browser, onClientBrowserCreated)		
	end
)

addEventHandler("onHelpHidden", root,
	function()
		if not browser then
			return
		end

		setBrowserRenderingPaused(guiGetBrowser(browser), true)
	end
)

function onClientBrowserCreated()
	loadBrowserURL(source, helpURL)
end

-- proxy through to specific pages if we have some contextual prompt open
function getHelpURL()
	local prompt = getCurrentHelpPrompt()

	if dutyRedirect then
		local url = dutyRedirect
		dutyRedirect = nil
		return url
	end

	if prompt and prompt.id then
		if prompt.id == "BASICS_TERRORIST" then
			return "http://mta/local/help/index.html#teams?q=terrorist"
		elseif prompt.id == "BASICS_POLICE" then
			return "http://mta/local/help/index.html#teams?q=police"
		elseif prompt.id == "BASICS_BODYGUARD" then
			return "http://mta/local/help/index.html#teams?q=bodyguard"
		elseif prompt.id == "BASICS_PM" then
			return "http://mta/local/help/index.html#teams?q=pm"
		elseif prompt.id == "MEDIC_HEAL" or prompt.id == "MEDIC_AMBULANCE" or prompt.id == "MEDIC_PASSIVE_GIVE" then
			return "http://mta/local/help/index.html#classes?q=medic"
		elseif prompt.id == "OBJECTIVE_OVERVIEW" or prompt.id == "OBJECTIVE_OVERVIEW_PM" or prompt.id == "OBJECTIVE_ENTER" or prompt.id == "OBJECTIVE_COMPLETE" or prompt.id == "OBJECTIVE_NUDGE" then
			return "http://mta/local/help/index.html#how-to-play?q=objectives"
		elseif prompt.id == "TASK_OVERVIEW" or prompt.id == "TASK_OVERVIEW_PM" or prompt.id == "TASK_ENTER" or prompt.id == "TASK_COMPLETE" or prompt.id == "TASK_NUDGE" then
			return "http://mta/local/help/index.html#how-to-play?q=tasks"
		elseif prompt.id == "COMMAND_RECLASS" then
			return "http://mta/local/help/index.html#commands?q=com-reclass"
		elseif prompt.id == "COMMAND_SWAPCLASS" or prompt.id == "COMMAND_SWAPCLASS_TARGET" then
			return "http://mta/local/help/index.html#commands?q=com-swapclass"
		elseif prompt.id == "COMMAND_DUTY" then
			local classID = getElementData(localPlayer, "ptpm.classID")
					
			if classID then
				if classes[classID] == "pm" then
					return "http://mta/local/help/index.html#teams?q=pm"
				elseif classes[classID] == "bodyguard" then
					return "http://mta/local/help/index.html#teams?q=bodyguard"
				elseif classes[classID] == "police" then
					return "http://mta/local/help/index.html#teams?q=police"
				elseif classes[classID] == "terrorist" then
					return "http://mta/local/help/index.html#teams?q=terrorist"
				elseif classes[classID] == "psycho" then
					return "http://mta/local/help/index.html#teams?q=psycho"
				end
			end
		elseif prompt.id == "OPTION_HEALTH_REGEN_PM" then
			return "http://mta/local/help/index.html#maps?q=op-pm-health-bonus"
		elseif prompt.id == "OPTION_HEALTH_REGEN_MEDIC" then
			return "http://mta/local/help/index.html#maps?q=op-medic-health-bonus"
		elseif prompt.id == "OPTION_PM_WATER_PENALTY" then
			return "http://mta/local/help/index.html#maps?q=op-pm-water-penalty"
		elseif prompt.id == "OPTION_PM_WATER_DEATH" then
			return "http://mta/local/help/index.html#maps?q=op-pm-water-death"
		elseif prompt.id == "OPTION_PM_ABANDONED_PENALTY" then
			return "http://mta/local/help/index.html#maps?q=op-pm-abandon-penalty"
		elseif prompt.id == "SAFE_ZONE" then
			return "http://mta/local/help/index.html#how-to-play?q=safe-zone"
		end
	end

	return "http://mta/local/help/index.html", true
end

function explainRole()
	local classID = getElementData(localPlayer, "ptpm.classID")
			
	if not classID then
		outputChatBox("You are not on a team, your duty is to spawn!", unpack(colour.personal))
		return
	end

	if classes[classID] == "pm" then
		dutyRedirect = "http://mta/local/help/index.html#teams?q=pm"
	elseif classes[classID] == "bodyguard" then
		dutyRedirect = "http://mta/local/help/index.html#teams?q=bodyguard"
	elseif classes[classID] == "police" then
		dutyRedirect = "http://mta/local/help/index.html#teams?q=police"
	elseif classes[classID] == "terrorist" then
		dutyRedirect = "http://mta/local/help/index.html#teams?q=terrorist"
	elseif classes[classID] == "psycho" then
		dutyRedirect = "http://mta/local/help/index.html#teams?q=psycho"
	end

	triggerEvent("doShowHelp", root)
end
addCommandHandler("duty", explainRole)


----------------------------------------------------------
-- round transition messages

local helper = {
	messages = {
		"Visit [PTPM]https://PTPM.uk[WHITE] for strategy tips! (members only!)",
		"Don't know what to do? Type [PTPM]/duty[WHITE] or press [PTPM]F9",
		"Join the community at [PTPM]https://PTPM.uk[WHITE]!",
		"Press '[PTPM]Y[WHITE]' to chat with your team",
		"Check out [PTPM]https://PTPM.uk/scoreboard[WHITE] for the player list outside of MTA!",
		"The [PM]Prime Minister[WHITE] is shown in [PM]yellow",
		"Check out [PTPM]https://PTPM.uk[WHITE] to see your League and compare it to others!",
		"What is PTPM? Press [PTPM]F9[WHITE] and click '[PTPM]PTPM[WHITE]' to find out",
		"Are you Silver, Gold or even Platinum? Find out at [PTPM]https://PTPM.uk/stats[WHITE]!",
		"Want to change your team? Type [PTPM]/reclass <team>",
		"Navigate the class selection from your keyboard using the [PTPM]arrow keys[WHITE] and holding [PTPM]ctrl",
		"Are you playing as a [PTPM]medic[WHITE]? You can heal people with [PTPM]/heal",
		"There's a [PTPM]minigun[WHITE]? Find out more at [PTPM]https://PTPM.uk[WHITE]!",
		"Want a full list of the commands? Press [PTPM]F9[WHITE] and click '[PTPM]PTPM[WHITE]'",
		"Show off your ingame skills to the community on [PTPM]https://PTPM.uk[WHITE]!",
		"Use [PTPM]right click[WHITE] to [PTPM]driveby[WHITE] (when you have a driveby weapon)",
		"Cool screenshots and videos of PTPM gameplay at [PTPM]https://PTPM.uk[WHITE]!",
		"Tap '[PTPM]jump[WHITE]' underneath a helicopter to grab on",
		"Hold [PTPM]F2[WHITE] or [PTPM]F3[WHITE] to open the Strategy Radial for quick communication" -- todo read the real binds and use those
	},

	message = "",
	current = 0,
	width = 0,
	drawing = false,
	yPos = 0
}

addEventHandler("onClientAvailable", localPlayer,
	function()
		helper.current = math.random(1,#helper.messages)
	end
)

function showHelpMessage(minY) 
	if helper.drawing then
		return
	end

	helper.width = dxGetTextWidth(helper.messages[helper.current], 1, "default-bold")
	helper.yPos = minY
	helper.drawing = true
	helper.message = colour.hex.parse(helper.messages[helper.current])

	addEventHandler("onClientRender", root, drawHelpMessage)
end

function hideHelpMessage()
	if not helper.drawing then
		return
	end

	helper.drawing = false
	removeEventHandler("onClientRender", root, drawHelpMessage)

	helper.current = (helper.current % #helper.messages) + 1
end

function drawHelpMessage()
	dxDrawText(helper.message, screenX / 2 - helper.width / 2, helper.yPos, screenX / 2 + helper.width / 2, helper.yPos + 10, 0xFFFFFFFF, 1, "default", "center", "center", false, false, false, true)
end


-- addCommandHandler("nm",
-- 	function()
-- 		if not helper.drawing then
-- 			showHelpMessage(screenY/2-(538/2)+538)
-- 		end

-- 		helper.current = (helper.current % #helper.messages) + 1
-- 	end
-- )