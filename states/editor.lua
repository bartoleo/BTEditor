
--- game gamestate
Gamestate.editor = Gamestate.new()
local state = Gamestate.editor

-- constant

-- GAME environment
EDITOR={}
EDITOR.inputenabled = false
EDITOR.filename = nil
EDITOR.title = ""
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
EDITOR.statusbarheight=20
EDITOR.palettewidth=120
EDITOR.cameraworld={x1=0,y1=0,x2=0,y2=0}
EDITOR.palette={}
EDITOR.palettenodeheight = 60
EDITOR.palettenodeselected = nil
EDITOR.filename = ""
EDITOR.firstdraw = 2
EDITOR.commands_queue={}
EDITOR.fileHistory={}
EDITOR.nodesNotValid=0
EDITOR.mousePointer=nil
EDITOR.notes = ""

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
  
  local list = loveframes.Create("list")
  list:SetSize(790, 32)
  list:SetDisplayType("horizontal")
  list:SetPadding(5)
  list:SetSpacing(5)
  EDITOR.gui.toolbar = list

  object = loveframes.Create("imagebutton")
  object:SetImage(images.fileopen)
  object:SizeToImage()
  object:SetText("")
  object.OnClick = state.clickEvent
  list:AddItem(object)
  EDITOR.gui.fileopenbutton = object
  local tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(0,30)
  tooltip:SetText("Open file")

  object = loveframes.Create("imagebutton")
  object:SetImage(images.filesave)
  object:SizeToImage()
  object:SetText("")
  object.OnClick = state.clickEvent
  list:AddItem(object)
  EDITOR.gui.filesavebutton = object
  local tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(-10,30)
  tooltip:SetText("Save")

  object = loveframes.Create("imagebutton")
  object:SetImage(images.filesaveas)
  object:SizeToImage()
  object:SetText("")
  object.OnClick = state.clickEvent
  list:AddItem(object)
  EDITOR.gui.filesaveasbutton = object
  local tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(-20,30)
  tooltip:SetText("Save As")

  object = loveframes.Create("text")
  object:SetMaxWidth(32)
  object:SetText(" ")
  list:AddItem(object)
  EDITOR.gui.divisor1 = object

  object = loveframes.Create("checkbox",frame)
  object:SetText("Autolayout")
  object:SetChecked(true)
  list:AddItem(object)
  EDITOR.gui.chkautolayout=object
  
  object = loveframes.Create("text")
  object:SetMaxWidth(32)
  object:SetText(" ")
  list:AddItem(object)
  EDITOR.gui.divisor2 = object

  object = loveframes.Create("imagebutton")
  object:SetImage(images.center)
  object:SizeToImage()
  object:SetText("")
  object.OnClick = state.clickEvent
  list:AddItem(object)
  EDITOR.gui.centerbutton = object
  tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(-70,30)
  tooltip:SetText("Center on selected node")
 
  object = loveframes.Create("imagebutton")
  object:SetImage(images.zoomin)
  object:SizeToImage()
  object:SetText("")
  object.OnClick = state.clickEvent
  list:AddItem(object)
  EDITOR.gui.zoominbutton = object
  tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(-20,30)
  tooltip:SetText("Zoom In")
 
  object = loveframes.Create("imagebutton")
  object:SetImage(images.zoomout)
  object:SizeToImage()
  object:SetText("")
  object.OnClick = state.clickEvent
  list:AddItem(object)
  EDITOR.gui.zoomoutbutton = object
  tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(-20,30)
  tooltip:SetText("Zoom Out")

  object = loveframes.Create("text")
  object:SetMaxWidth(32)
  object:SetText(" ")
  list:AddItem(object)
  EDITOR.gui.divisor3 = object

  object = loveframes.Create("imagebutton")
  object:SetImage(images.bin)
  object:SizeToImage()
  object:SetText("")
  object.OnClick = state.clickEvent
  list:AddItem(object)
  EDITOR.gui.binbutton = object
  tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(-70,30)
  tooltip:SetText("Deletes node and children")

  object = loveframes.Create("text")
  object:SetMaxWidth(100)
  object:SetText(" ")
  list:AddItem(object)
  EDITOR.gui.divisorcenter = object

  object = loveframes.Create("imagebutton")
  object:SetText("")
  object:SetImage(images.help)
  object:SizeToImage()
  object.OnClick = state.clickEvent
  list:AddItem(object)
  EDITOR.gui.helpbutton = object
  local tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(-20,30)
  tooltip:SetText("Help")

  object = loveframes.Create("imagebutton")
  object:SetImage(images.options)
  object:SetText("")
  object:SizeToImage()
  object.OnClick = state.clickEvent
  list:AddItem(object)
  EDITOR.gui.optionsbutton = object
  local tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(-30,30)
  tooltip:SetText("Options")
  EDITOR.gui.toolbar:RedoLayout ()

  object = loveframes.Create("text")
  object:SetMaxWidth(60)
  object:SetText("Filename:")
  EDITOR.gui.lbl_lblfilename = object
  
  object = loveframes.Create("text")
  object:SetMaxWidth(300)
  object:SetText(EDITOR.filename)
  EDITOR.gui.lbl_filename = object

  object = loveframes.Create("button")
  object:SetText("notes")
  object:SetWidth(40)
  object.OnClick = state.clickEvent
  EDITOR.gui.notesbutton = object
  local tooltip = loveframes.Create("tooltip")
  tooltip:SetObject(object)
  tooltip:SetPadding(0)
  tooltip:SetOffsets(-30,30)
  tooltip:SetText("Show/Edit notes")

  object = loveframes.Create("text")
  object:SetMaxWidth(40)
  object:SetText("Title:")
  EDITOR.gui.lbl_title = object
  object = loveframes.Create("textinput")
  object:SetWidth(300)
  object:SetText(EDITOR.title)
  EDITOR.gui.txt_title = object
  
  object = loveframes.Create("text")
  object:SetFont(fonts[",9"])
  object:SetMaxWidth(40)
  object:SetText("Type:")
  EDITOR.gui.lbl_nodetype = object
  object = loveframes.Create("textinput")
  object:SetFont(fonts[",9"])
  object.OnTextChanged = state.applyChangesNode
  object:SetWidth(120)
  object:SetHeight(17)
  EDITOR.gui.txt_nodetype = object
  object = loveframes.Create("text")
  object:SetFont(fonts[",9"])
  object:SetMaxWidth(40)
  object:SetText("Name:")
  EDITOR.gui.lbl_nodename = object
  object = loveframes.Create("textinput")
  object:SetFont(fonts[",9"])
  object.OnTextChanged = state.applyChangesNode
  object:SetWidth(120)
  object:SetHeight(17)
  EDITOR.gui.txt_nodename = object
  object = loveframes.Create("text")
  object:SetFont(fonts[",9"])
  object:SetMaxWidth(40)
  object:SetText("Func:")
  EDITOR.gui.lbl_nodefunc = object
  object = loveframes.Create("textinput")
  object:SetFont(fonts[",9"])
  object:SetWidth(300)
  object:SetHeight(17)
  object.OnTextChanged = state.applyChangesNode
  EDITOR.gui.txt_nodefunc = object
  
  state:layoutgui()

  state:loadPalette()

  state:newTree()

  love.graphics.setBackgroundColor(255, 255, 255)

  -- forcing alpha of dialogs to 200
  loveframes.skins.available[loveframes.config["ACTIVESKIN"]].controls.frame_body_color[4]=200

  state.readFileHistory()

  EDITOR.firstdraw = 2

  -- enable input
  EDITOR.inputenabled = true

end

function state:leave()
  --profiler.stop()
  collectgarbage("restart")
end

function state:update(dt) 

    if EDITOR.commands_queue then
      for i=#EDITOR.commands_queue,1,-1 do
        local cmd = EDITOR.commands_queue[i].cmd
        local arg = EDITOR.commands_queue[i].arg
        if cmd=="loadfile" then
          local status, err = pcall(state.loadFile)
          if status == false then
            state.createDialog(state.funcnil,"alert",err)
          end
        end
        if cmd=="savefile" then
          local status, err = pcall(state.saveFile)
          if status == false then
            state.createDialog(state.funcnil,"alert",err)
          end
        end
        if cmd=="setfocus" then
          if arg then
            arg:SetFocus(true)
          end
        end
        table.remove(EDITOR.commands_queue,i)
      end
    end

    local _x,_y = love.mouse.getPosition()
    local _xc,_yc = EDITOR.camera:worldCoords(_x,_y)
    if EDITOR.dolayout and EDITOR.gui.chkautolayout:GetChecked() then
      state:layout()
    end

    if EDITOR.inputenabled then
      if EDITOR.mouseaction == "move" then
        endx,endy = _xc,_yc
        EDITOR.camera:move(startx-endx, starty-endy)
        startx,starty=EDITOR.camera:worldCoords(_x,_y)
        state:changedCameraWorld()
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
  love.graphics.rectangle("fill",screen_width-EDITOR.palettewidth,EDITOR.toolbarheight,screen_width,screen_height-EDITOR.statusbarheight-EDITOR.toolbarheight)
  love.graphics.rectangle("fill",0,screen_height-EDITOR.statusbarheight,screen_width,EDITOR.statusbarheight)
  love.graphics.setColor(64,64,64,255)
  love.graphics.rectangle("line",0,0,screen_width,EDITOR.toolbarheight)
  love.graphics.rectangle("line",screen_width-EDITOR.palettewidth,EDITOR.toolbarheight,screen_width,screen_height-EDITOR.statusbarheight-EDITOR.toolbarheight)
  love.graphics.rectangle("line",0,screen_height-EDITOR.statusbarheight,screen_width,EDITOR.statusbarheight)
  
  state:drawPalette()

  state:drawEditBox()

  loveframes.draw()

  state:drawStatusBar()

  if EDITOR.mousePointer then
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(EDITOR.mousePointer,_x,_y)
  end

  if EDITOR.firstdraw>0 then
    EDITOR.firstdraw = EDITOR.firstdraw - 1
    EDITOR.gui.toolbar:RedoLayout ()
  end

end

function state:keypressed(key, unicode)
  if key=="lctrl" then
    loveframes.config["DEBUG"]=not loveframes.config["DEBUG"]
  end

  if EDITOR.inputenabled then  
    
    if key=="f1" then
      state.createDialogHelp()
    end
    if key=="f3" then
        state.createDialog(state.loadFileFromDialog,"open")
    end
    if key=="f2" then
      if EDITOR.filename~="" and love.keyboard.isDown("lshift") ==false then
        table.insert(EDITOR.commands_queue,{cmd="savefile"})
      else
        state.createDialog(state.saveFileFromDialog,"save")
      end
    end

    if key=="f6" then
      if EDITOR.nodeselected and EDITOR.palettenodeselected then
        local _node = classes.node:new("",EDITOR.palettenodeselected.type,EDITOR.palettenodeselected.func,nil,nil,nil,nil,nil,EDITOR.nodeselected,nil)
        _node.name = EDITOR.nodeselected.name..".".._node.indexchild
        _node:changeWidth()
        state:addnode(_node)
        EDITOR.dolayout=true
      end
    end
  end

  loveframes.keypressed(key, unicode)

end

function state:mousepressed(x, y, button)

  loveframes.mousepressed(x, y, button)
  local _x,_y = EDITOR.camera:worldCoords(x,y)

  if EDITOR.inputenabled then
    if y > EDITOR.toolbarheight then
      if x < screen_width - EDITOR.palettewidth then
        if (button=="l" or button=="r") and state:nodeHit(EDITOR.nodekeys,_x,_y) then
          state:changeNodeSelected(state:nodeHit(EDITOR.nodekeys,_x,_y))
          startx,starty = _x,_y
          EDITOR.mouseaction = "movenode"
        else
          startx,starty = _x,_y
          EDITOR.mouseaction = "move"
          state:changePointer(images.pointer_move)
          if button=="wd" then
            state:zoom(_x,_y,1/1.5)
          end
          if button=="wu" then
            state:zoom(_x,_y,1.5)
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
  if object==EDITOR.gui.fileopenbutton then
    state.createDialog(state.loadFileFromDialog,"open")
  end
  if object==EDITOR.gui.filesavebutton then
    if EDITOR.filename~="" then
      table.insert(EDITOR.commands_queue,{cmd="savefile"})
    else
      state.createDialog(state.saveFileFromDialog,"save")
    end
  end
  if object==EDITOR.gui.filesaveasbutton then
    state.createDialog(state.saveFileFromDialog,"save")
  end
  if object==EDITOR.gui.optionsbutton then
    state.createDialogOptions()
  end
  if object==EDITOR.gui.binbutton then
    state:deleteNode(EDITOR.nodeselected,true)
  end
  if object==EDITOR.gui.centerbutton then
    state:centerNode(EDITOR.nodeselected)
  end
  if object==EDITOR.gui.zoominbutton then
    local _x,_y = EDITOR.camera:worldCoords(screen_middlex-EDITOR.palettewidth/2,screen_middley+EDITOR.toolbarheight/2)
    state:zoom(_x,_y,1.5)
  end
  if object==EDITOR.gui.zoomoutbutton then
    local _x,_y = EDITOR.camera:worldCoords(screen_middlex-EDITOR.palettewidth/2,screen_middley+EDITOR.toolbarheight/2)
    state:zoom(_x,_y,1/1.5)
  end
  if object==EDITOR.gui.helpbutton then
    state.createDialogHelp()
  end
  if object==EDITOR.gui.notesbutton then
    state.createDialogNotes()
  end
end

function state.createDialog(onClose,ptype,...)

    EDITOR.inputenabled = false

    local frame = loveframes.Create("frame")
    frame:SetModal (true)
    frame:ShowCloseButton(false)
    frame.OnClose = onClose
    frame:Center()
    EDITOR.gui.dialog = frame
    EDITOR.gui.dialog.returnvalue = false

    if ptype=="open" then
      frame:SetName("Open File")
      frame:SetSize(650, 240)
      frame:Center()
      local object = loveframes.Create("text",frame)
      object:SetText("Filename to open : ")
      object:SetPos(15, 65)
      object = loveframes.Create("textinput", frame)
      object:SetPos(150, 60)
      object:SetWidth(450)
      object:SetText(EDITOR.filename)
      object:SetFocus(true)
      EDITOR.gui.dialog.txt_filename = object
    end

    if ptype=="save" then
      frame:SetName("Save File")
      frame:SetSize(650, 240)
      frame:Center()
      local object = loveframes.Create("text",frame)
      object:SetText("Filename to save : ")
      object:SetPos(15, 65)
      object = loveframes.Create("textinput", frame)
      object:SetPos(150, 60)
      object:SetWidth(450)
      object:SetText(EDITOR.filename)
      object:SetFocus(true)
      EDITOR.gui.dialog.txt_filename = object
    end
    
    if ptype=="alert" then
      frame:SetName("Warning!")
      frame:SetSize(500, 240)
      frame:Center()
      local text = loveframes.Create("text",frame)
      text:SetText(arg[1])
      text:SetPos(5, 60)
    end

    if ptype=="save" or ptype=="open" then
      local object = loveframes.Create("button",frame)
      object:SetText("Set SaveDirectory as path")
      object:SetPos(150,90)
      object:SetSize(150,20)
      object.OnClick = function() EDITOR.gui.dialog.txt_filename:SetText( love.filesystem.getSaveDirectory().."/") EDITOR.gui.dialog.txt_filename:SetFocus(true) end

      local object = loveframes.Create("text",frame)
      object:SetText("Choose from history : ")
      object:SetPos(15, 130)

      object = loveframes.Create("multichoice",frame)
      for i,v in ipairs(EDITOR.fileHistory) do
        object:AddChoice(v)
      end
      object:SetPos(150, 125)
      object:SetWidth(450)
      object.OnChoiceSelected = function(object, choice) EDITOR.gui.dialog.txt_filename:SetText( choice ) end
      EDITOR.gui.dialog.cmbfilehistory=object

      local text = loveframes.Create("text",frame)
      text:SetText("(file format is Lua or Json (extension of file must be .json)")
      text:SetPos(15, 180)

    end

    local object = loveframes.Create("button",frame)
    object:SetPos(frame:GetWidth()/2-10-object:GetWidth(),frame:GetHeight()-30)
    object:SetText("OK")
    object.OnClick = function() EDITOR.gui.dialog.returnvalue = true if (EDITOR.gui.dialog.OnClose) then EDITOR.gui.dialog.OnClose(EDITOR.gui.dialog) end EDITOR.gui.dialog:Remove() EDITOR.inputenabled = true end
    if ptype~="alert" then
      object = loveframes.Create("button",frame)
      object:SetText("Cancel")
      object:SetPos(frame:GetWidth()/2+10,frame:GetHeight()-30)
      object.OnClick = function() EDITOR.gui.dialog.returnvalue = false if (EDITOR.gui.dialog.OnClose) then EDITOR.gui.dialog.OnClose(EDITOR.gui.dialog) end EDITOR.gui.dialog:Remove() EDITOR.inputenabled = true end
    end
end

function state.createDialogHelp()

    EDITOR.inputenabled = false

    local frame = loveframes.Create("frame")
    frame:SetName("Help")
    frame:SetModal (true)
    frame:ShowCloseButton(false)
    frame:SetSize(600, 430)
    frame.OnClose = onClose
    frame:Center()
    EDITOR.gui.dialog = frame
    EDITOR.gui.dialog.returnvalue = false
    
    local list1 = loveframes.Create("list", frame)
    list1:SetPos(5, 30)
    list1:SetSize(590, 365)
    list1:SetPadding(5)
    list1:SetSpacing(5)
    local text1 = loveframes.Create("text")
    text1:SetText("Version "..game_version..
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
 ---------------------------------------------------------------------------- 
]===])
    list1:AddItem(text1)    
    local text1 = loveframes.Create("text")
    text1:SetText([===[Use mouse to drag nodes from the palette to the right onto other nodeselected 
 Use mouse left button to move nodes (horizzontaly not over other nodes) 
 Use mouse right button to move nodes between nodes 
 Use mouse wheel to zoom in/zoom out 
 Load and save works in Lua or Json (file must have extension .json) 
]===])
    list1:AddItem(text1)    

    local object = loveframes.Create("button",frame)
    object:SetPos(frame:GetWidth()/2-object:GetWidth()/2,frame:GetHeight()-30)
    object:SetText("Close")
    object.OnClick = function() EDITOR.gui.dialog.returnvalue = true if (EDITOR.gui.dialog.OnClose) then EDITOR.gui.dialog.OnClose(EDITOR.gui.dialog) end EDITOR.gui.dialog:Remove() EDITOR.inputenabled = true end
end


function state.createDialogOptions()

    EDITOR.inputenabled = false

    local frame = loveframes.Create("frame")
    frame:SetName("Options")
    frame:SetModal (true)
    frame:ShowCloseButton(false)
    frame:SetSize(400, 210)
    frame.OnClose = onClose
    frame:Center()
    EDITOR.gui.dialog = frame
    EDITOR.gui.dialog.returnvalue = false
    EDITOR.gui.dialog.OnClose = state.closeDialogOptions
    
    local object =loveframes.Create("text",frame)
    object:SetPos(10, 45+5)
    object:SetMaxWidth(80)
    object:SetText("Resolution:")

    object = loveframes.Create("multichoice",frame)
    object:SetPos(100, 45)
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
    object.OnChoiceSelected = function(object, choice) local _res = split(EDITOR.gui.dialog.cmbresolution:GetChoice(),"x") EDITOR.gui.dialog.txt_customwidth:SetText( _res[1] ) EDITOR.gui.dialog.txt_customheight:SetText( _res[2] )  end
    EDITOR.gui.dialog.cmbresolution=object
    
    local object =loveframes.Create("text",frame)
    object:SetPos(10, 80)
    object:SetMaxWidth(100)
    object:SetText("Custom Width:")
    EDITOR.gui.dialog.lbl_customwidth=object
    
    local object =loveframes.Create("textinput",frame)
    object:SetPos(100, 75)
    object:SetText("".._G.screen_width)
    object:SetWidth(70)
    EDITOR.gui.dialog.txt_customwidth=object

    local object =loveframes.Create("text",frame)
    object:SetPos(180, 80)
    object:SetMaxWidth(50)
    object:SetText("Height:")
    EDITOR.gui.dialog.lbl_customwidth=object
    
    local object =loveframes.Create("textinput",frame)
    object:SetPos(230, 75)
    object:SetText("".._G.screen_height)
    object:SetWidth(70)
    EDITOR.gui.dialog.txt_customheight=object

    object = loveframes.Create("checkbox",frame)
    object:SetPos(100, 105)
    object:SetText("Fullscreen")
    object:SetChecked(screen_fullscreen)
    EDITOR.gui.dialog.chkfullscreen=object

    object = loveframes.Create("checkbox",frame)
    object:SetPos(100, 135)    object:SetText("VSync")
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
      if changeScreenMode({width=EDITOR.gui.dialog.txt_customwidth:GetText(),height=EDITOR.gui.dialog.txt_customheight:GetText(),fullscreen=EDITOR.gui.dialog.chkfullscreen:GetChecked(),vsync=EDITOR.gui.dialog.chkvsync:GetChecked(),fsaa=0}) then
        getScreenMode()
        saveScreenMode("configs.txt")
      end
    end
    state:layoutgui()
    for i,v in ipairs(EDITOR.palette) do
      v.x = screen_width-EDITOR.palettewidth+5
    end
end

function state.createDialogNotes()

    EDITOR.inputenabled = false

    local frame = loveframes.Create("frame")
    frame:SetName("Note")
    frame:SetModal (true)
    frame:ShowCloseButton(false)
    frame:SetSize(500, 450)
    frame.OnClose = funcnil
    frame:Center()
    EDITOR.gui.dialog = frame
    EDITOR.gui.dialog.returnvalue = false
    EDITOR.gui.dialog.OnClose = state.closeDialogNotes
    
    local object =loveframes.Create("textinput",frame)
    object:SetPos(10, 38)
    object:SetMultiline(true)
    object:ShowLineNumbers(false)
    object:SetSize(480, 360)
    object:SetText(EDITOR.notes)
    object:SetFocus(true)
    EDITOR.gui.dialog.txtnotes=object

    local object = loveframes.Create("button",frame)
    object:SetPos(frame:GetWidth()/2-10-object:GetWidth(),frame:GetHeight()-30)
    object:SetText("Apply")
    object.OnClick = function() EDITOR.gui.dialog.returnvalue = true if (EDITOR.gui.dialog.OnClose) then EDITOR.gui.dialog.OnClose(EDITOR.gui.dialog) end EDITOR.gui.dialog:Remove() EDITOR.inputenabled = true end
    object = loveframes.Create("button",frame)
    object:SetText("Cancel")
    object:SetPos(frame:GetWidth()/2+10,frame:GetHeight()-30)
    object.OnClick = function() EDITOR.gui.dialog.returnvalue = false if (EDITOR.gui.dialog.OnClose) then EDITOR.gui.dialog.OnClose(EDITOR.gui.dialog) end EDITOR.gui.dialog:Remove() EDITOR.inputenabled = true end
end

function state.closeDialogNotes()
    if EDITOR.gui.dialog.returnvalue==true then
      EDITOR.notes = EDITOR.gui.dialog.txtnotes:GetText()
    end
end

function state.drawGrid()
    love.graphics.setColor(200,200,200,150)
  
    if EDITOR.camera.zoom *EDITOR.gridsize > 5 then
      ax=EDITOR.cameraworld.x1-EDITOR.cameraworld.x1%EDITOR.gridsize
      ay=EDITOR.cameraworld.y1-EDITOR.cameraworld.y1%EDITOR.gridsize
      dx=EDITOR.cameraworld.x2-EDITOR.cameraworld.x2%EDITOR.gridsize+EDITOR.gridsize
      dy=EDITOR.cameraworld.y2-EDITOR.cameraworld.y2%EDITOR.gridsize+EDITOR.gridsize
  
      for i=ax,dx,EDITOR.gridsize do
        love.graphics.line(i,ay,i,dy)
      end
      for i=ay,dy,EDITOR.gridsize do 
        love.graphics.line(ax,i,dx,i)
      end
    end
end

function state.drawNodes()
    for i,v in pairs(EDITOR.nodekeys) do
       v:draw(true)
    end
end

function state.drawPalette()
    for i,v in pairs(EDITOR.palette) do
       v:draw(false)
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
  state:updateNodes()
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
    EDITOR.gui.txt_nodetype:SetText(EDITOR.nodeselected.type)
    EDITOR.gui.txt_nodename:SetText(EDITOR.nodeselected.name)
    EDITOR.gui.txt_nodefunc:SetText(EDITOR.nodeselected.func)
    if EDITOR.nodeselected.type=="Start" then
      EDITOR.gui.lbl_nodetype:SetVisible(false)
      EDITOR.gui.txt_nodetype:SetVisible(false)
      EDITOR.gui.lbl_nodename:SetVisible(false)
      EDITOR.gui.txt_nodename:SetVisible(false)
      EDITOR.gui.lbl_nodefunc:SetVisible(false)
      EDITOR.gui.txt_nodefunc:SetVisible(false)
    else
      EDITOR.gui.lbl_nodetype:SetVisible(true)
      EDITOR.gui.txt_nodetype:SetVisible(true)
      EDITOR.gui.lbl_nodename:SetVisible(true)
      EDITOR.gui.txt_nodename:SetVisible(true)
      EDITOR.gui.lbl_nodefunc:SetVisible(true)
      EDITOR.gui.txt_nodefunc:SetVisible(true)
      EDITOR.gui.txt_nodefunc:SetFocus(true)
      state.positionEditNode()
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
  state:updateNodes()
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
  
  state.positionEditNode()

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
function state:updateNodes()
  EDITOR.nodesize = 0
  EDITOR.nodelevels = 0
  EDITOR.nodesNotValid = 0
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
   if pnode:validate() == false then
      EDITOR.nodesNotValid=EDITOR.nodesNotValid+1
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
  EDITOR.gui.lbl_lblfilename:SetPos(5, 40)
  EDITOR.gui.lbl_filename:SetPos(70, 35)
  EDITOR.gui.lbl_title:SetPos(400, 40)
  EDITOR.gui.txt_title:SetPos(440, 35)
  EDITOR.gui.notesbutton:SetPos(740, 35)
  EDITOR.gui.toolbar:SetPos(0,0)
  EDITOR.gui.divisorcenter:SetMaxWidth(0)
  EDITOR.gui.toolbar:SetSize(screen_width,32)
  EDITOR.gui.divisorcenter:SetMaxWidth(screen_width-480)
  EDITOR.gui.toolbar:RedoLayout ()
  EDITOR.firstdraw = 2

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
  if ppointer~=EDITOR.mousePointer then
    EDITOR.mousePointer = ppointer
    if EDITOR.mousePointer then
      love.mouse.setVisible(false)
    else
      love.mouse.setVisible(true)
    end
  end
end

function state:changedCameraWorld()
  EDITOR.cameraworld.x1,EDITOR.cameraworld.y1 = EDITOR.camera:worldCoords(0,0)
  EDITOR.cameraworld.x2,EDITOR.cameraworld.y2 = EDITOR.camera:worldCoords(screen_width,screen_height)
  state.positionEditNode()
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
    state:updateNodes()
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
    state:updateNodes()
    EDITOR.dolayout = true
    state:changeNodeSelected(_newnode)
  end
end

function state:loadPalette()
  table.insert(EDITOR.palette, classes.node:new("","Selector","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*0,nil,nil,nil,nil))
  table.insert(EDITOR.palette, classes.node:new("","RandomSelector","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*1,nil,nil,nil,nil))
  table.insert(EDITOR.palette, classes.node:new("","Sequence","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*2,nil,nil,nil,nil))
  table.insert(EDITOR.palette, classes.node:new("","Condition","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*3,nil,nil,nil,nil))
  table.insert(EDITOR.palette, classes.node:new("","Action","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*4,nil,nil,nil,nil))
  table.insert(EDITOR.palette, classes.node:new("","RepeatUntil","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*5,nil,nil,nil,nil))
  table.insert(EDITOR.palette, classes.node:new("","Continue","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*6,nil,nil,nil,nil))
  table.insert(EDITOR.palette, classes.node:new("","Wait","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*7,nil,nil,nil,nil))
  table.insert(EDITOR.palette, classes.node:new("","WaitContinue","",nil,screen_width-EDITOR.palettewidth+5,EDITOR.toolbarheight+5+EDITOR.palettenodeheight*8,nil,nil,nil,nil))
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

function state.funcnil()
end

function state.saveFileFromDialog()
  if EDITOR.gui.dialog.returnvalue==true then
    EDITOR.filename = EDITOR.gui.dialog.txt_filename:GetText()
    EDITOR.gui.lbl_filename:SetText(EDITOR.filename)
    table.insert(EDITOR.commands_queue,{cmd="savefile"})
  end
end

function state.loadFileFromDialog()
  if EDITOR.gui.dialog.returnvalue==true then
    EDITOR.filename = EDITOR.gui.dialog.txt_filename:GetText()
    EDITOR.gui.lbl_filename:SetText(EDITOR.filename)
    table.insert(EDITOR.commands_queue,{cmd="loadfile"})
  end
end

function state.saveFile()
  if EDITOR.filename=="" then
    state.createDialog(state.funcnil,"alert","choose filename!")
    return false
  end
  EDITOR.title = EDITOR.gui.txt_title:GetText()
  local tree = state.serializeTree()
  local treeser 
  if string.ends(string.upper(EDITOR.filename),".JSON") then
    treeser = json.encode(tree)
  else
    treeser = DataDumper(tree)
  end
  if string.starts(EDITOR.filename,love.filesystem.getSaveDirectory().."/") then
    local _filename = string.sub(EDITOR.filename,string.len(love.filesystem.getSaveDirectory().."/")+1)
    if love.filesystem.write(_filename,treeser) then
      return true
    else
      error("Error saving file "..EDITOR.filename)
      return false
    end
  else
    local file = io.open(EDITOR.filename, "w")
    if file == nil then
      error("Error saving file "..EDITOR.filename)
    end
    file:write(treeser)
    file:flush()
    file:close()
  end
  
  state.addFileToHistory(EDITOR.filename)

end

function state.loadFile()
  local tree
  local treeser
  if EDITOR.filename=="" then
    state.createDialog(state.funcnil,"alert","choose filename!")
  end
  if string.starts(EDITOR.filename,love.filesystem.getSaveDirectory().."/") then
    local _filename = string.sub(EDITOR.filename,string.len(love.filesystem.getSaveDirectory().."/")+1)
    treeser = love.filesystem.read(_filename,treeser) 
  else
    local file = io.open(EDITOR.filename, "rb")
    if file == nil then
      error("Error loading file "..EDITOR.filename)
    end
    treeser = file:read("*all")
    file:close()
  end
  if treeser == nil then
    error("Error loading file "..EDITOR.filename.." or file is empty!")
    return false
  end
  if string.ends(string.upper(EDITOR.filename),".JSON") then
    tree = json.decode(treeser)
  else
    tree = loadstring(treeser)()
  end

  for k,v in pairs(tree) do
    if (type(v)=="boolean" or type(v)=="string" or type(v)=="number") and string.starts(k,"_")==false then
      EDITOR[k]=v
    elseif k == "nodes" then
      EDITOR.nodes={}
      EDITOR.nodekeys={}
      for ii,vv in ipairs(v) do
        state.deserializeChild(EDITOR.nodes,vv,1)
      end
    end
  end

  state:updateNodes()
  EDITOR.dolayout = true

  EDITOR.gui.txt_title:SetText(EDITOR.title)
  EDITOR.gui.chkautolayout:SetChecked(EDITOR.autolayout)

  state.addFileToHistory(EDITOR.filename)

  state:changeNodeSelected(EDITOR.nodes[1])

  return true
end

function state.deserializeChild(pnodeParent,pnode,plevel)
  local _nodeparent = nil
  if plevel > 1 then
    _nodeparent = pnodeParent
  end
  local _node = classes.node:new(pnode.name,pnode.type,pnode.func,pnode.id,pnode.x,pnode.y,pnode.width,pnode.height,_nodeparent,pnode.indexchild)
  for k,v in pairs(pnode) do
    if (type(v)=="boolean" or type(v)=="string" or type(v)=="number") and string.starts(k,"_")==false then
      _node[k]=v
    elseif k == "children" then
      _node.children={}
      for ii,vv in ipairs(v) do
        state.deserializeChild(_node,vv,plevel+1)
      end
    end
  end
  state:addnode(_node)
end

function state.serializeTree()
  local tree={}
  tree.title = EDITOR.title
  tree.notes = EDITOR.notes
  tree.autolayout = EDITOR.gui.chkautolayout:GetChecked()
  tree.nodes={}
  for i,v in ipairs(EDITOR.nodes) do
    tree.nodes = state.serializeNode(tree.nodes,v,1)
  end
  return tree
end

function state.serializeNode(pnodeparent, pnode,plevel)
  local node = {}
  for k,v in pairs(pnode) do
    if (type(v)=="boolean" or type(v)=="string" or type(v)=="number") and string.starts(k,"_")==false then
      node[k] = v
    elseif k == "children" then
      for ii,vv in ipairs(v) do
        node = state.serializeNode(node,vv,plevel+1)
      end
    end
  end
  if plevel == 1 then
    table.insert(pnodeparent,node)
  else
    if pnodeparent.children == nil then
      pnodeparent.children={}
    end
    table.insert(pnodeparent.children,node)
  end
  return pnodeparent
end

function state.addFileToHistory(pfilename)
  local _found=false
  for i,v in ipairs(EDITOR.fileHistory) do
    if v==pfilename then
      _found = true
      break
    end
  end
  if _found==false then
    table.insert(EDITOR.fileHistory,pfilename)
    love.filesystem.write("filehistory.txt",json.encode(EDITOR.fileHistory))
  end
end

function state.readFileHistory()
  if love.filesystem.exists("filehistory.txt")==false then
    EDITOR.fileHistory={}
  else
    local _filehistory = love.filesystem.read("filehistory.txt")
    if (_filehistory) then
      EDITOR.fileHistory =  json.decode(_filehistory)
    end
  end 
end

function state:drawStatusBar()
  love.graphics.setFont(fonts[",12"])
  love.graphics.setColor(0,0,0,255)
  love.graphics.print("Nodes :"..EDITOR.nodesize,2,screen_height-EDITOR.statusbarheight+2)
  love.graphics.print("Levels :"..EDITOR.nodelevels,2+200,screen_height-EDITOR.statusbarheight+2)
  if EDITOR.nodesNotValid==0 then
    love.graphics.setColor(0,0,0,255)
  else
    love.graphics.setColor(255,0,0,255)
  end
  love.graphics.print("Nodes KO:"..EDITOR.nodesNotValid,2+100,screen_height-EDITOR.statusbarheight+2)
end

function state.applyChangesNode(object, text)
  if EDITOR.nodeselected then
    EDITOR.nodeselected.type=EDITOR.gui.txt_nodetype:GetText()
    EDITOR.nodeselected.name=EDITOR.gui.txt_nodename:GetText()
    EDITOR.nodeselected.func=EDITOR.gui.txt_nodefunc:GetText()
    EDITOR.nodeselected:changeWidth()
  end
end

function state.positionEditNode()
  if EDITOR.nodeselected then
    local _x,_y = EDITOR.camera:cameraCoords(EDITOR.nodeselected.x,EDITOR.nodeselected.y)
    local _width,_height = EDITOR.camera:cameraCoords(EDITOR.nodeselected.x+EDITOR.nodeselected.width,EDITOR.nodeselected.y+EDITOR.nodeselected.height)
    if _x+339 > screen_width-EDITOR.palettewidth then
      _width = _width + (screen_width-EDITOR.palettewidth-_x-339)
      _x = _x + (screen_width-EDITOR.palettewidth-_x-339)
    end    
    if _x < 0 then
      _width = _width + (-_x)
      _x = _x + (-_x)
    end    
    EDITOR.gui.lbl_nodetype:SetPos(_x+2,_height+7)
    EDITOR.gui.txt_nodetype:SetPos(_x+35,_height+2)
    EDITOR.gui.lbl_nodename:SetPos(_x+172,_height+7)
    EDITOR.gui.txt_nodename:SetPos(_x+205,_height+2)
    EDITOR.gui.lbl_nodefunc:SetPos(_x+2,_height+25)
    EDITOR.gui.txt_nodefunc:SetPos(_x+35,_height+20)
    EDITOR.box={x=_x,y=_y,width=_width,height=_height}
  end
end

function state.drawEditBox()
  if EDITOR.box and EDITOR.nodeselected and EDITOR.nodeselected.type~="Start" then
    love.graphics.setColor(0,0,0,200)
    love.graphics.rectangle("line",EDITOR.box.x,EDITOR.box.height,337,39)
    love.graphics.setColor(255,255,255,200)
    love.graphics.rectangle("fill",EDITOR.box.x,EDITOR.box.height,337,39)
  end
end

function state:centerNode(pnode)
  if pnode then
    EDITOR.camera = Camera.new(pnode.x,pnode.y,1,0)
    _x1,_y1 = EDITOR.camera:worldCoords(0,0)
    _x,_y = EDITOR.camera:worldCoords(EDITOR.palettewidth,EDITOR.toolbarheight)
    EDITOR.camera = Camera.new(pnode.x-_x1+_x,pnode.y-_y1+_y,1,0)
    state:changedCameraWorld()
  end
end

function state:zoom(xc,yc,zoom)
  _xs,_ys=EDITOR.camera:cameraCoords(xc,yc)
  local _newzoom = EDITOR.camera.zoom*zoom
  if _newzoom >= 0.90 and _newzoom<=1.1 then
    _newzoom = 1
  end
  EDITOR.camera = Camera.new(xc,yc,_newzoom,EDITOR.camera.rot)
  _xc2,_yc2=EDITOR.camera:worldCoords(_xs,_ys)
  EDITOR.camera = Camera.new(xc-_xc2+xc,yc-_yc2+yc,_newzoom,EDITOR.camera.rot)
  state:changedCameraWorld()
end

function state:newTree()
  EDITOR.title = "new Tree"
  EDITOR.filename = ""
  EDITOR.notes=""

  EDITOR.nodes = {}
  EDITOR.nodekeys = {}
  EDITOR.nodesize = 0
  EDITOR.nodesNotValid=0
  state:addnode(classes.node:new("","Start","","__start__",screen_middlex,32,nil,nil,nil,1))
  EDITOR.dolayout=true

  EDITOR.camera = Camera.new(screen_middlex+EDITOR.palettewidth/2,screen_middley-EDITOR.toolbarheight-5, 1, 0)
  state:changedCameraWorld()

  EDITOR.mouseaction = nil

  endx=0
  startx=0
  endy=0
  starty=0

  state:changeNodeSelected(EDITOR.nodes[1])
end