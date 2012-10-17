
--- game gamestate
Gamestate.editor = Gamestate.new()
local state = Gamestate.editor

-- constant

-- GAME environment
EDITOR={}
EDITOR.inputenabled = false
EDITOR.filename = nil
EDITOR.title = "new Tree"
EDITOR.nodes = {}
EDITOR.nodeselected = nil
EDITOR.dolayout=false

function state:enter(pre, action, level,  ...)

  getScreenMode()
  
  -- disable input
  EDITOR.inputenabled = false
   
  -- logic
  if action=="INIT" then
  end 
  
  loveframes.config["DEBUG"]=false
  
  EDITOR.gui = {}

  local object

  object = loveframes.Create("button")
  object:SetSize(100, 15)
  object:SetPos(screen_width-105, 5)
  object:SetText("Clickable Button")
  object.OnClick = state.clickEvent
  EDITOR.gui.button = object

  object = loveframes.Create("text")
  object:SetPos(5, 5)
  object:SetMaxWidth(100)
  object:SetText("Title")
  EDITOR.gui.lbl_title = object
  
  object = loveframes.Create("textinput")
  object:SetPos(60, 5)
  object:SetWidth(490)
  EDITOR.gui.txt_title = object

  EDITOR.gui.txt_title:SetText ("prova")


  EDITOR.nodes = {}
  state:addnode(node:new("","START","","__start__",screen_middlex,32,nil,nil,nil,1))
  EDITOR.dolayout=true

  EDITOR.camera = Camera.new(screen_middlex,screen_middley, 1, 0)

  EDITOR.moveto = false
  endx=0
  startx=0
  endy=0
  starty=0
  
  state:changenodeselected(EDITOR.nodes[1])

  love.graphics.setBackgroundColor(255, 255, 255)

  -- enable input
  EDITOR.inputenabled = true

end

function state:leave()
  --profiler.stop()
  collectgarbage("restart")
end

function state:update(dt) 
  
    if EDITOR.dolayout then
      state:layout()
    end

    if EDITOR.moveto then
      local _x,_y = love.mouse.getPosition()
      endx,endy = EDITOR.camera:worldCoords(_x,_y)
      EDITOR.camera:move(startx-endx, starty-endy)
      startx,starty=EDITOR.camera:worldCoords(_x,_y)
    end

    loveframes.update(dt)

end

function state:draw()

  EDITOR.camera:attach()
  state.drawGrid()
  state.drawNodes()
  EDITOR.camera:detach()
  
  loveframes.draw()  
end

function state:keypressed(key, unicode)
  if key=="lctrl" then
    loveframes.config["DEBUG"]=not loveframes.config["DEBUG"]
  end

  if EDITOR.inputenabled then  
    if key==" " and EDITOR.nodeselected then
      EDITOR.camera = Camera.new(EDITOR.nodeselected.x,EDITOR.nodeselected.y,1,0)
    end

    if key=="a" then
      if EDITOR.nodeselected then
        local _node = node:new("","new","",nil,nil,nil,nil,nil,EDITOR.nodeselected,nil)
        _node.name = EDITOR.nodeselected.name..".".._node.indexchild
        state:addnode(_node)
        EDITOR.dolayout=true
      end
    end

    loveframes.keypressed(key, unicode)
  end

end

function state:mousepressed(x, y, button)

  loveframes.mousepressed(x, y, button)

  if EDITOR.inputenabled then
    local _x,_y = EDITOR.camera:worldCoords(x,y)
    if button=="l" and state:nodeselected(_x,_y) then
    else
      startx,starty = _x,_y
      EDITOR.moveto = true
      if button=="wd" then
        EDITOR.camera = Camera.new(_x,_y,EDITOR.camera.zoom/1.5,EDITOR.camera.rot)
        --EDITOR.camera = EDITOR.camera:move(_x,_y)
      end
      if button=="wu" then
        EDITOR.camera = Camera.new(_x,_y,EDITOR.camera.zoom*1.5,EDITOR.camera.rot)
        --EDITOR.camera = EDITOR.camera:move(_x,_y)
      end
    end
  end

end

function state:mousereleased(x, y, button)

  if EDITOR.inputenabled then
    EDITOR.moveto = false
  end

  loveframes.mousereleased(x, y, button)

end

function state:keyreleased(key)

  if EDITOR.inputenabled then
  end

  loveframes.keyreleased(key)

end

function state.clickEvent(object, mousex , mousey)
  if object==EDITOR.gui.button then
    state.createDialog()
  end
end

function state.createDialog(onClose)
    local frame = loveframes.Create("frame")
    frame:SetModal (true)
    frame:ShowCloseButton(false)
    frame.OnClose = onClose
    frame:Center()
    EDITOR.gui.dialog = frame
    EDITOR.gui.dialog.returnvalue = false
    
    local object = loveframes.Create("button",frame)
    object:SetPos(frame:GetWidth()/2-10-object:GetWidth(),frame:GetHeight()-30)
    object:SetText("OK")
    object.OnClick = function() EDITOR.gui.dialog.returnvalue = true if (EDITOR.gui.dialog.OnClose) then EDITOR.gui.dialog.OnClose(EDITOR.gui.dialog) end EDITOR.gui.dialog:Remove() end
    object = loveframes.Create("button",frame)
    object:SetText("Cancel")
    object:SetPos(frame:GetWidth()/2+10,frame:GetHeight()-30)
    object.OnClick = function() EDITOR.gui.dialog.returnvalue = false if (EDITOR.gui.dialog.OnClose) then EDITOR.gui.dialog.OnClose(EDITOR.gui.dialog) end EDITOR.gui.dialog:Remove() end
end

function state.drawGrid()
    love.graphics.setColor(0,0,0,32)
    for i=1,screen_height/32 do
      love.graphics.line(0,i*32,screen_width,i*32)
    end
    for i=1,screen_width/32 do
      love.graphics.line(i*32,0,i*32,screen_height)
    end
end

function state.drawNodes()
    for i,v in pairs(EDITOR.nodes) do
       v:draw()
    end
end

function state:addnode(pnode)
  table.insert(EDITOR.nodes,pnode)
end

function state:changenodeselected(pnode)
  EDITOR.nodeselected = pnode
  for i,v in pairs(EDITOR.nodes) do
     if v.id == pnode.id then
       v.selected=true
     else 
       v.selected=false
     end
  end  
end

function state:nodeselected(px,py)
  for i,v in pairs(EDITOR.nodes) do
     if state.collidepoint(px,py,v.x,v.y,v.width,v.height) then
       state:changenodeselected(v)
       return true
     end
  end
  return false
end

function state:layout()
  local _collision = false
  state:updatenodes()
  for i,v in pairs(EDITOR.nodes) do
    v.y = (v.level-1) *64+32
    for ii,vv in pairs(EDITOR.nodes) do
      if vv ~= v and vv.level == v.level then
        if state.collidebox(v.x,v.y,v.width,v.height,vv.x,vv.y,vv.height,vv.width) then
          _collision = true
          local _a,_b
          _a,_b = minbyattribute(v,vv,"levelindex")
          _a.x = _a.x -10
          _b.x = _b.x +5
        end
        if vv.levelindex < v.levelindex and vv.x>v.x then
          print("1")
          _collision = true
          local __x = vv.x
          vv.x = v.x
          v.x = __x
        end
        if vv.levelindex > v.levelindex and vv.x<v.x then
          print("1")
          _collision = true
          local __x = vv.x
          vv.x = v.x
          v.x = __x
        end
      end
    end
  end
  if _collision == false then
    EDITOR.dolayout=false
  end
end

function state.collidebox(px,py,pwidth,pheight,px2,py2,pwidth2,pheight2) 
   if state.collidepoint(px,py,px2,py2,pwidth2,pheight2) then
      return true
   end
   if state.collidepoint(px+pwidth,py,px2,py2,pwidth2,pheight2) then
      return true
   end
   if state.collidepoint(px,py+pheight,px2,py2,pwidth2,pheight2) then
      return true
   end
   if state.collidepoint(px+pwidth,py+pheight,px2,py2,pwidth2,pheight2) then
      return true
   end
   return false
end 

function state.collidepoint(px,py,px2,py2,pwidth2,pheight2) 
   if px>=px2 and px<=px2+pwidth2 and py>=py2 and py<=py2+pheight2 then
      return true
   end
   return false
end 

function minbyattribute(a,b,att)
  if a[att]<b[att] then
    return a,b
  end
  return b,a
end
function minbyparentattribute(a,b,parent,att)
  if a[parent][att]<b[parent][att] then
    return a,b
  end
  return b,a
end
function state:updatenodes()
 local levels={}
 for i,v in ipairs(EDITOR.nodes) do
   if levels[v.level] then
     levels[v.level]=levels[v.level]+1
   else
     levels[v.level]=1
   end
   v.levelindex = levels[v.level]
 end
end