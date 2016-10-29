-- screenWidth,screenHeight, dxGetStatus:VideoCardName,dxGetStatus:VideoCardRAM,dxGetStatus:SettingWindowed,dxGetStatus:SettingDrawDistance,dxGetStatus:Setting32BitColor,dxGetStatus:SettingFOV
requestedData = {}
requestedDataStr = ""

screenWidth, screenHeight = guiGetScreenSize()
dxInfo = dxGetStatus ( )

table.insert(requestedData, screenWidth)
table.insert(requestedData, screenHeight)
table.insert(requestedData, dxInfo.VideoCardName)
table.insert(requestedData, dxInfo.VideoCardRAM)
table.insert(requestedData, dxInfo.SettingWindowed and "window" or "full")
table.insert(requestedData, dxInfo.SettingDrawDistance)
table.insert(requestedData, dxInfo.Setting32BitColor and "32" or "16")
table.insert(requestedData, dxInfo.SettingFOV)

for _,v in ipairs(requestedData) do
	requestedDataStr = requestedDataStr .. v .. ","
end

requestedDataStr = string.sub(requestedDataStr, 0, -2)
triggerServerEvent ( "logClientData", resourceRoot, requestedDataStr )