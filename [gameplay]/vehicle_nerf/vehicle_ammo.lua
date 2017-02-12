local limitedVehicles = {
	[520] = {
		ammo = 50,
		reload = 2500,
		name = "Hydra",
		countPrimary = false,
		countSecondary = true
	},
	[432] = {
		ammo = 100,
		reload = 1000,
		name = "Rhino",
		countPrimary = true,
		countSecondary = false
	},
}

addEventHandler ( "onVehicleRespawn", getRootElement(), function()
	local vehId = getElementModel(source)
	if limitedVehicles[vehId] then
		setElementData(source, "vehAmmo", limitedVehicles[vehId].ammo)
	end
end )