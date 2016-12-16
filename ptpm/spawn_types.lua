--[[----------------------------------------------
	Spawn object that defines a single spawn point
]]------------------------------------------------

Spawn = {}
Spawn.__index = Spawn

function Spawn:create(posX, posY, posZ, rot, int)
	local new = setmetatable(
		{
			position = {x = posX, y = posY, z = posZ},
			rotation = rot or 0,
			interior = int or 0,
			type = "point",
		},
		Spawn
	)

	return new
end


--[[----------------------------------------------
	Spawn object that defines 2 points, between which spawn points can be randomly picked
]]------------------------------------------------

SpawnLine = {}
SpawnLine.__index = SpawnLine

function SpawnLine:create(startX, startY, startZ, endX, endY, endZ, rot, int)
	local new = setmetatable(
		{
			startPoint = {x = startX, y = startY, z = startZ},
			endPoint = {x = endX, y = endY, z = endZ},
			rotation = rot or 0,
			interior = int or 0,
			type = "line",
		},
		SpawnLine
	)

	return new
end

function SpawnLine:__index(key)
	if key == "position" then
		local r = math.random()
		return {
			x = self.startPoint.x + ((self.endPoint.x - self.startPoint.x) * r), 
			y = self.startPoint.y + ((self.endPoint.y - self.startPoint.y) * r),  
			z = self.startPoint.z + ((self.endPoint.z - self.startPoint.z) * r)
		}
	end
end


--[[----------------------------------------------
	Spawn object that defines a square within which spawn points can be randomly picked
]]------------------------------------------------

SpawnArea = {}
SpawnArea.__index = SpawnArea

function SpawnArea:create(cornerX, cornerY, posZ, w, h, rot, int)
	local new = setmetatable(
		{
			corner = {x = cornerX, y = cornerY, z = posZ},
			size = {width = w, height = h},
			rotation = rot or 0,
			interior = int or 0,	
			type = "area",
		},
		SpawnArea
	)

	return new
end


function SpawnArea:__index(key)
	if key == "position" then
		return {
			x = self.corner.x + (self.size.width * math.random()), 
			y = self.corner.y + (self.size.height* math.random()),  
			z = self.corner.z
		}
	end	
end


--[[----------------------------------------------
	Spawn object that defines a circle within which spawn points can be randomly picked
	minRadius defines a minimum distance from the centre, making it into a ring shape
]]------------------------------------------------

SpawnCircle = {}
SpawnCircle.__index = SpawnCircle

function SpawnCircle:create(posX, posY, posZ, radius, minRadius, rot, int)
	local new = setmetatable(
		{
			center = {x = posX, y = posY, z = posZ},
			radius = radius,
			minRadius = minRadius or 0,
			rotation = rot or 0,
			interior = int or 0,	
			type = "area",
		},
		SpawnCircle
	)

	return new
end


function SpawnCircle:__index(key)
	if key == "position" then
		local cX, cY = getPointOnCircle(self.minRadius + (math.random() * (self.radius - self.minRadius)), math.random() * 360)
		return {
			x = self.center.x + cX,
			y = self.center.y + cY,
			z = self.center.z
		}
	end	
end



--[[----------------------------------------------
	Spawn Group object that holds a list of Spawns (Spawn points / lines / areas)
]]------------------------------------------------

SpawnGroup = {}
SpawnGroup.__index = SpawnGroup

function SpawnGroup:create()
	local new = setmetatable(
		{
			spawns = {}
		},
		SpawnGroup
	)
	
	return new
end


function SpawnGroup:addSpawn(spawn)
	self.spawns[#self.spawns + 1] = spawn
end


function SpawnGroup:getRandomSpawn()
	if #self.spawns == 0 then
		return
	end
	
	return math.random(1, #self.spawns);
end