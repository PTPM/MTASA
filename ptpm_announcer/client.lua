local announcerBetaOptIn = false

addEvent( "playAnnouncer", true )
addEventHandler( "playAnnouncer", localPlayer, function (soundFile, delay)
	delay = delay or 50
	outputDebugString("ANN " ..soundFile.. " with " .. delay)
	if announcerBetaOptIn then
		setTimer(function()
			playSound(soundFile)
		end, delay, 1) 
	end
end )


addCommandHandler( "aboi", function()
	announcerBetaOptIn = true
end )