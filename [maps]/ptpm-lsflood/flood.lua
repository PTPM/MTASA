local water = nil

addEventHandler("onResourceStart",resourceRoot,
	function()
		water = createWater(20,-2870,15.5,2998,-2870,15.5,20,-1152,15.5,2998,-1152,15.5) 
		setWaterLevel(water,15.5)		
	end
)

addEventHandler("onResourceStop",resourceRoot,
	function()
		--destroyElement(water)
		--water = nil
	end
)