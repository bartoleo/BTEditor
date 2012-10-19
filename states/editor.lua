
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
EDITOR.nodesize = 0
EDITOR.nodelevels = 0
EDITOR.nodeselected = nil
EDITOR.dolayout=false
EDITOR.fontsize=10
EDITOR.divisory=96
EDITOR.gridsize=EDITOR.divisory/3
EDITOR.arrowsize=EDITOR.divisory/10
EDITOR.toolbarheight=64
EDITOR.palettewidth=120
EDITOR.cameraworld={x1=0,y1=0,x2=0,y2=0}
EDITOR.palette={}
EDITOR.palettenodeheight = 60
EDITOR.palettenodeselected = nil

EDITOR.pointer=nil

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

  object = loveframes.Create("imagebutton")
  object:SetSize(24, 24)
  object:SetImage(images.options)
  object:SetText("")
  object.OnClick = state.clickEvent
  EDITOR.gui.optionsbutton = object
  local tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(-30,30)
  tooltip:SetText("Options")

  object = loveframes.Create("imagebutton")
  object:SetSize(24, 24)
  object:SetImage(images.bin)
  object:SetText("")
  object.OnClick = state.clickEvent
  EDITOR.gui.binbutton = object
  tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(-150,30)
  tooltip:SetText("Deletes node and children")

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
  EDITOR.nodesize = 0
  state:addnode(classes.node:new("","START","","__start__",screen_middlex,32,nil,nil,nil,1))
  EDITOR.dolayout=true

  EDITOR.camera = Camera.new(screen_middlex+EDITOR.palettewidth/2,screen_middley-EDITOR.toolbarheight-5, 1, 0)
  state:getCameraWorld()

  EDITOR.mouseaction = nil

  state:loadPalette()

  endx=0
  startx=0
  endy=0
  starty=0

  state:changeNodeSelected(EDITOR.nodes[1])

  love.graphics.setBackgroundColor(255, 255, 255)

  -- forcing alpha of dialogs to 200
  loveframes.skins.available[loveframes.config["ACTIVESKIN"]].controls.frame_body_color[4]=200

  -- enable input
  EDITOR.inputenabled = true

end

function state:leave()
  --profiler.stop()
  collectgarbage("restart")
end

function state:update(dt) 
    local _x,_y = love.mouse.getPosition()
    local _xc,_yc = EDITOR.camera:worldCoords(_x,_y)
    if EDITOR.dolayout then
      state:layout()
    end

    if EDITOR.inputenabled then
      if EDITOR.mouseaction == "move" then
        endx,endy = _xc,_yc
        EDITOR.camera:move(startx-endx, starty-endy)
        startx,starty=EDITOR.camera:worldCoords(_x,_y)
        state:getCameraWorld()
      end
      
      if _y>EDITOR.toolbarheight then
        if EDITOR.mouseaction == nil then
          if _x < screen_width-EDITOR.palettewidth then
            if state:nodeHit(EDITOR.nodekeys,_xc,_yc) then
              state:changePointer(images.pointer_finger)
            else
              state:changePointer(nil)
            end
          else
            if state:nodeHit(EDITOR.palette,_x,_y) then
              state:changePointer(images.pointer_finger)
            else
              state:changePointer(nil)
            end
          end
        end 
        if EDITOR.mouseaction == "movenode"  then
          if state:nodeHit(EDITOR.nodekeys,_xc,_yc) then
            state:changePointer(images.pointer_down)
          else
            state:changePointer(nil)
          end
        end
        if EDITOR.mouseaction == "movepalette"  then
          if state:nodeHit(EDITOR.nodekeys,_xc,_yc) then
            state:changePointer(images.pointer_down)
          else
            state:changePointer(nil)
          end
        end 
      end
    end

    loveframes.update(dt)

end

function state:draw()

  local _x,_y = love.mouse.getPosition()

  EDITOR.camera:attach()
  state:drawGrid()
  state:drawNodes()
  EDITOR.camera:detach()
  
  love.graphics.setColor(196,196,196,255)
  love.graphics.rectangle("fill",0,0,screen_width,EDITOR.toolbarheight)
  love.graphics.rectangle("fill",screen_width-EDITOR.palettewidth,EDITOR.toolbarheight,screen_width,screen_height)
  love.graphics.setColor(64,64,64,255)
  love.graphics.rectangle("line",0,0,screen_width,EDITOR.toolbarheight)
  love.graphics.rectangle("line",screen_width-EDITOR.palettewidth,EDITOR.toolbarheight,screen_width,screen_height)
  
  state:drawPalette()

  loveframes.draw()

  state:drawDebug()

  if EDITOR.pointer then
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(EDITOR.pointer,_x,_y)
  end
end

function state:keypressed(key, unicode)
  if key=="lctrl" then
    loveframes.config["DEBUG"]=not loveframes.config["DEBUG"]
  end

  if EDITOR.inputenabled then  
    if key==" " and EDITOR.nodeselected then
      EDITOR.camera = Camera.new(EDITOR.nodeselected.x,EDITOR.nodeselected.y,1,0)
      state:getCameraWorld()
    end

    if key=="a" then
      if EDITOR.nodeselected then
        local _node = classes.node:new("","SELECTOR","",nil,nil,nil,nil,nil,EDITOR.nodeselected,nil)
        _node.name = EDITOR.nodeselected.name..".".._node.indexchild
        _node:changeWidth()
        state:addnode(_node)
        EDITOR.dolayout=true
      end
    end
    if key=="b" then
      if EDITOR.nodeselected then
        local _node = classes.node:new("","SEQUENCE","",nil,nil,nil,nil,nil,EDITOR.nodeselected,nil)
        _node.name = EDITOR.nodeselected.name..".".._node.indexchild
        _node:changeWidth()
        state:addnode(_node)
        EDITOR.dolayout=true
      end
    end
    if key=="c" then
      if EDITOR.nodeselected then
        local _node = classes.node:new("","CONDITION","",nil,nil,nil,nil,nil,EDITOR.nodeselected,nil)
        _node.name = EDITOR.nodeselected.name..".".._node.indexchild
        _node:changeWidth()
        state:addnode(_node)
        EDITOR.dolayout=true
      end
    end
    if key=="d" then
      state:changePointer(nil)
    end
    if key=="e" then
      state:changePointer(images.pointer)
    end
    if key=="f" then
      state:changePointer(images.pointer_finger)
    end
    if key=="g" then
      state:changePointer(images.pointer_down)
    end
    if key=="g" then
      state:changePointer(images.pointer_move)
    end

    loveframes.keypressed(key, unicode)
  end

end

function state:mousepressed(x, y, button)

  loveframes.mousepressed(x, y, button)

  if EDITOR.inputenabled then
    if y > EDITOR.toolbarheight then
      if x < screen_width - EDITOR.palettewidth then
        local _x,_y = EDITOR.camera:worldCoords(x,y)
        if (button=="l" or button=="r") and state:nodeHit(EDITOR.nodekeys,_x,_y) then
          state:changeNodeSelected(state:nodeHit(EDITOR.nodekeys,_x,_y))
          startx,starty = _x,_y
          EDITOR.mouseaction = "movenode"
        else
          startx,starty = _x,_y
          EDITOR.mouseaction = "move"
          state:changePointer(images.pointer_move)
          if button=="wd" then
            local _newzoom = EDITOR.camera.zoom/1.5
            if _newzoom >= 0.90 and _newzoom<=1.1 then
              _newzoom = 1
            end
            EDITOR.camera = Camera.new(_x,_y,_newzoom,EDITOR.camera.rot)
            --EDITOR.camera = EDITOR.camera:move(_x,_y)
            state:getCameraWorld()
          end
          if button=="wu" then
            local _newzoom = EDITOR.camera.zoom*1.5
            if _newzoom >= 0.90 and _newzoom<=1.1 then
              _newzoom = 1
            end
            EDITOR.camera = Camera.new(_x,_y,_newzoom,EDITOR.camera.rot)
            --EDITOR.camera = EDITOR.camera:move(_x,_y)
            state:getCameraWorld()
          end
        end
      end
      if x >= screen_width-EDITOR.palettewidth then
        local _node = state:nodeHit(EDITOR.palette,x,y)
        if _node then
          state:changePaletteNodeSelected(_node)
          startx,starty = _x,_y
          EDITOR.mouseaction = "movepalette"
        end
      end
    end
  end

end

function state:mousereleased(x, y, button)

  if EDITOR.inputenabled then
    if EDITOR.mouseaction == "move" then
      EDITOR.mouseaction = nil
    end
    state:changePointer(nil)
    if EDITOR.mouseaction == "movenode" and EDITOR.nodeselected then
      local _x,_y = love.mouse.getPosition()
      endx,endy = EDITOR.camera:worldCoords(_x,_y)
      if button == "l" then
        state:moveNode(EDITOR.nodeselected,-startx+endx,0,true)
      elseif button == "r" then
        local _targetnode = state:nodeHit(EDITOR.nodekeys,endx,endy)
        if _targetnode and _targetnode ~= EDITOR.nodeselected and EDITOR.nodeselected~=EDITOR.nodes then
          state:moveNodeParent(EDITOR.nodeselected,_targetnode)
        else
          state:moveNode(EDITOR.nodeselected,-startx+endx,0,true)
        end
      end
      EDITOR.mouseaction = nil
      EDITOR.dolayout = true
    end
    if EDITOR.mouseaction == "movepalette" and EDITOR.palettenodeselected then
      local _x,_y = love.mouse.getPosition()
      endx,endy = EDITOR.camera:worldCoords(_x,_y)
      if button == "l" then
        local _targetnode = state:nodeHit(EDITOR.nodekeys,endx,endy)
        if _targetnode  then
          local _node = classes.node:new("",EDITOR.palettenodeselected.type,EDITOR.palettenodeselected.func,nil,nil,nil,nil,nil,_targetnode,nil)
          _node.name = _targetnode.name..".".._node.indexchild
          _node:changeWidth()
          state:addnode(_node)
          EDITOR.dolayout=true
        end
      end
      EDITOR.mouseaction = nil
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
  if object==EDITOR.gui.binbutton then
    state:deleteNode(EDITOR.nodeselected,true)
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
    for i,v in ipairs(EDITOR.palette) do
      v.x = screen_width-EDITOR.palettewidth+5
    end
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
       v:draw(true)
    end
end

function state.drawPalette()
    for i,v in pairs(EDITOR.palette) do
       v:draw(true)
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

function state:changeNodeSelected(pnode)
  if pnode then
    EDITOR.nodeselected = pnode
    for i,v in pairs(EDITOR.nodekeys) do
       if v.id == pnode.id then
         v.selected=true
       else 
         v.selected=false
       end
    end
  end  
end

function state:nodeHit(ptable,px,py)
  for i,v in pairs(ptable) do
     if state.collidepoint(px,py,v.x,v.y,v.width,v.height) then
       return v
     end
  end
  return nil
end

function state:layout()
  local _collision = false
  local _a,_b,_step
  state:updatenodes()
  for i,v in pairs(EDITOR.nodekeys) do
    v.y = (v.level-1) *EDITOR.divisory
    for ii,vv in pairs(EDITOR.nodekeys) do
      if vv ~= v and vv.level == v.level then
        if state.collidebox(v.x-5,v.y,v.width+10,v.height,vv.x-5,vv.y,vv.width+10,vv.height) then
          _collision = true
          _a,_b = minbyattribute(v,vv,"levelindex")
          _step = (_b.x-_a.x)/4
          _step = (_step > 2) and _step or 2
          _a.x = _a.x - _step
          _b.x = _b.x + _step
        end
        if vv.levelindex < v.levelindex and vv.x>v.x then
          _collision = true
          _step = (vv.x-v.x)/4
          _step = (_step > 2) and _step or 2
          vv.x = vv.x -_step
          v.x = v.x + _step
        end
        if vv.levelindex > v.levelindex and vv.x<v.x then
          _collision = true
          _step = (v.x-vv.x)/4
          _step = (_step > 2) and _step or 2
          vv.x = vv.x + _step
          v.x = v.x - _step
        end
      end
    end
  end
  -- parent nodes are on center of children
  local _ox,_oy = EDITOR.nodes[1].x,EDITOR.nodes[1].y
  local _minx,_maxx
  for i,v in pairs(EDITOR.nodekeys) do
    if v.children then
      for ii,vv in ipairs(v.children) do
        if ii == 1 then
          _minx=vv.x
          _maxx=vv.x+vv.width
        elseif vv.x<_minx then
          _minx = vv.x
        elseif vv.x>_maxx then
          _maxx = vv.x+vv.width
        end
        if (v.x+v.width/2~=(_minx+_maxx)/2) then
          v.x = (_minx+_maxx)/2-v.width/2
          _collision = true
        end
      end
    end
  end
  -- recenter tree on top node
  state:moveNode(EDITOR.nodes[1],_ox-EDITOR.nodes[1].x,_oy-EDITOR.nodes[1].y,true)
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
  EDITOR.nodesize = 0
  EDITOR.nodelevels = 0
  local levelindex =0
  for i,v in ipairs(EDITOR.nodes) do
    v.level = 1
    if v.level > EDITOR.nodelevels then
      EDITOR.nodelevels = v.level
    end
    levelindex=state:updatenode(v,levelindex)
  end
end
function state:updatenode(pnode,plevelindex)
   local levelindex=plevelindex
   EDITOR.nodesize = EDITOR.nodesize + 1
   if pnode.parent~=nil then
     pnode.level = pnode.parent.level+1
   end
   if pnode.level > EDITOR.nodelevels then
      EDITOR.nodelevels = pnode.level
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
  EDITOR.gui.lbl_title:SetPos(5, 5)
  EDITOR.gui.txt_title:SetPos(60, 5)
  EDITOR.gui.optionsbutton:SetPos(screen_width-24-5, 5)
  EDITOR.gui.binbutton:SetPos(screen_width-24-5-24-5, 5)
end

function state:moveNode(pnode,pdx,pdy,precursive)
  pnode.x=pnode.x+pdx
  pnode.y=pnode.y+pdy
  if precursive then
    for i,v in ipairs(pnode.children) do
      state:moveNode(v,pdx,pdy,precursive)
    end
  end
end

function state:changePointer(ppointer)
  if ppointer~=EDITOR.pointer then
    EDITOR.pointer = ppointer
    if EDITOR.pointer then
      love.mouse.setVisible(false)
    else
      love.mouse.setVisible(true)
    end
  end
end

function state:drawDebug()
  love.graphics.print(love.timer.getFPS(),5,screen_height-25)
  love.graphics.print(EDITOR.nodesize.." "..EDITOR.nodelevels,5,screen_height-15)
end

function state:getCameraWorld()
  EDITOR.cameraworld.x1,EDITOR.cameraworld.y1 = EDITOR.camera:worldCoords(0,0)
  EDITOR.cameraworld.x2,EDITOR.cameraworld.y2 = EDITOR.camera:worldCoords(screen_width,screen_height)
end

function state:moveNodeParent(pnode,pnewparent)
  if pnode~=pnewparent then
    _checkifchildren = false
    _checkifchildren = state:checkIfChildren(pnode,pnewparent)
    if _checkifchildren == false then
      -- tolgo il child dal padre vecchio
      if pnode.parent then
        local _index
        for i,v in ipairs(pnode.parent.children) do
          if v==pnode then
            _index = i
          end
        end
        table.remove(pnode.parent.children,_index)
      end
      -- aggiungo il node al parent
      table.insert(pnewparent.children,pnode)
      --
      pnode.parent = pnewparent
      pnode.level = pnewparent.level+1
    end 
    state:updatenodes()
    EDITOR.dolayout = true
  end
end

function state:checkIfChildren(pnode,pnode2)
  if pnode.children then
    for i,v in ipairs(pnode.children) do
      if v==pnode2 then
        return true
      else
        if state:checkIfChildren(v,pnode2) then
          return true
        end
      end
    end
  end
  return false
end

function state:deleteNode(pnode,external)
  local _nodeselected=false
  local _newnode
  if pnode == EDITOR.nodeselected then
    _nodeselected = true
    _newnode = pnode.parent
  end
  if pnode and pnode ~= EDITOR.nodes[1] then
    for i=#pnode.children,1,-1 do
      state:deleteNode(pnode.children[i],false)
    end
    if pnode.parent then
      local _index
      for i,v in ipairs(pnode.parent.children) do
        if v==pnode then
          _index = i
        end
      end
      table.remove(pnode.parent.children,_index)
    end
    EDITOR.nodekeys[pnode.id] = nil 
  end
  if external then
    state:updatenodes()
    EDITOR.dolayout = true
    state:changeNodeSelected(_newnode)
  end
end

function state:loadPalette()
  table.insert(EDITOR.palette, classes.node:new("","SELECTOR","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*0,nil,nil,nil,nil))
  table.insert(EDITOR.palette, classes.node:new("","SEQUENCE","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*1,nil,nil,nil,nil))
  table.insert(EDITOR.palette, classes.node:new("","CONDITION","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*2,nil,nil,nil,nil))
  table.insert(EDITOR.palette, classes.node:new("","ACTION","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*3,nil,nil,nil,nil))
end

function state:changePaletteNodeSelected(pnode)
  EDITOR.palettenodeselected = pnode
  for i,v in pairs(EDITOR.palette) do
     if v.id == pnode.id then
       v.selected=true
     else 
       v.selected=false
     end
  end  
end
