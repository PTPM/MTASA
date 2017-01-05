function helpSystemCreateDefinitions()
	registerHelpEvent("BASICS_TERRORIST", {
		text = "You are a terrorist. Kill the Prime Minister. He is yellow on the map",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "terrorcount", false, 3}}
	})

	registerHelpEvent("BASICS_POLICE", {
		text = "You are a cop. Protect the Prime Minister from attackers!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "policecount", false, 3}}
	})

	registerHelpEvent("BASICS_BODYGUARD", {
		text = "You are a bodyguard. Follow the Prime Minister, and protect him from attackers",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "bgcount", false, 3}}
	})

	registerHelpEvent("BASICS_PM", {
		text = "You are the Prime Minister. Cops and Bodyguards will protect you. Do not let the Terrorists kill you!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "pmcount", false, 3}}
	})


	registerHelpEvent("MEDIC_HEAL", {
		text = "You are a medic. Stand close to a hurt player and type /heal!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "hphealed", false, 100}}
	})

	registerHelpEvent("MEDIC_H", {
		text = "You can type /h instead of /heal. It is faster!",
		condition = {fn = conditionStatNumberComparisons, args = {"__player", {"hphealed", true, 200}, {"hcount", false, 2}}},
		cooldown = 60000 * 6,
	})	

	registerHelpEvent("MEDIC_AMBULANCE", {
		text = "While inside an Ambulance you will give nearby teammates a bigger health boost",
		condition = {fn = conditionStatNumberComparisons, args = {"__player", {"hphealed", true, 300}, {"eventambulancecount", false, 3}}},
		increment = "eventambulancecount",
		cooldown = 60000 * 4,
	})

	registerHelpEvent("MEDIC_PASSIVE_GIVE", {
		text = "Medics will slowly heal teamates that are nearby",
		condition = {fn = conditionStatNumberComparisons, args = {"__player", {"hphealed", true, 100}, {"hphealedpassive", false, 30}}},
		cooldown = 60000 * 4,
	})	


	registerHelpEvent("PICKUP_NEAR", {
		text = "A weapon pickup is nearby...",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "roundsplayed", true, 20}},
		cooldown = 60000,
	})	


	registerHelpEvent("OBJECTIVE_OVERVIEW", {
		text = "The red markers on the map are objectives for the Prime Minister. He must visit them to win. He will lose if the time runs out",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "objectivesplayed", false, 3}},
	})	

	registerHelpEvent("OBJECTIVE_OVERVIEW_PM", {
		text = "You must complete the objectives to win. Go to the red marker on the map to begin",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "objectivesplayed", false, 3}},
	})		

	registerHelpEvent("OBJECTIVE_ENTER", {
		text = "Stay inside the marker to complete this objective. You will be given a new objective once completed",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "objectivesplayed", false, 3}},
	})		

	registerHelpEvent("OBJECTIVE_COMPLETE", {
		text = "Objective complete! +3 minutes have been added to the round. A new objective has been unlocked, go there now",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "objectivesplayed", false, 3}},
	})		

	registerHelpEvent("OBJECTIVE_NUDGE", {
		text = "You must visit the objectives to win. You will lose if you run out of time!",
		cooldown = 50000,
	})		


	registerHelpEvent("TASK_OVERVIEW", {
		text = "The red markers on the map are tasks that the Prime Minister can complete. Each completed task will give him a new advantage",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "tasksplayed", false, 3}},
	})	

	registerHelpEvent("TASK_OVERVIEW_PM", {
		text = "The red markers on the map are tasks that you can complete. Each completed task gives you a new advantage towards winning the round",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "tasksplayed", false, 3}},
	})		

	registerHelpEvent("TASK_ENTER", {
		text = "This is a task. Stay inside the marker to complete the task and receive a bonus. The bonus will help you to survive",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "tasksplayed", false, 3}},
	})	

	registerHelpEvent("TASK_COMPLETE", {
		text = "You have completed the task! Each task completed gives you a new bonus reward",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "tasksplayed", false, 3}},
	})		

	registerHelpEvent("TASK_NUDGE", {
		text = "This map has tasks. The Prime Minister gets powerful bonuses from them. Find a red marker on the map to try it!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "tasksplayed", false, 5}},
	})	


	registerHelpEvent("COMMAND_RECLASS", {
		text = "You can change team by using /reclass. For example: /reclass terrorist",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "reclasscount", false, 3}},
		cooldown = 60000 * 6,
	})	

	registerHelpEvent("COMMAND_RC", {
		text = "You can reclass faster using /rc. For example: /rc c is the same as /reclass cop",
		condition = {fn = conditionStatNumberComparisons, args = {"__player", {"rccount", false, 3}, {"reclasscount", true, 3}}},
		cooldown = 60000 * 6,
	})

	registerHelpEvent("COMMAND_SWAPCLASS", {
		text = "Don't want to be Prime Minister? You may ask to swap with another player using /swapclass player",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "swapclasscount", false, 3}},
		cooldown = 60000 * 6,
	})	

	registerHelpEvent("COMMAND_SWAPCLASS_TARGET", {
		text = "Do you want to be Prime Minister? [Prime Minister] is offering to swap class with you. Type /y to accept, or /n to decline.",
		displayTime = 15000,
		importance = 9999,
		force = true,
	})	

	registerHelpEvent("COMMAND_PLAN", {
		text = "Type /plan <message> to let your team know what you want them to do",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "plancount", false, 3}},
		cooldown = 60000 * 6,
	})	

	registerHelpEvent("COMMAND_PLAN_SET", {
		text = "The Prime Minister has set a plan. This is how he wants to survive. Follow his instructions!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "plancount", false, 3}},
		cooldown = 60000 * 6,
	})		

	registerHelpEvent("COMMAND_DUTY", {
		text = "To learn more about your class, type /duty",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "roundsplayed", false, 10}},
		cooldown = 60000 * 6,
	})	

	registerHelpEvent("BIND_F4", {
		text = "Press F4 to show the class selection menu after you next die",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "leaveclasscount", false, 3}},
		cooldown = 60000 * 6,
	})		


	registerHelpEvent("CAMERA_ENTER", {
		text = "WARNING: While viewing a camera you can still be attacked. Use the left/right arrow keys to change camera. Type /camoff or press enter to exit",
		displayTime = 60000 * 30,
		importance = 9995,
		force = true,
	})	


	registerHelpEvent("OPTION_HEALTH_REGEN_PM", {
		text = "The Prime Minister will slowly gain health over time. Use this wisely!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "pmcount", false, 3}},
		cooldown = 60000 * 15,
	})	

	registerHelpEvent("OPTION_HEALTH_REGEN_MEDIC", {
		text = "Medics will slowly gain health over time. Use this extra health to heal your team. Coordinate with another medic to heal even faster!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "mediccount", false, 3}},
		cooldown = 60000 * 15,
	})	

	registerHelpEvent("OPTION_PM_WATER_PENALTY", {
		text = "The Prime Minister can't swim on this map. You will slowly become tired & hurt, and will eventually die",
		cooldown = 60000 * 2,
	})

	registerHelpEvent("OPTION_PM_WATER_DEATH", {
		text = "The Prime Minister can't swim on this map. You will die if you enter the water",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "waterdeathcount", false, 3}},
		cooldown = 60000 * 2,
	})

	registerHelpEvent("OPTION_PM_ABANDONED_PENALTY", {
		text = "The Prime Minister must stay in a vehicle on this map. You will slowly lose health while exposed to the open air",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "abandonedcount", false, 3}},
		cooldown = 60000 * 1,
	})

	registerHelpEvent("OPTION_DISTANCE_TO_PM", {
		text = "The Prime Minister is hidden on the map. Find him! Use the distance meter to see how far away he is and track him down",
		cooldown = 60000 * 5,
	})

	-- registerHelpEvent("OPTION_CANT_DRIVE", {
	-- 	text = "The Prime Minister is hidden on the map. Find him! Use the distance meter to see how far away he is and track him down",
	-- 	cooldown = 60000 * 5,
	-- })


	registerHelpEvent("SAFE_ZONE", {
		text = "The blue area is a safe zone. Hydras and Rustlers can't come in here.",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "safezonecount", false, 3}},
		cooldown = 60000 * 6,
	})		
end