SpawnArea = {}
SpawnArea.__index = SpawnArea

function SpawnArea:create(posX, posY, posZ)
	local new = setmetatable(
		{
			posX = posX,
			posY = posY,
			posZ = posZ
		},
		Spawn
	)

	return new
end

function SpawnArea:isInside(player)
	return nil
end




SpawnAreaCube = {}
SpawnAreaCube.__index = SpawnAreaCube
setmetatable(SpawnAreaCube, {__index = SpawnArea})

function SpawnAreaCube:create(posX, posY, posZ, width, depth, height)
	local new = setmetatable(
		{
			posX = posX,
			posY = posY,
			posZ = posZ,
			width = width,
			depth = depth,
			height = height,
		},
		SpawnAreaCube
	)

	return new
end

function SpawnAreaCube:isInside(player)
	local x, y, z = getElementPosition(player)

	return x >= self.posX and x <= (self.posX + self.width) and
			y >= self.posY and y <= (self.posY + self.depth) and
			z >= self.posZ and z <= (self.posZ + self.height)
end




SpawnAreaSphere = {}
SpawnAreaSphere.__index = SpawnAreaSphere
setmetatable(SpawnAreaSphere, {__index = SpawnArea})

function SpawnAreaSphere:create(posX, posY, posZ, radius)
	local new = setmetatable(
		{
			posX = posX,
			posY = posY,
			posZ = posZ,
			radius = radius,
			radiusSqr = radius ^ 2,
		},
		SpawnAreaSphere
	)

	return new
end


function SpawnAreaSphere:isInside(player)
	local x, y, z = getElementPosition(player)

	return distanceSquared(x, y, z, self.posX, self.posY, self.posZ) <= self.radiusSqr
end