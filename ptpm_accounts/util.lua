local databaseColumns = {}

function prepareDatabase( database )
	executeSQLQuery( "CREATE TABLE IF NOT EXISTS " .. escapeStr( database ) .. " ( username VARCHAR(22) )" )
	databaseColumns[database] = {}
	databaseColumns[database]["username"] = true
end

function addColumnToDatabase( database, column, definition, default )
	if default ~= nil then
		default = " DEFAULT " .. tostring( default ) .. " NOT NULL"
	else
		default = ""
	end
	
	-- if anyone find another way to check if column exists feel free to fix
	local exists = executeSQLQuery( "SELECT " .. escapeStr( column ) .. " FROM " .. escapeStr( database ) ) -- can't avoid the error print in server log :(
	if type(exists) ~= "table" then
		outputDebugString( "NOTE: Ignore 'no such column' error above, it's fixed", 0, 255, 0, 0 )
		executeSQLQuery( "ALTER TABLE " .. escapeStr( database ) .. " ADD " .. escapeStr( column ) .. " " .. escapeStr( definition ) .. escapeStr( default ) )
		outputServerLog( "- New column '" .. column .. "' (" .. definition .. default .. ") added to database '" .. database .. "'" )
	end
	databaseColumns[database][column] = true
end

function doesColumnExistOnDatabase( database, column )
	if databaseColumns[database] then
		if databaseColumns[database][column] then
			return true
		end
	end
	return false
end

function removeIllegalCharacters( text )
	return string.gsub( text, "[^A-Za-z0-9_%-]", "" ) or ""
end

function escapeStr( str )
	return string.gsub( str, "['\"´`]", "" ) or ""
end