local announcerBetaOptIn = false
local messageQueue = {} --structure: array( array("file"=>"x.mp3", "length"=>3000), ...)
local currentlyPlaying = false

addCommandHandler("abdb", function()
	outputChatBox(toJSON(messageQueue))
end)

function playNextQueueItem()
	if currentlyPlaying then 
		-- Already playing, do nothing
		outputDebugString("ANN playing halted, still have something")
		return 
	end

	if #messageQueue>0 then
		-- Play the file OR a silence, if false
		local pauseBetweenEntries = 0
		local sound = messageQueue[1]
		if sound["file"] then
			playSound(sound["file"])
			pauseBetweenEntries = 300
			
			outputDebugString("ANN playing " ..sound["file"] .. " (" ..sound["length"].." ms)")
		else
			outputDebugString("ANN playing pause of " .. sound["length"])
		end
		table.remove(messageQueue, 1)
		
		currentlyPlaying = true
		
		-- Allow next sound to play after this file + optional pauseBetweenEntries
		outputDebugString("ANN set timer for next line to play after: " .. (sound["length"] + pauseBetweenEntries))
		setTimer(function()
			currentlyPlaying = false
			playNextQueueItem()
		end, sound["length"] + pauseBetweenEntries, 1)
		
	else
		-- No messages, do nothing
	end
end


addEvent( "playAnnouncer", true )
addEventHandler( "playAnnouncer", localPlayer, function (sound, delay)
	if announcerBetaOptIn then	
		-- Add it to the queue:
		if delay then
			table.insert(messageQueue, { ["file"]=false, ["length"]=delay })
		end
		table.insert(messageQueue, sound)
		playNextQueueItem()
	else
		outputDebugString("ANN but no aboi")
	end
end )


addCommandHandler( "aboi", function()
	announcerBetaOptIn = true
	outputChatBox("ANN aboi")
end )