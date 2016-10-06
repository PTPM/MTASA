antiflood = {}
antiflood.timeBetweenMsg = get("timeBetweenMsg") or 2
antiflood.LastMessage = {}

addEventHandler("onSettingChange", getRootElement(), function(setting, oldV, newV)
	local resName = getResourceName(getThisResource())
	if setting == "*"..resName..".timeBetweenMsg" then
		antiflood.timeBetweenMsg = newV
	end
end)

addEventHandler("onPlayerChat", root, function()
	local timeBetweenMsg = (antiflood.timeBetweenMsg)*1000
	if antiflood.LastMessage[source] and ((antiflood.LastMessage[source]+timeBetweenMsg)>getTickCount()) then
		outputChatBox("Stop spamming the chat!", source, 255, 0, 0)
		cancelEvent()
	end
	antiflood.LastMessage[source] = getTickCount()
end)