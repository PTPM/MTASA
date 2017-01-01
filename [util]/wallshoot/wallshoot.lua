-- track if we have disabled the control so we don't override other resources that might toggle it as well 
local disabledFire = false


function processFireToggle()
	if isPedInVehicle(localPlayer) or not getControlState("aim_weapon") then
		if disabledFire then
			toggleControl("fire", true)
			disabledFire = false
		end	

		return
	end

	local slot = getPedWeaponSlot(localPlayer)

	-- handgun, shotgun, smg, rifle, sniper
	if slot ~= 2 and slot ~= 3 and slot ~= 4 and slot ~= 5 and slot ~= 6 then
		return
	end

	local mx, my, mz = getPedWeaponMuzzlePosition(localPlayer)

	if not mx or not my or not mz then
		return
	end


	local tx, ty, tz = getPedTargetCollision(localPlayer)

	-- the thing we are aiming at is very close to us, so just allow it
	-- this prevents it blocking you shooting e.g. a player right in front of you
	if tx and ty and tz and distanceSquared(mx, my, mz, tx, ty, tz) <= 15.625 then -- 2.5 ^ 3
		--dxDrawText("clear early", 100, 300, 200, 300)

		if disabledFire then
			toggleControl("fire", true)
			disabledFire = false
		end

		return
	end

	if not tx then
		tx, ty, tz = getPedTargetEnd(localPlayer)

		if not tx then
			return
		end
	end

	-- get the muzzle -> target vector
	local vx = tx - mx
	local vy = ty - my
	local vz = tz - mz
	-- normalise
	local max = math.max(math.abs(vx), math.max(math.abs(vy), math.abs(vz)))
	vx = (vx / max)
	vy = (vy / max)
	vz = (vz / max)

	-- track backwards a little from the muzzle point to get out of any objects the muzzle might be inside
	-- track forwards towards the target by 2.5m (anything further than that isn't really "wallshooting")
	-- optionally check slightly above the weapon, in the case of looking down over a ledge
	if isLineOfSightClear(mx - (vx * 0.3), my - (vy * 0.3), mz - (vz * 0.3), mx + (vx * 2.5), my + (vy * 2.5), mz + (vz * 2.5), true, false, false, true, false, false, true, localPlayer) or
		isLineOfSightClear(mx - (vx * 0.3), my - (vy * 0.3), mz - (vz * 0.3) + 0.3, mx + (vx * 2.5), my + (vy * 2.5), mz + (vz * 2.5) + 0.3, true, false, false, true, false, false, true, localPlayer) then
		--dxDrawText("clear", 100, 300, 200, 300)

		if disabledFire then
			toggleControl("fire", true)
			disabledFire = false
		end
	else
		--dxDrawText("blocked", 100, 300, 200, 300)

		if isControlEnabled("fire") then
			toggleControl("fire", false)
			disabledFire = true
		end
	end
end
addEventHandler("onClientRender", root, processFireToggle)

function distanceSquared(aX, aY, aZ, bX, bY, bZ)
	local vX = aX - bX
	local vY = aY - bY
	local vZ = aZ - bZ

	return vX*vX + vY*vY + vZ*vZ
end