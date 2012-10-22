--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

-- columnlistarea class
columnlistarea = class("columnlistarea", base)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: intializes the element
--]]---------------------------------------------------------
function columnlistarea:initialize(parent)
	
	self.type               = "columnlistarea"
	self.display            = "vertical"
	self.parent             = parent
	self.width              = 80
	self.height             = 25
	self.clickx             = 0
	self.clicky             = 0
	self.offsety            = 0
	self.offsetx            = 0
	self.extrawidth         = 0
	self.extraheight        = 0
	self.rowcolorindex      = 1
	self.rowcolorindexmax   = 2
	self.bar                = false
	self.internal           = true
	self.internals          = {}
	self.children           = {}

	-- apply template properties to the object
	loveframes.templates.ApplyToObject(self)
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function columnlistarea:update(dt)
	
	local visible      = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local cwidth, cheight = self.parent:GetColumnSize()
	local parent          = self.parent
	local base            = loveframes.base
	local update          = self.Update
	local internals       = self.internals
	local children        = self.children
	
	self:CheckHover()
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = parent.x + self.staticx
		self.y = parent.y + self.staticy
	end
	
	for k, v in ipairs(internals) do
		v:update(dt)
	end
	
	for k, v in ipairs(children) do
		v:update(dt)
		v:SetClickBounds(self.x, self.y, self.width, self.height)
		v.y = (v.parent.y + v.staticy) - self.offsety + cheight
		v.x = (v.parent.x + v.staticx) - self.offsetx
	end
	
	if update then
		update(self, dt)
	end

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function columnlistarea:draw()

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local stencilfunc   = function() love.graphics.rectangle("fill", self.x, self.y, self.width, self.height) end
	local stencil       = love.graphics.newStencil(stencilfunc)
	local skins         = loveframes.skins.available
	local skinindex     = loveframes.config["ACTIVESKIN"]
	local defaultskin   = loveframes.config["DEFAULTSKIN"]
	local selfskin      = self.skin
	local skin          = skins[selfskin] or skins[skinindex]
	local drawfunc      = skin.DrawColumnListArea or skins[defaultskin].DrawColumnListArea
	local drawoverfunc  = skin.DrawOverColumnListArea or skins[defaultskin].DrawOverColumnListArea
	local draw          = self.Draw
	local drawcount     = loveframes.drawcount
	local internals     = self.internals
	local children      = self.children
	
	-- set the object's draw order
	self:SetDrawOrder()
		
	if draw then
		draw(self)
	else
		drawfunc(self)
	end
	
	love.graphics.setStencil(stencil)
	
	for k, v in ipairs(children) do
		local col = loveframes.util.BoundingBox(self.x, v.x, self.y, v.y, self.width, v.width, self.height, v.height)
		if col == true then
			v:draw()
		end
	end
	
	love.graphics.setStencil()
	
	for k, v in ipairs(internals) do
		v:draw()
	end
	
	if not draw then
		skin.DrawOverColumnListArea(self)
	end
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function columnlistarea:mousepressed(x, y, button)

	local toplist   = self:IsTopList()
	local internals = self.internals
	local children  = self.children
	
	if self.hover and button == "l" then
		
		local baseparent = self:GetBaseParent()
	
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
		
	end
	
	if self.bar and toplist then
	
		local bar = self:GetScrollBar()
			
		if button == "wu" then
			bar:Scroll(-5)
		elseif button == "wd" then
			bar:Scroll(5)
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
function columnlistarea:mousereleased(x, y, button)

	local internals = self.internals
	local children  = self.children
	
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end
	
	for k, v in ipairs(children) do
		v:mousereleased(x, y, button)
	end

end

--[[---------------------------------------------------------
	- func: CalculateSize()
	- desc: calculates the size of the object's children
--]]---------------------------------------------------------
function columnlistarea:CalculateSize()
	
	local iw, ih      = self.parent:GetColumnSize()
	local numitems    = #self.children
	local height      = self.height
	local width       = self.width
	local itemheight  = ih
	local itemwidth	  = 0
	local bar         = self.bar
	local children    = self.children
	
	for k, v in ipairs(children) do
		itemheight = itemheight + v.height
	end
		
	self.itemheight = itemheight
		
	if self.itemheight > height then
		
		self.extraheight = self.itemheight - height
			
		if not bar then
			table.insert(self.internals, scrollbody:new(self, "vertical"))
			self.bar = true
			self:GetScrollBar().autoscroll = self.parent.autoscroll
		end
			
	else
			
		if bar then
			self.internals[1]:Remove()
			self.bar = false
			self.offsety = 0
		end
			
	end
	
end

--[[---------------------------------------------------------
	- func: RedoLayout()
	- desc: used to redo the layour of the object
--]]---------------------------------------------------------
function columnlistarea:RedoLayout()
	
	local children = self.children
	local starty   = 0
	local startx   = 0
	local bar      = self.bar
	local display  = self.display
	
	if #children > 0 then
	
		for k, v in ipairs(children) do
		
			local height = v.height
				
			v.staticx = startx
			v.staticy = starty
				
			if bar then
				v:SetWidth(self.width - self.internals[1].width)
				self.internals[1].staticx = self.width - self.internals[1].width
				self.internals[1].height = self.height
			else
				v:SetWidth(self.width)
			end
				
			starty = starty + v.height
				
			v.lastheight = v.height
				
		end
		
	end
	
end

--[[---------------------------------------------------------
	- func: AddRow(data)
	- desc: adds a row to the object
--]]---------------------------------------------------------
function columnlistarea:AddRow(data)

	local row = columnlistrow:new(self, data)
	
	local colorindex    = self.rowcolorindex
	local colorindexmax = self.rowcolorindexmax
	
	if colorindex == colorindexmax then
		self.rowcolorindex = 1
	else
		self.rowcolorindex = colorindex + 1
	end
	
	table.insert(self.children, row)
	self:CalculateSize()
	self:RedoLayout()
	self.parent:AdjustColumns()
	
end

--[[---------------------------------------------------------
	- func: GetScrollBar()
	- desc: gets the object's scroll bar
--]]---------------------------------------------------------
function columnlistarea:GetScrollBar()

	local internals = self.internals
	
	if self.bar then
		local scrollbody = internals[1]
		local scrollarea = scrollbody.internals[1]
		local scrollbar  = scrollarea.internals[1]
		return scrollbar
	else
		return false
	end
	
end

--[[---------------------------------------------------------
	- func: Sort()
	- desc: sorts the object's children
--]]---------------------------------------------------------
function columnlistarea:Sort(column, desc)
	
	self.rowcolorindex = 1
	
	local colorindexmax = self.rowcolorindexmax
	local children      = self.children
	
	table.sort(children, function(a, b)
		if desc then
            return a.columndata[column] < b.columndata[column]
        else
			return a.columndata[column] > b.columndata[column]
		end
	end)
	
	for k, v in ipairs(children) do
	
		local colorindex = self.rowcolorindex
		
		v.colorindex = colorindex
		
		if colorindex == colorindexmax then
			self.rowcolorindex = 1
		else
			self.rowcolorindex = colorindex + 1
		end
	
	end
	
	self:CalculateSize()
	self:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: Clear()
	- desc: removes all items from the object's list
--]]---------------------------------------------------------
function columnlistarea:Clear()

	self.children = {}
	self:CalculateSize()
	self:RedoLayout()
	self.parent:AdjustColumns()
	
end