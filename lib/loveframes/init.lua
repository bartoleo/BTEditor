--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

local BASE = (...) .. '.'
if string.sub(BASE,-5)=="init." then
	BASE = string.sub(BASE,1,string.len(BASE)-6)
end

-- central library table
loveframes = {}

-- library info
loveframes.info                      = {}
loveframes.info.author               = "Nikolai Resokav"
loveframes.info.version              = "0.9.4"
loveframes.info.stage                = "Alpha"

-- library configurations
loveframes.config                    = {}
loveframes.config["DIRECTORY"]       = BASE
loveframes.config["DEFAULTSKIN"]     = "Blue"
loveframes.config["ACTIVESKIN"]      = "Blue"
loveframes.config["INDEXSKINIMAGES"] = true
loveframes.config["DEBUG"]           = true

-- misc library vars
loveframes.drawcount                 = 0
loveframes.lastselection             = 0
loveframes.selectiondelay            = 0.05
loveframes.selectionstartdelay       = 0.50
loveframes.selecting                 = false
loveframes.hoverobject               = false
loveframes.modalobject               = false
loveframes.selectedobject            = false
loveframes.basicfont                 = love.graphics.newFont(12)
loveframes.basicfontsmall            = love.graphics.newFont(10)

--[[---------------------------------------------------------
	- func: load()
	- desc: loads the library
--]]---------------------------------------------------------
function loveframes.load()
	
	-- install directory of the library
	local dir = loveframes.config["DIRECTORY"]
	
	-- require the internal base libraries
	require(dir .. "/third-party/middleclass")
	require(dir .. "/util")
	require(dir .. "/skins")
	require(dir .. "/templates")
	require(dir .. "/debug")
	
	-- create a list of gui objects and skins
	local objects = loveframes.util.GetDirContents(dir .. "/objects")
	local skins = loveframes.util.GetDirContents(dir .. "/skins")
	local templates = loveframes.util.GetDirContents(dir .. "/templates")
	
	-- loop through a list of all gui objects and require them
	for k, v in ipairs(objects) do
		if v.extension == "lua" then
			require(v.path .. "/" ..v.name)
		end
	end
	
	-- loop through a list of all gui templates and require them
	for k, v in ipairs(templates) do
		if v.extension == "lua" then
			require(v.path .. "/" ..v.name)
		end
	end
	
	-- loop through a list of all gui skins and require them
	for k, v in ipairs(skins) do
		if v.extension == "lua" then
			require(v.path .. "/" ..v.name)
		end
	end
	
	-- create the base gui object
	loveframes.base = base:new()
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates all library objects
--]]---------------------------------------------------------
function loveframes.update(dt)

	local object = loveframes.base
	
	object:update(dt)

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws all library objects
--]]---------------------------------------------------------
function loveframes.draw()

	local object = loveframes.base
	
	-- set the drawcount to zero
	loveframes.drawcount = 0
	
	-- draw the base object
	object:draw()
	
	-- draw the debug library
	loveframes.debug.draw()
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function loveframes.mousepressed(x, y, button)

	local object = loveframes.base
	
	object:mousepressed(x, y, button)
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function loveframes.mousereleased(x, y, button)

	local object = loveframes.base
	
	object:mousereleased(x, y, button)
	
	-- reset the hover object
	if button == "l" then
		loveframes.hoverobject = false
		loveframes.selectedobject = false
	end
	
end

--[[---------------------------------------------------------
	- func: keypressed(key)
	- desc: called when the player presses a key
--]]---------------------------------------------------------
function loveframes.keypressed(key, unicode)

	local object = loveframes.base
	
	object:keypressed(key, unicode)
	
end

--[[---------------------------------------------------------
	- func: keyreleased(key)
	- desc: called when the player releases a key
--]]---------------------------------------------------------
function loveframes.keyreleased(key)

	local object = loveframes.base
	
	object:keyreleased(key)
	
end

--[[---------------------------------------------------------
	- func: Create(type, parent)
	- desc: creates a new object or multiple new objects
			(based on the method used) and returns said
			object or objects for further manipulation
--]]---------------------------------------------------------
function loveframes.Create(data, parent)
	
	if type(data) == "string" then
	
		-- make sure the object specified is valid
		if not _G[data] then
			loveframes.util.Error("Error creating object: Invalid object '" ..data.. "'.")
		end
		
		-- create the object
		local object = _G[data]:new()
		
		-- apply template properties to the object
		loveframes.templates.ApplyToObject(object)
		
		-- if the object is a tooltip, return it and go no further
		if data == "tooltip" then
			return object
		end
		
		-- remove the object if it is an internal
		if object.internal then
			object:Remove()
			return
		end
		
		-- parent the new object by default to the base gui object
		object.parent = loveframes.base
		table.insert(loveframes.base.children, object)
		
		-- if the parent argument is not nil, make that argument the object's new parent
		if parent then
			object:SetParent(parent)
		end
		
		-- return the object for further manipulation
		return object
		
	elseif type(data) == "table" then

		-- table for creation of multiple objects
		local objects = {}
		
		-- this function reads a table that contains a layout of object properties and then
		-- creates objects based on those properties
		local function CreateObjects(t, o, c)
		
			local child = c or false
			
			for k, v in pairs(t) do
			
				-- current default object
				local object = _G[v.type]:new()
				
				-- indert the object into the table of objects being created
				table.insert(objects, object)
				
				-- parent the new object by default to the base gui object
				object.parent = loveframes.base
				table.insert(loveframes.base.children, object)
				
				if o then
					object:SetParent(o)
				end
				
				-- loop through the current layout table and assign the properties found
				-- to the current object
				for i, j in pairs(v) do
					
					if i ~= "children" and i ~= "func" then
						if child == true then
							if i == "x" then
								object["staticx"] = j
							elseif i == "y" then
								object["staticy"] = j
							else
								object[i] = j
							end
						else
							object[i] = j
						end
					elseif i == "children" then
						CreateObjects(j, object, true)
					end
					
				end
				
				if v.func then
					v.func(object)
				end
				
			end
			
		end
		
		-- create the objects
		CreateObjects(data)
		
		return objects
		
	end
	
end

-- load the library
loveframes.load()