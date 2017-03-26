local defaultColour = string.format("#%02x%02x%02x", 255, 100, 100)
local joinColour = string.format("#%02x%02x%02x", 255, 150, 150)

local cache = {
	enabled = true,
	messages = {},
	stripColours = true
}

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		if cache.enabled then
			setTimer(outputMessageCache, 1000, 0)
		end
	end
)

addEventHandler('onClientPlayerJoin', root,
	function()
		if cache.enabled then
			table.insert(cache.messages, joinColour .. getColorStrippedPlayerName(source) .. " joined")
		else
			outputChatBox('* ' .. getColorStrippedPlayerName(source) .. ' has joined the game', 255, 100, 100)
		end
	end
)

addEventHandler('onClientPlayerChangeNick', root,
	function(oldNick, newNick)
		outputChatBox('* ' .. oldNick .. ' is now known as ' .. newNick, 255, 100, 100)
	end
)

addEventHandler('onClientPlayerQuit', root,
	function(reason)
		if cache.enabled then
			-- kicks and bans bypass the cache
			if reason ~= "Kicked" and reason ~= "Banned" then
				table.insert(cache.messages, defaultColour .. getColorStrippedPlayerName(source) .. " left (" .. reason .. ")")
			else
				-- Kick and Ban messages are handled server side, because onClientPlayerQuit does not pass the actual reason, it passes the quitType and calls that "reason"
			end
		else
			outputChatBox('* ' .. getColorStrippedPlayerName(source) .. ' has left the game (' .. reason .. ')', 255, 100, 100)
		end
	end
)


function outputMessageCache()
	if #cache.messages == 0 then
		return
	end

	local output = "* "

	for _, message in ipairs(cache.messages) do
		if #output + #message > 256 then
			outputChatBox(output, 255, 100, 100, true)
			output = "* "
		end

		output = output .. (#output == 2 and "" or ", ") .. message
	end

	outputChatBox(output, 255, 100, 100, true)

	cache.messages = {}
end

function getColorStrippedPlayerName(element)
	if cache.stripColours then
		return stripColourCodes(getPlayerName(element))
	else
		return getPlayerName(element)
	end
end

function stripColourCodes(s)
	local strippedString = s
	local substitutions = 0

	while true do
		strippedString, substitutions = string.gsub(strippedString, "#%x%x%x%x%x%x", "")

		if substitutions == 0 then
			break
		end
	end

	return strippedString
end