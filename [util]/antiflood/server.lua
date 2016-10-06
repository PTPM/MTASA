antiflood = {}
antiflood.timeBetweenMsg = get("timeBetweenMsg") or 2
antiflood.maxWarnings = get("maxWarnings") or 3
antiflood.LastMessage = {}
antiflood.Warnings = {}

addEventHandler("onSettingChange", getRootElement(), function(setting, oldV, newV)
	local resName = getResourceName(getThisResource())
	if setting == "*"..resName..".timeBetweenMsg" then
		antiflood.timeBetweenMsg = newV
	elseif setting == "*"..resName..".maxWarnings" then
		antiflood.maxWarning = newV
	end
end)

addEventHandler("onPlayerChat", root, function()
	local timeBetweenMsg = (antiflood.timeBetweenMsg)*1000
	if antiflood.LastMessage[source] and ((antiflood.LastMessage[source]+timeBetweenMsg)>getTickCount()) then
		if antiflood.Warnings[source] and antiflood.Warnings[source] == antiflood.maxWarnings then
			outputChatBox("Stop spamming the chat!", source, 255, 0, 0)
			cancelEvent()
		else
			if not antiflood.Warnings[source] then
				antiflood.Warnings[source] = 1
			else
				antiflood.Warnings[source] = antiflood.Warnings[source]+1
			end
		end
	else
		antiflood.Warnings[source] = 0
	end
	antiflood.LastMessage[source] = getTickCount()
end)

addEventHandler("onPlayerQuit", root, function()
	antiflood.LastMessage[source] = false
	antiflood.Warnings[source] = false
end)
