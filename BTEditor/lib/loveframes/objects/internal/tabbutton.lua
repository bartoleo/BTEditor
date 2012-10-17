--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

-- tabbutton class
tabbutton = class("tabbutton", base)
tabbutton:include(loveframes.templates.default)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function tabbutton:initialize(parent, text, tabnumber, tip, image)

	self.type           = "tabbutton"
	self.text           = text
	self.tabnumber      = tabnumber
	self.parent         = parent
	self.staticx        = 0
	self.staticy        = 0
	self.width          = 50
	self.height         = 25
	self.internal       = true
	self.down           = false
	self.image          = nil
	
	if tip then
		self.tooltip = tooltip:new(self, tip)
		self.tooltip:SetFollowCursor(false)
		self.tooltip:SetOffsets(0, -5)
	end
	
	if image then
		self:SetImage(image)
	end
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function tabbutton:update(dt)
	
	local visible      = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local parent = self.parent
	local base   = loveframes.base
	local update = self.Update
	
	self:CheckHover()
	self:SetClickBounds(parent.x, parent.y, parent.width, parent.height)
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	if update then
		update(self, dt)
	end

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function tabbutton:draw()
	
	if not self.visible then
		return
	end
	
	local font          = love.graphics.getFont()
	local width         = font:getWidth(self.text)
	local image         = self.image
	local skins         = loveframes.skins.available
	local skinindex     = loveframes.config["ACTIVESKIN"]
	local defaultskin   = loveframes.config["DEFAULTSKIN"]
	local selfskin      = self.skin
	local skin          = skins[selfskin] or skins[skinindex]
	local drawfunc      = skin.DrawTabButton or skins[defaultskin].DrawTabButton
	local draw          = self.Draw
	local drawcount     = loveframes.drawcount
	
	loveframes.drawcount = drawcount + 1
	self.draworder = loveframes.drawcount
		
	if draw then
		draw(self)
	else
		drawfunc(self)
	end
	
	if image then
		local imagewidth = image:getWidth()
		self.width = imagewidth + 15 + width
	else
		self.width = 10 + width
	end
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function tabbutton:mousepressed(x, y, button)

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local hover = self.hover
	
	if hover and button == "l" then
		
		local baseparent = self:GetBaseParent()
	
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
	
		self.down = true
		loveframes.hoverobject = self
		
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function tabbutton:mousereleased(x, y, button)
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local hover     = self.hover
	local parent    = self.parent
	local tabnumber = self.tabnumber
	
	if hover and button == "l" then
	
		if button == "l" then
			parent:SwitchToTab(tabnumber)
		end
		
	end
	
	self.down = false

end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the object's text
--]]---------------------------------------------------------
function tabbutton:SetText(text)

	self.text = text
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the object's text
--]]---------------------------------------------------------
function tabbutton:GetText()

	return self.text
	
end

--[[---------------------------------------------------------
	- func: SetImage(image)
	- desc: adds an image to the object
--]]---------------------------------------------------------
function tabbutton:SetImage(image)

	if type(image) == "string" then
		self.image = love.graphics.newImage(image)
	else
		self.image = image
	end
	
end

--[[---------------------------------------------------------
	- func: GetImage()
	- desc: gets the object's image
--]]---------------------------------------------------------
function tabbutton:GetImage()

	return self.image
	
end

--[[---------------------------------------------------------
	- func: GetTabNumber()
	- desc: gets the object's tab number
--]]---------------------------------------------------------
function tabbutton:GetTabNumber()

	return self.tabnumber
	
end