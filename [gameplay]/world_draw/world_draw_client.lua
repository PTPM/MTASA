local elements = {}

local draw = {
	distance = 100,
	distanceAlpha = 70, -- full alpha this distance and closer
	drawScale = {0.5, 1.1},
}

-- types:
-- {id = "", draw = "healthbar", reqs = {}}
-- {id = "", draw = "text", args = { "the text" }}
-- {id = "", draw = "functionName", args = {}}	

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		draw.distance = math.pow(draw.distance, 2)
		draw.distanceAlpha = math.pow(draw.distanceAlpha, 2)
		draw.alphaDiff = draw.distance - draw.distanceAlpha
	end
)

addEventHandler("onClientElementDataChange", root,
	function(dataName, oldValue)
		if dataName == "world.draw" then
			local data = getElementData(source, dataName)

			if not data then
				if elements[source] then
					elements[source] = nil
				end

				return
			end

			local totalHeight = 0

			for i = #data, 1, -1 do
				if type(data[i].draw) == "string" then
					if data[i].draw == "text" then
						data[i].cacheHeight = 16
						totalHeight = totalHeight + 16
					elseif data[i].draw == "healthbar" then
						data[i].cacheHeight = 80 / 12
						totalHeight = totalHeight + (80 / 12)
						local t = getElementType(source)
						local maxHealth = 100
						local offset = 0

						if t == "vehicle" then
							maxHealth = 750
							offset = 249
						end

						data[i].args = {}
						data[i].args[1] = maxHealth
						data[i].args[2] = offset
					else
						if _G[data[i].draw] then
							data[i].draw = _G[data[i].draw]
							data[i].cacheHeight = data[i].draw()
							totalHeight = totalHeight + data[i].cacheHeight
						end
					end
				end

				if data[i].reqs then
					for j = #data[i].reqs, 1, -1 do
						data[i].reqs[j] = _G[data[i].reqs[j]]

						if not data[i].reqs[j] then
							table.remove(data[i].reqs, j)
						end
					end
				end

				if data[i].draw ~= "text" and data[i].draw ~= "healthbar" and type(data[i].draw) ~= "function" then
					table.remove(data, i)
				end
			end

			elements[source] = {data = data, height = totalHeight, streamed = isElementStreamedIn(source)}
		end
	end
)

addEventHandler("onClientElementDestroy", root,
	function()
		if elements[source] then
			elements[source] = nil
		end
	end
)

addEventHandler("onClientElementStreamIn", root,
	function()
		if elements[source] then
			elements[source].streamed = true
		end
	end
)

addEventHandler("onClientElementStreamOut", root,
	function()
		if elements[source] then
			elements[source].streamed = false
		end
	end
)


addEventHandler("onClientHUDRender", root,
	function()
		local cx, cy, cz = getCameraMatrix()

		for element, drawings in pairs(elements) do
			if drawings.streamed then

				local passedReq = true
				-- optimise away the case of a single draw that doesn't pass reqs
				-- this way we don't need to check distance or screen visibility
				if #drawings.data == 1 and drawings.data[1].reqs then
					for _, req in pairs(drawings.data[1].reqs) do
						if not req(element) then
							passedReq = false
							break
						end
					end
				end

				if passedReq then
					local ex, ey, ez = getElementPosition(element)
					local dist = distanceSquared(cx, cy, cz, ex, ey, ez)

					if dist <= draw.distance then
						local screenX, screenY = getScreenFromWorldPosition(ex, ey, ez, 0.06)

						if screenX and screenY then 	
							-- 0 = far away, 1 = on top
							local distScale = 1 - (dist / draw.distance)

							local alpha = 1 - ((math.max(dist - draw.distanceAlpha, 0)) / draw.alphaDiff)
							local scale = lerp(draw.drawScale[1], draw.drawScale[2], distScale)
							local totalHeight = -((drawings.height * scale) / 2)

							for i, drawing in ipairs(drawings.data) do
								local passed = true

								if drawing.reqs then
									for _, req in pairs(drawing.reqs) do
										if not req(element) then
											passed = false
											break
										end
									end
								end

								--dxDrawLine(screenX - 150, screenY - totalHeight, screenX + 150, screenY - totalHeight, tocolor(255, 0, 0, 255), 1)

								if passed and (drawing.ignoreLOS or isLineOfSightClear(cx, cy, cz, ex, ey, ez, true, true, false, true, false, false, false, element)) then
									if drawing.draw == "text" then
										dxDrawText(drawing.args[1], screenX - 50, screenY - totalHeight - 20, screenX + 50, screenY - totalHeight, tocolor(255, 255, 255, alpha * 255), scale, "default-bold", "center", "center", false, false, false)		
										
										totalHeight = totalHeight + (drawing.cacheHeight * scale)
									elseif drawing.draw == "healthbar" then
										local width = scale * 80
										local height = width / 12

										dxDrawRectangle(screenX - (width / 2) - 2, screenY - height - 2 - totalHeight, width + 4, height + 4, tocolor(0, 0, 0, 255 * alpha))

										local healthScale = math.max(0, getElementHealth(element) - drawing.args[2]) / drawing.args[1]
										dxDrawRectangle(screenX - (width / 2), screenY - height - totalHeight, width * healthScale, height, tocolor(200 * (1 - healthScale), 150 * healthScale, 0, 255 * alpha))
										totalHeight = totalHeight + (drawing.cacheHeight * scale)
									else
										drawing.draw(element, screenX, screenY - totalHeight, distScale, scale, alpha, unpack(drawing.args))
										totalHeight = totalHeight + (drawing.cacheHeight * scale)
									end

									totalHeight = totalHeight + (2 * scale)
								end
							end
						end
					end
				end
			end
		end
	end
)

function drawIcon(element, screenX, screenY, distScale, scale, alpha, path, text)
	if not element then
		return 50
	end

	local width = scale * 50
	local height = scale * 50

	--xDrawImage(screenX - (width / 2) - 2, screenY - height - 2, width + 4, height + 4, "images/icons/" .. path .. ".png", 0, 0, 0, tocolor(0, 0, 0, alpha * 255))
	--dxDrawImage(screenX - (width / 2), screenY - height, width, height, "images/icons/" .. path .. ".png", 0, 0, 0, tocolor(255, 255, 255, alpha * 255))
	dxDrawText(text, screenX - (width / 2), screenY - height, screenX + (width / 2), screenY, tocolor(0, 102, 204, alpha * 255), scale, "default-bold", "center", "center", false, false, false)				

	return height
end


-- function attach3DDraw(element, id, checkLOS, draw, args)
-- 	if not element or not isElement(element) then
-- 		return
-- 	end

-- 	local data = getElementData(element, "world.draw") or {}

-- 	for _, drawing in ipairs(data) do
-- 		if drawing.id == id then
-- 			drawing.checkLOS = checkLOS
-- 			drawing.draw = draw
-- 			drawing.args = args
-- 			setElementData(element, "world.draw", data)
-- 			return
-- 		end
-- 	end

-- 	table.insert(data, {
-- 		id = id,
-- 		checkLOS = checkLOS,
-- 		draw = draw,
-- 		args = args
-- 	})

-- 	outputChatBox("Set draw " .. id)

-- 	setElementData(element, "world.draw", data)
-- end

-- function detach3DDraw(element, id)
-- 	if not element or not isElement(element) then
-- 		return
-- 	end

-- 	local data = getElementData(element, "world.draw")

-- 	if not data then
-- 		return
-- 	end

-- 	local removed = false
-- 	for i = #data, 1, -1 do
-- 		if data[i].id == id then
-- 			table.remove(data, i)
-- 			removed = true
-- 			outputChatBox("Removed draw " .. id)
-- 		end
-- 	end

-- 	if removed then
-- 		if #data == 0 then
-- 			data = nil
-- 		end

-- 		setElementData(element, "world.draw", data)
-- 	end
-- end

-- function detachAll3DDraws(element)
-- 	if not element then
-- 		for e, drawings in pairs(elements) do
-- 			setElementData(e, "world.draw", nil)
-- 		end

-- 		return
-- 	end

-- 	if not isElement(element) then
-- 		return
-- 	end
	
-- 	setElementData(e, "world.draw", nil)
-- end



function lerp(startValue, endValue, t)
	return startValue + ((endValue - startValue) * t)
end


function distanceSquared(aX, aY, aZ, bX, bY, bZ)
	local vX = aX - bX
	local vY = aY - bY
	local vZ = aZ - bZ

	return vX*vX + vY*vY + vZ*vZ
end