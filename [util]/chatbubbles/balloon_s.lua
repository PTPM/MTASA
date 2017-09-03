local input_pla = {}

addEvent("chatbox_input", true)
addEventHandler("chatbox_input", resourceRoot, function(player, input)
	if (input) then
		input_pla[player] = true
	else
		input_pla[player] = nil
	end
end)

addEvent("get_chatbox", true)
addEventHandler("get_chatbox", resourceRoot, function(player)
	triggerClientEvent(player, "recivie_chatbox", resourceRoot, input_pla)
end)