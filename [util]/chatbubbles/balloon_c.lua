local UPDATE_TIME = 500 -- This is the interval controls the amount of time that a player recivies the table with the players with chatbox opened
local CHECK_TIME = 500 -- this is the interval that checks if player has chatbox active or not
local screenW, screenH = guiGetScreenSize()
local imaW = 64 --NOTE: Set here the bubble size
local imaH = 64

local my_player_list = {}
local isChatOpen = false

setTimer(function()
	if (isChatBoxInputActive() or isConsoleActive()) and (isChatOpen == false) then
		isChatOpen = true
		triggerServerEvent("chatbox_input", resourceRoot, localPlayer, true)
	elseif not (isChatBoxInputActive() or isConsoleActive()) and (isChatOpen == true) then
		isChatOpen = false
		triggerServerEvent("chatbox_input", resourceRoot, localPlayer, false)
	end
end, CHECK_TIME, 0)

addEventHandler("onClientRender", root, function()
	local me_x, me_y, me_z = getElementPosition(localPlayer)
	for i, v in pairs(my_player_list) do
		if (v) then
			local you_x, you_y, you_z = getElementPosition(i)
			local dist = getDistanceBetweenPoints3D(me_x, me_y, me_z, you_x, you_y, you_z)
			local x, y = getScreenFromWorldPosition(you_x, you_y, you_z + 1)
			if (x) and (y) then
				local multi = 1/dist
				if (multi > 1) then multi = 1 end
				local imgW = multi * imaW
				local imgH = multi * imaH
				if (dist < 30) then
					dxDrawImage(x - (imgW/2), y - (imgH/2), imgW, imgH, "bubble.png")
				end
			end
		end
	end
end)

--Used a timer with 50 ms of delay to recivie the table with the input enabled (didn't use "onClientRender" cause it might provoke lag)
setTimer(triggerServerEvent, UPDATE_TIME, 0, "get_chatbox", resourceRoot, localPlayer)

addEvent("recivie_chatbox", true)
addEventHandler("recivie_chatbox", resourceRoot, function(tab)
	my_player_list = tab
end)