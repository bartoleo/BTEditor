--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

-- tabs class
tabs = class("tabpanel", base)
tabs:include(loveframes.templates.default)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function tabs:initialize()
	
	self.type           = "tabs"
	self.width          = 100
	self.height         = 50
	self.clickx         = 0
	self.clicky         = 0
	self.offsetx        = 0
	self.tab            = 1
	self.tabnumber      = 1
	self.padding        = 5
	self.tabheight      = 25
	self.autosize       = true
	self.internal       = false
	self.tooltipfont    = loveframes.basicfontsmall
	self.tabs           = {}
	self.internals      = {}
	self.children       = {}
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the element
--]]---------------------------------------------------------
function tabs:update(dt)
	
	local visible      = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local x, y          = love.mouse.getPosition()
	local tabheight     = self.tabheight
	local padding       = self.padding
	local autosize      = self.autosize
	local tabheight     = self.tabheight
	local padding       = self.padding
	local autosize      = self.autosize
	local children      = self.children
	local numchildren   = #children
	local internals     = self.internals
	local tab           = self.tab
	local parent        = self.parent
	local base          = loveframes.base
	local update        = self.Update
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	self:CheckHover()
	
	if numchildren > 0 and tab == 0 then
		self.tab = 1
	end
	
	local pos = 0
	
	for k, v in ipairs(internals) do
		v:update(dt)
		if v.type == "tabbutton" then
			v.y = (v.parent.y + v.staticy)
			v.x = (v.parent.x + v.staticx) + pos + self.offsetx
			pos = pos + v.width - 1
		end
	end
	
	for k, v in ipairs(children) do
		v:update(dt)
		v:SetPos(padding, tabheight + padding)
	end
	
	if update then
		update(self, dt)
	end

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function tabs:draw()
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local internals     = self.internals
	local tabheight     = self:GetHeightOfButtons()
	local stencilfunc   = function() love.graphics.rectangle("fill", self.x, self.y, self.width, tabheight) end
	local stencil       = love.graphics.newStencil(stencilfunc)
	local internals     = self.internals
	local skins         = loveframes.skins.available
	local skinindex     = loveframes.config["ACTIVESKIN"]
	local defaultskin   = loveframes.config["DEFAULTSKIN"]
	local selfskin      = self.skin
	local skin          = skins[selfskin] or skins[skinindex]
	local drawfunc      = skin.DrawTabPanel or skins[defaultskin].DrawTabPanel
	local draw          = self.Draw
	local drawcount     = loveframes.drawcount
	
	loveframes.drawcount = drawcount + 1
	self.draworder = loveframes.drawcount
		
	if draw then
		draw(self)
	else
		drawfunc(self)
	end
	
	love.graphics.setStencil(stencil)
	
	for k, v in ipairs(internals) do
		v:draw()
	end
	
	love.graphics.setStencil()
	
	if #self.children > 0 then
		self.children[self.tab]:draw()
	end
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function tabs:mousepressed(x, y, button)
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local children     = self.children
	local numchildren  = #children
	local tab          = self.tab
	local internals    = self.internals
	local numinternals = #internals
	local hover        = self.hover
	
	if hover then
	
		if button == "l" then
		
			local baseparent = self:GetBaseParent()
		
			if baseparent and baseparent.type == "frame" then
				baseparent:MakeTop()
			end
			
		end
		
	end
	
	if button == "wu" then
		
		local buttonheight = self:GetHeightOfButtons()
		local col          = loveframes.util.BoundingBox(self.x, x, self.y, y, self.width, 1, buttonheight, 1)
		local visible      = internals[numinternals - 1]:GetVisible()
			
		if col and visible then
			self.offsetx = self.offsetx + 5
			if self.offsetx > 0 then
				self.offsetx = 0
			end
		end
			
	end
		
	if button == "wd" then
		
		local buttonheight = self:GetHeightOfButtons()
		local col          = loveframes.util.BoundingBox(self.x, x, self.y, y, self.width, 1, buttonheight, 1)
		local visible      = internals[numinternals]:GetVisible()
			
		if col and visible then
			local bwidth = self:GetWidthOfButtons()
			if (self.offsetx + bwidth) < self.width then
				self.offsetx = bwidth - self.width
			else
				self.offsetx = self.offsetx - 5
			end
		end
			
	end
	
	for k, v in ipairs(internals) do
		v:mousepressed(x, y, button)
	end
	
	if numchildren > 0 then
		children[tab]:mousepressed(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function tabs:mousereleased(x, y, button)

	local visible     = self.visible
	local children    = self.children
	local numchildren = #children
	local tab         = self.tab
	local internals   = self.internals
	
	if not visible then
		return
	end
	
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end
	
	if numchildren > 0 then
		children[tab]:mousereleased(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: AddTab(name, object, tip, image)
	- desc: adds a new tab to the tab panel
--]]---------------------------------------------------------
function tabs:AddTab(name, object, tip, image)

	local tabheight  = self.tabheight
	local padding    = self.padding
	local autosize   = self.autosize
	local retainsize = object.retainsize
	local tabnumber  = self.tabnumber
	local internals  = self.internals
	
	object:Remove()
	object.parent = self
	object.staticx = 0
	object.staticy = 0
	object:SetWidth(self.width - 10)
	object:SetHeight(self.height - 35)
	
	table.insert(self.children, object)
	internals[tabnumber] = tabbutton:new(self, name, tabnumber, tip, image)
	internals[tabnumber].height = self.tabheight
	self.tabnumber = tabnumber + 1
	
	for k, v in ipairs(internals) do
		self:SwitchToTab(k)
		break
	end
	
	self:AddScrollButtons()
	
	if autosize and not retainsize then
		object:SetSize(self.width - padding*2, (self.height - tabheight) - padding*2)
	end
		
end

--[[---------------------------------------------------------
	- func: AddScrollButtons()
	- desc: creates scroll buttons fot the tab panel
	- note: for internal use only
--]]---------------------------------------------------------
function tabs:AddScrollButtons()

	local internals = self.internals
	
	for k, v in ipairs(internals) do
		if v.type == "scrollbutton" then
			table.remove(internals, k)
		end
	end
	
	local leftbutton = scrollbutton:new("left")
	leftbutton.parent = self
	leftbutton:SetPos(0, 0)
	leftbutton:SetSize(15, 25)
	leftbutton:SetAlwaysUpdate(true)
	leftbutton.Update = function(object, dt)
		if self.offsetx ~= 0 then
			object.visible = true
		else
			object.visible = false
			object.down = false
			object.hover = false
		end
		
		if object.down == true then
			if self.offsetx ~= 0 then
				self.offsetx = self.offsetx + 1
			end
		end
	end
	
	local rightbutton = scrollbutton:new("right")
	rightbutton.parent = self
	rightbutton:SetPos(self.width - 15, 0)
	rightbutton:SetSize(15, 25)
	rightbutton:SetAlwaysUpdate(true)
	rightbutton.Update = function(object, dt)
		local bwidth = self:GetWidthOfButtons()
		if (self.offsetx + bwidth) > self.width then
			object.visible = true
		else
			object.visible = false
			object.down = false
			object.hover = false
		end
		
		if object.down == true then
			if ((self.x + self.offsetx) + bwidth) ~= (self.x + self.width) then
				self.offsetx = self.offsetx - 1
			end
		end
	end
	
	table.insert(internals, leftbutton)
	table.insert(internals, rightbutton)

end

--[[---------------------------------------------------------
	- func: GetWidthOfButtons()
	- desc: gets the total width of all of the tab buttons
--]]---------------------------------------------------------
function tabs:GetWidthOfButtons()

	local width     = 0
	local internals = self.internals
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" then
			width = width + v.width
		end
	end
	
	return width
	
end

--[[---------------------------------------------------------
	- func: GetHeightOfButtons()
	- desc: gets the height of one tab button
--]]---------------------------------------------------------
function tabs:GetHeightOfButtons()
	
	return self.tabheight
	
end

--[[---------------------------------------------------------
	- func: SwitchToTab(tabnumber)
	- desc: makes the specified tab the active tab
--]]---------------------------------------------------------
function tabs:SwitchToTab(tabnumber)
	
	local children = self.children
	
	for k, v in ipairs(children) do
		v.visible = false
	end
	
	self.tab = tabnumber
	self.children[tabnumber].visible = true
	
end

--[[---------------------------------------------------------
	- func: SetScrollButtonSize(width, height)
	- desc: sets the size of the scroll buttons
--]]---------------------------------------------------------
function tabs:SetScrollButtonSize(width, height)

	local internals = self.internals
	
	for k, v in ipairs(internals) do
		if v.type == "scrollbutton" then
			v:SetSize(width, height)
		end
	end
	
end

--[[---------------------------------------------------------
	- func: SetPadding(paddint)
	- desc: sets the padding for the tab panel
--]]---------------------------------------------------------
function tabs:SetPadding(padding)

	self.padding = padding
	
end

--[[---------------------------------------------------------
	- func: SetPadding(paddint)
	- desc: gets the padding of the tab panel
--]]---------------------------------------------------------
function tabs:GetPadding()

	return self.padding
	
end

--[[---------------------------------------------------------
	- func: SetTabHeight(height)
	- desc: sets the height of the tab buttons
--]]---------------------------------------------------------
function tabs:SetTabHeight(height)

	local internals = self.internals
	
	self.tabheight = height
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" then
			v:SetHeight(self.tabheight)
		end
	end
	
end

--[[---------------------------------------------------------
	- func: SetToolTipFont(font)
	- desc: sets the height of the tab buttons
--]]---------------------------------------------------------
function tabs:SetToolTipFont(font)

	local internals = self.internals
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" and v.tooltip then
			v.tooltip:SetFont(font)
		end
	end
	
end

--[[---------------------------------------------------------
	- func: GetTabNumber()
	- desc: gets the object's tab number
--]]---------------------------------------------------------
function tabs:GetTabNumber()

	return self.tab
	
end