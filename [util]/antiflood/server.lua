antiflood = {
	settings = {
		timeBetweenMsg = get("timeBetweenMsg") or 2000,
		maxWarnings = get("maxWarnings") or 3,
		repetitionTimeout = get("repetitionTimeout") or 8000,
	},

	lastMessage = {},
	lastMessageContent = {},
	warnings = {},
	incidences = {},
	muteTimers = {},
	msBetweenMessages = 0
}

addEvent("onPlayerFloodPunished", false)
addEvent("onPlayerFloodAbsolved", false)

addEventHandler("onResourceStart", resourceRoot,
	function()
		antiflood.msBetweenMessages = antiflood.settings.timeBetweenMsg
	end
)

addEventHandler("onSettingChange", root, 
	function(setting, oldV, newV)
		local resName = getResourceName(getThisResource())

		if setting == "*"..resName..".timeBetweenMsg" then
			antiflood.settings.timeBetweenMsg = fromJSON(newV)
			antiflood.msBetweenMessages = antiflood.settings.timeBetweenMsg
		elseif setting == "*"..resName..".maxWarnings" then
			antiflood.settings.maxWarnings = fromJSON(newV)
		end
	end
)

function shouldAllowMessage(player, messageContent)
	if isPlayerMuted(player) then
		return false, false
	end

	-- Anti repetition
	if (antiflood.lastMessageContent[player] and antiflood.lastMessageContent[player]==messageContent and ((antiflood.lastMessage[player] + antiflood.settings.repetitionTimeout) > getTickCount())) then
		-- Don't allow the message to go through, but don't punish for it either
		return false, false
	end
	
	-- Anti flood
	if antiflood.lastMessage[player] and ((antiflood.lastMessage[player] + antiflood.msBetweenMessages) > getTickCount()) then
		if antiflood.warnings[player] and antiflood.warnings[player] >= antiflood.settings.maxWarnings then
			antiflood.incidences[player] = antiflood.incidences[player] and antiflood.incidences[player] + 1 or 1
			antiflood.warnings[player] = 0

			punish(player)

			return false, true
		else
			if not antiflood.warnings[player] then
				antiflood.warnings[player] = 1
			else
				antiflood.warnings[player] = antiflood.warnings[player] + 1
			end
		end
	else
		antiflood.warnings[player] = 0
	end

	antiflood.lastMessage[player] = getTickCount()
	antiflood.lastMessageContent[player] = messageContent

	return true
end

addEventHandler("onPlayerQuit", root, 
	function()
		antiflood.lastMessage[source] = nil
		antiflood.warnings[source] = nil
		antiflood.incidences[source] = nil
		killMuteTimer(source)
	end
)

function punish(player) 
	if not antiflood.incidences[player] then
		return
	end

	if antiflood.incidences[player] == 1 then
		setPlayerMuted(player, true, 30)

		triggerEvent("onPlayerFloodPunished", root, player, { punishment = "mute", length = 30 })
	elseif antiflood.incidences[player] == 2 then
		setPlayerMuted(player, true, 60)

		triggerEvent("onPlayerFloodPunished", root, player, { punishment = "mute", length = 60 })
	elseif antiflood.incidences[player] >= 3 then
		local playerName = getPlayerName(player)
		kickPlayer(player, "Repeated flooding")

		triggerEvent("onPlayerFloodPunished", root, playerName, { punishment = "kick" })
	end	
end

-- wrap setPlayerMuted with our own version
_setPlayerMuted = setPlayerMuted
function setPlayerMuted(player, muted, length)
	_setPlayerMuted(player, muted)

	killMuteTimer(player)

	if muted then
		antiflood.muteTimers[player] = setTimer(
			function(victim, len)
				if victim and isElement(victim) then
					triggerEvent("onPlayerFloodAbsolved", root, victim, { punishment = "mute", length = len })
					setPlayerMuted(victim, false)
				end
			end, 
		length * 1000, 1, player, length)	
	end
end


function killMuteTimer(player)
	if not antiflood.muteTimers[player] then
		return
	end

	if isTimer(antiflood.muteTimers[player]) then
		killTimer(antiflood.muteTimers[player])
	end

	antiflood.muteTimers[player] = nil
end