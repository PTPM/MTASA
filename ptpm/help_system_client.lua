local uiScale = math.min(screenY, 1000) / 600
local state = {
	grow = 0,
	slideIn = 1,
	showing = 2,
	slideOut = 3,
	shrink = 4,
	complete = 5,
}

local help = {
	text = "",
	duration = 0,

	x = screenX,
	y = screenY * 0.8,
	height = 80,
	width = 0,
	showing = false,
	startTick = 0,
	showTick = 0,
	animationProgress = 0,
	animationState = 0,
	queue = {},
	slideBlocks = {},

	reset = function(self)
		self.startTick = getTickCount()
		self.animationProgress = 0
		self.animationState = state.grow
		self.width = self.height * 3.5

		for i = 1, 9 do
			self.slideBlocks[i] = -(i * 0.1)
		end
	end,

	stateAnimationProgress = function(self, state)
		if (self.animationState == state) then
			return self.animationProgress
		elseif (self.animationState > state) then
			return 1
		end

		return 0
	end,

	nextState = function(self)
		self.animationState = self.animationState + 1
		self.animationProgress = 0

		if self.animationState == state.showing then
			self.showTick = getTickCount()
		end
	end
}

local delta = 0
local lastTick = 0
local speed = 2

addEvent("showHelpEvent", true)
addEvent("hideHelpEvent", true)


-- scale
local function s(value)
	return value * uiScale
end

function helpSystemSetup()
	help.height = help.height * uiScale

	help.font = dxCreateFont("fonts/tahoma.ttf", 9 * (uiScale * 2), false, "proof")

	if not help.font then
		help.font = "default"
	end

	--triggerEvent("showHelpEvent", resourceRoot, "WARNING: While viewing a camera you can still be attacked. Use the left/right arrow keys to change camera. Type /camoff or press enter to exit", 6000, nil, false)
	--triggerEvent("showHelpEvent", resourceRoot, "this is a multi line message\nthis is a multi line message\nnew\nline", 2000, nil, false)
	--triggerEvent("showHelpEvent", resourceRoot, "this is a queued\nmulti\nline\nmessage", 6000, nil, true)
end 


function showHelpEvent(text, duration, image, managerLink, queue) 
	if help.showing then
		if queue then
			table.insert(help.queue, {text = text, duration = duration, image = image, managerLink = managerLink})
		end

		return
	end

	setupHelpEvent(text, duration, managerLink, image)
end
addEventHandler("showHelpEvent", resourceRoot, showHelpEvent)

function hideHelpEvent()
	if not help.showing then
		return
	end

	if help.animationState == state.showing then
		help:nextState()
	elseif help.animationState < state.showing then
		help.duration = 0
	end
end
addEventHandler("hideHelpEvent", resourceRoot, hideHelpEvent)


function setupHelpEvent(text, duration, managerLink, image)
	help:reset()

	local circleSize = help.height + s(12)
	help.text = dxWordWrapText(text, help.width - (circleSize / 2) - s(4), help.font, 0.5)
	help.duration = duration
	help.linkDuration = ((2000 / help.duration) / 2)
	help.managerLink = managerLink

	if duration < 3000 then
		help.managerLink = nil
	end

	if image and image.name then
		help.image = "images/icons/" .. image.name .. ".png"
	else
		help.image = "images/icons/question.png"
	end

	if image and image.colour then
		help.imageColour = image.colour
	else
		help.imageColour = {0, 0, 0}
	end

	if not help.showing then
		lastTick = getTickCount()	
		addEventHandler("onClientRender", root, drawHelp)
	end

	help.showing = true
	playSoundFrontEnd(2)
end


function drawHelp()
	delta = (getTickCount() - lastTick) / 1000
	lastTick = getTickCount()

	if help.animationProgress < 1 then
		help.animationProgress = math.min(help.animationProgress + (delta * speed), 1)

		if help.animationProgress == 1 and (help.animationState == state.grow or help.animationState == state.slideIn or help.animationState == state.slideOut or help.animationState == state.shrink) then
			help:nextState()
		end
	end

	local height = getEasingValue(help:stateAnimationProgress(state.grow), "InOutQuad") * help.height
	local xOffset = getEasingValue(help:stateAnimationProgress(state.slideIn), "InOutQuad") * help.width

	if help.animationState >= state.slideOut then
		height = (1 - getEasingValue(help:stateAnimationProgress(state.shrink), "InOutQuad")) * help.height
		xOffset = (1 - getEasingValue(help:stateAnimationProgress(state.slideOut), "InOutQuad")) * help.width
	end


	local partWidth = help.width / #help.slideBlocks
	for i = 1, #help.slideBlocks do
		if help.animationState >= state.slideIn then
			if help.slideBlocks[i] < 1 then
				help.slideBlocks[i] = math.min(help.slideBlocks[i] + (delta * speed), 1)
			end
		end

		local partHeight = help.height + ((help.height / 3) * getEasingValue(math.max(help.slideBlocks[i], 0), "SineCurve"))

		dxDrawRectangle(help.x - xOffset + ((i - 1) * partWidth), help.y - (partHeight / 2), partWidth, partHeight, colour.black)
	end

	local durationProgress = (getTickCount() - help.showTick) / help.duration
	-- draw a progress bar so you can see how long the message will be visible for
	if help.animationState == state.showing then
		dxDrawLine(help.x, help.y + (help.height / 2) - 2, help.x - xOffset + (help.width * durationProgress), help.y + (help.height / 2) - 2, tocolor(255,0,0,durationProgress * 255), 2)
	end

	-- we want the circle to be a little bigger than the rectangle so it looks nicer
	local circleSize = height + s(12)
	dxDrawImage(help.x - (circleSize / 2) - xOffset, help.y - (circleSize / 2), circleSize, circleSize, "images/class_selection/asset_white_circle.png", 0, 0, 0, tocolor(255, 255, 255, 255 * (height / help.height)))


	local imageSize = height
	local imageRot = 0

	if help.managerLink and help.animationState == state.showing and durationProgress >= (0.5 - help.linkDuration) and durationProgress <= (0.5 + help.linkDuration) then
		local n = (durationProgress - (0.5 - help.linkDuration)) / (help.linkDuration * 2)

		if n < 0.5 then
			local ease = getEasingValue(math.min(n * 6, 1), "InQuad")
			imageSize = imageSize * (1 - ease)
			imageRot = 360 * (1 - ease)
		else
			local ease = getEasingValue(math.min((1 - n) * 6, 1), "InQuad")
			imageSize = imageSize * (1 - ease)
			imageRot = 360 * (1 - ease)
		end
	end

	if help.image then
		dxDrawImage(help.x - (imageSize / 2) - xOffset, help.y - (imageSize / 2), imageSize, imageSize, help.image, imageRot, 0, 0, tocolor(help.imageColour[1], help.imageColour[2], help.imageColour[3], 255 * (imageSize / help.height)))
	end

	if help.managerLink and help.animationState == state.showing then
		local textSize = height - imageSize
		dxDrawText("press", help.x - xOffset - (textSize / 2), help.y - (height / 2) + s(10), help.x - xOffset + (textSize / 2), help.y + (height / 2), tocolor(0,0,0,255 * (textSize / help.height)), 0.5, help.font, "center", "top", true, false, false, false)
		dxDrawText("F9", help.x - xOffset - (textSize / 2), help.y - (height / 2), help.x - xOffset + (textSize / 2), help.y + (height / 2), tocolor(255,0,0,255 * (textSize / help.height)), 1, help.font, "center", "center", true, false, false, false)
		dxDrawText("for more", help.x - xOffset - (textSize / 2), help.y - (height / 2), help.x - xOffset + (textSize / 2), help.y + (height / 2) - s(10), tocolor(0,0,0,255 * (textSize / help.height)), 0.5, help.font, "center", "bottom", true, false, false, false)
	end

	dxDrawText(help.text, help.x - xOffset + (circleSize / 2) + s(2), help.y - (help.height / 2), help.x - xOffset + help.width - s(2), help.y + (help.height / 2), colour.white, 0.5, help.font, "left", "center", false, false, false, true)


	-- animate out
	if help.animationState == state.showing and (getTickCount() - help.showTick) > help.duration then
		help:nextState()
	end

	-- complete, push the next item in the queue or stop drawing
	if help.animationState == state.complete then
		if #help.queue > 0 then
			setupHelpEvent(help.queue[1].text, help.queue[1].duration, help.queue[1].managerLink, help.queue[1].image)
			table.remove(help.queue, 1)
		else
			removeEventHandler("onClientRender", root, drawHelp)
			help.showing = false	
		end
	end
end



addCommandHandler("he",
	function()
		triggerEvent("showHelpEvent", resourceRoot, "this is a message", 4000, false)
	end
)
addCommandHandler("s",
	function(cmd, s)
		playSoundFrontEnd(tonumber(s))
	end
)