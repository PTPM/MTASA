addEventHandler("onClientPlayerDamage", getRootElement(), function()
	if getElementData(source, "antispawnkill") then
		cancelEvent()
	end
end)
