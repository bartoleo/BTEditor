--- intro gamestate
Gamestate.intro = Gamestate.new()
local state = Gamestate.intro

state.dt = 0
state.autoexit = 4

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param enter (LUADOC TODO add enter description) 
-- @param pre (LUADOC TODO add pre description) 
-- @return (LUADOC TODO add return description) 
function state:enter(pre, action, ...)
  
  love.graphics.setBackgroundColor(64, 64, 64)
  
  getScreenMode()

end

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param leave (LUADOC TODO add leave description) 
-- @return (LUADOC TODO add return description) 
function state:leave()
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
  love.graphics.setFont(fonts[",20"])
  love.graphics.print(game_title, 20, 40, -0.3)
  love.graphics.printf("Love Editor for Behaviour Trees", 0, screen_middley, screen_width, 'center')
  love.graphics.printf(math.floor(state.autoexit-state.dt).." seconds remaining or mouse click to continue", 0, screen_middley+25, screen_width, 'center')
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
