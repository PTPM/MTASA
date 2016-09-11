local help = {
	{name = "How to play",
	 children = {
					{name = "What is PTPM?",
					 children = {
									{desc = "Protect the Prime Minister (PTPM) is a team based mode promoting teamwork and strategy over the conventional deathmatch tactics.\n\nThe aim for the 'good guys' is for the PM to stay alive for the allotted time limit with the help of his bodyguards and the cops. The aim of the Terrorists is to murder the PM before the end of the round. Generally rounds last for 15 minutes, but it is dependant on the map. You can see the time left on the timer in the top center of the screen.\n\nThe round ends if one of the following happens:\n- The timer reaches 0 and the PM is still alive\n- The PM is killed (bad guys win)"}
--									{desc = "The aim of the game is for the PM to stay alive for the allotted time limit with the help of his bodyguards and the cops. Each map is slightly different in design requiring tactics to be varied depending on which map is being played. The aim of the terrorists is to hunt down and kill the PM before the end of the round.\n\n The game has several classes, divided into 5 teams. All classes in the same team spawn in the same \"base\". Within each team, the different classes have different weapons. Some classes have special \"medic\" powers, and usually spawn with less weaponry. Medics have a slightly paler colour so you can identify them on the radar.\n\nThere is an unarmed \"Prime Minister\" (PM) class (yellow). Closely guarding the Prime Minister is the \"bodyguard\" team (green), consisting of all the bodyguard classes. Then there are the more heavily-armed \"cops\" (blue). The \"good guys\" are allies, they fight united against the \"terrorists\" (pink) team. There are also \"psychos\" (orange) who can kill whoever they like and generally mess around."}
								}
					},
					{name = "Teams",
					 children = {
									{desc = "The game has several classes, divided into 5 teams. All classes in the same team spawn in the same 'base'. Within each team, the different classes have different weapons.\n\nSome classes have special 'medic' powers allowing them to transfer their own health onto other players (/heal), and usually spawn with less weaponry. Medics have a slightly paler colour so you can identify them on the radar and in the chat.\n\nThere is an unarmed 'Prime Minister' (PM) class (yellow).\n\nClosely guarding the Prime Minister is the 'Bodyguard' team (green), consisting of all the bodyguard classes.\n\nThen there are the more heavily-armed 'Cops' (blue).\n\nThe 'good guys' are allies, they fight united against the 'Terrorists' (pink) team.\n\nThere are also 'Psychos' (orange) who can kill whoever they like and generally mess around.\n\n\nTeams can chat privately by pressing 'Y'."}
								}
					},
					{name = "Maps",
					 children = {
									{desc = "There are many maps in the PTPM mode, each with different locations and features, requiring tactics to be varied depending on which map is being played.\n\nWithin the map, you are blocked from going too far away by the map boundaries. You can see where these are by looking for the red lines on the F11 map or on the radar.\n\nFor the majority of the maps, the PM's health recharges 1% every 5 seconds.\n Medics' health also recharges, but at a faster rate (only on specific maps). Medics can transfer some of their health to other players using /heal\n\n\nSome maps have a series of optional tasks for the PM to do, marked on the map by red blips. While completing these tasks will not guarantee victory (they can be ignored if you wish), a useful bonus will be given to the PM for each completed task. It is in the best interest of the Terrorists to stop all tasks from being completed. When a task is being attempted, the task blip on the radar will turn green to indicate it is being used. A small description of the task and a countdown will also appear on the screen to show how long left until completion (Psychos cannot see this).\n\n\nSome maps also have a series of objectives for the PM to complete. So rather than simply staying alive, the PM must complete all the objectives within the round or he will lose. The current objective will be shown on the radar as a red blip and announced on the screen. Unlike tasks, no information about the time needed to complete the objective will be shown to the Terrorists, so they must act fast to stop the PM."}
								}
					}				
				}
	},
	{name = "Commands",
	 children = {
					{name = "Game",
					 children = {
									{desc = "All <player> parameters take complete or unambiguous fragments of player nicknames.\n\n\n-  /kill - kill yourself\n\n-  /plan <text> - allows the PM to set the plan, or one of the good guys to read the plan\n\n-  /reclass <class> - to reclass to a different team\n\n-  F4 - by pressing F4 you can go back to the class selection screen after you next die\n\n-  /swapclass <person> - this allows the PM to send a swapclass offer to another player. If accepted, that player will become PM and the PM will take that player's class\n\n-  /y - to accept a swapclass offer\n\n-  /n - to decline a swapclass offer\n\n-  /duty - displays your duty in the game\n\n-  /heal <player> - this allows medics to transfer some of their health to another nearby player"}
								}
					}, 
					{name = "Communication",
					 children = {
									{desc = "All <player> parameters take complete or unambiguous fragments of player nicknames.\n\n\n-  /pm <player> <message> - to send a personal message to the specified player\n\n-  /me <message>\n\n-  /teamsay <message> (or press 'Y') - to send a message to your team mates"}
								}
					},
					{name = "Infomation",
					 children = {
									{desc = "All <player> parameters take complete or unambiguous fragments of player nicknames.\n\n\n-  /motd - displays the message of the day\n\n-  /pinfo <player> - displays information about the player and their account\n\n-  /getweather - displays information about the current weather type (to help report 'bad' weathers)\n\n-  /timeleft - shows the amount of time left in the round\n\n-  F2 - this toggles the vehicle blips on the radar on and off"}
								}
					},
					{name = "Cheaters",
					 children = {
									{desc = "/report - to report a disruptive player to the admins"}
								}
					}					
				}
	},	
	{name = "Contact",
	 children = {
					{name = "Website/IRC",
					 children = {
									{desc = "If you want to contact us about anything try one of the following:\n\nWebsite: http://sparksptpm.co.uk/\n\nIRC: connect to irc.gtanet.com on port 6667 and join the channel #ptpm"}
								}
					},		
					{name = "In-game",
					 children = {
									{desc = "If you need to contact an admin in-game use one of the following:\n\n\n- If you know them by name, simply /pm <name> <message> to speak directly to them.\n\n- /report can be used to report any disruptive players to all available admins.\n\n\nAdmins will always be happy to talk to you, so feel free to speak up in the main game chat!"}
								}
					}							
				}
	},
	{name = "Who are we?",
	 children = {
					{desc = [[Administrators:
- Snowy (Number)
- uhm
- fredro
- NUB
					
Scripters:
- Remp
- Awwu
- uhm
- Snowy (Number)

Contributors:
- Timberwolf
- Rambopappa
- antario
- Puppyluv (iKent)
- Fool
- Raid
- mattdy

Special Thanks:
- Spark]]}
				}
	}
}

local helpPos = {x = 10, y = 20, w = 90, h = 20, wgap = 8, hgap = 4}
local helpTab
local helpGUI = {}
local helpDivide = {line = {}, bar = {}}

addEvent( "onClientAvailable", true )

--addEventHandler("onClientResourceStart", resourceRoot,
addEventHandler( "onClientAvailable", localPlayer,
	function()
		helpTab = exports.helpmanager:addHelpTab( thisResource )

		local w,h = guiGetSize(helpTab,false)
		
		helpPos.tw, helpPos.th = w,h
		
		helpGUI[1] = {}
		
		local hint = guiCreateLabel(w/2-75,5,150,20,"Click on a section to begin",false,helpTab)
		guiSetFont(hint,"default-small")
		guiLabelSetHorizontalAlign(hint,"center")
		
		for i,v in ipairs(help) do
			helpGUI[1][i] = guiCreateLabel(helpPos.x, helpPos.y + ((i-1)*helpPos.h) + ((i-1)*helpPos.hgap), helpPos.w, helpPos.h, v.name, false, helpTab)
			
			guiLabelSetHorizontalAlign(helpGUI[1][i],"left",false)
			guiLabelSetVerticalAlign(helpGUI[1][i],"center")
			
			setElementData(helpGUI[1][i],"helpIndex",{1,i,help[i]})
			
			addEventHandler("onClientGUIClick",helpGUI[1][i],shuffleHelp,false)
		end
		
	--	helpDivide.line[1] = guiCreateStaticImage(helpPos.x + helpPos.w + 5, 5, 2, helpPos.th - 10,"images/white_dot.png",false,helpTab)
	end
)


function shuffleHelp(button,state)
	if button == "left" and state == "up" then
		local index = getElementData(source,"helpIndex")
		
		cleanScrollpanes(index[1])
		
		resetHelp(index[1]+1)

		resetColour(index[1])

		
		if index[3].children then
			guiLabelSetColor(source,135,206,250)
			
			local level = index[1]+1
			
			if not helpGUI[level] then 
				helpGUI[level] = {} 
			end
			
			if not helpDivide.line[level] then
				helpDivide.line[level] = guiCreateStaticImage(helpPos.x + ((level-1)*helpPos.w) + ((level-1)*helpPos.wgap) - helpPos.wgap, 5, 1, helpPos.th - 10,"images/white_dot.png",false,helpTab)
			end			
			
			for i,v in ipairs(index[3].children) do
				if not helpGUI[level][i] then
					if v.name then
						helpGUI[level][i] = guiCreateLabel(helpPos.x + ((level-1)*helpPos.w) + ((level-1)*helpPos.wgap), helpPos.y + ((i-1)*helpPos.h) + ((i-1)*helpPos.hgap), helpPos.w, helpPos.h, v.name, false, helpTab)
						guiLabelSetHorizontalAlign(helpGUI[level][i],"left",false)
						guiLabelSetVerticalAlign(helpGUI[level][i],"center")
					else
						helpGUI[level][i] = guiCreateScrollPane(helpPos.x + ((level-1)*helpPos.w) + ((level-1)*helpPos.wgap), helpPos.y + ((i-1)*helpPos.h) + ((i-1)*helpPos.hgap), helpPos.tw - ((level-1)*helpPos.w) - ((level-1)*helpPos.wgap) - helpPos.x - 10, helpPos.th - helpPos.y - 10, false, helpTab)					
						
						local w,h = guiGetSize(helpGUI[level][i],false)
						
						local label = guiCreateLabel(1,1,w-20,h*5,v.desc,false,helpGUI[level][i])
						
						guiCreateLabel(1,h*5,1,1,"",false,helpGUI[level][i])
						
						guiLabelSetHorizontalAlign(label,"left",true)
						guiLabelSetVerticalAlign(label,"top")
						
					--	helpGUI[level][i] = guiCreateLabel(helpPos.x + ((level-1)*helpPos.w) + ((level-1)*helpPos.wgap), helpPos.y + ((i-1)*helpPos.h) + ((i-1)*helpPos.hgap), helpPos.tw - ((level-1)*helpPos.w) - ((level-1)*helpPos.wgap) - helpPos.x - 10, helpPos.th - helpPos.y - 10, v.desc, false, helpTab)						
					--	guiLabelSetHorizontalAlign(helpGUI[level][i],"left",true)
					--	guiLabelSetVerticalAlign(helpGUI[level][i],"top")
					end
									
					setElementData(helpGUI[level][i],"helpIndex",{level,i,index[3].children[i]})
					
					addEventHandler("onClientGUIClick",helpGUI[level][i],shuffleHelp,false)
				else
					if v.name then
						guiSetSize(helpGUI[level][i],helpPos.w, helpPos.h, false)
						
						guiSetText(helpGUI[level][i],v.name)
						
						guiLabelSetHorizontalAlign(helpGUI[level][i],"left",false)
						guiLabelSetVerticalAlign(helpGUI[level][i],"center")
					else
						destroyElement(helpGUI[level][i])
						
						helpGUI[level][i] = guiCreateScrollPane(helpPos.x + ((level-1)*helpPos.w) + ((level-1)*helpPos.wgap), helpPos.y + ((i-1)*helpPos.h) + ((i-1)*helpPos.hgap), helpPos.tw - ((level-1)*helpPos.w) - ((level-1)*helpPos.wgap) - helpPos.x - 10, helpPos.th - helpPos.y - 10, false, helpTab)					
						
						local w,h = guiGetSize(helpGUI[level][i],false)
						local label = guiCreateLabel(1,1,w-20,h*5,v.desc,false,helpGUI[level][i])
						
						guiCreateLabel(1,h*5,1,1,"",false,helpGUI[level][i])
						
						guiLabelSetHorizontalAlign(label,"left",true)
						guiLabelSetVerticalAlign(label,"top")					
					
					--	guiSetSize(helpGUI[level][i],helpPos.tw - ((level-1)*helpPos.w) - ((level-1)*helpPos.wgap) - helpPos.x - 10, helpPos.th - helpPos.y - 10, false)
						
					--	guiSetText(helpGUI[level][i],v.desc)	

					--	guiLabelSetHorizontalAlign(helpGUI[level][i],"left",true)
					--	guiLabelSetVerticalAlign(helpGUI[level][i],"top")
					end
					
					setElementData(helpGUI[level][i],"helpIndex",{level,i,index[3].children[i]})
				
					guiSetPosition(helpGUI[level][i],helpPos.x + ((level-1)*helpPos.w) + ((level-1)*helpPos.wgap), helpPos.y + ((i-1)*helpPos.h) + ((i-1)*helpPos.hgap),false)					
				end
			end
		end
	end
end


function resetHelp(level)
	while true do
		if not helpGUI[level] then break end
		
		for i,v in ipairs(helpGUI[level]) do	
			guiSetPosition(v,0,0,false)
			guiSetSize(v,0,0,false)
			guiSetText(v,"")
		end
		
		if helpDivide.line[level] then
			destroyElement(helpDivide.line[level])
			helpDivide.line[level] = nil
		end
		
		resetColour(level)
		
		level = level + 1
	end
end


function resetColour(level)
	if not helpGUI[level] then return end
		
	for i,v in ipairs(helpGUI[level]) do
		guiLabelSetColor(v,255,255,255)
	end
end


function cleanScrollpanes(level)
	while true do
		if not helpGUI[level] then break end
		
		for i,v in ipairs(helpGUI[level]) do
			if getElementType(v) == "gui-scrollpane" then
				destroyElement(v)
				helpGUI[level][i] = nil
			end
		end
		
		level = level + 1
	end
end






local helper = {
	draw = false, 
	text = "", 
	alpha = 0, 
	step = 7,
	messages = {
		"Tip:  Don't know what to do?  Type /duty or press F9",
		"Tip:  The Prime Minister is shown in yellow",
		"Tip:  Want to change your team?  Type /reclass <team>",
		"Tip:  Are you a medic?  You can heal people with /heal",
		"Tip:  Want a full list of the commands?  Press F9 and click 'ptpm'",
		"Tip:  Use right click to driveby (when you have a driveby weapon)",
		"Tip:  Tap 'jump' underneath a helicopter to grab on",
		"Tip:  What is ptpm? Press F9 and click 'ptpm' to find out",
		"Tip:  Press 'F11' to see the map",
		"Tip:  Low on health?  Try a vending machine",
		"Tip:  Press 'Y' to chat with your team",
		"Tip:  Watch out for Psychopaths, they will kill anyone"
	}
}

--addEventHandler("onClientResourceStart",resourceRoot,
addEventHandler( "onClientAvailable", localPlayer,
	function()
		helper.current = math.random(1,#helper.messages)
		
		
		setTimer(drawHelperText,math.random(80,110)*1000,1)
	end
)


function drawHelperText()
	setTimer( drawHelperText, math.random( 80, 110 )*1000, 1 )

	if not getElementData( localPlayer, "ptpm.classID" ) then
		return 
	end
	
	helper.current = (helper.current % #helper.messages) + 1
	helper.draw = true
	
	setTimer(function() helper.step = -7 end, 8000, 1)
end


addEventHandler("onClientRender",root,
	function()
		if helper.draw then
			if helper.step > 0 then
				if helper.alpha < 255 then
					helper.alpha = helper.alpha + helper.step
					if helper.alpha >= 255 then 
						helper.alpha = 255 
						helper.step = 0
					end
				end
			elseif helper.step < 0 then
				if helper.alpha > 0 then
					helper.alpha = helper.alpha + helper.step
					if helper.alpha <= 0 then 
						helper.alpha = 0 
						helper.step = 7
						helper.draw = false
					end
				end
			end
		
			local width = dxGetTextWidth(helper.messages[helper.current], 1, "default-bold")
		--	dxDrawRectangle(screenX/2 - width/2 - 10, screenY - 30, width + 20, 30, tocolor(0,0,0,150), false)
			dxDrawText(helper.messages[helper.current], screenX/2 - width/2 + 1, screenY - 55 + 1, screenX/2 + width/2 + 1, screenY, tocolor(0,0,0,helper.alpha), 1, "default-bold", "center", "center", true, true, false)
			dxDrawText(helper.messages[helper.current], screenX/2 - width/2, screenY - 55, screenX/2 + width/2, screenY, tocolor(160,32,240,helper.alpha), 1, "default-bold", "center", "center", true, true, false)
		end
	end
)