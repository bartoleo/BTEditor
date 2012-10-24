--- intro gamestate
Gamestate.intro = Gamestate.new()
local state = Gamestate.intro

state.dt = 0
state.autoexit = 5

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param enter (LUADOC TODO add enter description) 
-- @param pre (LUADOC TODO add pre description) 
-- @return (LUADOC TODO add return description) 
function state:enter(pre, action, ...)
  
  love.graphics.setBackgroundColor(255, 255, 255)
  
  getScreenMode()

end

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param leave (LUADOC TODO add leave description) 
-- @return (LUADOC TODO add return description) 
function state:leave()
  images.splash_bteditor = nil
end

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param update (LUADOC TODO add update description) 
-- @param dt (LUADOC TODO add dt description) 
-- @return (LUADOC TODO add return description) 
function state:update(dt)
  state.dt = state.dt + dt
  if state.dt >= state.autoexit then
    Gamestate.switch(Gamestate.editor,"INIT")
  end
end

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param draw (LUADOC TODO add draw description) 
-- @return (LUADOC TODO add return description) 
function state:draw()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(images.bteditor_splash,screen_middlex-images.bteditor_splash:getWidth()/2,screen_middley-images.bteditor_splash:getHeight()/2)

  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.setFont(fonts[",12"])
  love.graphics.printf("Version "..game_version..
    [===[
 
Behaviour Tree Editor made in Love

thanks to:

all of Love project and forums
[love2d.org]

Nikolai Resokov for LoveFrames lib
[github.com/NikolaiResokav/LoveFrames]

vrld for hump lib
[github.com/vrld/hump]

Bart van Strien for SECS class
[love2d.org/wiki/Simple_Educative_Class_System]

]===]
  ,screen_middlex-60 , screen_middley-70, 300, 'left')
  love.graphics.printf(math.floor(state.autoexit-state.dt).." seconds remaining or mouse click to continue", 0, screen_height-20, screen_width, 'center')
end

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param keypressed (LUADOC TODO add keypressed description) 
-- @param key (LUADOC TODO add key description) 
-- @param unicode (LUADOC TODO add unicode description) 
-- @return (LUADOC TODO add return description) 
function state:keypressed(key, unicode)
  --- to go directly in new editor
  if key == "lctrl" then
    debug.debug()
  	Gamestate.switch(Gamestate.editor,"INIT")
  else
    Gamestate.switch(Gamestate.editor,"INIT")
  end
end

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param mousepressed (LUADOC TODO add mousepressed description) 
-- @param x (LUADOC TODO add x description) 
-- @param y (LUADOC TODO add y description) 
-- @param button (LUADOC TODO add button description) 
-- @return (LUADOC TODO add return description) 
function state:mousepressed(x, y, button)
  Gamestate.switch(Gamestate.editor,"INIT")
end
