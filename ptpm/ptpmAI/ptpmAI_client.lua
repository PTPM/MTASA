
addEventHandler( "onClientRender",root,
   function( )
      local px, py, pz, tx, ty, tz, dist
      px, py, pz = getCameraMatrix( )
      for _, v in ipairs( getElementsByType 'ped' ) do
         tx, ty, tz = getElementPosition( v )
         dist = math.sqrt( ( px - tx ) ^ 2 + ( py - ty ) ^ 2 + ( pz - tz ) ^ 2 )
         if dist < 30.0 then
            if isLineOfSightClear( px, py, pz, tx, ty, tz, true, false, false, true, false, false, false,localPlayer ) then
               local sx, sy, sz = getPedBonePosition( v, 2 )
               local x,y = getScreenFromWorldPosition( sx, sy, sz + 0.3 )
               if x then -- getScreenFromWorldPosition returns false if the point isn't on screen
			   
			    local n = getElementData(v,"name")
				local c = getElementData ( v, "nameTagColor")	
				
				dxDrawText( n, x+1, y+1, x+1, y+1, tocolor(0, 0, 0,64), 1, "default" , "center" )
                dxDrawText( n, x, y, x, y, tocolor(c[1],c[2],c[3]), 1, "default" , "center" )
				
				local armorWidth = 130
				local armorHeight = 25
				
				-- Offset for HP/armor bar
				y = y + 28
				
				-- Armor
				dxDrawRectangle ( x - (armorWidth/2), y - (armorHeight/2), armorWidth, armorHeight , tocolor(222,222,222, 200) )
				
				-- HP
				dxDrawRectangle ( x - (armorWidth/2) + 5, y - (armorHeight/2) +5, armorWidth-10, armorHeight-10 , tocolor(0,255,0, 200) )
               end
            end
         end
      end
   end
)