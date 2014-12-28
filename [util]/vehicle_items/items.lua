vehicleSpecials = {
	[427] = {special = "armor", infinite = false}, -- enforcer
	[416] = {special = "health", infinite = false}, -- ambulance
	[598] = {special = "shotgun", infinite = false}, -- police car lv
	[596] = {special = "shotgun", infinite = false}, -- police car ls
	[597] = {special = "shotgun", infinite = false}, -- police car sf
	[599] = {special = "shotgun", infinite = false}, -- police rancher
	[420] = {special = "cash", infinite = false}, -- taxi
	[438] = {special = "cash", infinite = false}, -- cabbie
	[592] = {special = "parachute", infinite = true}, -- andromada
	[577] = {special = "parachute", infinite = true}, -- at-400
	[511] = {special = "parachute", infinite = true}, -- beagle
	[548] = {special = "parachute", infinite = true}, -- cargobob
	[512] = {special = "parachute", infinite = true}, -- cropduster
	[593] = {special = "parachute", infinite = true}, -- dodo
	[425] = {special = "parachute", infinite = true}, -- hunter
	[520] = {special = "parachute", infinite = true}, -- hydra
	[417] = {special = "parachute", infinite = true}, -- leviathan
	[487] = {special = "parachute", infinite = true}, -- maverick
	[553] = {special = "parachute", infinite = true}, -- nevada
	[488] = {special = "parachute", infinite = true}, -- news chopper
	[497] = {special = "parachute", infinite = true}, -- police maverick
	[563] = {special = "parachute", infinite = true}, -- raindance
	[476] = {special = "parachute", infinite = true}, -- rustler
	[447] = {special = "parachute", infinite = true}, -- seasparrow
	[519] = {special = "parachute", infinite = true}, -- shamal
	[460] = {special = "parachute", infinite = true}, -- skimmer
	[469] = {special = "parachute", infinite = true}, -- sparrow
	[513] = {special = "parachute", infinite = true}, -- stuntplane
}
vehicleSpecialUsed = {}

addEventHandler( "onVehicleEnter", root,
	function ( player, seat, jacked )
		if player and seat == 0 then
			if type( vehicleSpecialUsed[source] ) == "table" and vehicleSpecialUsed[source][player] then
				-- already used the special
			else
				if not vehicleSpecialUsed[source] then
					vehicleSpecialUsed[source] = {}
				end
				local model = getElementModel( source )
				if vehicleSpecials[model] and vehicleSpecials[model].special == "armor" then
					setPedArmor( player, 100 )
				elseif vehicleSpecials[model] and vehicleSpecials[model].special == "health" then
					local currentH = getElementHealth( player )
					currentH = math.min( currentH + 50, 100 )
					setElementHealth( player, currentH )
				elseif vehicleSpecials[model] and vehicleSpecials[model].special == "shotgun" then
					local previousWeapon = getPedWeaponSlot( player )
					setPedWeaponSlot( player, 3 ) -- returns true even if player doesn't have weapon in that slot
					if getPedWeaponSlot( player ) ~= 3 or getPedTotalAmmo( player ) == 0 or getPedWeapon( player ) == 25 then
						giveWeapon( player, 25, 10 )
					end
					if previousWeapon then
						setPedWeaponSlot( player, previousWeapon )
					end
				elseif vehicleSpecials[model] and vehicleSpecials[model].special == "cash" then
					givePlayerMoney( player, 12 )
				elseif vehicleSpecials[model] and vehicleSpecials[model].special == "parachute" then
					giveWeapon( player, 46, 1 )
				end
				if vehicleSpecials[model] and (not vehicleSpecials[model].infinite) then
					vehicleSpecialUsed[source][player] = true
				end
			end
		end
	end
)

function clearVehicleSpecialUsed()
	vehicleSpecialUsed[source] = {}
end
addEventHandler( "onVehicleRespawn", root, clearVehicleSpecialUsed )
addEventHandler( "onVehicleExplode", root, clearVehicleSpecialUsed )