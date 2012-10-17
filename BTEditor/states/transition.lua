--- transition gamestate
Gamestate.transition = Gamestate.new()
local state = Gamestate.transition
local _pre = nil
local _next = nil
local _args = nil
state.dt = 0
state.autoexit = 10
state.type = "FADE"

Gamestate.transition.screenshot = nil

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param enter (LUADOC TODO add enter description) 
-- @param pre (LUADOC TODO add pre description) 
-- @return (LUADOC TODO add return description) 
function state:enter(pre, nextstate, type, dt, ...)
 
  getScreenMode()
 
  _pre = pre
  _next = nextstate
  if (type) then
    state.type=type
  end
  if (dt) then
    state.autoexit = dt
  end
  _args = arg
  state.dt = 0
  
  Gamestate.transition.screenshot = love.graphics.newImage(love.graphics.newScreenshot( ))
  
  love.graphics.setBackgroundColor(0, 0, 0)
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
    --print (_args[1])
    Gamestate.switch(_next,unpack(_args))
	_next = nil
	_pre = nil
	_args = nil
	love.graphics.clear ( )
  end
end

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param draw (LUADOC TODO add draw description) 
-- @return (LUADOC TODO add return description) 
function state:draw()

  --print ("transition.draw"..255-((state.dt/state.autoexit)*254))
  
  if (state.type=="FADE") then
    love.graphics.setColor(255, 255, 255, 255-((state.dt/state.autoexit)*254))
    love.graphics.draw(Gamestate.transition.screenshot,0,0)
  end

end

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param keypressed (LUADOC TODO add keypressed description) 
-- @param key (LUADOC TODO add key description) 
-- @param unicode (LUADOC TODO add unicode description) 
-- @return (LUADOC TODO add return description) 
function state:keypressed(key, unicode)
end

--- state (LUADOC TODO add resume)
-- state (LUADOC TODO add description)
-- @param mousepressed (LUADOC TODO add mousepressed description) 
-- @param x (LUADOC TODO add x description) 
-- @param y (LUADOC TODO add y description) 
-- @param button (LUADOC TODO add button description) 
-- @return (LUADOC TODO add return description) 
function state:mousepressed(x, y, button)
end

