-- how much of the vehicle damage we transfer onto the players
local damageTransfer = 0.1

addEventHandler("onVehicleDamage", root,
	function(loss)	
		-- driveby on bikes stops you being able to damage the player
		-- so, transfer some of the vehicle (bike) damage onto the drivers to make up for it
		if getVehicleType(source) == "BMX" or getVehicleType(source) == "Bike" then
			--outputDebugString("server vehicle damage " .. tostring(loss).." health " .. tostring(getElementHealth(source)))

			local playerDamage = math.floor((loss * damageTransfer) + 0.5)

			for seat, player in pairs(getVehicleOccupants(source)) do
				if isPedDoingGangDriveby(player) then
					local armour = getPedArmor(player)

					if armour and armour > 0 then
						setPedArmor(player, math.max(0, armour - playerDamage))
					else
						local health = getElementHealth(player)

						if health - playerDamage <= 0 then
							killPed(player)
						else
							setElementHealth(player, health - playerDamage)
						end
					end
				end
			end
		end
	end
)