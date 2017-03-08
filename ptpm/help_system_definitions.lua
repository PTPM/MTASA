function helpSystemCreateDefinitions()
	registerHelpEvent("BASICS_TERRORIST", {
		text = "You are a [TERRORIST]Terrorist[WHITE]. Kill the [PM]Prime Minister[WHITE]. He is [PM]yellow[WHITE] on the map.",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "terrorcount", false, 3}},
		cooldown = 60000 * 15,
	})

	registerHelpEvent("BASICS_POLICE", {
		text = "You are a [POLICE]Cop[WHITE]. Protect the [PM]Prime Minister[WHITE] from attackers!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "policecount", false, 3}},
		cooldown = 60000 * 15,
	})

	registerHelpEvent("BASICS_BODYGUARD", {
		text = "You are a [BODYGUARD]Bodyguard[WHITE]. Follow the [PM]Prime Minister[WHITE], and protect him from attackers.",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "bgcount", false, 3}},
		cooldown = 60000 * 15,
	})

	registerHelpEvent("BASICS_PM", {
		text = "You are the [PM]Prime Minister[WHITE]. [POLICE]Cops[WHITE] and [BODYGUARD]Bodyguards[WHITE] will protect you. Do not let the [TERRORIST]Terrorists[WHITE] kill you!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "pmcount", false, 3}},
		cooldown = 60000 * 15,
	})


	registerHelpEvent("MEDIC_HEAL", {
		text = "You are a [TEAM]medic[WHITE]. Stand close to a hurt player and type [PTPM]/heal[WHITE] to heal them.",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "hphealed", false, 100}},
		image = {name = "medic", colour = {255, 0, 0}},
		cooldown = 60000 * 6,
	})

	registerHelpEvent("MEDIC_H", {
		text = "You can type [PTPM]/h[WHITE] instead of [PTPM]/heal[WHITE]. It is faster!",
		condition = {fn = conditionStatNumberComparisons, args = {"__player", {"hphealed", true, 200}, {"hcount", false, 2}}},
		cooldown = 60000 * 15,
		linkHelpManager = false,
		image = {name = "medic", colour = {255, 0, 0}}
	})	

	registerHelpEvent("MEDIC_AMBULANCE", {
		text = "While inside an [PTPM]Ambulance[WHITE] you will give nearby teammates a bigger health boost.",
		condition = {fn = conditionStatNumberComparisons, args = {"__player", {"hphealed", true, 300}, {"eventambulancecount", false, 3}}},
		increment = "eventambulancecount",
		cooldown = 60000 * 10,
		image = {name = "medic", colour = {255, 0, 0}}
	})

	registerHelpEvent("MEDIC_PASSIVE_GIVE", {
		text = "[TEAM]Medics[WHITE] will slowly heal teammates that are nearby.",
		condition = {fn = conditionStatNumberComparisons, args = {"__player", {"hphealed", true, 100}, {"hphealedpassive", false, 30}}},
		cooldown = 60000 * 15,
		image = {name = "medic", colour = {255, 0, 0}}
	})	


	registerHelpEvent("PICKUP_NEAR", {
		text = "A [PTPM]weapon[WHITE] pickup is nearby...",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "roundsplayed", true, 20}},
		cooldown = 60000 * 10,
		displayTime = 4000,
		linkHelpManager = false,
		image = {name = "gun"},
	})	


	registerHelpEvent("OBJECTIVE_OVERVIEW", {
		text = "The [RED]red markers[WHITE] on the map are [RED]objectives[WHITE] for the [PM]Prime Minister[WHITE]. He must visit them to win. He will lose if the time runs out!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "objectivesplayed", false, 3}},
		cooldown = 60000 * 15,
	})	

	registerHelpEvent("OBJECTIVE_OVERVIEW_PM", {
		text = "You must complete the [RED]objectives[WHITE] in this map to win. Go to the [RED]red marker[WHITE] on the map to begin!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "objectivesplayed", false, 3}},
		cooldown = 60000,
	})		

	registerHelpEvent("OBJECTIVE_ENTER", {
		text = "Stay inside the marker to complete this [RED]objective[WHITE]. You will be given a new [RED]objective[WHITE] once completed.",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "objectivesplayed", false, 3}},
		cooldown = 60000 * 5,
	})		

	registerHelpEvent("OBJECTIVE_COMPLETE", {
		text = "[RED]Objective[WHITE] complete! [PTPM]+3 minutes[WHITE] have been added to the round. A new [RED]objective[WHITE] has been unlocked, go there now!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "objectivesplayed", false, 3}},
	})		

	registerHelpEvent("OBJECTIVE_NUDGE", {
		text = "You must visit the [RED]objectives[WHITE] to win. You will lose if you run out of time!",
		cooldown = 50000,
	})		


	registerHelpEvent("TASK_OVERVIEW", {
		text = "The [RED]red markers[WHITE] on the map are [RED]tasks[WHITE] that the [PM]Prime Minister[WHITE] can complete. Each completed [RED]task[WHITE] will give him a new advantage.",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "tasksplayed", false, 3}},
		cooldown = 60000 * 15,
	})	

	registerHelpEvent("TASK_OVERVIEW_PM", {
		text = "The [RED]red markers[WHITE] on the map are [RED]tasks[WHITE] that you can complete. Each completed [RED]task[WHITE] gives you a new advantage towards winning the round!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "tasksplayed", false, 3}},
		cooldown = 60000,
	})		

	registerHelpEvent("TASK_ENTER", {
		text = "This is a [RED]task[WHITE]. Stay inside the marker to complete the [RED]task[WHITE] and receive a bonus. The bonus will help you to survive!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "tasksplayed", false, 3}},
		cooldown = 60000 * 5,
	})	

	registerHelpEvent("TASK_COMPLETE", {
		text = "You have completed the [RED]task[WHITE]! Each [RED]task[WHITE] completed gives you a new bonus reward!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "tasksplayed", false, 3}},
	})		

	registerHelpEvent("TASK_NUDGE", {
		text = "This map has [RED]tasks[WHITE]. The [PM]Prime Minister[WHITE] gets powerful bonuses from them. Find a [RED]red marker[WHITE] on the map to try it!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "tasksplayed", false, 8}},
		cooldown = 30000,
	})	

	registerHelpEvent("TASK_EXPLAIN", {
		text = "This is a [RED]task[WHITE]. Only the [PM]Prime Minister[WHITE] can use it. It will give him a [PTPM]bonus[WHITE], if he can complete it.",
		condition = {fn = conditionTaskExplanationComparison, args = {"__player"}},
		cooldown = 60000 * 2,
	})		


	registerHelpEvent("COMMAND_RECLASS", {
		text = "You can change team by using [PTPM]/reclass[WHITE]. For example: [PTPM]/reclass [TERRORIST]terrorist",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "reclasscount", false, 3}},
		cooldown = 60000 * 15,
	})	

	registerHelpEvent("COMMAND_RC", {
		text = "You can reclass faster using [PTPM]/rc[WHITE]. For example: [PTPM]/rc [POLICE]c[WHITE] is the same as [PTPM]/reclass [POLICE]cop",
		condition = {fn = conditionStatNumberComparisons, args = {"__player", {"rccount", false, 3}, {"reclasscount", true, 3}}},
		cooldown = 60000 * 15,
		linkHelpManager = false,
	})

	registerHelpEvent("COMMAND_SWAPCLASS", {
		text = "Don't want to be [PM]Prime Minister[WHITE]? You may ask to swap with another player using [PTPM]/swapclass <player>",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "swapclasscount", false, 3}},
		cooldown = 60000 * 15,
	})	

	registerHelpEvent("COMMAND_SWAPCLASS_TARGET", {
		text = "Do you want to be [PM]Prime Minister[WHITE]? The [PM]Prime Minister[WHITE] is offering to swap class with you. Type [PTPM]/y[WHITE] to accept, or [PTPM]/n[WHITE] to decline.",
		displayTime = 15000,
		importance = 9999,
		force = true,
	})	

	registerHelpEvent("COMMAND_PLAN", {
		text = "Type [PTPM]/plan <message>[WHITE] to let your team know what you want them to do!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "plancount", false, 3}},
		cooldown = 60000 * 10,
		image = {name = "plan"},
		linkHelpManager = false,
	})	

	registerHelpEvent("COMMAND_PLAN_SET", {
		text = "The [PM]Prime Minister[WHITE] has set a plan. This is how he wants to survive. Follow his instructions!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "plancount", false, 3}},
		cooldown = 60000 * 6,
		image = {name = "plan"},
		linkHelpManager = false,
	})		

	registerHelpEvent("COMMAND_DUTY", {
		text = "To learn more about your class, type [PTPM]/duty",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "roundsplayed", false, 10}},
		cooldown = 60000 * 15,
	})	

	registerHelpEvent("BIND_F4", {
		text = "You can press [PTPM]F4[WHITE] to return to the class selection menu.",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "leaveclasscount", false, 3}},
		cooldown = 60000 * 15,
		linkHelpManager = false,
	})		


	registerHelpEvent("CAMERA_ENTER", {
		text = "[RED]WARNING[WHITE]: While viewing a camera you can still be attacked. Use the [PTPM]left/right arrow keys[WHITE] to change camera. Type [PTPM]/camoff[WHITE] or press [PTPM]enter[WHITE] to exit.",
		displayTime = 60000 * 30,
		importance = 9995,
		force = true,
		image = {name = "camera"},
		linkHelpManager = false,
	})	


	registerHelpEvent("OPTION_HEALTH_REGEN_PM", {
		text = "The [PM]Prime Minister[WHITE] will slowly gain health over time. Use this wisely!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "pmcount", false, 3}},
		cooldown = 60000 * 15,
		image = {name = "hearts", colour = {255, 0, 0}}
	})	

	registerHelpEvent("OPTION_HEALTH_REGEN_MEDIC", {
		text = "[TEAM]Medics[WHITE] will slowly gain health over time. Use this extra health to heal your team. Coordinate with another [TEAM]medic[WHITE] to heal even faster!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "mediccount", false, 3}},
		cooldown = 60000 * 15,
		image = {name = "hearts", colour = {255, 0, 0}}
	})	

	registerHelpEvent("OPTION_PM_WATER_PENALTY", {
		text = "The [PM]Prime Minister[WHITE] can't swim on this map. You will slowly become tired & hurt, and will eventually die!",
		cooldown = 60000 * 2,
		image = {name = "water", colour = {32, 147, 232}}
	})

	registerHelpEvent("OPTION_PM_WATER_DEATH", {
		text = "The [PM]Prime Minister[WHITE] can't swim on this map. You will die if you enter the water!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "waterdeathcount", false, 3}},
		cooldown = 60000 * 2,
		image = {name = "water", colour = {32, 147, 232}}
	})

	registerHelpEvent("OPTION_PM_ABANDONED_PENALTY", {
		text = "The [PM]Prime Minister[WHITE] must stay in a vehicle on this map. You will slowly lose health while exposed to the open air!",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "abandonedcount", false, 3}},
		cooldown = 60000 * 1,
	})

	registerHelpEvent("OPTION_DISTANCE_TO_PM", {
		text = "The [PM]Prime Minister[WHITE] is hidden on the map. Find him! Use the [RED]distance meter[WHITE] to see how far away he is and track him down.",
		cooldown = 60000 * 15,
		linkHelpManager = false,
	})

	-- registerHelpEvent("OPTION_CANT_DRIVE", {
	-- 	text = "You can't drive this vehicle",
	-- 	cooldown = 60000 * 5,
	-- })

	-- registerHelpEvent("OPTION_CANT_PASSENGER", {
	-- 	text = "You can't enter this vehicle",
	-- 	cooldown = 60000 * 5,
	-- })

	registerHelpEvent("SAFE_ZONE", {
		text = "The [BLUE]blue[WHITE] area is a [BLUE]safe zone[WHITE]. Dangerous vehicles can't come in here.",
		condition = {fn = conditionStatNumberComparison, args = {"__player", "safezonecount", false, 3}},
		cooldown = 60000 * 8,
	})			
end