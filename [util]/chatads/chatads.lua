-- Original author: "uhm" from the MTASA Community 
-- Date: 29 september 2016
-- Description: Show your promotional messages on a configurable interval
-- Released under MIT License ©2016 uhm

local adIntervalInSeconds = tonumber(get("adInterval"))
local adFile = get("adFile")
local adPrefix = get("defaultColor")

addEventHandler ( "onResourceStart", getRootElement(), function()
	if (source==getResourceRootElement(getThisResource())) then
	
		-- Check config
		if (type(adIntervalInSeconds) ~= "number") then
			outputDebugString("ChatAds resource misconfiguration: adInterval is not a number. Change value in Admin Panel > Resources > chatads > Settings",1);
			return false
		end

		-- Read from file...
		 local file = fileOpen(adFile);
		 local ads = {}
		 if file then
			local buffer
			while not fileIsEOF(file) do 
				buffer = fileRead(file, 51200) 
			end
			fileClose(file)
			ads = split(buffer,"\n")
			outputDebugString("ChatAds resource loaded: " .. #ads .. " ads found")
			 
			lastAdID = -1
		
			-- Display ad
			function displayAd()
				if #ads==0 then 
					return false
				elseif #ads>1 then
					-- Make sure the ad isn't the same as the previous ad
					while true do
						theAdID = math.random(1,#ads)		
						if theAdID ~= lastAdID then 
							lastAdID = theAdID
							break
						end
					end
				else 
					-- If there is only one ad, then display that
					theAdID = 1
				end
				
				outputChatBox(adPrefix .. ads[theAdID], getRootElement(), 255,255,255, true)
				lastAdID = theAdID
			end
			
			-- Set the repeating timer
			if #ads>0 then
				setTimer(displayAd, adIntervalInSeconds * 1000, 0)
			else
				outputDebugString("ChatAds resource loaded, but didn't find ads from the ad file.",2);
			end
			
			
		else
			-- File not found
			outputDebugString("ChatAds resource loaded, but ad file is missing or unreadable.",1);
		end
	end
end )