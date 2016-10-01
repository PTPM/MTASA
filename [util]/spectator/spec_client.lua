local spec = {}
local sx,sy = guiGetScreenSize()
local localPlayer = getLocalPlayer()
local loading = {}


addEvent( "spectateStart", true )
function spectateStart( target, savePos )
	spec.active = true

	if not spec.left then
		spec.left = guiCreateStaticImage((sx*0.45)-57, sy*0.8, 57, 57, "left.png",false)
	end
			
	if not spec.text then
		spec.text = guiCreateLabel((sx*0.5)-75,sy*0.85,150,80,"",false)
		guiLabelSetHorizontalAlign(spec.text,"center")
	end
			
	if not spec.right then
		spec.right = guiCreateStaticImage(sx*0.55, sy*0.8, 57, 57, "right.png",false)
	end	
	
	if savePos then
		spec.savePos = true
		savePosition()
	end	
	
	spec.int = getCameraInterior()
	spec.playerInt = getElementInterior(localPlayer)
	spec.dim = getElementDimension(localPlayer)
	
	if target then
		setTarget(target)
	else
		setTarget( findTarget(1) )
	end
	
	bindKey("arrow_l", "down", spectatePrev)
	bindKey("arrow_r", "down", spectateNext)
	
	spec.update = setTimer(spectateUpdate,1000,0)
end
addEventHandler( "spectateStart", root, spectateStart )


addEvent( "spectateStop", true )
function spectateStop( ignoreSaves )
	if not spec.active then return end
	
	if spec.left then
		destroyElement(spec.left)
		spec.left = nil
	end
			
	if spec.text then
		destroyElement(spec.text)
		spec.text = nil
	end			
			
	if spec.right then
		destroyElement(spec.right)
		spec.right = nil
	end

	if spec.update then
		if isTimer(spec.update) then
			killTimer(spec.update)
		end
	end
	
	unbindKey("arrow_l", "down", spectatePrev)
	unbindKey("arrow_r", "down", spectateNext)
	
	setCameraTarget(localPlayer)
	
	if spec.savePos then
		spec.savePos = false
		
		restorePosition()
	end
	
	if spec.int then
		setCameraInterior(spec.int)
	end
	
	if spec.dim then
		setElementDimension(localPlayer, spec.dim)
	end
	
	if spec.playerInt then
		setElementInterior(localPlayer, spec.playerInt)
	end
	
	spec.active = false
	spec.target = nil
	spec.update = nil
	spec.pos = nil
	spec.players = nil
	spec.int = nil
	spec.dim = nil
	spec.playerInt = nil
	
	if not ignoreSaves then
		checkGroundLoaded()
	end
end
addEventHandler( "spectateStop", root, spectateStop )


function checkGroundLoaded()
	local x,y = getElementPosition(localPlayer)
	local hit = processLineOfSight(x,y,3000,x,y,-3000,true,false,false,true,false,true,false,true,localPlayer)
	-- if the ground hasn't loaded yet
	if not hit then
		-- save the original gravity
		loading.savedGravity = getGravity()
		setGravity(0)
		
		-- unfreeze the player once the environment has loaded
		loading.timer = setTimer(
			function()
				local x,y = getElementPosition(localPlayer)
				local hit = processLineOfSight(x,y,3000,x,y,-3000,true,false,false,true,false,true,false,true,localPlayer)
				if hit then
					setGravity(loading.savedGravity)
					loading.savedGravity = nil
						
					killTimer(loading.timer)
					loading.timer = nil
				end
			end,100,0)
	end
end


function spectatePrev()
	setTarget( findTarget( -1 ) )
end


function spectateNext()
	setTarget( findTarget( 1 ) )
end


addEvent( "setTarget", true )
function setTarget( player )
	spec.target = player
	
	if spec.target and isElement(spec.target) then
		setCameraTarget(spec.target)
		guiSetText(spec.text, "Spectating:\n" .. getPlayerName(spec.target))
		
	--[[	if not spec.update then
			spec.update = setTimer(spectateUpdate,1000,0)
		end]]
	else		
		setCameraTarget( localPlayer )
		setCameraMatrix( 0,0,10,0,10,8)
		guiSetText(spec.text, "Spectating:\nNo one to spectate")
		
	--[[	if spec.update then
			if isTimer(spec.update) then
				killTimer(spec.update)
			end
			spec.update = nil
		end	
]]		
	end
end
addEventHandler( "setTarget", root, setTarget )


addEvent( "setSpectateList", true )
function setSpecList( list )
	spec.players = list
end
addEventHandler( "setSpectateList", root, setSpecList )


function findTarget(dir)
	local players
	
	if spec.players then
		players = spec.players
	else
		players = getElementsByType("player")
	end
	
	
	local pos
	
	for i,p in ipairs(players) do
		if spec.target and p == spec.target then
			pos = i
		end
	end
	
	if not pos then pos = 1 end
	
	-- from race
	for i=1,#players do
		pos = ((pos + dir - 1) % #players ) + 1
		if players[pos] ~= localPlayer and isElement(players[pos]) and not isPedDead(players[pos]) then
			return players[pos]
		end
	end
	return nil
end


function spectateUpdate()
	if spec.active then
		if spec.target then
			if isElement(spec.target) then
				if not isPedDead(spec.target) then
					local dim = getElementDimension(spec.target)
						
					if dim and getElementDimension(localPlayer) ~= dim then
						setElementDimension(localPlayer,dim)
					end					
				
				
					local int = getElementInterior(spec.target)
					
					if int and getCameraInterior() ~= int then
						setCameraInterior(int)
						setElementInterior(localPlayer,int)
					end
				else
					setTarget( findTarget(1) )
				end
			else
				setTarget( findTarget(1) )
			end
		else
			setTarget( findTarget(1) )
		end
	end
end


function savePosition()
	local x,y,z = getElementPosition( localPlayer )
	
	spec.pos = { x, y, z }
end


function restorePosition()
	if not spec.pos then
		return
	end
	
	setElementPosition( localPlayer, spec.pos[1], spec.pos[2], spec.pos[3] )
end


addCommandHandler( "specinfo",
	function()
		if spec.target then
			outputChatBox( "(c) Target: " .. tostring( getElementDimension( spec.target ) ) .. ", " .. tostring( getElementInterior( spec.target ) ) )
			outputChatBox( "(c) Local: " .. tostring( getElementDimension( localPlayer ) ) .. ", " .. tostring( getElementInterior( localPlayer ) ) .. ", " .. tostring( getCameraInterior() ) )
			triggerServerEvent( "specinfotest", localPlayer, spec.target )
		end
	end
)