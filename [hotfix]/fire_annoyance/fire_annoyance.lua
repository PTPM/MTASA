local fireWeapons = {[18] = true, [37] = true} -- molotov, flame thrower


addEventHandler("onPlayerSpawn", root,
	function(x, y, z, rot, team)
		if not team then
			return
		end

		toggleFireControl(source, getPedWeapon(source))
	end
)

addEventHandler("onPlayerWeaponSwitch", root,
	function(previousWeapon, currentWeapon)
		toggleFireControl(source, currentWeapon)
	end
)

-- this could technically be evaded in the however-many-ms it takes to send the new state to the client
-- do something better if that ever becomes a big enough problem
function toggleFireControl(player, weapon)
	if not fireWeapons[weapon] or not getPlayerTeam(player) then
		if not isControlEnabled(player, "fire") then
 			toggleControl(player, "fire", true)
 		end

		return
	end

	if getPedTotalAmmo(player) == 0 then
 		return
 	end

 	if exports.ptpm:isPlayerInSpawnArea(player) then
 		toggleControl(player, "fire", false)
 	else
 		if not isControlEnabled(player, "fire") then
 			toggleControl(player, "fire", true)
 		end
 	end
end