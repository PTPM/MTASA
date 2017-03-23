local myLastWeapon = nil

addEventHandler("onClientPlayerWeaponFire", root, function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
    if source==localPlayer then
		if weapon~=myLastWeapon then
			triggerServerEvent ( "resyncMyWeapon", resourceRoot , weapon )
			myLastWeapon = weapon
		end
	end
end)