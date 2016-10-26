addEvent("DoVendingMachineAnimation",true)
addEventHandler("DoVendingMachineAnimation",root,function(name)
	for _,player in ipairs(getElementsByType("player")) do
		if player and player ~= source then
			triggerClientEvent(player,"playVendingMachineAnimation",source,name)
		end
	end
end)


function plotMachineServer(player,machine)
	if player and machine then
		triggerClientEvent(player,"plotMachineClient",player,machine)
	else
		outputDebugString("Attempt to call plotMachineServer with invalid argument(s).")
	end
end


function disableMachineServer(player,machine)
	if player and machine then
		triggerClientEvent(player,"disableMachineClient",player,machine)
	else
		outputDebugString("Attempt to call disableMachineServer with invalid argument(s).")
	end
end


function useVendingMachineServer(player,machine)
	if player and machine then
		triggerClientEvent(player,"useVendingMachineClient",player,machine)
	else
		outputDebugString("Attempt to call useVendingMachineServer with invalid argument(s).")
	end
end	


function stopVendingMachineAnimationServer(player)
	--outputChatBox("internal: "..tostring(sourceResource).." , "..tostring(getResourceName(sourceResource)))
	if player then
		-- if being called externally we want to trigger on everyone, otherwise trigger on everyone except the source player
		if (sourceResource and sourceResource ~= getThisResource()) then
			triggerClientEvent(root,"stopVendingMachineAnimation",player,player,true)
		else
			for _,p in ipairs(getElementsByType("player")) do
				if p and p ~= player then
					triggerClientEvent(p,"stopVendingMachineAnimation",player,player)
				end
			end
		end
	else
		outputDebugString("Attempt to call stopVendingMachineAnimationServer with invalid player argument.")
	end
end	
addEvent("stopVendingMachineAnimationServer",true)
addEventHandler("stopVendingMachineAnimationServer",root,function()
	stopVendingMachineAnimationServer(source)
end)	
