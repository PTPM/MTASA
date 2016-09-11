local stats = {
    [ 69 ] = 1000,
    [ 70 ] = 1000,
    [ 71 ] = 1000,
    [ 72 ] = 1000,
    [ 73 ] = 998,
    [ 74 ] = 1000,
    [ 75 ] = 1000,
    [ 76 ] = 1000,
    [ 77 ] = 1000,
    [ 78 ] = 1000,
    [ 79 ] = 1000,
	[ 160 ] = 1000,
	[ 229 ] = 1000,
	[ 230 ] = 1000,
	[ 223 ] = 1000,
	[ 225 ] = 1000,
	--[ 24 ] = 1000,
	[ 22 ] = 1000
}

local function applyStats(player)
	for stat,value in pairs(stats) do
		setPedStat(player, stat, value)
	end
end

addEventHandler('onResourceStart', resourceRoot,
	function()
		for i,player in ipairs(getElementsByType('player')) do
			applyStats(player)
		end
	end
)

addEventHandler('onPlayerJoin', root,
	function()
		applyStats(source)
	end
)

addEventHandler('onGamemodeMapStart', root,
	function()
		for _,player in ipairs(getElementsByType('player')) do
			applyStats(player)
		end	
	end
)

addEventHandler('onPlayerSpawn', root,
	function()
		applyStats(source)
	end
)
