function removeWeaponReprimand(weaponId)
	setWeaponAmmo ( client, weaponId, 0 )
	outputChatBox ( "ADMIN: Don't troll the spawn!", client, 255, 0, 0 )
end

addEvent( "removeWeaponEvent", true )
addEventHandler( "removeWeaponEvent", resourceRoot, removeWeaponReprimand )