--- node

local node = SECS_class:new()

function node:init(pname,ptype,pfunc,pid,px,py,pwidth,pheight,pparent,pindexchild)
  
  --- common properties for node
  self.name = pname
  self.type = ptype
  self.func = pfunc
  self.id = pid
  if self.id==nil then
    self.id = generateId("node")
  end 
  self.x = px
  self.y = py
  self.finished = false
  self.textwidth, self.textlines = fonts[","..EDITOR.fontsize]:getWrap(self.type.."\n"..self.name.."\n"..self.func.." ", 400)
  self.width = pwidth
  if pwidth==nil then
    self:changeWidth()
  end
  self.height = nvl(pheight,EDITOR.fontsize*2+EDITOR.fontsize*self.textlines)
  self.selected = false
  self.parent = pparent
  self.children={}
  self.level = 1
  self.sleep = false
  if self.parent then
    self.level = self.parent.level+1
  end
  self.indexchild = pindexchild
  if self.indexchild ==nil then
    self.indexchild = 1
    if self.parent then
      for i,v in ipairs(self.parent.children) do
        self.indexchild = self.indexchild +1
      end
    end
  end
  if self.x==nil then
    if self.parent then
      self.x = self.parent.x+self.parent.width/2+(self.indexchild-1)*64-self.width/2
      for i,v in ipairs (self.parent.children) do
        self.x = v.x+v.width+5
      end
    else
      self.x = (self.indexchild-1)*64
    end
  end
  if self.y==nil then
    if self.parent then
      self.y = self.parent.y+EDITOR.divisory
    else
      self.y = (self.level-1)*EDITOR.divisory*2
    end
  end
  self.levelindex = self.level*10+self.indexchild
  self.valid=nil
end

function node:update(dt)
 
  return true
 
end

function node:draw(pclipifoutsidecamera)
  local _draw = true
  if pclipifoutsidecamera then
    if self.x+self.width < EDITOR.cameraworld.x1 or self.x > EDITOR.cameraworld.x2 or self.y+self.height < EDITOR.cameraworld.y1 or self.y > EDITOR.cameraworld.y2 then
      _draw = false
    end
  end
  if _draw then
    if self.selected then
      love.graphics.setLineWidth(3)
    else
      love.graphics.setLineWidth(1)
    end
    love.graphics.setFont(fonts[","..EDITOR.fontsize])
    if self.type=="Start" then
      love.graphics.setColor(255,150,80,255)
      love.graphics.circle("fill",self.x+self.width/2,self.y+self.height/2,self.height/2)
      love.graphics.setColor(0,0,0,255)
      love.graphics.circle("line",self.x+self.width/2,self.y+self.height/2,self.height/2)
      if self.selected then
        love.graphics.setLineWidth(1)
        love.graphics.setColor(255,255,0,255)
        love.graphics.circle("line",self.x+self.width/2,self.y+self.height/2,self.height/2)
        love.graphics.setLineWidth(3)
        love.graphics.setColor(0,0,0,255)
      end
    end
    if self.type=="Selector" or self.type=="RandomSelector" then
      love.graphics.setColor(255,150,80,255)
      love.graphics.polygon("fill",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
      love.graphics.setColor(0,0,0,255)
      love.graphics.polygon("line",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
      if self.selected then
        love.graphics.setLineWidth(1)
        love.graphics.setColor(255,255,0,255)
        love.graphics.polygon("line",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
        love.graphics.setLineWidth(3)
        love.graphics.setColor(0,0,0,255)
      end
      if self.type=="Selector" then
        love.graphics.setColor(255,255,255,255)
        love.graphics.draw(images.selector,self.x+2,self.y+2)
      end
      if self.type=="RandomSelector" then
        love.graphics.setColor(255,255,255,255)
        love.graphics.draw(images.randomselector,self.x+2,self.y+2)
      end
    end
    if self.type=="Sequence" then
      love.graphics.setColor(150,255,150,255)
      love.graphics.polygon("fill",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
      love.graphics.setColor(0,0,0,255)
      love.graphics.polygon("line",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
      if self.selected then
        love.graphics.setLineWidth(1)
        love.graphics.setColor(255,255,0,255)
        love.graphics.polygon("line",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
        love.graphics.setLineWidth(3)
        love.graphics.setColor(0,0,0,255)
      end
      love.graphics.setColor(255,255,255,255)
      love.graphics.draw(images.sequence,self.x+2,self.y+2)
    end
    if self.type=="Action" then
      love.graphics.setColor(150,150,255,255)
      love.graphics.polygon("fill",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
      love.graphics.setColor(0,0,0,255)
      love.graphics.polygon("line",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
      if self.selected then
        love.graphics.setLineWidth(1)
        love.graphics.setColor(255,255,0,255)
        love.graphics.polygon("line",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
        love.graphics.setLineWidth(3)
        love.graphics.setColor(0,0,0,255)
      end
      love.graphics.setColor(255,255,255,255)
      love.graphics.draw(images.action,self.x+2,self.y+2)
    end
    if self.type=="Decorator" or self.type=="RepeatUntil" or self.type=="Continue"  or self.type=="Wait" or self.type=="WaitContinue"then
      love.graphics.setColor(255,255,100,255)
      love.graphics.polygon("fill",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
      love.graphics.setColor(0,0,0,255)
      love.graphics.polygon("line",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
      if self.selected then
        love.graphics.setLineWidth(1)
        love.graphics.setColor(255,255,0,255)
        love.graphics.polygon("line",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
        love.graphics.setLineWidth(3)
        love.graphics.setColor(0,0,0,255)
      end
    end
    if self.type=="Condition" then
      love.graphics.setColor(150,255,150,255)
      love.graphics.polygon("fill",self.x+self.width/2,self.y
        ,self.x+self.width,self.y+self.height/2,self.x+self.width/2,self.y+self.height,self.x,self.y+self.height/2)
      love.graphics.setColor(0,0,0,255)
      love.graphics.polygon("line",self.x+self.width/2,self.y
        ,self.x+self.width,self.y+self.height/2,self.x+self.width/2,self.y+self.height,self.x,self.y+self.height/2)
      if self.selected then
        love.graphics.setLineWidth(1)
        love.graphics.setColor(255,255,0,255)
        love.graphics.polygon("line",self.x+self.width/2,self.y
        ,self.x+self.width,self.y+self.height/2,self.x+self.width/2,self.y+self.height,self.x,self.y+self.height/2)
        love.graphics.setLineWidth(3)
        love.graphics.setColor(0,0,0,255)
      end
      love.graphics.setColor(255,255,255,255)
      love.graphics.draw(images.condition,self.x+2,self.y+2)
    end
    love.graphics.setColor(0,0,0,255)
    if self.type=="Start" then
      love.graphics.printf(self.type.."\n"..self.name.."\n"..self.func,self.x,self.y+EDITOR.fontsize*3/2,self.width,"center")
    else
      love.graphics.printf(self.type.."\n"..self.name.."\n"..self.func,self.x,self.y+EDITOR.fontsize/2,self.width,"center")
    end
    if self.validtext then
      love.graphics.setColor(255,0,0,255)
      love.graphics.print(self.validtext,self.x,self.y+self.height+2)
    end
  end
  love.graphics.setLineWidth(1)
  
  if self.parent then
    local _drawarrow = true
    if _draw==false then
    end
    if _drawarrow then
      love.graphics.setColor(0,0,0,255)
      EDITOR.drawArrow(self.parent.x+self.parent.width/2,self.parent.y+self.parent.height+2,self.x+self.width/2,self.y-2)
    end
  end
  --if self.children then
  --  for i,v in ipairs(self.children) do
  --    love.graphics.setColor(64,64,64,255)
  --    EDITOR.drawArrow(self.x+self.width/2,self.y+self.height+2,v.x+v.width/2,v.y-2)
  --  end
  --end
end

function node:changeWidth()
  self.textwidth, self.textlines = fonts[","..EDITOR.fontsize]:getWrap(self.type.."\n"..self.name.."\n"..self.func.." ", 400)
  local _increment = 28
  if (self.type=="Condition") then
    _increment =EDITOR.fontsize*4+28
  end
  self.width = self.textwidth+_increment
end

function node:validate()
  local _valid = true
  local _validtext = ""
  if self.type == "Start" then
    if self.children==nil or #self.children==0 then
      _valid = false
      _validtext = _validtext.."At least one child node"
    end
  elseif self.type=="Selector" or self.type=="RandomSelector" then
    if self.children==nil or #self.children==0 then
      _valid = false
      _validtext = _validtext.."At least one child node"
    end
  elseif self.type == "Sequence" then
    if self.children==nil or #self.children==0 then
      _valid = false
      _validtext = _validtext.."At least one child node"
    end
  elseif self.type == "Condition" then
    if self.children~=nil and #self.children>0 then
      _valid = false
      _validtext = _validtext.."Childs are forbidden"
    end
    if self.func==nil or self.func=="" then
      _valid = false
      _validtext = _validtext.."Define a function for condition node"
    end
  elseif self.type == "Action" then
    if self.children~=nil and #self.children>0 then
      _valid = false
      _validtext = _validtext.."Children are forbidden"
    end
    if self.func==nil or self.func=="" then
      _valid = false
      _validtext = _validtext.."Define a function for action node"
    end
  elseif self.type=="Decorator" or self.type=="RepeatUntil" or self.type=="Continue"  or self.type=="Wait" or self.type=="WaitContinue" then
    if self.children==nil or #self.children==0 then
      _valid = false
      _validtext = _validtext.."At least one child"
    end
    if self.children~=nil and #self.children>1 then
      _valid = false
      _validtext = _validtext.."Only one child allowed"
    end
  end   
  if _validtext =="" then
    _validtext = nil
  end
  self.valid = _valid
  self.validtext = _validtext
  return self.valid, self.validtext
end

return node