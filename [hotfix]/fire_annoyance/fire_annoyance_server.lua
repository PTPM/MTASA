function removeWeaponReprimand(weaponId)
	takeWeapon ( client, weaponId)
	outputChatBox ( "ADMIN: Don't troll the spawn!", client, 255, 0, 0 )
end

addEvent( "removeWeaponEvent", true )
addEventHandler( "removeWeaponEvent", resourceRoot, removeWeaponReprimand )