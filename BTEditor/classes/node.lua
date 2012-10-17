--- node

node = SECS_class:new()

function node:init(pname,ptype,pfunction,pid,px,py,pwidth,pheight,pparent,pindexchild)
  --- common properties for node
  self.name = pname
  self.type = ptype
  self.func = pfunction
  self.id = pid
  if self.id==nil then
    self.id = generateId("node")
  end 
  self.x = px
  self.y = py
  self.finished = false
  self.textwidth, self.textlines = fonts[",10"]:getWrap(self.type.."\n"..self.name.."\n"..self.func.." ", 400)
  self.width = nvl(pwidth,self.textwidth+10*2)
  self.height = nvl(pheight,10*2+10*self.textlines)
  self.selected = false
  self.parent = pparent
  self.level = 1
  self.sleep = false
  if pparent then
    self.level = pparent.level+1
  end
  self.indexchild = pindexchild
  if self.indexchild ==nil then
    self.indexchild = 1
    if pparent ~= nil then
      for i,v in ipairs(EDITOR.nodes) do
        if v.parent == pparent then
          self.indexchild = self.indexchild +1
        end
      end
    end
  end
  if self.x==nil then
    if pparent then
      self.x = pparent.x+(self.indexchild-1)*100
    else
      self.x = (self.indexchild-1)*100
    end
  end
  if self.y==nil then
    if pparent then
      self.y = pparent.y+pparent.height+32
    else
      self.y = (level-1)*64
    end
  end
  self.levelindex = self.level*10+self.indexchild
end

function node:update(dt)
 
  return true
 
end

function node:draw()
  if self.selected then
    love.graphics.setLineWidth(3)
  else
    love.graphics.setLineWidth(1)
  end
  love.graphics.setFont(fonts[",10"])
  love.graphics.setColor(255,150,80,255)
  love.graphics.polygon("fill",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
  love.graphics.setColor(0,0,0,255)
  love.graphics.polygon("line",self.x,self.y,self.x+self.width,self.y,self.x+self.width,self.y+self.height,self.x,self.y+self.height)
  love.graphics.printf(self.type.."\n"..self.name.."\n"..self.func.." "..self.indexchild..":"..self.levelindex,self.x,self.y+10,self.width,"center")
  love.graphics.setLineWidth(1)
  if self.parent then
    love.graphics.line(self.parent.x+self.parent.width/2,self.parent.y+self.parent.height,self.x+self.width/2,self.y)
  end
end

function node:validate()
  return true,""
end