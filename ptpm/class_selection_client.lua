local colours = {
	black = tocolor(0, 0, 0, 255),
	grey = tocolor(128, 128, 128, 255),
	darkGrey = tocolor(60, 60, 60, 255),
	white = tocolor(255, 255, 255, 255),

	hex = {
		pm = string.format("#%02x%02x%02x", unpack(classColours.pm)),
		bodyguard = string.format("#%02x%02x%02x", unpack(classColours.bodyguard)),
		bodyguardm = string.format("#%02x%02x%02x", unpack(classColours.bodyguardm)),
		police = string.format("#%02x%02x%02x", unpack(classColours.police)),
		policem = string.format("#%02x%02x%02x", unpack(classColours.policem)),
		terrorist = string.format("#%02x%02x%02x", unpack(classColours.terrorist)),
		terroristm = string.format("#%02x%02x%02x", unpack(classColours.terroristm)),
		psycho = string.format("#%02x%02x%02x", unpack(classColours.psycho)),
		black = string.format("#%02x%02x%02x", 0, 0, 0),
		red = string.format("#%02x%02x%02x", 255, 0, 0),
	}
}

local uiScale = screenY / 600
local font = {
	globalScalar = 1
}
local classSelection = {
	visible = false,
	hiding = false,
	spawnMessage = "",
}
local lastTick = 0
local delta = 0
local currentlySelectedPetal = nil
local currentlySelectedFlower = nil
local election = {
	active = false,
	countdown = 0,
	entered = false,
	candidates = 0,
	cleared = false,
}


addEvent("enterClassSelection", true)
addEvent("leaveClassSelection", true)
addEvent("updateClassSelection", true)
addEvent("onPlayerRequestSpawnDenied", true)
addEvent("onPlayerRequestSpawnReserved", true)
addEvent("onElectionFinished", true)
addEvent("onElectionCountdown", true)


local flowers = {
	protect = {
		x = (screenX * 0.5) - (math.min(screenX, (1000 * uiScale)) * 0.29),
		y = screenY * 0.6,
		radius = 105,
		colour = tocolor(80, 80, 207, 255),
		backgroundColour = tocolor(200, 200, 255, 255),
		defaultPetalSize = 70,
		border = {src = "images/class_selection/asset_circle_border_big.png", size = 220},
		text = {
			default = {
				top = {text = string.format("%sBodyguards%s and %sCops", colours.hex.bodyguard, colours.hex.black, colours.hex.police), size = 1.2},
				middle = {text = string.format("PROTECT"), size = 120 / 44},
				bottom = {text = string.format("the %sPrime Minister", colours.hex.pm), size = 1.2},
			}
		}
	},

	attack = {
		x = (screenX * 0.5) + (math.min(screenX, (1000 * uiScale)) * 0.29),
		y = screenY * 0.6,
		radius = 100,
		colour = tocolor(255, 0, 175, 255),
		backgroundColour = tocolor(255, 204, 239, 255),
		defaultPetalSize = 70,
		animation = {
			reversePetals = true,
		},
		border = {src = "images/class_selection/asset_circle_border_big.png", size = 220},
		text = {
			default = {
				top = {text = string.format("%sTerrorists", colours.hex.terrorist), size = 1.2},
				middle = {text = string.format("ATTACK"), size = 120 / 44},
				bottom = {text = string.format("the %sPrime Minister", colours.hex.pm), size = 1.2},
			}
		}
	},	

	psycho = {
		x = screenX * 0.5,
		y = screenY * 1,
		radius = 80,
		colour = tocolor(255, 128, 0, 255),
		backgroundColour = tocolor(255, 217, 179, 255),
		defaultPetalSize = 60,
		rotation = {
			start = -180,
			full = 180,
			offset = 0.5,
		},
		border = {src = "images/class_selection/asset_circle_border_big.png", size = 220},
		text = {
			offsetY = -0.15,
			default = {
				top = {text = string.format("%sPsychopaths", colours.hex.psycho), size = 1.1},
				middle = {text = string.format("KILL ALL"), size = 120 / 65},
			}
		}
	},

	polls = {
		x = screenX * 0.5,
		y = screenY * 1,
		radius = 80,
		colour = tocolor(255, 0, 0, 255),
		backgroundColour = tocolor(255, 222, 222, 255),
		defaultPetalSize = 60,
		rotation = {
			start = -180,
			full = 180,
			offset = 0.5,
		},
		animation = {
			burst = 1,
		},
		border = {src = "images/class_selection/asset_circle_border_big.png", size = 220},
		text = {
			offsetY = -0.2,
			default = {
				top = {text = string.format("Round\nstarts"), size = 1.1},
				middle = {text = string.format("%sSOON", colours.hex.red), size = 120 / 44},
			}
		}
	},

	pm = {
		x = screenX * 0.5,
		y = screenY * 0.19,
		radius = 75,
		colour = tocolor(unpack(classColours.pm)),
		selectedColour = tocolor(unpack(classColours.light.pm)),
		shadow = true,
		postGUI = true,
		hover = true,
		defaultPetalSize = 0,
		animation = {
			inSpeed = 0.6,
			pulse = 0,
		},
		border = {src = "images/class_selection/asset_circle_border_big.png", size = 220},
		image = "images/class_selection/ptpm-skins-147.png",
		tooltip = {
			text = "",
			default = "Enter Election",
			alpha = 0,
		}
	}
}

-- common required defaults
for _, flower in pairs(flowers) do
	if not flower.rotation then flower.rotation = {} end
	if not flower.animation then flower.animation = {} end
	if not flower.petals then flower.petals = {} end
end


addEventHandler("onClientResourceStart", resourceRoot,
	function()
		-- the default fonts do not scale well, so load our own version at the sizes we need
		font.scalar = (120 / 44) * uiScale
		font.base = dxCreateFont("fonts/tahoma.ttf", 9 * font.scalar, false, "proof")

		-- if the user cannot load the font, default to a built-in one with the appropriate scaling
		if not font.base then
			font.base = "default"
			font.scalar = 1
		end

		font.smallScalar = 1.2 * uiScale
		font.small = dxCreateFont("fonts/tahoma.ttf", 9 * font.smallScalar, false, "proof")

		if not font.small then
			font.small = "default"
			font.smallScalar = 1
		end
	end
)

-- called when the player is sent to the class selection screen
function enterClassSelection(mapName, classes, isFull, electionActive, numberOfCandidates)
	if classSelection.visible then
		if not classSelection.hiding then
			return
		end

		removeClassSelection()
	end

	if classSelection.hidingTimer then
		if isTimer(classSelection.hidingTimer) then
			killTimer(classSelection.hidingTimer)
		end
		classSelection.hidingTimer = nil
	end

	classSelection.visible = true
	classSelection.hiding = false
	classSelection.spawnMessage = "Select\nyour class"

	election.active = electionActive

	if election.active then
		election.entered = false
		election.candidates = numberOfCandidates
		election.cleared = false
	else
		onElectionFinished()
	end

	font.globalScalar = 1

	-- reset the petals
	for _, flower in pairs(flowers) do
		flower.petals = {}
		flower.petalSize = flower.defaultPetalSize
	end

	local medicDescription = string.format("%s.\nHeal other players\nwith %s/heal", colours.hex.black, colours.hex.red)

	-- create new petals from the class data
	for id, class in ipairs(classes) do
		local petal = {
			classID = id,
			classType = class.type,
			colour = tocolor(unpack(classColours[class.type .. (class.medic and "m" or "")])),
			selectedColour = tocolor(unpack(classColours.light[class.type .. (class.medic and "m" or "")])),
			animation = {
				inAnim = {"OutBack", 0, 0, 3},
				inSpeed = 2.1, 
				outSpeed = 3.6
			},
			border = {src = "images/class_selection/asset_circle_border.png", size = 112},
			image = getSkinImage(class.skin, class.mapSkinImage, mapName),
			weapons = weaponListToString(class.weapons, false, textLengthSorter),
			title = string.format("%s%s", colours.hex[class.type], teamMemberFriendlyName[class.type]),
			shadowSelected = true,
			shadowOffset = 2,
		}

		if class.medic then
			petal.title = petal.title .. string.format(" %sMedic", colours.hex[class.type .. "m"])
		end

		if class.type == "police" then
			petal.flower = flowers.protect
			petal.description = string.format("Kill the %sTerrorists", colours.hex.terrorist)
			flowers.protect.petals[#flowers.protect.petals + 1] = petal
		elseif class.type == "bodyguard" then
			petal.flower = flowers.protect
			petal.description = string.format("Protect the %sPrime Minister", colours.hex.pm)			
			flowers.protect.petals[#flowers.protect.petals + 1] = petal
		elseif class.type == "terrorist" then
			petal.flower = flowers.attack
			petal.description = string.format("Kill the %sPrime Minister", colours.hex.pm)
			flowers.attack.petals[#flowers.attack.petals + 1] = petal
		elseif class.type == "psycho" then
			petal.flower = flowers.psycho
			flowers.psycho.petals[#flowers.psycho.petals + 1] = petal
		elseif class.type == "pm" then
			flowers.pm.classID = id
		end

		if class.medic then
			petal.description = petal.description .. medicDescription
		end
	end

	updateClassSelection(isFull)

	bindKey("arrow_l", "down", scrollClassSelection, -1)
	bindKey("arrow_r", "down", scrollClassSelection, 1)
	bindKey("arrow_u", "down", scrollClassSelection, 2)
	bindKey("arrow_d", "down", scrollClassSelection, -2)
	bindKey("arrow_l", "up", scrollClassSelectionInterrupt, -1)
	bindKey("arrow_r", "up", scrollClassSelectionInterrupt, 1)
	bindKey("lshift", "down", playerClassSelectionAccept)
	bindKey("rshift", "down", playerClassSelectionAccept)
	bindKey("enter", "down", playerClassSelectionAccept)

	setPlayerHudComponentVisible("all", false)

	setupClassSelectionUI()
	lastTick = getTickCount()

	showCursor(true, true)
	addEventHandler("onClientRender", root, drawClassSelection)
end
addEventHandler("enterClassSelection", root, enterClassSelection)


-- called every time information on the screen needs updating (team availability)
function updateClassSelection(isFull, numberOfCandidates)
	if isFull then
		--toggleFull(flowers.pm, isFull.pm)
		flowers.pm.isFull = isFull.pm
		setTooltip(flowers.pm)

		for _, petal in ipairs(flowers.protect.petals) do
			if petal.classType == "bodyguard" then
				toggleFull(petal, isFull.bodyguard)
			elseif petal.classType == "police" then
				toggleFull(petal, isFull.police)
			end
		end

		for _, petal in ipairs(flowers.attack.petals) do
			if petal.classType == "terrorist" then
				toggleFull(petal, isFull.terrorist)
			end
		end	
	end

	if numberOfCandidates and tonumber(numberOfCandidates) then
		election.candidates = numberOfCandidates

		if election.entered then
			classSelection.spawnMessage = string.format("Election chance\n%s%d%%", colours.hex.red, math.floor(100 / election.candidates))
		end
	end
end
addEventHandler("updateClassSelection", root, updateClassSelection)


-- called when the player spawns in-game and leaves the class selection
function leaveClassSelection()
	showCursor(false, false)

	currentlySelectedPetal = nil
	currentlySelectedFlower = nil
	classSelection.hiding = true

	unbindKey("arrow_l", "down", scrollClassSelection)
	unbindKey("arrow_r", "down", scrollClassSelection)
	unbindKey("arrow_u", "down", scrollClassSelection)
	unbindKey("arrow_d", "down", scrollClassSelection)
	unbindKey("arrow_l", "up", scrollClassSelectionInterrupt)
	unbindKey("arrow_r", "up", scrollClassSelectionInterrupt)
	unbindKey("lshift", "down", playerClassSelectionAccept)
	unbindKey("rshift", "down", playerClassSelectionAccept)
	unbindKey("enter", "down", playerClassSelectionAccept)

	setPlayerHudComponentVisible("all", true)

	-- set up the "out" animation on the flowers and petals
	for _, flower in pairs(flowers) do
		if #flower.petals > 0 then
			local step = 1.2 / #flower.petals 

			for i, petal in ipairs(flower.petals) do
				petal.animation.inOutDir = -1

				if petal.animation.reversePetals then
					petal.animation.inOut = 0 - ((((#flower.petals + 1) - i) % #flower.petals) * step)
				else
					petal.animation.inOut = 0 - ((i - 1) * step)
				end
			end
		end

		flower.animation.inOutDir = -1
		flower.animation.inOut = 0
	end
	
	-- stop drawing once the out animation has completed
	classSelection.hidingTimer = setTimer(removeClassSelection,	1000, 1)
end
addEventHandler("leaveClassSelection", root, leaveClassSelection)

function removeClassSelection()
	removeEventHandler("onClientRender", root, drawClassSelection)
	classSelection.hiding = false
	classSelection.visible = false
end


function onElectionFinished(electedPM)
	election.active = false
	election.candidates = 0

	if election.entered and electedPM ~= localPlayer then
		classSelection.spawnMessage = "Select\nyour class"
	end

	setTooltip(flowers.pm)

	if classSelection.visible and not classSelection.hiding then
		if not election.cleared then
			-- allow the polls flower to hide before we show the psychos
			setTimer(
				function()
					if classSelection.visible and not classSelection.hiding then
						election.cleared = true
					end
				end,
			1000, 1)

			flowers.polls.animation.inOutDir = -1
			flowers.polls.animation.inOut = 0
		end
	end

	election.entered = false
end
addEventHandler("onElectionFinished", root, onElectionFinished)


function onElectionCountdown(seconds)
	election.countdown = seconds
	flowers.polls.animation.burst = 0
	flowers.polls.text.default.top.text = string.format("Round\nstarts in")
	flowers.polls.text.default.middle.text = string.format("%s%d", colours.hex.red, election.countdown)
end
addEventHandler("onElectionCountdown", root, onElectionCountdown)


-- all the setup that needs to be done once the class selection has been entered, before anything can be drawn
function setupClassSelectionUI()
	for _, flower in pairs(flowers) do	
		if #flower.petals > 0 then
			-- calculate petal size
			-- clamp between 8 and 22 petals (e.g. anything less than 8 won't get bigger, anything more than 22 won't get smaller)
			-- if we aren't using the full 360 circle, scale the value down to the correct number (e.g. 180 = (22 / 2) = 11)
			local minPetalsClamp = math.floor(8 * ((flower.rotation.full or 360) / 360))
			local maxPetalsClamp = math.floor(22 * ((flower.rotation.full or 360) / 360))

			-- clamp the petal size between 20 (min) and the default size (max)
			flower.petalSize = lerp(20, flower.petalSize, 1 - math.min(1, ((math.max(#flower.petals, minPetalsClamp) - minPetalsClamp) / (maxPetalsClamp - minPetalsClamp))))

			-- set up animation data
			-- normalise the step so every flower animates at the same speed, regardless of how many petals it has
			local step = 1.6 / #flower.petals 

			for i, petal in ipairs(flower.petals) do
				petal.animation.inOutDir = 1

				if flower.animation.reversePetals then
					petal.animation.inOut = 0 - ((((#flower.petals + 1) - i) % #flower.petals) * step)
				else
					petal.animation.inOut = 0 - ((i - 1) * step)
				end

				-- smaller petals look silly with a bigger offset
				petal.shadowOffset = flower.petalSize >= 40 and 2 or 1
			end
		end

		flower.animation.inOutDir = 1
		flower.animation.inOut = 0

		if flower.animation.pulse then
			flower.animation.pulse = 0
		end

		-- calculate shadow size based on part size
		if flower.radius >= 50 then
			flower.shadowOffset = 3
		else
			flower.shadowOffset = 2
		end
	end
end


function drawClassSelection()
	-- use the frame delta to normalised all the animation speeds
	delta = (getTickCount() - lastTick) / 1000
	lastTick = getTickCount()

	processCursorMovement()

	if not classSelection.hiding then
		dxDrawRectangle(0, 0, screenX, screenY, tocolor(0, 0, 0, 130))
	end

	drawFlower(flowers.pm)

	local height = flowers.pm.y + s(flowers.pm.radius)
	dxDrawText("The Prime Minister", flowers.pm.x - s(flowers.pm.radius * 2), height, flowers.pm.x + s(flowers.pm.radius * 2), height + s(25), colours.white, sf(120/44), font.base, "center", "top", false, false, false, false, true)
	
	if election.active then
		if election.candidates == 1 then
			dxDrawText("There is 1 candidate\nin this election", flowers.pm.x - s(flowers.pm.radius * 2), height + s(40), flowers.pm.x + s(flowers.pm.radius * 2), height + s(50), colours.white, sfs(1.2), font.small, "center", "top", false, false, false, true, false)	
		else
			dxDrawText("There are " .. tostring(election.candidates) .. " candidates\nin this election", flowers.pm.x - s(flowers.pm.radius * 2), height + s(40), flowers.pm.x + s(flowers.pm.radius * 2), height + s(50), colours.white, sfs(1.2), font.small, "center", "top", false, false, false, true, false)
		end
	end

	dxDrawText(classSelection.spawnMessage, (screenX / 2) - s(60), screenY * 0.65, (screenX / 2) + s(60), (screenY * 0.65) + s(50), colours.white, sf(2.0), font.base, "center", "top", false, false, false, true, false)

	drawFlower(flowers.protect)
	drawFlower(flowers.attack)

	if election.cleared then
		drawFlower(flowers.psycho)
	else
		drawFlower(flowers.polls)
	end

	if classSelection.hiding then
		font.globalScalar = math.max(0, font.globalScalar - (2.4 * delta))
	end
end


function drawFlower(flower)
	-- step is the distance between each petal
	local step = (flower.rotation.full or 360) / math.max(#flower.petals, 1)

	for i, petal in ipairs(flower.petals) do
		if not petal.x or not petal.y then
			petal.x, petal.y = getPointOnCircle(s(flower.radius + 28) - s((70 / flower.petalSize) * 5), ((i - 1) * step) + (flower.rotation.start or -90) + ((flower.rotation.offset or 0) * step))
		end

		drawPart(petal, flower.x + petal.x, flower.y + petal.y, flower.petalSize / 2)
	end

	drawPart(flower, flower.x, flower.y, flower.radius)
	return
end

-- part is either a flower or a petal
function drawPart(part, x, y, radius)
	local drawRadius = radius
	
	-- apply the in/out animation
	if part.animation.inOutDir == 1 then
		--size = getEasingValue(math.max(0, petal.animation.inOut), "OutBack", 0, 0, 3) * flower.petalSize
		drawRadius = getEasingValue(math.max(0, part.animation.inOut), unpack(part.animation.inAnim or {"OutElastic", 0.3, 1.0})) * radius
	elseif part.animation.inOutDir == -1 then
		drawRadius = (1 - getEasingValue(math.max(0, part.animation.inOut), "InBack", 0.3, 1.0)) * radius
	end

	if part.animation.inOut < 1 then
		local speed = (part.animation.inOutDir == 1) and (part.animation.inSpeed or 1) or (part.animation.outSpeed or 2.4)
		part.animation.inOut = math.min(part.animation.inOut + (speed * delta), 1)
	end

	-- grow a little if we are hovered
	if part.isSelected and not classSelection.hiding then
		drawRadius = drawRadius + 10
	end	

	-- apply the active custom animations
	if part.animation.burst and part.animation.burst < 1 then
		drawRadius = drawRadius + (getEasingValue(math.max(0, part.animation.burst), "SineCurve") * 10)
		part.animation.burst = (part.animation.burst + (4.5 * delta))
	end

	if not part.isSelected and part.animation.pulse then
		drawRadius = drawRadius + (getEasingValue(math.max(0, part.animation.pulse), "SineCurve") * 4)
		part.animation.pulse = (part.animation.pulse + (0.36 * delta)) % 1
	end

	drawRadius = s(drawRadius)
	part.drawRadius = drawRadius

	if drawRadius > 0 and (part.animation.inOutDir ~= -1 or part.animation.inOut < 1) then
		-- todo: calculate the border image based on the size of the part
		-- draw a drop shadow underneath the whole part
		if part.shadow or (part.shadowSelected and part.isSelected) then
			dxDrawImage(x - drawRadius - 1, y - drawRadius - 1 + 4, (drawRadius + 1) * 2, (drawRadius + 1) * 2, part.border.src, 0, 0, 0, colours.black, part.postGUI)	
		end	

		local backgroundColour = part.isSelected and part.selectedColour or part.backgroundColour
		if part.isFull then
			backgroundColour = colours.darkGrey
		end

		-- draw the main background circle (plain white)
		dxDrawImage(x - drawRadius, y - drawRadius, drawRadius * 2, drawRadius * 2, "images/class_selection/asset_white_circle.png", 0, 0, 0, backgroundColour or colours.white, part.postGUI)			

		-- draw the central image (for petals and pm this is the skin image)
		if part.image then
			local imageOffset = 0

			-- move the central image down a little to simulate being pressed in
			if part.isSelected and part.isPressed and not part.isFull then
				imageOffset = s(2)
			end

			dxDrawImage(x - drawRadius + s(1), y - drawRadius + s(1) + imageOffset, (drawRadius * 2) - s(2), (drawRadius * 2) - s(2), part.image, 0, 0, 0, part.isFull and colours.darkGrey or colours.white, part.postGUI)	
		end

		-- draw shaded edges to simulate being pressed in
		if part.isSelected and not part.isFull then
			if part.isPressed then
				dxDrawImageSection(x - drawRadius - s(2), y - drawRadius - s(2) + s(part.shadowOffset or 1), (drawRadius + s(2)) * 2, drawRadius + s(2), 0, 0, part.border.size, part.border.size / 2, part.border.src, 0, 0, 0, colours.black, part.postGUI)
			else
				dxDrawImageSection(x - drawRadius - s(2), y - s(part.shadowOffset or 1), (drawRadius + s(2)) * 2, drawRadius + s(2), 0, part.border.size / 2, part.border.size, part.border.size / 2, part.border.src, 0, 0, 0, colours.black, part.postGUI)
			end
		end

		-- draw the main circle border over the other images
		dxDrawImage(x - drawRadius - s(2), y - drawRadius - s(2), (drawRadius + s(2)) * 2, (drawRadius + s(2)) * 2, part.border.src, 0, 0, 0, part.colour, part.postGUI)	

		-- only draw the text we actually have
		if part.text and (part.text.override or part.text.default) then
			local textData = part.text.override or part.text.default

			local offsetY = s(part.text.offsetY or 0) * radius

			if textData.top then
				dxDrawText(textData.top.text, x - s(radius - 20), y - s(radius - 20) + offsetY, x + s(radius - 20), y - s(15) + offsetY, colours.black, sfs(textData.top.size), font.small, "center", "bottom", false, false, false, true, false)	
			end

			if textData.middle then
				dxDrawText(textData.middle.text, x - radius, y - s(radius - 20) + offsetY, x + radius, y + s(radius - 20) + offsetY, colours.black, sf(textData.middle.size), font.base, "center", "center", false, false, false, true, false)	
			end	

			if textData.bottom then
				dxDrawText(textData.bottom.text, x - s(radius - 20), y + s(15) + offsetY, x + s(radius - 20), y + s(radius - 20) + offsetY, colours.black, sfs(textData.bottom.size), font.small, "center", "top", false, false, false, true, false)	
			end	
		end

		if part.tooltip then
			if part.isSelected then
				drawTooltip(x, y, s(radius), part.tooltip)
			else
				if part.tooltip.alpha > 0 then
					part.tooltip.alpha = 0
				end
			end
		end
	end
end


function drawTooltip(centerX, centerY, radius, data)
	-- calculate the tooltip size the first time it is drawn (if we haven't already)
	if not data.width or not tonumber(data.width) then
		data.width = math.max(dxGetTextWidth(data.text, sfs(1.2), font.small, false) + 15, 45)
	end

	if not data.height or not tonumber(data.height) then
		data.height = dxGetFontHeight(sfs(1.2), font.small) + 2
	end

	dxDrawImage(centerX - (data.width / 2), centerY + (radius * 0.65), data.width, data.height, "images/class_selection/asset_choosebutton_neutral.png", 0, 0, 0, tocolor(0, 0, 0, data.alpha * 255), true)
	dxDrawText(data.text, centerX - (data.width / 2), centerY + (radius * 0.65), centerX + (data.width / 2), centerY + (radius * 0.65) + data.height, tocolor(255, 255, 255, data.alpha * 255), sfs(1.2), font.small, "center", "center", false, false, true, false, false)

	if data.alpha < 1 then
		data.alpha = math.min(data.alpha + 0.06, 1)
	end
end


local skinImages = {[100] = true, [111] = true, [137] = true, [141] = true, [147] = true, [163] = true, [164] = true, [165] = true, [166] = true, [179] = true, [181] = true, 
[183] = true, [191] = true, [200] = true, [212] = true, [230] = true, [246] = true, [274] = true, [275] = true, [276] = true, [280] = true, [281] = true, [282] = true, 
[283] = true, [284] = true, [285] = true, [286] = true, [288] = true, [73] = true}
function getSkinImage(skin, mapSkinImage, mapName)
	if skinImages[skin] then
		return "images/class_selection/ptpm-skins-" .. tostring(skin) .. ".png"
	end

	if mapSkinImage and mapName then
		return ":" .. mapName .. "/ptpm-skins-" .. tostring(skin) .. ".png"
	end

	-- default (unknown) skin
	return "images/class_selection/ptpm-skins-unknown.png"
end


function processCursorMovement()
	for _, flower in pairs(flowers) do
		for _, petal in ipairs(flower.petals) do
			petal.lastHovered = petal.isHovered

			if not petal.x or not petal.y or not petal.drawRadius then
				petal.isHovered = false
			else
				petal.isHovered = isMouseOver(flower.x + petal.x, flower.y + petal.y, petal.drawRadius)

				if not petal.lastHovered and petal.isHovered then
					onPetalEnter(flower, petal)
				elseif petal.lastHovered and not petal.isHovered then
					onPetalLeave(flower, petal)
				end
			end
		end

		flower.lastHovered = flower.isHovered

		if not flower.x or not flower.y or not flower.drawRadius then
			flower.isHovered = false
		else
			flower.isHovered = isMouseOver(flower.x, flower.y, flower.drawRadius)

			if not flower.lastHovered and flower.isHovered then
				onFlowerEnter(flower)
			elseif flower.lastHovered and not flower.isHovered then
				onFlowerLeave(flower)
			end
		end
	end
end

-- left/right arrows down (left -1, right 1)
function scrollClassSelection(key, state, dir)
	if scrollTimer then
		if isTimer(scrollTimer) then
			killTimer(scrollTimer)
		end
		scrollTimer = nil
	end

	if dir == 1 or dir == -1 then
		scrollTimer = setTimer(scrollClassSelection, 300, 0, key, state, dir)
	end

	-- if we have nothing selected, default to pm
	if not currentlySelectedPetal and not currentlySelectedFlower then
		if dir == -1 or dir == -2 then
			onPetalEnter(flowers.protect, flowers.protect.petals[1])
		else
			onPetalEnter(flowers.attack, flowers.attack.petals[1])
		end

		return
	end

	-- holding ctrl lets you jump between flowers
	if getKeyState("lctrl") or getKeyState("rctrl") then
		local nextFlower = nil

		if dir == 1 then
			if getSelectedFlower() == flowers.protect then
				nextFlower = flowers.pm
			elseif getSelectedFlower() == flowers.pm or getSelectedFlower() == flowers.psycho then
				nextFlower = flowers.attack
			end
		elseif dir == -1 then
			if getSelectedFlower() == flowers.attack then
				nextFlower = flowers.pm
			elseif getSelectedFlower() == flowers.pm or getSelectedFlower() == flowers.psycho then
				nextFlower = flowers.protect
			end
		elseif dir == 2 then
			if getSelectedFlower() == flowers.psycho or getSelectedFlower() == flowers.attack or getSelectedFlower() == flowers.protect then
				nextFlower = flowers.pm
			end
		elseif dir == -2 and election.cleared then
			if getSelectedFlower() == flowers.pm or getSelectedFlower() == flowers.attack or getSelectedFlower() == flowers.protect then
				nextFlower = flowers.psycho
			end
		end

		if nextFlower then
			outputDebugString("moving: flower: " .. tostring(currentlySelectedFlower ~= nil) .. ", petal: " .. tostring(currentlySelectedPetal ~= nil))
			if nextFlower == flowers.pm then
				onFlowerEnter(nextFlower)
			else
				onPetalEnter(nextFlower, nextFlower.petals[1])
			end
		end

		return
	end

	-- without holding ctrl, up/down do nothing
	if dir == 2 or dir == -2 then
		return
	end

	-- find and select the next petal on the flower
	for _, flower in pairs(flowers) do
		for i, petal in ipairs(flower.petals) do
			if petal == currentlySelectedPetal then
				onPetalLeave(flower, petal)

				local nextIndex = (i % #flower.petals) + dir

				if nextIndex <= 0 then
					nextIndex = #flower.petals + nextIndex
				end

				onPetalEnter(flower, flower.petals[nextIndex])
				return
			end
		end
	end
end

-- left/right arrows up
function scrollClassSelectionInterrupt(key, state, dir)
	if scrollTimer then
		if isTimer(scrollTimer) then
			killTimer(scrollTimer)
		end
		scrollTimer = nil
	end
end

-- enter and shift
function playerClassSelectionAccept()
	if currentlySelectedFlower then
		chooseFlower(currentlySelectedFlower)
		return
	end

	if currentlySelectedPetal then
		choosePetal(currentlySelectedPetal)
		return
	end
end

function getSelectedFlower()
	if currentlySelectedFlower then
		return currentlySelectedFlower
	end

	if currentlySelectedPetal then
		return currentlySelectedPetal.flower
	end

	return
end

function onPetalEnter(flower, petal)
	if currentlySelectedPetal and currentlySelectedPetal ~= petal then
		onPetalLeave(currentlySelectedPetal.flower, currentlySelectedPetal)
	end

	if currentlySelectedFlower then
		onFlowerLeave(currentlySelectedFlower)
	end

	outputDebugString("petal enter: " .. tostring(petal.classID))
	flower.text.override = {
			top = {text = petal.weapons, size = 1.1},
			middle = {text = petal.title, size = 1.5}
		}

	if flower == flowers.psycho then
		flower.text.override.top.size = 0.85 
	end

	if petal.description then
		flower.text.override.bottom = {text = petal.description, size = 1.1}
	end

	currentlySelectedPetal = petal
	petal.isSelected = true
end

function onPetalLeave(flower, petal)
	outputDebugString("petal leave: " .. tostring(petal.classID))
	petal.isPressed = false
	petal.isSelected = false

	if currentlySelectedPetal == petal then
		flower.text.override = nil
		currentlySelectedPetal = nil
	end
end

function onFlowerEnter(flower)
	if flower.hover then
		if currentlySelectedPetal then
			onPetalLeave(currentlySelectedPetal.flower, currentlySelectedPetal)
		end

		outputDebugString("flower enter")
		flower.isSelected = true
		currentlySelectedFlower = flower
	end
end

function onFlowerLeave(flower)
	outputDebugString("flower leave")
	flower.isPressed = false
	flower.isSelected = false
	currentlySelectedFlower = nil
end

function isMouseOver(x, y, radius)
	local cX, cY = getCursorPosition()

	if not cX or not cY then
		return false
	end

	return getDistanceBetweenPoints2D(x, y, cX * screenX, cY * screenY) < radius
end

function processCursorClicks(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if button ~= "left" then
		return
	end

	for _, flower in pairs(flowers) do
		for _, petal in ipairs(flower.petals) do
			if petal.isHovered then
				if state == "down" then
					petal.isPressed = true
				elseif state == "up" then
					petal.isPressed = false
					choosePetal(petal)
				end

				-- only let one be used at once
				return
			end
		end

		if flower.isHovered then
			if state == "down" then
				flower.isPressed = true
			elseif state == "up" then
				flower.isPressed = false
				chooseFlower(flower)
			end
			return
		end
	end
end
addEventHandler("onClientClick", root, processCursorClicks)

function choosePetal(petal)
	if petal.isFull then
		return
	end

	outputChatBox("Chosen " .. tostring(petal.title))

	triggerServerEvent("onPlayerRequestSpawn", resourceRoot, petal.classID)
end

function chooseFlower(flower)
	if flower == flowers.pm then
		if flower.isFull then
			return
		end

		outputChatBox("Chosen pm")

		triggerServerEvent("onPlayerRequestSpawn", resourceRoot, flowers.pm.classID)
	else
		outputChatBox("Chosen unknown flower")
	end
end

function onPlayerRequestSpawnDenied(classID)
	-- this should only happen very rarely, but it's a nice failsafe to enforce the reason why they couldn't spawn
	for _, flower in pairs(flowers) do
		if flower.classID == classID then
			toggleFull(flower, true)
		end

		for _, petal in ipairs(flower.petals) do
			if petal.classID == classID then
				toggleFull(petal, true)
				return
			end
		end
	end
end
addEventHandler("onPlayerRequestSpawnDenied", root, onPlayerRequestSpawnDenied)

function onPlayerRequestSpawnReserved(classID, withdrawn)
	outputDebugString("request spawn " .. tostring(classID) .. " " .. tostring(withdrawn and "withdrawn" or ""))
	classSelection.spawnMessage = "Select\nyour class"

	if classes[classID] == "pm" then
		election.entered = not withdrawn

		setTooltip(flowers.pm)

		if not withdrawn then
			-- force the spawn message to update
			updateClassSelection(nil, election.candidates)
		end
	else
		if not withdrawn then
			local petal = getPetalFromClassID(classID)

			if petal then
				classSelection.spawnMessage = string.format("Spawning as\n%s", petal.title)
			end
		end
	end
end
addEventHandler("onPlayerRequestSpawnReserved", root, onPlayerRequestSpawnReserved)

-- part can be a petal or flower
function toggleFull(part, full)
	part.isFull = full

	if full then		
		setTooltip(part, "Full")
	else
		if part.tooltip and part.tooltip.default then
			setTooltip(part, part.tooltip.default)
		else
			part.tooltip = nil
		end
	end
end

function setTooltip(part, text)
	if part == flowers.pm then
		text = getPMTooltipText()
	end

	part.tooltip = part.tooltip or {}
	part.tooltip.text = text
	part.tooltip.alpha = 0
	part.tooltip.width = nil
end

function getPMTooltipText()
	if flowers.pm.isFull then
		return "Full"
	elseif election.entered then
		return "Withdraw"
	elseif not election.active then
		return "Spawn"
	end

	return "Enter Election"
end

function lerp(startValue, endValue, t)
	return startValue + ((endValue - startValue) * t)
end

-- scale
function s(value)
	return value * uiScale
end

-- scaleFont
function sf(value)
	return ((value * uiScale) / font.scalar) * font.globalScalar
end

-- scaleFontSmall
function sfs(value)
	return ((value * uiScale) / font.smallScalar) * font.globalScalar
end

function getPointOnCircle(radius, rotation)
	return radius * math.cos(math.rad(rotation)), radius * math.sin(math.rad(rotation))
end

function textLengthSorter(a, b)
	return dxGetTextWidth(a, sfs(1.1), font.small) < dxGetTextWidth(b, sfs(1.1), font.small)
end

function getPetalFromClassID(classID)
	for _, flower in pairs(flowers) do
		for _, petal in ipairs(flower.petals) do
			if petal.classID == classID then
				return petal
			end
		end
	end
end

addCommandHandler("reset",
	function()
		setupClassSelectionUI()
	end
)

addCommandHandler("scale", 
	function(command, s)
		uiScale = tonumber(s)
	end
)

addCommandHandler("hide", 
	function(command)
		leaveClassSelection()
	end
)