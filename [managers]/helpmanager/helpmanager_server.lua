addEvent("onClientHelpManagerReady", true)

addEventHandler("onClientHelpManagerReady", root,
	function()
		triggerClientEvent(client, "sendHelpManagerSettings", client, get("defaultTabName"))
	end
)

function showHelp(element)
	return triggerClientEvent(element, "doShowHelp", root)
end

function hideHelp(element)
	return triggerClientEvent(element, "doHideHelp", root)
end