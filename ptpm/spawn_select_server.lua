function initClassSelection( thePlayer )

	if not data	then return end	
	if data.roundEnded then return end
	local inClassSelection = getElementData( thePlayer, "ptpm.inClassSelection" )
	if not isPlayerActive( thePlayer ) or inClassSelection then return end	
	setElementData( thePlayer, "ptpm.inClassSelection", true, false )
	
	if getPlayerClassID( thePlayer ) then
		setElementData( thePlayer, "ptpm.classID", false )
	end
	
	setElementData( thePlayer, "ptpm.score.class", nil )
	setPlayerTeam( thePlayer, nil )
	resetPlayerColour( thePlayer )
	
	setPlayerControllable( thePlayer, false )
	
	-- Make table of available classes and their weapons
	local spawnSelect2AllClasses = {}
	local skinComedyNames = {
		[73] = "Shaggy",
		[100] = "Ruff Rider",
		[111] = "Boris",
		[137] = "Box Man",
		[141] = "May Lana",
		[147] = "The Prime Minister",
		[163] = "Baldy Black",
		[164] = "Coat Hanger",
		[165] = "Agent Wesson",
		[166] = "Will Smith",
		[179] = "Ammunation",
		[181] = "Fool!",
		[183] = "Token Black",
		[191] = "The Girl",
		[200] = "Hilly Billy",
		[212] = "The Groom",
		[230] = "Hoody",
		[246] = "The Beat Cop",
		[274] = "Terrorist Medic",
		[275] = "Cop Medic",
		[276] = "Bodyguard Medic",
		[280] = "Officer Brutality",
		[281] = "Officer Friendly",
		[282] = "Officer Dopey",
		[283] = "Rick Grimes",
		[284] = "Highway Patrol",
		[285] = "SWAT",
		[286] = "FBI",
		[288] = "The Sheriff"
	}
	
	for classID,classObj in pairs(classes) do
		local classFullInfo = {
			classType = classObj.type,
			medic = classObj.medic,
			skin = getElementData(classObj.class, "skin"),
			weaponsString = getElementData(classObj.class, "weapons"),
			comedyName = skinComedyNames[getElementData(classObj.class, "skin")]
		}
		
		table.insert(spawnSelect2AllClasses, classFullInfo)
	end
	
	-- Hold up, SpawnSelect2 allows only: 1 PM, 3 cops, 1 cmedic, 3 bodyguards, 1 bmedic, 7 terrorists, 1 tmedic and 0 psychopaths (currently)
	local spawnSelect2ClassesFiltered = {}	
	local spawnSelect2ClassCountMax = { pm = 1, police = 4, policemedic = 0, bodyguard = 4, bodyguardmedic = 0, terrorist = 8, terroristmedic = 0, psycho = 0}
	
	for k,fullClassObj in pairs(spawnSelect2AllClasses) do
		local ct = fullClassObj.classType
		if fullClassObj.medic then ct = ct .. "medic" end
		outputDebugString(ct)
		
		if spawnSelect2ClassCountMax[ct] and spawnSelect2ClassCountMax[ct] > 0 then
			table.insert(spawnSelect2ClassesFiltered, fullClassObj)
			spawnSelect2ClassCountMax[ct] = spawnSelect2ClassCountMax[ct]-1
		end
	end
	
	-- Tell client which classes are available
	for _, p in ipairs( getElementsByType( "player" ) ) do
		if p and isElement( p ) then
			triggerClientEvent ( p, "ptpmSpawnSelect", p, spawnSelect2ClassesFiltered )	
		end
	end
	
	setCameraMatrix( thePlayer, data.wardrobe.camX,
								data.wardrobe.camY,
								data.wardrobe.camZ,
								data.wardrobe.playerX,
								data.wardrobe.playerY,
								data.wardrobe.playerZ )
	setCameraInterior( thePlayer, data.wardrobe.interior )
	
	if tableSize( getElementsByType( "objective", runningMapRoot ) ) > 0 then
		clearObjectiveTextFor( thePlayer ) 
	end
	
	if tableSize( getElementsByType( "task", runningMapRoot ) ) > 0 then
		clearTaskTextFor( thePlayer )
	end
end