
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
EDITOR.nodekeys = {}
EDITOR.nodeselected = nil
EDITOR.dolayout=false
EDITOR.fontsize=10
EDITOR.divisory=96
EDITOR.gridsize=EDITOR.divisory/3
EDITOR.arrowsize=EDITOR.divisory/10

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
  object:SetText("Clickable Button")
  object.OnClick = state.clickEvent
  EDITOR.gui.button = object

  local object = loveframes.Create("imagebutton")
  object:SetSize(24, 24)
  object:SetImage(images.options)
  object:SetText("")
  object.OnClick = state.clickEvent
  EDITOR.gui.optionsbutton = object

  object = loveframes.Create("text")
  object:SetMaxWidth(100)
  object:SetText("Title")
  EDITOR.gui.lbl_title = object
  
  object = loveframes.Create("textinput")
  object:SetWidth(490)
  EDITOR.gui.txt_title = object

  EDITOR.gui.txt_title:SetText ("prova")
  
  state:layoutgui()

  EDITOR.nodes = {}
  EDITOR.nodekeys = {}
  state:addnode(classes.node:new("","START","","__start__",screen_middlex,32,nil,nil,nil,1))
  EDITOR.dolayout=true

  EDITOR.camera = Camera.new(screen_middlex,screen_middley-32, 1, 0)

  EDITOR.moveto = false
  EDITOR.movenodeto = false

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
        local _node = classes.node:new("","SELECTOR","",nil,nil,nil,nil,nil,EDITOR.nodeselected,nil)
        _node.name = EDITOR.nodeselected.name..".".._node.indexchild
        state:addnode(_node)
        EDITOR.dolayout=true
      end
    end
    if key=="b" then
      if EDITOR.nodeselected then
        local _node = classes.node:new("","SEQUENCE","",nil,nil,nil,nil,nil,EDITOR.nodeselected,nil)
        _node.name = EDITOR.nodeselected.name..".".._node.indexchild
        state:addnode(_node)
        EDITOR.dolayout=true
      end
    end
    if key=="c" then
      if EDITOR.nodeselected then
        local _node = classes.node:new("","CONDITION","",nil,nil,nil,nil,nil,EDITOR.nodeselected,nil)
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
    if (button=="l" or button=="r") and state:nodeselected(_x,_y) then
      startx,starty = _x,_y
      EDITOR.movenodeto = true
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
    if EDITOR.movenodeto and EDITOR.nodeselected then
      local _x,_y = love.mouse.getPosition()
      endx,endy = EDITOR.camera:worldCoords(_x,_y)
      if button == "l" then
        state:movenode(EDITOR.nodeselected,-startx+endx,0,false)
      elseif button == "r" then
        state:movenode(EDITOR.nodeselected,-startx+endx,0,true)
      end
      EDITOR.movenodeto = false
      EDITOR.dolayout = true
    end
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
  if object==EDITOR.gui.optionsbutton then
    state.createDialogOptions()
  end
end

function state.createDialog(onClose)

    EDITOR.inputenabled = false

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
    object.OnClick = function() EDITOR.gui.dialog.returnvalue = true if (EDITOR.gui.dialog.OnClose) then EDITOR.gui.dialog.OnClose(EDITOR.gui.dialog) end EDITOR.gui.dialog:Remove() EDITOR.inputenabled = true end
    object = loveframes.Create("button",frame)
    object:SetText("Cancel")
    object:SetPos(frame:GetWidth()/2+10,frame:GetHeight()-30)
    object.OnClick = function() EDITOR.gui.dialog.returnvalue = false if (EDITOR.gui.dialog.OnClose) then EDITOR.gui.dialog.OnClose(EDITOR.gui.dialog) end EDITOR.gui.dialog:Remove() EDITOR.inputenabled = true end
end

function state.createDialogOptions()

    EDITOR.inputenabled = false

    local frame = loveframes.Create("frame")
    frame:SetName("Options")
    frame:SetModal (true)
    frame:ShowCloseButton(false)
    frame:SetSize(400, 180)
    frame.OnClose = onClose
    frame:Center()
    EDITOR.gui.dialog = frame
    EDITOR.gui.dialog.returnvalue = false
    EDITOR.gui.dialog.OnClose = state.closeDialogOptions
    
    local object =loveframes.Create("text",frame)
    object:SetPos(10, 45+5)
    object:SetMaxWidth(80)
    object:SetText("Resolution")

    object = loveframes.Create("multichoice",frame)
    object:SetPos(80, 45)
    local _modes=love.graphics.getModes()
    table.sort(_modes, function(a, b) return a.width*a.height < b.width*b.height end)  
    local _values={}
    local _value=_G.screen_width.."x".._G.screen_height
    local _val
    local _found=false
    for i,v in ipairs(_modes) do
      _val=v.width.."x"..v.height
      table.insert(_values,_val)
      if _value==_val then
        _found=true
      end
    end
    if _found==false then
      table.insert(_values,_val)
    end
    for i,v in ipairs(_values) do
      object:AddChoice(v)
    end
    object:SetChoice(_value)
    EDITOR.gui.dialog.cmbresolution=object

    object = loveframes.Create("checkbox",frame)
    object:SetPos(80, 75)
    object:SetText("Fullscreen")
    object:SetChecked(screen_fullscreen)
    EDITOR.gui.dialog.chkfullscreen=object

    object = loveframes.Create("checkbox",frame)
    object:SetPos(80, 105)
    object:SetText("VSync")
    object:SetChecked(screen_vsync)
    EDITOR.gui.dialog.chkvsync=object

    local object = loveframes.Create("button",frame)
    object:SetPos(frame:GetWidth()/2-10-object:GetWidth(),frame:GetHeight()-30)
    object:SetText("Apply")
    object.OnClick = function() EDITOR.gui.dialog.returnvalue = true if (EDITOR.gui.dialog.OnClose) then EDITOR.gui.dialog.OnClose(EDITOR.gui.dialog) end EDITOR.gui.dialog:Remove() EDITOR.inputenabled = true end
    object = loveframes.Create("button",frame)
    object:SetText("Cancel")
    object:SetPos(frame:GetWidth()/2+10,frame:GetHeight()-30)
    object.OnClick = function() EDITOR.gui.dialog.returnvalue = false if (EDITOR.gui.dialog.OnClose) then EDITOR.gui.dialog.OnClose(EDITOR.gui.dialog) end EDITOR.gui.dialog:Remove() EDITOR.inputenabled = true end
end

function state.closeDialogOptions()
    if EDITOR.gui.dialog.returnvalue==true then
      local _res = split(EDITOR.gui.dialog.cmbresolution:GetChoice(),"x")
      if changeScreenMode({width=_res[1],height=_res[2],fullscreen=EDITOR.gui.dialog.chkfullscreen:GetChecked(),vsync=EDITOR.gui.dialog.chkvsync:GetChecked(),fsaa=0}) then
        getScreenMode()
        saveScreenMode("configs.txt")
      end
    end
    state:layoutgui()
end

function state.drawGrid()
    love.graphics.setColor(0,0,0,24)
    for i=1,screen_height/EDITOR.gridsize do
      love.graphics.line(0,i*EDITOR.gridsize,screen_width,i*EDITOR.gridsize)
    end
    for i=1,screen_width/EDITOR.gridsize do
      love.graphics.line(i*EDITOR.gridsize,0,i*EDITOR.gridsize,screen_height)
    end
end

function state.drawNodes()
    for i,v in pairs(EDITOR.nodekeys) do
       v:draw()
    end
end

function state:addnode(pnode)
  while EDITOR.nodekeys[pnode.id]~=nil do
    pnode.id = generateId("node")
  end
  if pnode.parent==nil then
    table.insert(EDITOR.nodes,pnode)
  else
    table.insert(pnode.parent.children,pnode)
  end
  EDITOR.nodekeys[pnode.id]=pnode
  state:updatenodes()
end

function state:changenodeselected(pnode)
  EDITOR.nodeselected = pnode
  for i,v in pairs(EDITOR.nodekeys) do
     if v.id == pnode.id then
       v.selected=true
     else 
       v.selected=false
     end
  end  
end

function state:nodeselected(px,py)
  for i,v in pairs(EDITOR.nodekeys) do
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
  for i,v in pairs(EDITOR.nodekeys) do
    v.y = (v.level-1) *EDITOR.divisory
    for ii,vv in pairs(EDITOR.nodekeys) do
      if vv ~= v and vv.level == v.level then
        if state.collidebox(v.x,v.y,v.width,v.height,vv.x,vv.y,vv.width,vv.height) then
          _collision = true
          local _a,_b
          _a,_b = minbyattribute(v,vv,"levelindex")
          _a.x = _a.x -10
          _b.x = _b.x +5
        end
        if vv.levelindex < v.levelindex and vv.x>v.x then
          _collision = true
          vv.x = vv.x -10
          v.x = v.x + 10
        end
        if vv.levelindex > v.levelindex and vv.x<v.x then
          _collision = true
          local __x = vv.x
          vv.x = vv.x + 10
          v.x = v.x - 10
        end
      end
    end
  end
  local _mx,Mx
  for i,v in pairs(EDITOR.nodekeys) do
    if v.children then
      for ii,vv in ipairs(v.children) do
        if ii == 1 then
          _mx=vv.x
          _Mx=vv.x
        elseif vv.x<_mx then
          _mx = vv.x
        elseif vv.x>_Mx then
          _Mx = vv.x
        end
        if (v.x~=(_mx+_Mx)/2) then
          v.x = (_mx+_Mx)/2
          _collision = true
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
 local levelindex =0
 for i,v in ipairs(EDITOR.nodes) do
   v.level = 1
   levelindex=state:updatenode(v,levelindex)
 end
end
function state:updatenode(pnode,plevelindex)
   local levelindex=plevelindex
   if pnode.parent~=nil then
     pnode.level = pnode.parent.level+1
   end
   levelindex=levelindex+1
   pnode.levelindex = levelindex
   if pnode.children then
     for i,v in ipairs(pnode.children) do
       levelindex=state:updatenode(v,levelindex)
     end
   end
   return levelindex
end

function EDITOR.drawArrow(x1,y1,x2,y2)
  local angle = math.atan2(y1-y2, x1-x2)
  love.graphics.line(x1,y1,x2,y2)
  love.graphics.line(x2,y2,x2+math.cos(angle-0.25)*EDITOR.arrowsize,y2+math.sin(angle-0.25)*EDITOR.arrowsize)
  love.graphics.line(x2,y2,x2+math.cos(angle+0.25)*EDITOR.arrowsize,y2+math.sin(angle+0.25)*EDITOR.arrowsize)
end

function state:layoutgui()
  EDITOR.gui.button:SetPos(screen_width-105-37, 5)
  EDITOR.gui.optionsbutton:SetPos(screen_width-37, 5)
  EDITOR.gui.lbl_title:SetPos(5, 5)
  EDITOR.gui.txt_title:SetPos(60, 5)
end

function state:movenode(pnode,pdx,pdy,precursive)
  pnode.x=pnode.x+pdx
  pnode.y=pnode.y+pdy
  if precursive then
    for i,v in ipairs(pnode.children) do
      state:movenode(v,pdx,pdy,precursive)
    end
  end
end