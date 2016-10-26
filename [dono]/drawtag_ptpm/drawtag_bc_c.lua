addCommandHandler("tdraw",function()
	local drawtag = getResourceFromName("drawtag")
	if not (drawtag and getResourceRootElement(drawtag)) then return end
	local show = not exports.drawtag:isDrawingWindowVisible()
	exports.drawtag:showDrawingWindow(show)
end)

addCommandHandler("tedit",function()
	local drawtag = getResourceFromName("drawtag")
	if not (drawtag and getResourceRootElement(drawtag)) then return end
	local x,y,z = getElementPosition(localPlayer)
	local tag = getNearestTag(x,y,z)
	if not tag then return end
	local png = exports.drawtag:getTagTexture(tag)
	exports.drawtag:setEditorTexture(png)
end)

addCommandHandler("tcopy",function()
	local drawtag = getResourceFromName("drawtag")
	if not (drawtag and getResourceRootElement(drawtag)) then return end
	local x,y,z = getElementPosition(localPlayer)
	local tag = getNearestTag(x,y,z)
	if not tag then return end
	triggerServerEvent("drawtag_bc:copyTag",tag)
end)

