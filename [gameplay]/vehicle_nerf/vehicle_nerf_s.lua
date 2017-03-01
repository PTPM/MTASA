local limitedVehicles = {
	-- Hydra (Fighter jet):
	[520] = {
		ammo = 50,
		reloadTime = 2500,
		blockedControls = { 
			"vehicle_secondary_fire"
		}
	},
	
	-- Rhino (Tank):
	[432] = {
		ammo = 35,
		reloadTime = 1000,
		blockedControls = { 
			"vehicle_fire",
			"vehicle_secondary_fire"
		}
	},
	
	-- Mountain Bike (the only bicycle used in PTPM)
	[510] = {
		handlingChanges = {
			maxVelocity = 70 --From: 140
		}
	},
	
	-- Bike
	[509] = {
		handlingChanges = {
			maxVelocity = 60 --From: 120
		}
	},
	
	-- BMX
	[481] = {
		handlingChanges = {
			maxVelocity = 60 --From: 120
		}
	},
}

-- Vehicle weapons are done client side:
-- Ammo status is not synced, because of issues with setElementData on vehicles (presumably)
-- That's fine
addEvent( "getLimitedVehiclesInfo", true )
addEventHandler( "getLimitedVehiclesInfo", resourceRoot, function ( message )
	triggerClientEvent ( client, "setLimitedVehiclesInfo", client, limitedVehicles)
end )


-- Vehicle handling is done server side:
-- To assess default handling easily, use: 
-- NOTE: /run getModelHandling(510)["maxVelocity"]
-- For handlingKeys, see: https://wiki.multitheftauto.com/wiki/SetModelHandling

addEventHandler("onResourceStart", resourceRoot, function()
	for vehModel,config in pairs(limitedVehicles) do
		if config.handlingChanges then
			for handlingKey,handlingValue in pairs(config.handlingChanges) do
				setModelHandling(vehModel, handlingKey, handlingValue) 			
			end
		end
	end
end )
