-- game infos
game_id = "BTEditor"
game_title = "BTEditor"
game_version = "01.01"

-- libraries
Gamestate = require "lib/gamestate"
Camera = require "lib/camera"
Inspector = require "lib/inspect"
require("lib/SECS")
require("lib/utils")
require("lib/dumper")
require("lib/xml_collect")
require("lib/json")
require("lib/loveframes/init")
require("lib/BTLua")
require("lib/assetloader")

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

    Gamestate.registerEvents()
    require ("states/intro")
    Gamestate.switch(Gamestate.intro)

end

