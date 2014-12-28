verifySerials = true
verifyCommunity = false

local searchMatches = nil
local currentMatch = 1

addEvent( "onClientAvailable", true )

--addEventHandler( "onClientResourceStart", resourceRoot,
addEventHandler( "onClientAvailable", localPlayer,
	function()
		local sx,sy = guiGetScreenSize()
	
		bansWindow = {}
		
		bansWindow.window = guiCreateWindow(sx/2 - 406,sy/2 - 200,812,395,"Bans",false)
		
		bansWindow.gridlist = guiCreateGridList(9,29,677,322,false,bansWindow.window)
		guiGridListSetSelectionMode(bansWindow.gridlist,2)
		guiGridListAddColumn(bansWindow.gridlist,"Name",0.12)
		guiGridListAddColumn(bansWindow.gridlist,"IP",0.12)
		guiGridListAddColumn(bansWindow.gridlist,"Reason",0.25)
		guiGridListAddColumn(bansWindow.gridlist,"Admin",0.12)
		guiGridListAddColumn(bansWindow.gridlist,"Username",0.12)
		guiGridListAddColumn(bansWindow.gridlist,"Serial",0.2)
		guiGridListAddColumn(bansWindow.gridlist,"Date/Time",0.3)
		guiGridListSetSelectionMode(bansWindow.gridlist,0)
		
		bansWindow.search = guiCreateEdit(9,359,457,26,"Search...",false,bansWindow.window)
		bansWindow.findnext = guiCreateButton(474,361,94,22,"Find next",false,bansWindow.window)
		bansWindow.ban_label = guiCreateLabel(699,30,96,21,"Ban:",false,bansWindow.window)
		guiLabelSetColor(bansWindow.ban_label,255,000,000)
		guiLabelSetVerticalAlign(bansWindow.ban_label,"top")
		guiLabelSetHorizontalAlign(bansWindow.ban_label,"left",false)
		
		bansWindow.ban_player = guiCreateButton(699,51,94,22,"Player",false,bansWindow.window)
		bansWindow.ban_ip = guiCreateButton(699,81,94,22,"IP",false,bansWindow.window)
		bansWindow.ban_serial = guiCreateButton(699,111,94,22,"Serial",false,bansWindow.window)	
		bansWindow.ban_username = guiCreateButton(699,141,94,22,"Username",false,bansWindow.window)
		bansWindow.unban_label = guiCreateLabel(699,206,93,21,"Unban:",false,bansWindow.window)
		guiLabelSetColor(bansWindow.unban_label,255,0,0)
		guiLabelSetVerticalAlign(bansWindow.unban_label,"top")
		guiLabelSetHorizontalAlign(bansWindow.unban_label,"left",false)
		
		bansWindow.unban_selected = guiCreateButton(699,230,94,22,"Selected",false,bansWindow.window)
		bansWindow.unban_ip = guiCreateButton(699,260,94,22,"IP",false,bansWindow.window)
		bansWindow.unban_nickname = guiCreateButton(699,290,94,22,"Nickname",false,bansWindow.window)
		bansWindow.refresh = guiCreateButton(592,361,94,22,"Refresh",false,bansWindow.window)	
		bansWindow.close = guiCreateButton(699,361,94,22,"Close",false,bansWindow.window)
		guiSetVisible(bansWindow.window, false)	
		guiWindowSetSizable(bansWindow.window, false)
		guiGridListSetSortingEnabled(bansWindow.gridlist,false)
		
		local bansInput = {}
		bansInput.window = guiCreateWindow(sx/2 - 150,sy/2 - 75,299,151,"",false)
		bansInput.label = guiCreateLabel(8,19,278,51,"Enter the name (or part of the name) of the player you want to ban.",false,bansInput.window)
		guiLabelSetColor(bansInput.label,255,000,000)
		guiLabelSetVerticalAlign(bansInput.label,"center")
		guiLabelSetHorizontalAlign(bansInput.label,"center",true)
		bansInput.edit = guiCreateEdit(10,80,280,24,"",false,bansInput.window)
		bansInput.accept = guiCreateButton(10,115,95,23,"Accept",false,bansInput.window)
		guiSetProperty(bansInput.accept,"PushedTextColour","FFFF0000")
		guiSetProperty(bansInput.accept,"HoverTextColour","FFFF0000")
		bansInput.cancel = guiCreateButton(195,115,95,23,"Cancel",false,bansInput.window)
		guiSetProperty(bansInput.cancel,"PushedTextColour","FFFF0000")
		guiSetProperty(bansInput.cancel,"HoverTextColour","FFFF0000")
		guiSetVisible(bansInput.window, false)
		guiWindowSetSizable(bansInput.window, false)

		
		-- ban window
		if not verifySerials then
			guiSetEnabled(bansWindow.ban_serial,false)
		end
		
		if not verifyCommunity then
			guiSetEnabled(bansWindow.ban_username,false)
		end
		
		addEventHandler("onClientGUIClick",bansWindow.close,function()
			guiSetVisible(bansWindow.window, false)
			showCursor(false,false)
			searchMatches = nil
			currentMatch = 1
		end,false)
		
		addEventHandler("onClientGUIClick",bansWindow.refresh,function()
			triggerServerEvent("getServerBans", localPlayer)
		end,false)
		
		addEventHandler("onClientGUIClick",bansWindow.search,function()
			if guiGetText(bansWindow.search) == "Search..." then
				guiSetText(bansWindow.search,"")
			end
		end,false)
		
		addEventHandler("onClientGUIClick",bansWindow.findnext,function()
			if guiGetText(bansWindow.search) ~= "" then
				triggerServerEvent("searchBans", localPlayer,guiGetText(bansWindow.search))
			else
				if searchMatches then
					currentMatch = (currentMatch + 1) % (#searchMatches + 1)
					if currentMatch == 0 then currentMatch = 1 end
					
					guiGridListSetSelectedItem(bansWindow.gridlist,searchMatches[currentMatch]-1,1)	
				end
			end
		end,false)
		
		addEventHandler("onClientGUIClick",bansWindow.ban_player,function()
			guiSetText(bansInput.label,"Enter the name (or part of the name) of the player you want to ban, followed by an optional reason. (eg: Joe flying car)")
			guiSetText(bansInput.edit,"")
			guiSetInputEnabled(true)
			guiSetVisible(bansInput.window,true)
			guiBringToFront(bansInput.window)
		end,false)
		
		addEventHandler("onClientGUIClick",bansWindow.ban_ip,function()
			guiSetText(bansInput.label,"Enter the ip that you want to ban, followed by an optional reason. (eg: 127.0.0.1 cheater ip)")
			guiSetText(bansInput.edit,"")
			guiSetInputEnabled(true)
			guiSetVisible(bansInput.window,true)
			guiBringToFront(bansInput.window)
		end,false)
		
		addEventHandler("onClientGUIClick",bansWindow.ban_serial,function()
			guiSetText(bansInput.label,"Enter the serial that you want to ban, followed by an optional reason. (eg: AAAA-BBBB-CCCC-DDDD cheater serial)")
			guiSetText(bansInput.edit,"")
			guiSetInputEnabled(true)
			guiSetVisible(bansInput.window,true)
			guiBringToFront(bansInput.window)
		end,false)	
		
		addEventHandler("onClientGUIClick",bansWindow.ban_username,function()
			guiSetText(bansInput.label,"Enter the mta community username that you want to ban, followed by an optional reason. (eg: Sam flying car)")
			guiSetText(bansInput.edit,"")
			guiSetInputEnabled(true)
			guiSetVisible(bansInput.window,true)
			guiBringToFront(bansInput.window)
		end,false)	
		
		addEventHandler("onClientGUIClick",bansWindow.unban_selected,function()
			-- rows start from 0
			local row,_ = guiGridListGetSelectedItem(bansWindow.gridlist)
			
			if row ~= -1 then
				triggerServerEvent("serverUnbanSelected", localPlayer, row+1)
				-- refresh
				triggerServerEvent("getServerBans", localPlayer)
			end
		end,false)
		
		addEventHandler("onClientGUIClick",bansWindow.unban_ip,function()
			guiSetText(bansInput.label,"Enter the ip that you want to unban.")
			guiSetText(bansInput.edit,"")
			guiSetInputEnabled(true)
			guiSetVisible(bansInput.window,true)	
			guiBringToFront(bansInput.window)
		end,false)
		
		addEventHandler("onClientGUIClick",bansWindow.unban_nickname,function()
			guiSetText(bansInput.label,"Enter the nickname that you want to unban.")
			guiSetText(bansInput.edit,"")
			guiSetInputEnabled(true)
			guiSetVisible(bansInput.window,true)	
			guiBringToFront(bansInput.window)		
		end,false)
		
		
		-- ban input
		addEventHandler("onClientGUIClick",bansInput.cancel,function()
			guiSetVisible(bansInput.window,false)
			guiSetInputEnabled(false)
		end,false)
		
		addEventHandler("onClientGUIClick",bansInput.accept,function()
			local text = guiGetText(bansInput.label)
			
			if text:find("name") and not text:find("user") then
				if text:find("unban") then
					triggerServerEvent("serverUnbanPlayer", localPlayer, guiGetText(bansInput.edit))
				else
					triggerServerEvent("serverBanPlayer", localPlayer, guiGetText(bansInput.edit))
				end
			elseif text:find("ip") then
				if text:find("unban") then
					triggerServerEvent("serverUnbanIP", localPlayer, guiGetText(bansInput.edit))
				else
					triggerServerEvent("serverBanIP", localPlayer, guiGetText(bansInput.edit))
				end
			elseif text:find("serial") then
				triggerServerEvent("serverBanSerial", localPlayer, guiGetText(bansInput.edit))
			elseif text:find("username") then
				triggerServerEvent("serverBanUsername", localPlayer, guiGetText(bansInput.edit))
			end
			
			guiSetVisible(bansInput.window,false)
			guiSetInputEnabled(false)
			triggerServerEvent("getServerBans", localPlayer)
		end,false)
	end
)


addEvent("clientSeeBans",true)
function openBansWindow(op)
	if op then
		guiSetVisible(bansWindow.window,true)
		guiBringToFront(bansWindow.window)
		showCursor(true,true)
		triggerServerEvent("getServerBans", localPlayer)
	end
end
addEventHandler("clientSeeBans",root,openBansWindow)


addCommandHandler("bans",function()
	triggerServerEvent("canSeeBans",localPlayer)
end)


addEvent("returnServerBans",true)
addEventHandler("returnServerBans",root,
	function(banTable)
		-- remove all the rows
		if guiGridListGetRowCount(bansWindow.gridlist) > 0 then
			for i=0, guiGridListGetRowCount(bansWindow.gridlist), 1 do
				guiGridListRemoveRow(bansWindow.gridlist,i)
			end
		end


		for i,ban in ipairs(banTable) do
			if guiGridListGetRowCount(bansWindow.gridlist) < i then
				guiGridListAddRow(bansWindow.gridlist)
			end
			
			guiGridListSetItemText(bansWindow.gridlist,i-1,1,(ban.nick == false and "-" or tostring(ban.nick)),false,false)
			guiGridListSetItemText(bansWindow.gridlist,i-1,2,(ban.ip == false and "-" or tostring(ban.ip)),false,false)
			guiGridListSetItemText(bansWindow.gridlist,i-1,3,(ban.reason == false and "-" or tostring(ban.reason)),false,false)
			guiGridListSetItemText(bansWindow.gridlist,i-1,4,(ban.admin == false and "-" or tostring(ban.admin)),false,false)
			guiGridListSetItemText(bansWindow.gridlist,i-1,5,(ban.username == false and "-" or tostring(ban.username)),false,false)
			guiGridListSetItemText(bansWindow.gridlist,i-1,6,(ban.serial == false and "-" or tostring(ban.serial)),false,false)
			
			local time = getRealTime(ban.time)
			guiGridListSetItemText(bansWindow.gridlist,i-1,7,(ban.time == false and "-" or time.monthday.."/"..time.month.."/"..(time.year+1900).." - "..time.hour..":"..time.minute),false,false)	
		end
	end
)


addEvent("returnBanSearch",true)
addEventHandler("returnBanSearch",root,
	function(matches,size)
		if matches and size > 0 then
			searchMatches = matches
			currentMatch = 1
			guiGridListSetSelectedItem(bansWindow.gridlist,matches[currentMatch]-1,1)
			guiSetText(bansWindow.search,"")
		end	
	end
)
