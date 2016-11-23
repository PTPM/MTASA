function setDriverDrivebyAbility(...)
	local newTable = {...}
	enforceValidWeapons(newTable)
	settings.driver = newTable
	table.sort(settings.driver, weaponSort)
	previousWeaponSlot = 0
	return true
end

function setPassengerDrivebyAbility(...)
	local newTable = {...}
	enforceValidWeapons(newTable)
	settings.passenger = newTable
	table.sort(settings.passenger, weaponSort)
	previousWeaponSlot = 0
	return true
end

function getDriverDrivebyAbility()
	return settings.driver
end

function getPassengerDrivebyAbility()
	return settings.passenger
end

function setWeaponShotDelay(weaponID, delay)
	if not validDrivebyWeapons[weaponID] then
		outputDebugString("setWeaponShotDelay: 'weaponID' specified is not a valid driveby weapon", 0, 255, 255, 0)
		return false
	end

	local delay = tonumber(delay)
	if not delay then
		outputDebugString("setWeaponShotDelay: Bad 'delay' specified.", 0, 255, 255, 0)
		return false
	end

	settings.shotdelay[tostring(weaponID)] = delay
	return true
end

function getWeaponShotDelay(weaponID)
	if not validDrivebyWeapons[weaponID] then
		outputDebugString("getWeaponShotDelay: 'weaponID' specified is not a valid driveby weapon", 0, 255, 255, 0)
		return false
	end

	return settings.shotdelay[tostring(weaponID)] or 0
end

function setDrivebySteeringAbility(vehicles, bikes)
	if (vehicles) == nil then
		outputDebugString("setDrivebySteeringAbility: No valid arguments were passed.", 0, 255, 255, 0)
		return false
	end

	settings.steerCars = vehicles
	settings.steerBikes = type(bikes) ~= "boolean" and true or bikes
end

function getDrivebySteeringAbility(dbType)
	if dbType == "car" then
		return settings.steerCars
	elseif dbType == "bike" then
		return settings.steerBikes
	else
		outputDebugString("getDrivebySteeringAbility: Bad driveby type specified.  Should be 'car' or 'bike'.", 0, 255, 255, 0)
		return false
	end
end

function setDrivebyAutoEquip(enabled)
	if type(enabled) ~= "boolean" then
		outputDebugString("setDrivebyAutoEquip: Bad argument, should be a boolean.", 0, 255, 255, 0)
		return false
	end

	settings.autoEquip = enabled
	return true
end

function getDrivebyAutoEquip()
	return settings.autoEquip
end


