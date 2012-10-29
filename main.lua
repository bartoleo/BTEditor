-- game infos
game_id = "BTEditor"
game_title = "BTEditor"
game_version = "01.00"

-- libraries
Gamestate = require "lib/gamestate"
Camera = require "lib/camera"
require("lib/SECS")
require("lib/utils")
require("lib/dumper")
require("lib/xml_collect")
require("lib/json")
require("lib/loveframes/init")

--profiler = require "profiler"

function love.load()

    -- Set filesystem identity
    love.filesystem.setIdentity(game_id)

    love.graphics.setCaption(game_title.." v."..game_version)
	
    readScreenMode("configs.txt")
	
    -- Set Random Seed
    math.randomseed(os.time());
    math.random()
    math.random()
    math.random()
  	
	-- lazy font loading
	fonts = setmetatable({}, {__index = function(t,k)
		local s = split(k,",")
		local f
		local ss = tonumber(s[2])
		if (s[1]=="" or s[1]==nil) then
		  f = love.graphics.newFont(ss)
		else
		  f = love.graphics.newFont(s[1],ss)
		end
		rawset(t, k, f)
		return f
	end })

	-- lazy image loading with multiple extensions and recursive search
	images = setmetatable({}, {__index = function(t,k)
		local f
		extensions = {".png",".jpg",".gif"}
		for _,v in pairs(extensions) do
  		  if love.filesystem.exists( "images/"..k..v  ) then
  		    f = love.graphics.newImage( "images/"..k..v )
			break
		  else
		    local filesearch=recursiveSearchFile("images",k..v)
			if filesearch ~= "" then
			  f = love.graphics.newImage( filesearch )
			  break
			end
		  end
		end
		rawset(t, k, f)
		return f
	end })

    gamestates = {}
    loadfromdir(gamestates, "states", "lua", require)

    classes = {}
    loadfromdir(classes, "classes", "lua", require)

    --images = {}
    loadfromdir(images, "images/autoload", "png", love.graphics.newImage)

    sounds = {}
    loadfromdir(sounds, "sounds/autoload", "ogg", love.sound.newSoundData)
 
    music = {}
    loadfromdir(music, "music/autoload", "ogg", love.audio.newSource)

    Gamestate.registerEvents()
    Gamestate.switch(Gamestate[(arg[2] and arg[2]:match("--state=(.+)") or "intro")])

end

