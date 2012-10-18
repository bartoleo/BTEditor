--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

-- base object
base = class("base")
base:include(loveframes.templates.default)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: intializes the element
--]]---------------------------------------------------------
function base:initialize()
	
	-- width and height of the window
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	
	self.type 		= "base"
	self.width 		= w
	self.height 	= h
	self.internal	= true
	self.children 	= {}
	self.internals	= {}

end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function base:update(dt)
	
	local children = self.children
	
	for k, v in ipairs(children) do
		v:update(dt)
	end
	
	for k, v in ipairs(self.internals) do
		v:update(dt)
	end

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function base:draw()

	local children = self.children
	
	loveframes.drawcount = loveframes.drawcount + 1
	self.draworder = loveframes.drawcount
	
	for k, v in ipairs(children) do
		v:draw()
	end
	
	for k, v in ipairs(self.internals) do
		v:draw()
	end

end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function base:mousepressed(x, y, button)

	local visible = self.visible
	local children = self.children
	local internals = self.internals
	
	if not visible then
		return
	end
	
	if children then
		for k, v in ipairs(children) do
			v:mousepressed(x, y, button)
		end
	end
	
	if internals then
		for k, v in ipairs(internals) do
			v:mousepressed(x, y, button)
		end
	end

end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function base:mousereleased(x, y, button)

	local visible = self.visible
	local children = self.children
	local internals = self.internals
	
	if not visible then
		return
	end
	
	if children then
		for k, v in ipairs(children) do
			v:mousereleased(x, y, button)
		end
	end
	
	if internals then
		for k, v in ipairs(internals) do
			v:mousereleased(x, y, button)
		end
	end

end

--[[---------------------------------------------------------
	- func: keypressed(key)
	- desc: called when the player presses a key
--]]---------------------------------------------------------
function base:keypressed(key, unicode)

	local visible = self.visible
	local children = self.children
	local internals = self.internals
	
	if not visible then
		return
	end
	
	if children then
		for k, v in ipairs(children) do
			v:keypressed(key, unicode)
		end
	end
	
	if internals then
		for k, v in ipairs(internals) do
			v:keypressed(key, unicode)
		end
	end

end

--[[---------------------------------------------------------
	- func: keyreleased(key)
	- desc: called when the player releases a key
--]]---------------------------------------------------------
function base:keyreleased(key)

	local visible = self.visible
	local children = self.children
	local internals = self.internals
	
	if not visible then
		return
	end
	
	if children then
		for k, v in ipairs(children) do
			v:keyreleased(key)
		end
	end
	
	if internals then
		for k, v in ipairs(internals) do
			v:keyreleased(key)
		end
	end

end



--[[---------------------------------------------------------
	- func: SetPos(x, y)
	- desc: sets the object's position
--]]---------------------------------------------------------
function base:SetPos(x, y)

	local base = loveframes.base
	local parent = self.parent
	
	if parent == base then
		self.x = x
		self.y = y
	else
		self.staticx = x
		self.staticy = y
	end
	
end

--[[---------------------------------------------------------
	- func: SetX(x)
	- desc: sets the object's x position
--]]---------------------------------------------------------
function base:SetX(x)

	local base = loveframes.base
	local parent = self.parent
	
	if parent == base then
		self.x = x
	else
		self.staticx = x
	end

end

--[[---------------------------------------------------------
	- func: SetY(y)
	- desc: sets the object's y position
--]]---------------------------------------------------------
function base:SetY(y)

	local base = loveframes.base
	local parent = self.parent
	
	if parent == base then
		self.y = y
	else
		self.staticy = y
	end
	
end

--[[---------------------------------------------------------
	- func: GetPos()
	- desc: gets the object's position
--]]---------------------------------------------------------
function base:GetPos()

	return self.x, self.y
	
end

--[[---------------------------------------------------------
	- func: GetX()
	- desc: gets the object's x position
--]]---------------------------------------------------------
function base:GetX()

	return self.x
	
end

--[[---------------------------------------------------------
	- func: GetY()
	- desc: gets the object's y position
--]]---------------------------------------------------------
function base:GetY()

	return self.y
	
end

--[[---------------------------------------------------------
	- func: GetStaticPos()
	- desc: gets the object's static position
--]]---------------------------------------------------------
function base:GetStaticPos()

	return self.staticx, self.staticy
	
end

--[[---------------------------------------------------------
	- func: GetStaticX()
	- desc: gets the object's static x position
--]]---------------------------------------------------------
function base:GetStaticX()

	return self.staticx
	
end

--[[---------------------------------------------------------
	- func: GetStaticY()
	- desc: gets the object's static y position
--]]---------------------------------------------------------
function base:GetStaticY()

	return self.staticy
	
end

--[[---------------------------------------------------------
	- func: Center()
	- desc: centers the object in the game window or in
			it's parent if it has one
--]]---------------------------------------------------------
function base:Center()

	local base = loveframes.base
	local parent = self.parent
	
	if parent == base then
		local width = love.graphics.getWidth()
		local height = love.graphics.getHeight()
		
		self.x = width/2 - self.width/2
		self.y = height/2 - self.height/2
	else
		local width = parent.width
		local height = parent.height
		
		self.staticx = width/2 - self.width/2
		self.staticy = height/2 - self.height/2
	end
	
end

--[[---------------------------------------------------------
	- func: CenterX()
	- desc: centers the object by it's x value
--]]---------------------------------------------------------
function base:CenterX()

	local base = loveframes.base
	local parent = self.parent
	
	if parent == base then
		local width = love.graphics.getWidth()
		self.x = width/2 - self.width/2
	else
		local width = parent.width
		self.staticx = width/2 - self.width/2
	end
	
end

--[[---------------------------------------------------------
	- func: CenterY()
	- desc: centers the object by it's y value
--]]---------------------------------------------------------
function base:CenterY()

	local base = loveframes.base
	local parent = self.parent
	
	if parent == base then
		local height = love.graphics.getHeight()
		self.y = height/2 - self.height/2
	else
		local height = parent.height
		self.staticy = height/2 - self.height/2
	end
	
end

--[[---------------------------------------------------------
	- func: SetSize(width, height)
	- desc: sets the object's size
--]]---------------------------------------------------------
function base:SetSize(width, height)

	self.width = width
	self.height = height
	
end

--[[---------------------------------------------------------
	- func: SetWidth(width)
	- desc: sets the object's width
--]]---------------------------------------------------------
function base:SetWidth(width)

	self.width = width
	
end

--[[---------------------------------------------------------
	- func: SetHeight(height)
	- desc: sets the object's height
--]]---------------------------------------------------------
function base:SetHeight(height)

	self.height = height
	
end

--[[---------------------------------------------------------
	- func: GetSize()
	- desc: gets the object's size
--]]---------------------------------------------------------
function base:GetSize()

	return self.width, self.height
	
end

--[[---------------------------------------------------------
	- func: GetWidth()
	- desc: gets the object's width
--]]---------------------------------------------------------
function base:GetWidth()

	return self.width
	
end

--[[---------------------------------------------------------
	- func: GetHeight()
	- desc: gets the object's height
--]]---------------------------------------------------------
function base:GetHeight()

	return self.height
	
end

--[[---------------------------------------------------------
	- func: SetVisible(bool)
	- desc: sets the object's visibility
--]]---------------------------------------------------------
function base:SetVisible(bool)

	local children = self.children
	local internals = self.internals
	
	self.visible = bool

	if children then
		for k, v in ipairs(children) do
			v:SetVisible(bool)
		end
	end
	
	if internals then
		for k, v in ipairs(internals) do
			v:SetVisible(bool)
		end
	end
	
end

--[[---------------------------------------------------------
	- func: GetVisible()
	- desc: gets the object's visibility
--]]---------------------------------------------------------
function base:GetVisible()

	return self.visible
	
end

--[[---------------------------------------------------------
	- func: SetParent(parent)
	- desc: sets the object's parent
--]]---------------------------------------------------------
function base:SetParent(parent)

	local tparent = parent
	local cparent = self.parent
	local ptype = tparent.type
	local stype = self.type
	
	if ptype ~= "frame" and ptype ~= "panel" and ptype ~= "list" then
		return
	end
	
	self:Remove()
	self.parent = tparent
	
	table.insert(tparent.children, self)

end

--[[---------------------------------------------------------
	- func: GetParent()
	- desc: gets the object's parent
--]]---------------------------------------------------------
function base:GetParent()

	local parent = self.parent
	return parent
	
end

--[[---------------------------------------------------------
	- func: Remove()
	- desc: removes the object
--]]---------------------------------------------------------
function base:Remove()
	
	local pinternals = self.parent.internals
	local pchildren = self.parent.children
	
	if pinternals then
		for k, v in ipairs(pinternals) do
			if v == self then
				table.remove(pinternals, k)
			end
		end
	end
	
	if pchildren then
		for k, v in ipairs(pchildren) do
			if v == self then
				table.remove(pchildren, k)
			end
		end
	end
	
	self.removed = true
	
end

--[[---------------------------------------------------------
	- func: SetClickBounds(x, y, width, height)
	- desc: sets a boundary box for the object's collision
			detection
--]]---------------------------------------------------------
function base:SetClickBounds(x, y, width, height)

	local internals = self.internals
	local children = self.children
	
	self.clickbounds = {x = x, y = y, width = width, height = height}
	
	if internals then
		for k, v in ipairs(internals) do
			v:SetClickBounds(x, y, width, height)
		end
	end
	
	if children then
		for k, v in ipairs(children) do
			v:SetClickBounds(x, y, width, height)
		end
	end
	
end

--[[---------------------------------------------------------
	- func: GetClickBounds()
	- desc: gets the boundary box for the object's collision
			detection
--]]---------------------------------------------------------
function base:GetClickBounds()

	return self.clickbounds
	
end

--[[---------------------------------------------------------
	- func: RemoveClickBounds()
	- desc: removes the collision detection boundary for the 
			object 
--]]---------------------------------------------------------
function base:RemoveClickBounds()

	local internals = self.internals
	local children = self.children
	
	self.clickbounds = nil
	
	if internals then
		for k, v in ipairs(internals) do
			v:RemoveClickBounds()
		end
	end
	
	if children then
		for k, v in ipairs(children) do
			v:RemoveClickBounds()
		end
	end
	
end

--[[---------------------------------------------------------
	- func: InClickBounds()
	- desc: checks if the mouse is inside the object's
			collision detection boundaries
--]]---------------------------------------------------------
function base:InClickBounds()

	local x, y = love.mouse.getPosition()
	local bounds = self.clickbounds
	
	if bounds then
		local col = loveframes.util.BoundingBox(x, bounds.x, y, bounds.y, 1, bounds.width, 1, bounds.height)
		return col
	else
		return false
	end
	
end

--[[---------------------------------------------------------
	- func: IsTopCollision()
	- desc: checks if the object the top most object in a
			collision table
--]]---------------------------------------------------------
function base:IsTopCollision()

	local cols = loveframes.util.GetCollisions()
	local draworder = self.draworder
	local top = true
	
	-- loop through the object's parent's children
	for k, v in ipairs(cols) do
		if v.draworder > draworder then
			top = false
		end	
	end
	
	return top
		
end

--[[---------------------------------------------------------
	- func: GetBaseParent(object, t)
	- desc: finds the object's base parent
--]]---------------------------------------------------------
function base:GetBaseParent(t)
	
	local t = t or {}
	local base = loveframes.base
	local parent = self.parent
	
	if parent ~= base then
		table.insert(t, parent)
		parent:GetBaseParent(t)
	end
	
	return t[#t]
	
end

--[[---------------------------------------------------------
	- func: CheckHover()
	- desc: checks to see if the object should be in a
			hover state
--]]---------------------------------------------------------
function base:CheckHover()
	
	local x, y = love.mouse.getPosition()
	local selfcol = loveframes.util.BoundingBox(x, self.x, y, self.y, 1, self.width, 1, self.height)
	local hoverobject = loveframes.hoverobject
	local modalobject = loveframes.modalobject
	local clickbounds = self.clickbounds
	
	-- is the mouse inside the object?
	if selfcol then
		
		local top = self:IsTopCollision()
		
		if top then
			if not hoverobject then
				self.hover = true
			else
				if hoverobject == self then
					self.hover = true
				else
					self.hover = false
				end
			end
		else
			self.hover = false
		end
	
		if clickbounds then
			if not self:InClickBounds() then
				self.hover = false
			end
		end
	
	else
		
		self.hover = false
		
	end
	
	if modalobject then
	
		if modalobject ~= self then
		
			local baseparent = self:GetBaseParent()
			
			if baseparent ~= modalobject and self.type ~= "multichoice-row" then
			
				self.hover = false
				
				if self.focus then
					self.focus = false
				end
				
			end
			
		end
		
	end
	
	-- this chunk of code handles mouse enter and exit
	if self.hover == true then
	
		if not self.calledmousefunc then
		
			if self.OnMouseEnter then
				self.OnMouseEnter(self)
				self.calledmousefunc = true
			else
				self.calledmousefunc = true
			end
		
		end
		
	else
	
		if self.calledmousefunc then
			
			if self.OnMouseExit then
				self.OnMouseExit(self)
				self.calledmousefunc = false
			else
				self.calledmousefunc = false
			end
			
		end
		
	end
	
end

--[[---------------------------------------------------------
	- func: GetHover()
	- desc: return if the object is in a hover state or not
--]]---------------------------------------------------------
function base:GetHover()

	return self.hover

end

--[[---------------------------------------------------------
	- func: GetChildren()
	- desc: returns the object's children
--]]---------------------------------------------------------
function base:GetChildren()

	local children = self.children
	
	if children then
		return children
	end
	
end

--[[---------------------------------------------------------
	- func: IsTopList()
	- desc: returns true if the object is the top most list
			object or false if not
--]]---------------------------------------------------------
function base:IsTopList()

	local cols = loveframes.util.GetCollisions()
	local children = self:GetChildren()
	local order = self.draworder
	local top = true
	local found = false
	
	local function IsChild(object)
	
		local parents = object:GetParents()
		
		for k, v in ipairs(parents) do
			if v == self then
				return true
			end
		end
		
		return false
		
	end
	
	for k, v in ipairs(cols) do
		if v == self then
			found = true
		else
			if v.draworder > order then
				if IsChild(v) ~= true then
					top = false
					break
				end
			end
		end
	end
	
	if found == false then
		top = false
	end
	
	return top
	
end

--[[---------------------------------------------------------
	- func: IsTopChild()
	- desc: returns true if the object is the top most child
			in it's parent's children table or false if not
--]]---------------------------------------------------------
function base:IsTopChild()

	local children = self.parent.children
	local num = #children
	
	if children[num] == self then
		return true
	else
		return false
	end
	
end

--[[---------------------------------------------------------
	- func: MoveToTop()
	- desc: moves the object to the top of it's parent's
			children table
--]]---------------------------------------------------------
function base:MoveToTop()

	local pchildren = self.parent.children
	local pinternals = self.parent.internals
	
	local internal = false
	
	for k, v in ipairs(pinternals) do
		if v == self then
			internal = true
		end
	end
	
	self:Remove()
	
	if internal then
		table.insert(pinternals, self)
	else
		table.insert(pchildren, self)
	end
	
end

--[[---------------------------------------------------------
	- func: SetSkin(name)
	- desc: sets the object's skin
--]]---------------------------------------------------------
function base:SetSkin(name)

	local children = self.children
	local internals = self.internals
	
	self.skin = name
	
	if children then
		for k, v in ipairs(children) do
			v:SetSkin(name)
		end
	end
	
	if internals then
		for k, v in ipairs(internals) do
			v:SetSkin(name)
		end
	end
	
end

--[[---------------------------------------------------------
	- func: GetSkin(name)
	- desc: gets the object's skin
--]]---------------------------------------------------------
function base:GetSkin(name)

	return self.skin
	
end

--[[---------------------------------------------------------
	- func: SetAlwaysUpdate(bool)
	- desc: sets the object's skin
--]]---------------------------------------------------------
function base:SetAlwaysUpdate(bool)

	self.alwaysupdate = bool

end

--[[---------------------------------------------------------
	- func: GetAlwaysUpdate()
	- desc: gets whether or not the object will always update
--]]---------------------------------------------------------
function base:GetAlwaysUpdate()

	return self.alwaysupdate

end

--[[---------------------------------------------------------
	- func: SetRetainSize(bool)
	- desc: sets whether or not the object should retain it's
			size when another object tries to resize it
--]]---------------------------------------------------------
function base:SetRetainSize(bool)

	self.retainsize = bool
	
end

--[[---------------------------------------------------------
	- func: GetRetainSize()
	- desc: gets whether or not the object should retain it's
			size when another object tries to resize it
--]]---------------------------------------------------------
function base:GetRetainSize()
	
	return self.retainsize
	
end

--[[---------------------------------------------------------
	- func: IsActive()
	- desc: gets whether or not the object is active within
			it's parent's child table
--]]---------------------------------------------------------
function base:IsActive()

	local parent = self.parent
	local pchildren = parent.children
	local valid = false
	
	for k, v in ipairs(pchildren) do
		if v == self then
			valid = true
		end
	end
	
	return valid
	
end

--[[---------------------------------------------------------
	- func: GetParents()
	- desc: returns a table of the object's parents and it's
			sub-parents
--]]---------------------------------------------------------
function base:GetParents()
	
	local function GetParents(object, t)
		
		local t = t or {}
		local type = object.type
		local parent = object.parent
		
		if type ~= "base" then
			table.insert(t, parent)
			GetParents(parent, t)
		end
		
		return t
		
	end
	
	local parents = GetParents(self)
	
	return parents
	
end

--[[---------------------------------------------------------
	- func: IsTopInternal()
	- desc: returns true if the object is the top most 
			internal in it's parent's internals table or 
			false if not
--]]---------------------------------------------------------
function base:IsTopInternal()

	local internals = self.parent.internals
	
	if internals[#internals] ~= self then
		return false
	else
		return true
	end
	
end

--[[---------------------------------------------------------
	- func: IsInternal()
	- desc: returns true if the object is internal or 
			false if not
--]]---------------------------------------------------------
function base:IsInternal()

	return self.internal
	
end

--[[---------------------------------------------------------
	- func: GetType()
	- desc: gets the type of the object
--]]---------------------------------------------------------
function base:GetType()

	return self.type

end