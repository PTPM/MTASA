local myLastWeapon = nil

addEventHandler("onClientPlayerWeaponFire", root, function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
    if source==localPlayer then
		if weapon~=myLastWeapon then
			triggerServerEvent ( "resyncMyWeapon", resourceRoot , weapon )
			myLastWeapon = weapon
		end
	end
end)

addEventHandler("onClientVehicleExit", getRootElement(),
    function(thePlayer, seat)
        if thePlayer==localPlayer then
			local weapon = 0 --getPedWeapon(localPlayer) (not actually needed since it turns out that you always leave a vehicle disarmed)
			if weapon~=myLastWeapon then
				triggerServerEvent ( "resyncMyWeapon", resourceRoot , weapon )
				myLastWeapon = weapon
			end
		end
    end
)