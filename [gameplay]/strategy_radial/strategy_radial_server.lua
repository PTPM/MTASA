local resource = {
	ptpm = getResourceFromName("ptpm"),
	spam = getResourceFromName("antiflood"),
}

-- Was populated manually by listingen to every voice line recorded for a certain ped (`sfxBrowser` resource was a help)
-- key in table is ped model id (aka skin id)
local voicelineSFX = {
	["73"] = {
		comment = "Terrorist Shaggy",
		containerName = "spc_ga",
		bankId = "137",
		soundIds = {
			["Hello"] = 	{ 0, 61, 63 },
			["Insult"] = 	{ 18, 20, 51 },
			["Thanks"] = 	{ 134, 115, 116 },
			["Yes"] = 	{ 15 },
			["No"] = 		{ 9 },
			["Good job"]=	{ 118, 119 },
			["Wait"]= 	{ 45 },
			["Go"]= 		{ 137 },
			["Help!"]= 	{ 52, 71 },
			["Attack"]= 	{ 50 },
			["Defend"]= 	{ 31, 38 },
			["Heal me"]=	{ 29 }
		}
	},
	["100"] = {
		comment = "Terrorist Biker",
		containerName = "spc_ga",
		bankId = "191",
		soundIds = {
			["Hello"] = 	{ 172, 174, 175 },
			["Insult"] = 	{ 14, 17, 18, 19 },
			["Thanks"] = 	{ 150, 151 },
			["Yes"] = 	{ 156, 157 },
			["No"] = 		{ 111, 161, 163 },
			["Good job"]=	{ 92, 94 },
			["Wait"]= 	{ 25, 133 },
			["Go"]= 		{ 9, 12 },
			["Help!"]= 	{ 114 },
			["Attack"]= 	{ 73, 123 },
			["Defend"]= 	{ 122, 124 },
			["Heal me"]=	{ 80 }
		}
	},
	["111"] = {
		comment = "Terrorist Russian",
		containerName = "spc_ga",
		bankId = "75",
		soundIds = {
			["Hello"] = 	{ 0 },
			["Insult"] = 	{ 19 },
			["Thanks"] = 	{ 7 },
			["Yes"] = 	{ 7 },
			["No"] = 		{ 3 },
			["Good job"]=	{ 17 },
			["Wait"]= 	{ 18 },
			["Go"]= 		{ 1 },
			["Help!"]= 	{ 2 },
			["Attack"]= 	{ 10, 11 },
			["Defend"]= 	{ 4, 5 },
			["Heal me"]=	{ 6 }
		}
	},
	["179"] = {
		comment = "Terrorist Ammunation",
		containerName = "spc_fa",
		bankId = "13",
		soundIds = {
			["Hello"] = 	{ 58, 57 },
			["Insult"] = 	{ 21, 22 },
			["Thanks"] = 	{ 36 },
			["Yes"] = 	{ 11 },
			["No"] = 		{ 3 },
			["Good job"]=	{ 74 },
			["Wait"]= 	{ 9 },
			["Go"]= 		{ 28 },
			["Help!"]= 	{ 37 },
			["Attack"]= 	{ 12, 32 },
			["Defend"]= 	{ 40 },
			["Heal me"]=	{ 49 }
		}
	},
	["181"] = {
		comment = "Terrorist Punk",
		containerName = "spc_ga",
		bankId = "158",
		soundIds = {
			["Hello"] = 	{ 151, 152 },
			["Insult"] = 	{ 10, 17, 19, 22, 56 },
			["Thanks"] = 	{ 123, 124 },
			["Yes"] = 	{ 131, 130 },
			["No"] = 		{ 101, 142, 143, 146 },
			["Good job"]=	{ 4 },
			["Wait"]= 	{ 45 },
			["Go"]= 		{ 168, 177, 179 },
			["Help!"]= 	{ 83 },
			["Attack"]= 	{ 93, 95, 98 },
			["Defend"]= 	{ 1 },
			["Heal me"]=	{ 85, 78 ,79 }
		}
	},
	["183"] = {
		comment = "Terrorist Black Guy",
		containerName = "spc_ga",
		bankId = "143",
		soundIds = {
			["Hello"] = 	{ 183, 184 },
			["Insult"] = 	{ 104 },
			["Thanks"] = 	{ 168, 169 },
			["Yes"] = 	{ 155 },
			["No"] = 		{ 176, 177 },
			["Good job"]=	{ 200, 203 },
			["Wait"]= 	{ 222 },
			["Go"]= 		{ 123, 189 },
			["Help!"]= 	{ 199 },
			["Attack"]= 	{ 11, 13, 140 },
			["Defend"]= 	{ 65, 135 },
			["Heal me"]=	{ 103 }
		}
	},
	["191"] = {
		comment = "Terrorist Girl",
		containerName = "spc_fa",
		bankId = "6",
		soundIds = {
			["Hello"] = 	{ 159, 330 },
			["Insult"] = 	{ 33, 46, 70 },
			["Thanks"] = 	{ 117 },
			["Yes"] = 	{ 313, 311 },
			["No"] = 		{ 216, 218, 315 },
			["Good job"]=	{ 363 },
			["Wait"]= 	{ 360 },
			["Go"]= 		{ 210 },
			["Help!"]= 	{ 292, 297 },
			["Attack"]= 	{ 262 },
			["Defend"]= 	{ 345 },
			["Heal me"]=	{ 353, 354 }
		}
	},
	["274"] = {
		comment = "Terrorist Medic",
		containerName = "spc_ea",
		bankId = "7",
		soundIds = {
			["Hello"] = 	{ 31, 33 },
			["Insult"] = 	{ 10 },
			["Thanks"] = 	{ 22 },
			["Yes"] = 	{ 30, 32 },
			["No"] = 		{ 9 },
			["Good job"]=	{ 36 },
			["Wait"]= 	{ 35 },
			["Go"]= 		{ 4 },
			["Help!"]= 	{ 25 },
			["Attack"]= 	{ 14, 15 },
			["Defend"]= 	{ 13 },
			["Heal me"]=	{ 24 }
		}
	},
	["141"] = {
		comment = "Bodyguard Girl",
		containerName = "spc_ga",
		bankId = "111",
		soundIds = {
			["Hello"] = 	{ 0, 120, 121, 123 },
			["Insult"] = 	{ 52, 100, 160 },
			["Thanks"] = 	{ 147 },
			["Yes"] = 	{ 111, 112 },
			["No"] = 		{ 116, 117 },
			["Good job"]=	{ 171 },
			["Wait"]= 	{ 134, 135 },
			["Go"]= 		{ 5, 10 },
			["Help!"]= 	{ 81, 90 },
			["Attack"]= 	{ 69, 70, 71 },
			["Defend"]= 	{ 51 },
			["Heal me"]=	{ 63 }
		}
	},
	["166"] = {
		comment = "Bodyguard Will Smiff",
		containerName = "spc_ga",
		bankId = "20",
		soundIds = {
			["Hello"] = 	{ 68, 69 },
			["Insult"] = 	{ 9, 10 },
			["Thanks"] = 	{ 60 },
			["Yes"] = 	{ 61 },
			["No"] = 		{ 63 },
			["Good job"]=	{ 90 },
			["Wait"]= 	{ 72 },
			["Go"]= 		{ 47 },
			["Help!"]= 	{ 94 },
			["Attack"]= 	{ 34, 30 },
			["Defend"]= 	{ 27 },
			["Heal me"]=	{ 73 }
		}
	},
	["164"] = {
		comment = "Bodyguard Beefy White Guy",
		containerName = "spc_ga",
		bankId = "182",
		soundIds = {
			["Hello"] = 	{ 66,67 },
			["Insult"] = 	{ 4 },
			["Thanks"] = 	{ 85 },
			["Yes"] = 	{ 53 },
			["No"] = 		{ 57 },
			["Good job"]=	{ 81 },
			["Wait"]= 	{ 87 },
			["Go"]= 		{ 79 },
			["Help!"]= 	{ 9, 10 },
			["Attack"]= 	{ 32 },
			["Defend"]= 	{ 19 },
			["Heal me"]=	{ 17 }
		}
	},
	["276"] = {
		comment = "Bodyguard Medic",
		containerName = "spc_ea",
		bankId = "4",
		soundIds = {
			["Hello"] = 	{ 58 },
			["Insult"] = 	{ 25, 26 },
			["Thanks"] = 	{ 61 },
			["Yes"] = 	{ 41 },
			["No"] = 		{ 42 },
			["Good job"]=	{ 47 },
			["Wait"]= 	{ 48 },
			["Go"]= 		{ 38 },
			["Help!"]= 	{ 34, 32, 35 },
			["Attack"]= 	{ 22, 23 },
			["Defend"]= 	{ 19, 16, 21 },
			["Heal me"]=	{ 1 }
		}
	},
	["246"] = {
		comment = "Cop Stripper",
		containerName = "spc_ga",
		bankId = "146",
		soundIds = {
			["Hello"] = 	{ 10 },
			["Insult"] = 	{ 5 },
			["Thanks"] = 	{ 1 },
			["Yes"] = 	{ 13 },
			["No"] = 		{ 4 },
			["Good job"]=	{ 3 },
			["Wait"]= 	{ 2 },
			["Go"]= 		{ 0 },
			["Help!"]= 	{ 6 },
			["Attack"]= 	{ 8 },
			["Defend"]= 	{ 7 },
			["Heal me"]=	{ 11 }
		}
	},
	["275"] = {
		comment = "Cop Medic",
		containerName = "spc_ea",
		bankId = "3",
		soundIds = {
			["Hello"] = 	{ 24 },
			["Insult"] = 	{ 2, 10, 16 },
			["Thanks"] = 	{ 57 },
			["Yes"] = 	{ 50, 51 },
			["No"] = 		{ 1 },
			["Good job"]=	{ 48 },
			["Wait"]= 	{ 61 },
			["Go"]= 		{ 44 },
			["Help!"]= 	{ 18 },
			["Attack"]= 	{ 17 },
			["Defend"]= 	{ 21 },
			["Heal me"]=	{ 40, 41 }
		}
	},
	["281"] = {
		comment = "Cop San Fierro",
		containerName = "spc_ea",
		bankId = "41",
		soundIds = {
			["Hello"] = 	{ 22, 21 },
			["Insult"] = 	{ 0 },
			["Thanks"] = 	{ 93, 94 },
			["Yes"] = 	{ 90, 79 },
			["No"] = 		{ 125, 109 },
			["Good job"]=	{ 92 },
			["Wait"]= 	{ 66 },
			["Go"]= 		{ 77 },
			["Help!"]= 	{ 54, 112 },
			["Attack"]= 	{ 44, 45, 49 },
			["Defend"]= 	{ 48, 47 },
			["Heal me"]=	{ 97 }
		}
	},
	["285"] = {
		comment = "Cop SWAT",
		containerName = "spc_ea",
		bankId = "43",
		soundIds = {
			["Hello"] = 	{ 27 },
			["Insult"] = 	{ 42 },
			["Thanks"] = 	{ 37 },
			["Yes"] = 	{ 19 },
			["No"] = 		{ 18 },
			["Good job"]=	{ 8 },
			["Wait"]= 	{ 13 },
			["Go"]= 		{ 4, 6, 24 },
			["Help!"]= 	{ 20 },
			["Attack"]= 	{ 2 },
			["Defend"]= 	{ 0 },
			["Heal me"]=	{ 1 }
		}
	},
	["147"] = {
		comment = "The Prime Minister",
		containerName = "spc_ga",
		bankId = "185",
		soundIds = {
			["Hello"] = 	{ 150, 147, 152 },
			["Insult"] = 	{ 41, 42 },
			["Thanks"] = 	{ 50, 51, 52, 53 },
			["Yes"] = 	{ 138, 140 },
			["No"] = 		{ 141, 142 },
			["Good job"]=	{ 82, 85 },
			["Wait"]= 	{ 181, 186 },
			["Go"]= 		{ 6, 195 },
			["Help!"]= 	{ 101, 170 },
			["Attack"]= 	{ 99 },
			["Defend"]= 	{ 15 },
			["Heal me"]=	{ 104 }
		}
	},
	["137"] = {
		comment = "Psychopath Box Guy",
		containerName = "spc_ga",
		bankId = "132",
		soundIds = {
			["Hello"] = 	{ 50, 51, 60 },
			["Insult"] = 	{ 12, 26, 27, 28, 29, 30, 32, 43, 44, 46, 47, 59, 61, 69, 79, 83 },
			["Thanks"] = 	{ 15, 18, 31, 127, 128 },
			["Yes"] = 	{ 88,  94 },
			["No"] = 		{ 4, 89, 91, 92, 93 },
			["Good job"]=	{ 73 },
			["Wait"]= 	{ 119 },
			["Go"]= 		{ 16 },
			["Help!"]= 	{ 62, 77 },
			["Attack"]= 	{ 21, 64, 67, 118 },
			["Defend"]= 	{ 20, 114 },
			["Heal me"]=	{ 23, 57, 58 }
		}
	},
	["200"] = {
		comment = "Psychopath Hilly Billy",
		containerName = "spc_ga",
		bankId = "44",
		soundIds = {
			["Hello"] = 	{ 0, 4 },
			["Insult"] = 	{ 36, 49, 50, 51 },
			["Thanks"] = 	{ 134, 115, 116 },
			["Yes"] = 	{ 93, 94 },
			["No"] = 		{ 96, 97 },
			["Good job"]=	{ 3, 41 },
			["Wait"]= 	{ 60 },
			["Go"]= 		{ 8, 10, 12, 18 },
			["Help!"]= 	{ 65, 120, 121 },
			["Attack"]= 	{ 7 },
			["Defend"]= 	{ 24 },
			["Heal me"]=	{ 26 }
		}
	},
	["212"] = {
		comment = "Psychopath Crazy Hobo",
		containerName = "spc_ga",
		bankId = "153",
		soundIds = {
			["Hello"] = 	{ 1, 136, 137 },
			["Insult"] = 	{ 27, 58 },
			["Thanks"] = 	{ 173, 174 },
			["Yes"] = 	{ 125, 126, 127 },
			["No"] = 		{ 128, 129, 130, 132 },
			["Good job"]=	{ 19 },
			["Wait"]= 	{ 21, 90, 91 },
			["Go"]= 		{ 43 },
			["Help!"]= 	{ 23, 61 },
			["Attack"]= 	{ 9, 10, 100 },
			["Defend"]= 	{ 28, 34 },
			["Heal me"]=	{ 86 }
		}
	},
	["230"] = {
		comment = "Psychopath Weel Work For Weed",
		containerName = "spc_ga",
		bankId = "134",
		soundIds = {
			["Hello"] = 	{ 22, 24, 32, 80, 83 },
			["Insult"] = 	{ 14, 38, 62, 89 },
			["Thanks"] = 	{ 16, 109, 166 },
			["Yes"] = 	{ 82, 122 },
			["No"] = 		{ 33,  42, 115, 116 },
			["Good job"]=	{ 19, 20, 149, 167 },
			["Wait"]= 	{ 0, 84, 93, 128 },
			["Go"]= 		{ 51, 111, 135 },
			["Help!"]= 	{ 1, 47, 60, 118, 158, 160, 164 },
			["Attack"]= 	{ 26, 90 },
			["Defend"]= 	{ 61, 146, 156 },
			["Heal me"]=	{ 5, 78, 88  }
		}
	}
}

-- log when last time client played a voice line 
local sfxLastPlayed = {}

function handleIncomingStrategyRadialCommand(command, text, x, y, z)
	if isPlayerMuted( client ) then
		outputChatBox( "You are muted.", client, 128, 128, 255 ) --ptpm.colourPersonal
		return
	end
	
	if resource.spam and getResourceState(resource.spam) == "running" then
		local allow, wasPunished = exports.antiflood:shouldAllowMessage(client, text)
		if not allow then
			return
		end
	end
	
	if resource.ptpm and getResourceState(resource.ptpm) == "running" then
		exports.ptpm:sendTeamChatMessage( client, text )
		playSFXforStrategyRadialCommand(client, command)
	else
		local r,g,b = getPlayerNametagColor(client)
		outputChatBox (getPlayerName(client) ..  ":#FFFFFF " .. text, getRootElement(), r,g,b, true )
		playSFXforStrategyRadialCommand(client, command)
	end
end

function playSFXforStrategyRadialCommand(client, command)

	local pedModel = "" .. getElementModel( client )
	local voicelineId = 0
	
	if  (sfxLastPlayed[client] == nil or sfxLastPlayed[client] + 1000 < getTickCount()) and not isPedDead(client) and voicelineSFX[pedModel] then
		if voicelineSFX[pedModel].soundIds[command] then
			-- random line
			voicelineId = voicelineSFX[pedModel].soundIds[command][ math.random( #voicelineSFX[pedModel].soundIds[command] )] 

			local x,y,z = getElementPosition( client )
			
			-- play line for all players
			for _, player in ipairs(getElementsByType("player")) do
				if player and isElement(player) then
					local x2,y2,z2 = getElementPosition( player )
					
					if getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) < 30 then
						triggerClientEvent(player, "onPlayerVoiceLine", player, voicelineSFX[pedModel].containerName, voicelineSFX[pedModel].bankId, voicelineId, x, y, z)
					end
				end
			end
			sfxLastPlayed[client] = getTickCount()
		end
	end
end

addEventHandler("onResourceStart", root,
	function(theResource)
		if getResourceName(theResource) == "ptpm" then
			resource.ptpm = theResource
		elseif getResourceName(theResource) == "antiflood" then
			resource.spam = theResource
		end
	end
)


addEvent( "ptpmStrategyRadialRelay", true )
addEventHandler( "ptpmStrategyRadialRelay", resourceRoot, handleIncomingStrategyRadialCommand )