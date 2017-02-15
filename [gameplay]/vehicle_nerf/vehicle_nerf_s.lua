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
}

addEventHandler ( "onVehicleRespawn", getRootElement(), function()
	local vehId = getElementModel(source)
	if limitedVehicles[vehId] then
		setElementData(source, "vehAmmo", limitedVehicles[vehId].ammo)
		setElementData(source, "vehReload", limitedVehicles[vehId].reloadTime)
		setElementData(source, "vehControl", limitedVehicles[vehId].blockedControls)
		setElementData(source, "vehNerfed", true)
	end
end )


addEventHandler("onVehicleEnter", getRootElement(),
	function ( thePlayer, seat, jacked )
	
		local vehId = getElementModel(source)
		if limitedVehicles[vehId] then
	
			if not getElementData(source, "vehAmmo") then
				setElementData(source, "vehAmmo", limitedVehicles[vehId].ammo)
			end
			
			if not getElementData(source, "vehReload") then
				setElementData(source, "vehReload", limitedVehicles[vehId].reloadTime)
			end
			
			if not getElementData(source, "vehControl") then
				setElementData(source, "vehControl", limitedVehicles[vehId].blockedControls)
			end
			
			setElementData(source, "vehNerfed", true)
			
			triggerClientEvent(thePlayer, "delayedRestrictedVehicleDetection", thePlayer)
		end
	end
)