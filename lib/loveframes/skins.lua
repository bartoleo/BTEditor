--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

-- skins library
loveframes.skins = {}

-- available skins
loveframes.skins.available = {}

--[[---------------------------------------------------------
	- func: Register(skin)
	- desc: registers a skin
--]]---------------------------------------------------------
function loveframes.skins.Register(skin)
	
	local name = skin.name
	local author = skin.author
	local version = skin.version
	local namecheck = loveframes.skins.available[name]
	local dir = loveframes.config["DIRECTORY"] .. "/skins/" ..name
	local dircheck = love.filesystem.isDirectory(dir)
	local images = loveframes.util.GetDirContents(dir .. "/images")
	local indeximages = loveframes.config["INDEXSKINIMAGES"]
	
	if name == "" or not name then
		loveframes.util.Error("Could not register skin: Invalid or missing name data.")
	end
	
	if author == "" or not author then
		loveframes.util.Error("Could not register skin: Invalid or missing author data.")
	end
	
	if version == "" or version == nil then
		loveframes.util.Error("Could not register skin: Invalid or missing version data.")
	end
	
	if namecheck then
		loveframes.util.Error("Could not register skin: A skin with the name '" ..name.. "' already exists.")
	end
	
	if not dircheck then
		loveframes.util.Error("Could not register skin: Could not find a directory for skin '" ..name.. "'.")
	end
	
	loveframes.skins.available[name] = skin
	loveframes.skins.available[name].dir = dir
	loveframes.skins.available[name].images = {}
	
	if #images > 0 and indeximages == true then
	
		for k, v in ipairs(images) do
			loveframes.skins.available[name].images[v.name .. "." .. v.extension] = love.graphics.newImage(v.fullpath)
		end
		
	end
	
end