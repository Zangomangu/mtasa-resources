local root = getRootElement ()
local thisResourceRoot = getResourceRootElement(getThisResource())

function thisResourceStart ()
	outputChatBox ( "FR test script loaded - type 'commands' in the console for a list of commands." )
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
	    bindKey ( v, "l", "down", "Lights on/off", toggleVehicleLights  )
	    bindKey ( v, "k", "down", "Lock/unlock door", toggleVehicleLock )
	end
end

function playerWasted ( ammo, killer, weapon )
	local x, y, z = getElementPosition ( source )
	setTimer ( destroyElement, 3000, 1, createBlip ( x, y, z, 0, 2, 255, 255, 255, 170 ) )
end      

function playerJoin ()
	outputChatBox ( "Type 'commands' in the console for a list of commands.", source )
    bindKey ( source, "l", "down", toggleVehicleLights, "Lights on/off" )
    bindKey ( source, "k", "down", toggleVehicleLock, "Lock/unlock door" )
end

addEventHandler ( "onResourceStart", thisResourceRoot, thisResourceStart )
addEventHandler ( "onPlayerWasted", root, playerWasted )
addEventHandler ( "onPlayerJoin", root, playerJoin )

function consoleCommands ( player, commandName )
	if ( player ) then
		outputConsole ( "World: settime HH MM, setweather ID, blendweather ID, setgravity LEVEL (default .008), setgamespeed SPEED (default 1)", player )
		outputConsole ( "Player: kill, give ID/NAME AMMO, jetpack, setstat ID VALUE, setstyle ID, setplayergravity LEVEL (default .008)", player )
		outputConsole ( " setskin ID, listclothes TYPE, addclothes TYPE TEXTURE MODEL, removeclothes TYPE", player )
		outputConsole ( "Vehicle: createvehicle ID/NAME [PLATE], repair, setcolor [ID ID ID ID]", player )			
		outputConsole ( " checkupgrades, addupgrade ID, removeupgrade ID, setpaintjob ID", player )  
		outputConsole ( " attachtrailer TRAILERID [VEHICLEID], lights (l), lock (k)", player )
		outputConsole ( "Misc: getpos, setpos, warpto NAME", player )
	end
end

function consoleKill ( player, commandName )
	if ( player ) then
		killPlayer ( player )
	end
end
function consoleCreateVehicle ( player, commandName, first, second, third )
	if ( player ) then
		local id, x, y, z, r, d = 0, 0, 0, 0, 0, 5
		local plate = false
		r = getPlayerRotation ( player )
		x, y, z = getElementPosition ( player )
		x = x + ( ( math.cos ( math.rad ( r ) ) ) * d )
		y = y + ( ( math.sin ( math.rad ( r ) ) ) * d )
		if ( third ) then
			id = getVehicleIDFromName ( first .. " " .. second )
			plate = third
		elseif ( second ) then
			if ( getVehicleIDFromName ( first .. " " .. second ) ) then
				id = getVehicleIDFromName ( first .. " " .. second )
     		else
     			id = getVehicleIDFromName ( first )
				if ( not id ) then
					id = tonumber ( first )
				end
     			plate = second
			end			
		else
			id = getVehicleIDFromName ( first )
			if ( not id ) then
				id = tonumber ( first )
			end
		end
		local veh = false
		if ( plate == false ) then
			veh = createVehicle ( id, x, y, z, 0, 0, r )
			toggleVehicleRespawn ( veh, false )
		else
			veh = createVehicle ( id, x, y, z, 0, 0, r, plate )
			toggleVehicleRespawn ( veh, false )
		end
     	if ( veh == false ) then  outputConsole ( "Failed to create vehicle.", player )  end
	end
end
function consoleGive ( player, commandName, string1, string2, string3 )
	if ( player ) then
	    if ( string3 ) then
         	local status = giveWeapon ( player, getWeaponIDFromName ( string1 .. " " .. string2 ), string3, true )
         	if ( not status ) then
				outputConsole ( "Failed to give weapon.", player )
			end
	    elseif ( string2 ) then
	        if ( tonumber ( string1 ) ) then
	        	local status = giveWeapon ( player, string1, string2, true )
         		if ( not status ) then
					outputConsole ( "Failed to give weapon.", player )
				end
			else
			    local status = giveWeapon ( player, getWeaponIDFromName ( string1 ), string2, true )
         		if ( not status ) then
					outputConsole ( "Failed to give weapon.", player )
				end
			end
		else
		    outputConsole ( "Failed to give weapon.", player )
	    end
	end
end
function consoleWarpTo ( player, commandName, player2nick )
	if ( player ) then
    	local x, y, z, r, d = 0, 0, 0, 0, 2.5
    	local player2 = getPlayerFromNick ( player2nick )
    	if ( player2 ) then
        	if ( isPlayerInVehicle ( player2 ) ) then
        		local player2vehicle = getPlayerOccupiedVehicle ( player2 )
--outputDebugString ( "The player is in a " .. getVehicleName ( player2vehicle ) )
				local maxseats = getVehicleMaxPassengers ( player2vehicle ) + 1
--outputDebugString ( "The vehicle has " .. maxseats .. " seats" )
				local i = 0
				while ( i < maxseats ) do
					if ( getVehicleOccupant ( player2vehicle, i ) ) then
--outputDebugString ( "Seat " .. i .. " is occupied" )
						i = i + 1
					else
--outputDebugString ( "Seat " .. i .. " is free" )
						break
					end
				end
				if ( i < maxseats ) then
--outputDebugString ( "i (" .. i .. ") is less than maxseats (" .. maxseats .. "), warping player..." )
					--setTimer ( warpPlayerIntoVehicle, 1000, 1, player, player2vehicle, i )
					--fadeCamera ( player, false, 1, 0, 0, 0 )
					--setTimer ( fadeCamera, 1000, 1, player, true, 1 )
					local status = warpPlayerIntoVehicle ( player, player2vehicle, i )
					if ( status ) then
--outputDebugString ( "warpPlayerIntoVehicle returned true" )
					else
--outputDebugString ( "warpPlayerIntoVehicle returned false" )
					end
				else
					outputConsole ( "Sorry, the player's vehicle is full (" .. getVehicleName ( player2vehicle ) .. " " .. i .. "/" .. maxseats .. ")", player )
				end
			else
				x, y, z = getElementPosition ( player2 )
				r = getPlayerRotation ( player2 )
 	   			x = x - ( ( math.cos ( math.rad ( r + 90 ) ) ) * d )
			   	y = y - ( ( math.sin ( math.rad ( r + 90 ) ) ) * d )
   				setTimer ( setElementPosition, 1000, 1, player, x, y, z )
   				setTimer ( setPlayerRotation, 1000, 1, player, r )
				fadeCamera ( player, false, 1, 0, 0, 0 )
				setTimer ( fadeCamera, 1000, 1, player, true, 1 )
			end
		else
			outputConsole ( "No such player.", player )
		end
	end
end
function consoleSetTime ( player, commandName, hour, minute )
	if ( player ) then
		if ( setTime ( hour, minute ) == false ) then  outputConsole ( "Failed to set time.", player )  end
	end
end
function consoleSetWeather ( player, commandName, id )
	if ( player ) then
		if ( setWeather ( id ) == false ) then  outputConsole ( "Failed to set weather.", player )  end
	end
end
function consoleBlendWeather ( player, commandName, id )
	if ( player ) then
		if ( setWeatherBlended ( id ) == false ) then  outputConsole ( "Failed to blend weather.", player )  end
	end
end
function consoleSetGravity ( player, commandName, level )
	setGravity ( tonumber ( level ) )
end
function consoleSetGameSpeed ( player, commandName, value )
	setGameSpeed ( tonumber ( value ) )
end

function consoleSetFightingStyle ( player, commandName, id )
	if ( player and id ) then
	    local status = setPlayerFightingStyle ( player, tonumber(id) )
		if ( not status ) then
			outputConsole ( "Failed to set fighting style.", player )
		end
	end
end
function consoleSetSkin ( player, commandName, id )
	if ( player and id ) then
    	local blip = getElementData ( player, "blip" )
		local x, y, z = getElementPosition ( player )
		local r = getPlayerRotation ( player )
		local status = spawnPlayer ( player, x, y, z, r, id )
		if ( status ) then
    		if ( blip ) then
    			destroyElement ( blip )
    		end
		else
			outputConsole ( "Failed to spawn player.", player )
		end
	end
end
function consoleListClothes ( player, commandName, type )
	if ( player and type ) then
		type = tonumber ( type )
		local clothesstrings = {}
		local length_index = 0
		local texture, model = getClothesByTypeIndex ( type, 0 )
		outputConsole ( getClothesTypeName ( type ) .. " (" .. type ..") textures and models:", player )
		local index = 1
		while ( getClothesByTypeIndex ( type, index ) ) do
			texture, model = getClothesByTypeIndex ( type, index )
			if ( math.mod ( index-1, 10 ) ~= 0 ) then --
				clothesstrings[length_index] = clothesstrings[length_index] .. ", " .. texture .. " " .. model
			else
			    length_index = length_index + 1
				clothesstrings[length_index] = texture .. " " .. model
			end
			index = index + 1
		end
		for k,v in ipairs(clothesstrings) do
			outputConsole ( v, player )
		end
	end
end
function consoleAddClothes ( player, commandName, type, texture, model )
	if ( player ) then
		if ( getPlayerSkin ( player ) == 0 ) then
			if ( addPlayerClothes ( player, texture, model, tonumber ( type ) ) == false ) then
				outputConsole ( "Failed to add clothes.", player )
			end
		else
			outputConsole ( "You must have the CJ model.", player )
		end
	end
end
function consoleRemoveClothes ( player, commandName, type )
	if ( player ) then
		if ( getPlayerSkin ( player ) == 0 ) then
			if ( removePlayerClothes ( player, tonumber ( type ) ) == false ) then
				outputConsole ( "Failed to remove clothes.", player )
			end
		else
			outputConsole ( "You must have the CJ model.", player )
		end
	end
end
function consoleSetPlayerGravity ( player, commandName, level )
	if ( player ) then
		local success = setPlayerGravity ( player, tonumber ( level ) )
		if (not success) then
			outputConsole( "Failed to set player gravity", player )
		end
	end
end

function consoleRepairVehicle ( player, commandName )
	if ( player ) then
		if ( isPlayerInVehicle ( player ) ) then
			local veh = getPlayerOccupiedVehicle ( player )
			fixVehicle ( veh )
		else
		    outputConsole ( "You must be in a vehicle.", player )
		end
	end
end
function consoleSetColor ( player, commandName, col1, col2, col3, col4 )
	if ( player ) then
		if ( isPlayerInVehicle ( player ) ) then
			local veh = getPlayerOccupiedVehicle ( player )
			local col1old, col2old, col3old, col4old = getVehicleColor ( veh )
			if ( ( not col1 ) or col1 == "-1" ) then  col1 = col1old  end 
			if ( ( not col2 ) or col2 == "-1" ) then  col2 = col2old  end 
			if ( ( not col3 ) or col3 == "-1" ) then  col3 = col3old  end 
			if ( ( not col4 ) or col4 == "-1" ) then  col4 = col4old  end
			if ( setVehicleColor ( veh, tonumber ( col1 ), tonumber ( col2 ), tonumber ( col3 ), tonumber ( col4 ) ) == false ) then
				outputConsole ( "Failed to set vehicle color.", player )
			end 
		else
		    outputConsole ( "You must be in a vehicle.", player )
		end		
	end
end
function consoleCheckUpgrades ( player, commandName )
	if ( player ) then
		if ( isPlayerInVehicle ( player ) ) then
			local veh = getPlayerOccupiedVehicle ( player )
		    local upgrades = getVehicleUpgrades ( veh )
			local slotstrings = {}
		    outputConsole ( "Compatible upgrades for " .. getVehicleName ( veh ) .. ":", player )
		    local id = 1000
		    while ( id <= 1193 ) do
		        if ( addVehicleUpgrade ( veh, id ) ) then
		        	if ( slotstrings[getVehicleUpgradeSlotName ( id )] ) then
		        		slotstrings[getVehicleUpgradeSlotName ( id )] = slotstrings[getVehicleUpgradeSlotName ( id )] .. ", " .. id
		        	else
		        		slotstrings[getVehicleUpgradeSlotName ( id )] = " " .. getVehicleUpgradeSlotName ( id ) .. " - " .. id
		        	end
                    removeVehicleUpgrade ( veh, id )
				end
				id = id + 1
			end
			for k,v in ipairs(slotstrings) do
				outputConsole ( v, player )
			end
			for k,v in ipairs(upgrades) do
   				addVehicleUpgrade ( veh, v )
			end
		else
		    outputConsole ( "You must be in a vehicle.", player )
		end
	end
end
function consoleAddUpgrade ( player, commandName, id )
	if ( player ) then
		if ( isPlayerInVehicle ( player ) ) then
			local vehicle = getPlayerOccupiedVehicle ( player )
			local success = addVehicleUpgrade ( vehicle, tonumber ( id ) )
			if ( success ) then
			    outputConsole ( getVehicleUpgradeSlotName ( tonumber ( id ) ) .. " upgrade added.", player )
			else
				outputConsole ( "Failed to add upgrade.", player )
			end
		else
		    outputConsole ( "You must be in a vehicle!", player )
		end
	end
end
function consoleRemoveUpgrade ( player, commandName, id )
	if ( player ) then
		if ( isPlayerInVehicle ( player ) ) then
			local veh = getPlayerOccupiedVehicle ( player )
			if ( removeVehicleUpgrade ( veh, tonumber ( id ) ) ) then
			    outputConsole ( getVehicleUpgradeSlotName ( tonumber ( id ) ) .. " upgrade removed.", player )
			else
				outputConsole ( "Failed to remove upgrade.", player )
			end
		else
		    outputConsole ( "You must be in a vehicle.", player )
		end
	end
end
function consoleSetPaintJob ( player, commandName, id )
	if ( player ) then
		if ( isPlayerInVehicle ( player ) ) then
			local veh = getPlayerOccupiedVehicle ( player )
			if ( setVehiclePaintjob ( veh, tonumber ( id ) ) ) then
			    outputConsole ( "Paintjob " .. id .. " set.", player )
			else
				outputConsole ( "Failed to set paintjob.", player )
			end
		else
		    outputConsole ( "You must be in a vehicle.", player )
		end
	end
end

function consoleJetPack ( player, commandName )
	if ( player ) then
		if ( not doesPlayerHaveJetPack ( player ) ) then
			local status = givePlayerJetPack ( player )
			if ( not status ) then
				outputConsole ( "Failed to give jetpack.", player )
			end
		else
			local status = removePlayerJetPack ( player )
			if ( not status ) then
				outputConsole ( "Failed to remove jetpack.", player )
			end
		end
	end
end
function consoleAttachTrailer ( player, commandName, trailerid, vehicleid )
	if ( player ) then
		if ( vehicleid ) then
			local sx, sy, id, x, y, z, r, d = 0, 0, 0, 0, 0, 0, 0, 5
			r = getPlayerRotation ( player )
			sx, sy, z = getElementPosition ( player )
			x = sx + ( math.cos ( math.rad ( r ) ) * d )
			y = sy + ( math.sin ( math.rad ( r ) ) * d )
			local veh = createVehicle ( tonumber ( vehicleid ), x, y, z, 0, 0, r )
			x = sx + ( ( math.cos ( math.rad ( r ) ) ) * ( d + 7.5 ) )
			y = sy + ( ( math.sin ( math.rad ( r ) ) ) * ( d + 7.5 ) )
			local trailer = createVehicle ( tonumber ( trailerid ), x, y, z, 0, 0, r )
            if ( veh and trailer ) then
				toggleVehicleRespawn ( veh, false )
				toggleVehicleRespawn ( trailer, false )
            	if ( attachTrailerToVehicle ( veh, trailer ) == false ) then  outputConsole ( "Failed to attach vehicle.", player )  end
			else
				outputConsole ( "Failed to create vehicle and/or trailer.", player )
			end
		else			
			if ( isPlayerInVehicle ( player ) ) then
				local veh = getPlayerOccupiedVehicle ( player )
				local sx, sy, id, x, y, z, rx, ry, rz, d = 0, 0, 0, 0, 0, 0, 0, 0, 0, 7.5
				rx, ry, rz = getVehicleRotation ( veh )
				sx, sy, z = getElementPosition ( veh )
				x = sx + ( ( math.cos ( math.rad ( rz + 270 ) ) ) * d )
				y = sy + ( ( math.sin ( math.rad ( rz + 270 ) ) ) * d )
				local trailer = createVehicle ( tonumber ( trailerid ), x, y, z, rx, ry, rz )
     			if ( trailer ) then
					toggleVehicleRespawn ( trailer, false )
            		if ( attachTrailerToVehicle ( veh, trailer ) == false ) then  outputConsole ( "Failed to attach vehicle.", player )  end
				else
					outputConsole ( "Failed to create trailer.", player )
				end
			else
			    outputConsole ( "You must be in a vehicle if VEHICLEID argument is excluded.", player )
			end
		end
	end
end
function consoleSetStat ( player, commandName, id, value )
	if ( player ) then
		id = tonumber ( id )
		value = tonumber ( value )
		if ( id and value ) then
	        local flag = setPlayerStat ( player, id, value )
			if ( flag ) then
				outputConsole ( "Stat " .. id .. " set to: " .. getPlayerStat ( player, id ), player ) -- doesn't work
			else
				outputConsole ( "Failed to set stat.", player )
			end
		end
	end
end
function consoleGetPosition ( player, commandName )
	local vehicle = getPlayerOccupiedVehicle ( player )
	if ( vehicle ) then
		local trailer = getVehicleTowedByVehicle ( vehicle ) 
		if ( trailer ) then
			local x, y, z = getElementPosition ( vehicle )
			local rx, ry, rz = getVehicleRotation ( vehicle )
			local x2, y2, z2 = getElementPosition ( trailer )
			local rx2, ry2, rz2 = getVehicleRotation ( trailer )
			outputChatBox ( "Vehicle pos/rot: " .. x .. " " .. y .. " " .. z .. ", " .. rx .. " " .. ry .. " " .. rz, player )
			outputChatBox ( "Trailer pos/rot: " .. x2 .. " " .. y2 .. " " .. z2 .. ", " .. rx2 .. " " .. ry2 .. " " .. rz2, player )
		else
			local x, y, z = getElementPosition ( vehicle )
			local rx, ry, rz = getVehicleRotation ( vehicle )
			outputChatBox ( "Vehicle pos/rot: " .. x .. " " .. y .. " " .. z .. ", " .. rx .. " " .. ry .. " " .. rz, player )
		end
	else
		local x, y, z = getElementPosition ( player )
		local r = getPlayerRotation ( player )
		outputChatBox ( "Player pos/rot: " .. x .. " " .. y .. " " .. z .. ", " .. r, player )
	end
end
function consoleSetPosition ( player, commandName, x, y, z )
	x = tonumber ( x ) 
	y = tonumber ( y ) 
	z = tonumber ( z )
	if ( x and y and z ) then 
		local vehicle = getPlayerOccupiedVehicle ( player )
		if ( vehicle ) then
			setElementPosition ( vehicle, x, y, z )
		else
			setElementPosition ( player, x, y, z )
		end
	end
end

function consoleCreateObject ( player, commandName, distance, id )
	if ( player ) then
		local r = getPlayerRotation ( player )
		local x, y, z = getElementPosition ( player )
		x = x + ( ( math.cos ( math.rad ( r ) + math.pi/2 ) ) * distance )
		y = y + ( ( math.sin ( math.rad ( r ) + math.pi/2 ) ) * distance )
		local obj = createObject ( id, x, y, z )
     	if ( not obj ) then
			outputConsole ( "Failed to create object.", player )
		end
	end
end
function consoleCreateMarker ( player, commandName, distance, type, size, r, g, b, a )
	if ( player ) then
		local r = getPlayerRotation ( player )
		local x, y, z = getElementPosition ( player )
		x = x + ( ( math.cos ( math.rad ( r ) + math.pi/2 ) ) * distance )
		y = y + ( ( math.sin ( math.rad ( r ) + math.pi/2 ) ) * distance )
		local marker = createMarker ( x, y, z, type, size, r, g, b, a )
     	if ( not marker ) then
		 	outputConsole ( "Failed to create marker.", player )
		end
	end
end
function consoleOutputAllVehiclesToLog ( player, commandName )
	local vehicles = getElementsByType("vehicle")
	for k,v in ipairs(vehicles) do
	    local x, y, z = getElementPosition(v)
	    local rx, ry, rz = getVehicleRotation(v)
	    outputServerLog("<vehicle id=\"" .. getVehicleName(v) .. "\" model=\"" .. getVehicleID(v) .. "\" posX=\"" .. x .. "\" posY=\"" .. y .. "\" posZ=\"" .. z .. "\" rotX=\"" .. rx .. "\" rotY=\"" .. ry .. "\" rotZ=\"" .. rz .. "\"/>")
	end
end

addCommandHandler ( "commands", consoleCommands )
addCommandHandler ( "kill", consoleKill )
addCommandHandler ( "createvehicle", consoleCreateVehicle )
addCommandHandler ( "give", consoleGive )
addCommandHandler ( "warpto", consoleWarpTo )
addCommandHandler ( "settime", consoleSetTime )
addCommandHandler ( "setweather", consoleSetWeather )
addCommandHandler ( "blendweather", consoleBlendWeather )
addCommandHandler ( "setgravity", consoleSetGravity )
addCommandHandler ( "setgamespeed", consoleSetGameSpeed )
addCommandHandler ( "setstyle",  consoleSetFightingStyle )
addCommandHandler ( "setskin", consoleSetSkin )
addCommandHandler ( "listclothes", consoleListClothes )
addCommandHandler ( "addclothes", consoleAddClothes )
addCommandHandler ( "removeclothes", consoleRemoveClothes )
addCommandHandler ( "setplayergravity", consoleSetPlayerGravity )
addCommandHandler ( "repair", consoleRepairVehicle )
addCommandHandler ( "setcolor", consoleSetColor )
addCommandHandler ( "checkupgrades", consoleCheckUpgrades )
addCommandHandler ( "addupgrade", consoleAddUpgrade )
addCommandHandler ( "removeupgrade", consoleRemoveUpgrade )
addCommandHandler ( "setpaintjob", consoleSetPaintJob )
addCommandHandler ( "jetpack", consoleJetPack )
addCommandHandler ( "attachtrailer", consoleAttachTrailer )
addCommandHandler ( "setstat", consoleSetStat )
addCommandHandler ( "getpos", consoleGetPosition )
addCommandHandler ( "setpos", consoleSetPosition )
addCommandHandler ( "createobject", consoleCreateObject )
addCommandHandler ( "createmarker", consoleCreateMarker )
addCommandHandler ( "outputAllVehiclesToLog", consoleOutputAllVehiclesToLog )

function toggleVehicleLights ( player, key, state )
	if ( getPlayerOccupiedVehicleSeat ( player ) == 0 ) then
		local veh = getPlayerOccupiedVehicle ( player )
		if ( getVehicleOverrideLights ( veh ) ~= 2 ) then
			setVehicleOverrideLights ( veh, 2 )
		else
			setVehicleOverrideLights ( veh, 1 )
		end
	end
end
function toggleVehicleLock ( player, key, state )
	if ( getPlayerOccupiedVehicleSeat ( player ) == 0 ) then		
		local veh = getPlayerOccupiedVehicle ( player )
		if ( isVehicleLocked ( veh ) ) then
			setVehicleLocked ( veh, false )
		else
			setVehicleLocked ( veh, true )
		end
	end
end
