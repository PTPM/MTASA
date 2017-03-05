addEvent( "playHitSound", true )
addEventHandler( "playHitSound", localPlayer, function ( headshot )
	if headshot then
		playSound("hitsound-heavy.wav")
	else
		playSound("hitsound-light.wav")
	end
end )