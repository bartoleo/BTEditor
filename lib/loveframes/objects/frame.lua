--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

-- frame class
frame = class("frame", base)
frame:include(loveframes.templates.default)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function frame:initialize()
	
	self.type               = "frame"
	self.name               = "Frame"
	self.width              = 300
	self.height             = 150
	self.clickx             = 0
	self.clicky             = 0
	self.internal           = false
	self.draggable          = true
	self.screenlocked       = false
	self.dragging           = false
	self.modal              = false
	self.modalbackground    = false
	self.showclose          = true
	self.internals          = {}
	self.children           = {}
	self.OnClose            = nil
	
	-- create the close button for the frame
	local close = closebutton:new()
	close.parent = self
	close:SetSize(16, 16)
	close.OnClick = function()
		local onclose = self.OnClose
		self:Remove()
		if onclose then
			onclose(self)
		end
	end
	
	table.insert(self.internals, close)
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the element
--]]---------------------------------------------------------
function frame:update(dt)
	
	local visible      = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local x, y              = love.mouse.getPosition()
	local showclose         = self.showclose
	local close             = self.internals[1]
	local dragging          = self.dragging
	local screenlocked      = self.screenlocked
	local modal             = self.modal
	local base              = loveframes.base
	local basechildren      = base.children
	local numbasechildren   = #basechildren
	local draworder         = self.draworder
	local children          = self.children
	local internals         = self.internals
	local update            = self.Update
	
	close:SetPos(self.width - 20, 4)
	self:CheckHover()
	
	-- dragging check
	if dragging then
		self.x = x - self.clickx
		self.y = y - self.clicky
	end
	
	-- if screenlocked then keep within screen
	if screenlocked == true then
	
		local width = love.graphics.getWidth()
		local height = love.graphics.getHeight()
		local selfwidth = self.width
		local selfheight = self.height
		
		if self.x < 0 then
			self.x = 0
		end
		if self.x + selfwidth > width then
			self.x = width - selfwidth
		end
		if self.y < 0 then
			self.y = 0
		end
		if self.y + selfheight > height then
			self.y = height - selfheight
		end
		
	end
	
	if modal == true then
		
		local tip = false
		local key = 0
		
		for k, v in ipairs(basechildren) do
			if v.type == "tooltip" and v.show == true then
				tip = v
				key = k
			end
		end
		
		if tip ~= false then
			self:Remove()
			self.modalbackground:Remove()
			table.insert(basechildren, key - 2, self.modalbackground)
			table.insert(basechildren, key - 1, self)
		end
		
		if self.modalbackground.draworder > self.draworder then
			self:MakeTop()
		end
		
	end
	
	for k, v in ipairs(internals) do
		v:update(dt)
	end
	
	for k, v in ipairs(children) do
		v:update(dt)
	end
	
	if update then
		update(self, dt)
	end

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function frame:draw()
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local children      = self.children
	local internals     = self.internals
	local skins         = loveframes.skins.available
	local skinindex     = loveframes.config["ACTIVESKIN"]
	local defaultskin   = loveframes.config["DEFAULTSKIN"]
	local selfskin      = self.skin
	local skin          = skins[selfskin] or skins[skinindex]
	local drawfunc      = skin.DrawFrame or skins[defaultskin].DrawFrame
	local draw          = self.Draw
	local drawcount     = loveframes.drawcount
	
	loveframes.drawcount = drawcount + 1
	self.draworder = loveframes.drawcount
		
	if draw then
		draw(self)
	else
		drawfunc(self)
	end
	
	for k, v in ipairs(internals) do
		v:draw()
	end
	
	-- loop through the object's children and draw them
	for k, v in ipairs(children) do
		v:draw()
	end
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function frame:mousepressed(x, y, button)

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local width     = self.width
	local height    = self.height
	local selfcol   = loveframes.util.BoundingBox(x, self.x, y, self.y, 1, self.width, 1, self.height)
	local internals = self.internals
	local children  = self.children
	
	if selfcol then
	
		local top = self:IsTopCollision()
		
		-- initiate dragging if not currently dragging
		if not self.dragging and top and button == "l" then
			if y < self.y + 25 and self.draggable then
				self.clickx = x - self.x
				self.clicky = y - self.y
				self.dragging = true
			end
		end
		
		if top and button == "l" then
			self:MakeTop()
		end
		
	end
	
	for k, v in ipairs(internals) do
		v:mousepressed(x, y, button)
	end
		
	for k, v in ipairs(children) do
		v:mousepressed(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function frame:mousereleased(x, y, button)
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local dragging  = self.dragging
	local children  = self.children
	local internals = self.internals
	
	-- exit the dragging state
	if dragging then
		self.dragging = false
	end
	
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end
	
	for k, v in ipairs(children) do
		v:mousereleased(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: SetName(name)
	- desc: sets the frame's name
--]]---------------------------------------------------------
function frame:SetName(name)

	self.name = name
	
end

--[[---------------------------------------------------------
	- func: GetName()
	- desc: gets the frame's name
--]]---------------------------------------------------------
function frame:GetName()

	return self.name
	
end

--[[---------------------------------------------------------
	- func: SetDraggable(true/false)
	- desc: sets whether the frame can be dragged or not
--]]---------------------------------------------------------
function frame:SetDraggable(bool)

	self.draggable = bool
	
end

--[[---------------------------------------------------------
	- func: GetDraggable()
	- desc: gets whether the frame can be dragged ot not
--]]---------------------------------------------------------
function frame:GetDraggable()

	return self.draggable
	
end


--[[---------------------------------------------------------
	- func: SetScreenLocked(bool)
	- desc: sets whether the frame can be moved passed the
			boundaries of the window or not
--]]---------------------------------------------------------
function frame:SetScreenLocked(bool)

	self.screenlocked = bool
	
end

--[[---------------------------------------------------------
	- func: GetScreenLocked()
	- desc: gets whether the frame can be moved passed the
			boundaries of window or not
--]]---------------------------------------------------------
function frame:GetScreenLocked()

	return self.screenlocked
	
end

--[[---------------------------------------------------------
	- func: ShowCloseButton(bool)
	- desc: sets whether the close button should be drawn
--]]---------------------------------------------------------
function frame:ShowCloseButton(bool)

	local close = self.internals[1]

	close.visible = bool
	self.showclose = bool
	
end

--[[---------------------------------------------------------
	- func: MakeTop()
	- desc: makes the object the top object in the drawing
			order
--]]---------------------------------------------------------
function frame:MakeTop()
	
	local x, y            = love.mouse.getPosition()
	local key             = 0
	local base            = loveframes.base
	local basechildren    = base.children
	local numbasechildren = #basechildren
	
	if numbasechildren == 1 then
		return
	end
	
	if basechildren[numbasechildren] == self then
		return
	end
	
	-- make this the top object
	for k, v in ipairs(basechildren) do
		if v == self then
			table.remove(basechildren, k)
			table.insert(basechildren, self)
			key = k
			break
		end
	end
	
	basechildren[key]:mousepressed(x, y, "l")
	
end

--[[---------------------------------------------------------
	- func: SetModal(bool)
	- desc: makes the object the top object in the drawing
			order
--]]---------------------------------------------------------
function frame:SetModal(bool)

	local modalobject = loveframes.modalobject
	local mbackground = self.modalbackground
	
	self.modal = bool
	
	if bool then
	
		if modalobject then
			modalobject:SetModal(false)
		end
	
		loveframes.modalobject = self
		
		if not mbackground then
			self.modalbackground = modalbackground:new(self)
			self.modal = true
		end
		
	else
	
		if modalobject == self then
	
			loveframes.modalobject = false
			
			if mbackground then
				self.modalbackground:Remove()
				self.modalbackground = false
				self.modal = false
			end
			
		end
		
	end
	
end

--[[---------------------------------------------------------
	- func: GetModal()
	- desc: gets whether or not the object is in a modal
			state
--]]---------------------------------------------------------
function frame:GetModal()

	return self.modal
	
end

--[[---------------------------------------------------------
	- func: SetVisible(bool)
	- desc: set's whether the object is visible or not
--]]---------------------------------------------------------
function frame:SetVisible(bool)

	local children    = self.children
	local internals   = self.internals
	local closebutton = internals[1]
	
	self.visible = bool
	
	for k, v in ipairs(children) do
		v:SetVisible(bool)
	end

	if self.showclose then
		closebutton.visible = bool
	end
	
end