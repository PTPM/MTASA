local elements = {}

addEventHandler("onResourceStart", resourceRoot,
	function()
		-- setTimer(function()
		-- 	for i, v in ipairs(getElementsByType("vehicle")) do
		-- 		--setElementData(v, "world.draw", {{checkLOS = true, draw = "text", args = {tostring(getElementModel(v))}}}, false)
		-- 		--setElementData(v, "world.draw", {{checkLOS = true, draw = "drawIcon", args = {"shield", tostring("70")}}}, false)
		-- 		--setElementData(v, "world.draw", {{checkLOS = true, draw = "healthbar", args = {"question", tostring(getElementModel(v))}}}, false)
		-- 		--setElementData(v, "world.draw", {
		-- 			--{id = "healthb", draw = "healthbar", reqs = {"getVehicleOccupant"}},
		-- 			--{id = "model", draw = "text", args = {tostring(getElementModel(v))}},
		-- 			--{id = "shield", draw = "drawIcon", args = {"shield", tostring("Need /heal!")}}			
		-- 		--})
		-- 	end
		-- end, 1000, 1)
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		for element in pairs(elements) do
			setElementData(element, "world.draw", nil)
		end
	end
)

addEventHandler("onElementDestroy", root,
	function()
		if elements[source] then
			elements[source] = nil
		end
	end
)

function attach3DDraw(element, id, draw, args, reqs, ignoreLOS)
	if not element or not isElement(element) then
		return
	end

	local data = getElementData(element, "world.draw") or {}

	for _, drawing in ipairs(data) do
		if drawing.id == id then
			drawing.ignoreLOS = ignoreLOS
			drawing.draw = draw
			drawing.args = args
			drawing.reqs = reqs
			setElementData(element, "world.draw", data)
			return
		end
	end

	local newData = {
		id = id,
		draw = draw
	}

	if args then
		newData.args = args
	end

	if reqs then
		newData.reqs = reqs
	end

	if ignoreLOS then
		newData.ignoreLOS = ignoreLOS
	end

	table.insert(data, newData)

	elements[element] = true

	--outputChatBox("Set draw " .. id)

	setElementData(element, "world.draw", data)
end


function detach3DDraw(element, id)
	if not element or not isElement(element) then
		return
	end

	local data = getElementData(element, "world.draw")

	if not data then
		return
	end

	local removed = false
	for i = #data, 1, -1 do
		if data[i].id == id then
			table.remove(data, i)
			removed = true
			--outputChatBox("Removed draw " .. id)
		end
	end

	if removed then
		if #data == 0 then
			data = nil
			elements[element] = nil
		end

		setElementData(element, "world.draw", data)
	end
end

function detachAll3DDraws(element)
	if not element then
		for e, _ in pairs(elements) do
			setElementData(e, "world.draw", nil)
		end

		elements = {}

		return
	end

	if not isElement(element) then
		return
	end
	
	setElementData(element, "world.draw", nil)

	elements[element] = nil
end

-- addCommandHandler("a3d",
-- 	function(player, cmd, id)
-- 		attach3DDraw(player, id, false, "text", {id})
-- 	end
-- )
-- addCommandHandler("r3d",
-- 	function(player, cmd, id)
-- 		detach3DDraw(player, id)
-- 	end
-- )