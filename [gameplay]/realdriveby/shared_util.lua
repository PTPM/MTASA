validDrivebyWeapons = { 
	[22] = true, -- colt 45
	[23] = true, -- silenced
	[24] = true, -- deagle
	[25] = true, -- shotgun
	[26] = true, -- sawed off
	[27] = true, -- combat shotgun
	[28] = true, -- uzi
	[29] = true, -- mp5
	[32] = true, -- tech-9
	[30] = true, -- ak-47
	[31] = true, -- m4
	[33] = true, -- rifle
	[38] = true -- minigun
}

function enforceValidWeapons(t)
	for key, weaponID in ipairs(t) do
		if not validDrivebyWeapons[weaponID] then
			table.remove(t, key)
		end
	end
end

-- sort weapons into the natural order
function WeaponSort(a, b)
	local aSlot = getSlotFromWeapon(a)
	local bSlot = getSlotFromWeapon(b)

	if aSlot < bSlot then
		return true
	elseif bSlot < aSlot then
		return false
	else
		return a < b
	end
end