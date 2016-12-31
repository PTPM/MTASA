local defaultColour = string.format("#%02x%02x%02x", 255, 100, 100)
local joinColour = string.format("#%02x%02x%02x", 255, 150, 150)

local cache = {
	enabled = true,
	messages = {}
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
			table.insert(cache.messages, joinColour .. getPlayerName(source) .. " joined")
		else
			outputChatBox('* ' .. getPlayerName(source) .. ' has joined the game', 255, 100, 100)
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
			if reason == "Kicked" or reason == "Banned" then
				outputChatBox('* ' .. getPlayerName(source) .. ' left [' .. reason .. ']', 255, 100, 100)
			else
				table.insert(cache.messages, defaultColour .. getPlayerName(source) .. " left [" .. reason .. "]")
			end
		else
			outputChatBox('* ' .. getPlayerName(source) .. ' has left the game [' .. reason .. ']', 255, 100, 100)
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