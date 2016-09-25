﻿--[[ 
    exports.scoreboard:scoreboardAddColumn( "ptpm.score.roundsWon", root, 66, "Games won", 3 )
    exports.scoreboard:scoreboardAddColumn( "ptpm.score.roundsLost", root, 63, "Games lost", 4 )    
    exports.scoreboard:scoreboardAddColumn( "ptpm.score.pmWins", root, 66, "Wins as PM", 5 )
    exports.scoreboard:scoreboardAddColumn( "ptpm.score.pmLosses", root, 79, "Losses as PM", 6 )
    exports.scoreboard:scoreboardAddColumn( "ptpm.score.pmKills", root, 88, "Times killed PM", 7 )
    exports.scoreboard:scoreboardAddColumn( "ptpm.score.hpHealed", root, 111, "HP healed as medic", 8 )
    exports.scoreboard:scoreboardAddColumn( "ptpm.score.damage", root, 79, "Damage given", 9 )
    exports.scoreboard:scoreboardAddColumn( "ptpm.score.damageTaken", root, 81, "Damage taken", 10 )
    
    loadScoreboardStats( source )

function loadScoreboardStats(player)
  local kills = 0
  local deaths = 0
  local pmWins = 0
  local pmKills = 0
  local hpHealed = 0
  local roundsWon = 0
  local roundsLost = 0
  local damage = 0
  local pmLosses = 0
  local damageTaken = 0
    
  if isRunning( "ptpm_accounts" ) then
    kills = (exports.ptpm_accounts:getPlayerStatistic( player, "kills" ) or 0)
    deaths = (exports.ptpm_accounts:getPlayerStatistic( player, "deaths" ) or 0)
    pmWins = (exports.ptpm_accounts:getPlayerStatistic( player, "pmvictory" ) or 0)
    pmKills = (exports.ptpm_accounts:getPlayerStatistic( player, "pmkills" ) or 0)
    hpHealed = (exports.ptpm_accounts:getPlayerStatistic( player, "hphealed" ) or 0)
    roundsWon = (exports.ptpm_accounts:getPlayerStatistic( player, "roundswon" ) or 0)
    roundsLost = (exports.ptpm_accounts:getPlayerStatistic( player, "roundslost" ) or 0)
    damage = (exports.ptpm_accounts:getPlayerStatistic( player, "damage" ) or 0)
    pmLosses = (exports.ptpm_accounts:getPlayerStatistic( player, "pmlosses" ) or 0)
    damageTaken = (exports.ptpm_accounts:getPlayerStatistic( player, "damagetaken" ) or 0)
  end
    
  setElementData( player, "ptpm.score.kills", string.format( "%d", kills ) )
  setElementData( player, "ptpm.score.deaths", string.format( "%d", deaths ) )
  setElementData( player, "ptpm.score.pmWins", string.format( "%d", pmWins ) )
  setElementData( player, "ptpm.score.pmKills", string.format( "%d", pmKills ) )
  setElementData( player, "ptpm.score.hpHealed", string.format( "%d", hpHealed ) )
  setElementData( player, "ptpm.score.roundsWon", string.format( "%d", roundsWon ) )
  setElementData( player, "ptpm.score.roundsLost", string.format( "%d", roundsLost ) )
  setElementData( player, "ptpm.score.damage", string.format( "%d", damage ) )
  setElementData( player, "ptpm.score.pmLosses", string.format( "%d", pmLosses ) )
  setElementData( player, "ptpm.score.damageTaken", string.format( "%d", damageTaken ) )
  
end
      
      if currentPM then
        local pmWins = getElementData( currentPM, "ptpm.pmWins" ) or 0
        
        if isRunning( "ptpm_accounts" ) then
          --exports.ptpm_accounts:setPlayerAccountData(currentPM,{["pmVictory"] = ">+1"})
          pmWins = (exports.ptpm_accounts:getPlayerStatistic( currentPM, "pmvictory" ) or pmWins) + 1
          exports.ptpm_accounts:setPlayerStatistic( currentPM, "pmvictory", pmWins )
        else
          pmWins = pmWins + 1
        end
        
        setElementData( currentPM, "ptpm.score.pmWins", string.format( "%d", pmWins ) )
        setElementData( currentPM, "ptpm.pmWins", pmWins, false)
        
        local players = getElementsByType( "player" )
        for _, p in ipairs( players ) do
          if p and isElement( p ) and isPlayerActive( p ) then
            local classID = getPlayerClassID( p )
            if classID then
              if classes[classID].type == "pm" or classes[classID].type == "bodyguard" or classes[classID].type == "police" then
                local roundsWon = getElementData( p, "ptpm.roundsWon" ) or 0
      
                if isRunning( "ptpm_accounts" ) then        
                  roundsWon = (exports.ptpm_accounts:getPlayerStatistic( p, "roundswon" ) or roundsWon) + 1
                  exports.ptpm_accounts:setPlayerStatistic( p, "roundswon", roundsWon )
                else
                  roundsWon = roundsWon + 1
                end
                
                setElementData( p, "ptpm.score.roundsWon", string.format( "%d", roundsWon ) )
                setElementData( p, "ptpm.roundsWon", roundsWon, false)
              elseif classes[classID].type == "terrorist" then
                local roundsLost = getElementData( p, "ptpm.roundsLost" ) or 0
      
                if isRunning( "ptpm_accounts" ) then        
                  roundsLost = (exports.ptpm_accounts:getPlayerStatistic( p, "roundslost" ) or roundsLost) + 1
                  exports.ptpm_accounts:setPlayerStatistic( p, "roundslost", roundsLost )
                else
                  roundsLost = roundsLost + 1
                end
                
                setElementData( p, "ptpm.score.roundsLost", string.format( "%d", roundsLost ) )
                setElementData( p, "ptpm.roundsLost", roundsLost, false)
              end
            end
          end
        end     
      end		
        local pmLosses = getElementData( currentPM, "ptpm.pmWins" ) or 0
        
        if isRunning( "ptpm_accounts" ) then
          pmLosses = (exports.ptpm_accounts:getPlayerStatistic( currentPM, "pmlosses" ) or pmLosses) + 1
          exports.ptpm_accounts:setPlayerStatistic( currentPM, "pmlosses", pmLosses )
        else
          pmLosses = pmLosses + 1
        end
        
        setElementData( currentPM, "ptpm.score.pmLosses", string.format( "%d", pmLosses ) )
        setElementData( currentPM, "ptpm.pmLosses", pmLosses, false)
        
      
                if isRunning( "ptpm_accounts" ) then        
                  roundsWon = (exports.ptpm_accounts:getPlayerStatistic( p, "roundswon" ) or roundsWon) + 1
                  exports.ptpm_accounts:setPlayerStatistic( p, "roundswon", roundsWon )
                else
                  roundsWon = roundsWon + 1
                end
                
                setElementData( p, "ptpm.score.roundsWon", string.format( "%d", roundsWon ) )
                setElementData( p, "ptpm.roundsWon", roundsWon, false)
  local nick = exports.ptpm_accounts:getSensitiveUserdata( target, "username" )
    text = text .. "\nAccount: Playing as guest"

addEventHandler("onPlayerDamage", root,
function(attacker, weapon, bodypart, loss)
  if attacker and getElementType(attacker) == "player" and attacker ~= source then
    local damage = getElementData( attacker, "ptpm.damage" ) or 0
    local damageTaken = getElementData( source, "ptpm.damageTaken" ) or 0

    if isRunning( "ptpm_accounts" ) then        
      damage = (exports.ptpm_accounts:getPlayerStatistic( attacker, "damage" ) or damage) + loss
      exports.ptpm_accounts:setPlayerStatistic( attacker, "damage", damage )
      damageTaken = (exports.ptpm_accounts:getPlayerStatistic( source, "damagetaken" ) or damageTaken) + loss
      exports.ptpm_accounts:setPlayerStatistic( source, "damagetaken", damageTaken )
    else
      damage = damage + loss
      damageTaken = damageTaken + loss
    end
    
    setElementData( attacker, "ptpm.score.damage", string.format( "%d", damage ) )
    setElementData( attacker, "ptpm.damage", damage, false)
    setElementData( source, "ptpm.score.damageTaken", string.format( "%d", damageTaken ) )
    setElementData( source, "ptpm.damageTaken", damageTaken, false)
  end
end)