addEvent( "playHitSound", true )
addEventHandler( "playHitSound", localPlayer, function ( headshot )
	local sound = playSound("hitsound.wav")
	
	if headshot then
		setSoundVolume(sound, 1)
		setSoundSpeed ( sound, 1 )
	else
		setSoundVolume(sound, 0.3)
		setSoundSpeed ( sound, 1.2 )
	end
end )