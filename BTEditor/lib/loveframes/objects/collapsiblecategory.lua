--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

-- collapsiblecategory class
collapsiblecategory = class("collapsiblecategory", base)
collapsiblecategory:include(loveframes.templates.default)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function collapsiblecategory:initialize()

	self.type           = "collapsiblecategory"
	self.text           = "Category"
	self.width          = 200
	self.height         = 25
	self.closedheight   = 25
	self.padding        = 5
	self.internal       = false
	self.open           = false
	self.down           = false
	self.children       = {}
	self.OnOpenedClosed = nil
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function collapsiblecategory:update(dt)
	
	local visible      = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local open      = self.open
	local children  = self.children
	local curobject = children[1]
	local parent    = self.parent
	local base      = loveframes.base
	local update    = self.Update
	
	self:CheckHover()
	
	-- move to parent if there is a parent
	if parent ~= base and parent.type ~= "list" then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	if open == true then
		curobject:SetWidth(self.width - self.padding * 2)
		curobject:update(dt)
	end
	
	if update then
		update(self, dt)
	end

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function collapsiblecategory:draw()
	
	local visible = self.visible
	
	if visible == false then
		return
	end
	
	local open          = self.open
	local children      = self.children
	local curobject     = children[1]
	local skins         = loveframes.skins.available
	local skinindex     = loveframes.config["ACTIVESKIN"]
	local defaultskin   = loveframes.config["DEFAULTSKIN"]
	local selfskin      = self.skin
	local skin          = skins[selfskin] or skins[skinindex]
	local drawfunc      = skin.DrawCollapsibleCategory or skins[defaultskin].DrawCollapsibleCategory
	local draw          = self.Draw
	local drawcount     = loveframes.drawcount
	
	loveframes.drawcount = drawcount + 1
	self.draworder = loveframes.drawcount
		
	if draw then
		draw(self)
	else
		drawfunc(self)
	end
	
	if open then
		curobject:draw()
	end
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function collapsiblecategory:mousepressed(x, y, button)

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local hover     = self.hover
	local open      = self.open
	local children  = self.children
	local curobject = children[1]
	
	if hover then
	
		local col = loveframes.util.BoundingBox(self.x, x, self.y, y, self.width, 1, self.closedheight, 1)
		
		if button == "l" and col then
			
			local baseparent = self:GetBaseParent()
	
			if baseparent and baseparent.type == "frame" then
				baseparent:MakeTop()
			end
			
			self.down = true
			loveframes.hoverobject = self
		
		end
		
	end
	
	if open then
		curobject:mousepressed(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function collapsiblecategory:mousereleased(x, y, button)
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local hover     = self.hover
	local down      = self.down
	local clickable = self.clickable
	local enabled   = self.enabled
	local open      = self.open
	local col       = loveframes.util.BoundingBox(self.x, x, self.y, y, self.width, 1, self.closedheight, 1)
	local children  = self.children
	local curobject = children[1]
	
	if hover and col and down and button == "l" then
			
		if open then
			self:SetOpen(false)
		else
			self:SetOpen(true)
		end
		
		self.down = false
		
	end
	
	if open then
		curobject:mousepressed(x, y, button)
	end

end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the object's text
--]]---------------------------------------------------------
function collapsiblecategory:SetText(text)

	self.text = text
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the object's text
--]]---------------------------------------------------------
function collapsiblecategory:GetText()

	return self.text
	
end

--[[---------------------------------------------------------
	- func: SetObject(object)
	- desc: sets the category's object
--]]---------------------------------------------------------
function collapsiblecategory:SetObject(object)
	
	local children  = self.children
	local curobject = children[1]
	
	if curobject then
		curobject:Remove()
		self.children = {}
	end
	
	object:Remove()
	object.parent = self
	object:SetWidth(self.width - self.padding*2)
	object:SetPos(self.padding, self.closedheight + self.padding)
	
	table.insert(self.children, object)
	
end

--[[---------------------------------------------------------
	- func: SetObject(object)
	- desc: sets the category's object
--]]---------------------------------------------------------
function collapsiblecategory:GetObject()

	local children  = self.children
	local curobject = children[1]
	
	if curobject then
		return curobject
	else
		return false
	end
	
end

--[[---------------------------------------------------------
	- func: SetSize(width, height)
	- desc: sets the object's size
--]]---------------------------------------------------------
function collapsiblecategory:SetSize(width, height)

	self.width = width
	
end

--[[---------------------------------------------------------
	- func: SetHeight(height)
	- desc: sets the object's height
--]]---------------------------------------------------------
function collapsiblecategory:SetHeight(height)

	return
	
end

--[[---------------------------------------------------------
	- func: SetClosedHeight(height)
	- desc: sets the object's closed height
--]]---------------------------------------------------------
function collapsiblecategory:SetClosedHeight(height)

	self.closedheight = height
	
end

--[[---------------------------------------------------------
	- func: GetClosedHeight()
	- desc: gets the object's closed height
--]]---------------------------------------------------------
function collapsiblecategory:GetClosedHeight()

	return self.closedheight
	
end

--[[---------------------------------------------------------
	- func: SetOpen(bool)
	- desc: sets whether the object is opened or closed
--]]---------------------------------------------------------
function collapsiblecategory:SetOpen(bool)

	local children        = self.children
	local curobject       = children[1]
	local closedheight    = self.closedheight
	local padding         = self.padding
	local curobjectheight = curobject.height
	local onopenedclosed  = self.OnOpenedClosed
	
	self.open = bool
	
	if not bool then
		self.height = closedheight
		if curobject then
			curobject:SetVisible(false)
		end
	else
		self.height = closedheight + padding * 2 + curobjectheight
		if curobject then
			curobject:SetVisible(true)
		end
	end
	
	-- call the on opened closed callback if it exists
	if onopenedclosed then
		onopenedclosed(self)
	end
	
end

--[[---------------------------------------------------------
	- func: GetOpen()
	- desc: gets whether the object is opened or closed
--]]---------------------------------------------------------
function collapsiblecategory:GetOpen()

	return self.opened

end