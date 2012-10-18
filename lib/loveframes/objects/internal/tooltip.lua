--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

-- tooltip clas
tooltip = class("tooltip", base)
tooltip:include(loveframes.templates.default)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function tooltip:initialize(object, text, width)

	local width = width or 0
	
	self.type           = "tooltip"
	self.parent         = loveframes.base
	self.object         = object or nil
	self.width          = width or 0
	self.height         = 0
	self.padding        = 5
	self.xoffset        = 10
	self.yoffset        = -10
	self.internal       = true
	self.show           = false
	self.followcursor   = true
	self.alwaysupdate   = true
	
	self.text = loveframes.Create("text")
	self.text:Remove()
	self.text.parent = self
	self.text:SetText(text or "")
	self.text:SetWidth(width or 0)
	self.text:SetPos(0, 0)
	
	table.insert(loveframes.base.internals, self)
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function tooltip:update(dt)

	local visible      = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local text      = self.text
	local object    = self.object
	local draworder = self.draworder
	local update    = self.Update
	
	self.width  = text.width + self.padding * 2
	self.height = text.height + self.padding * 2
	
	if object then
	
		if object == loveframes.base then
			self:Remove()
			return
		end
		
		local hover      = object.hover
		local odraworder = object.draworder
		local ovisible   = object.visible
		local ohover     = object.hover
		
		self.show    = ohover
		self.visible = ovisible
		
		if ohover and ovisible then
			local top = self:IsTopInternal()
			if self.followcursor then
				local x, y = love.mouse.getPosition()
				self.x = x + self.xoffset
				self.y = y - self.height + self.yoffset
			else
				self.x = object.x + self.xoffset
				self.y = object.y - self.height + self.yoffset
			end
			
			if not top then
				self:MoveToTop()
			end
			
			text:SetPos(self.padding, self.padding)
			
		end
		
		local baseparent = object:GetBaseParent()
		
		if baseparent then
			if baseparent.removed and baseparent.removed then
				self:Remove()
			end
		elseif object.removed then
			self:Remove()
		end
		
	end
	
	text:update(dt)
	
	if update then
		update(self, dt)
	end

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function tooltip:draw()
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local show          = self.show
	local text          = self.text
	local skins         = loveframes.skins.available
	local skinindex     = loveframes.config["ACTIVESKIN"]
	local defaultskin   = loveframes.config["DEFAULTSKIN"]
	local selfskin      = self.skin
	local skin          = skins[selfskin] or skins[skinindex]
	local drawfunc      = skin.DrawToolTip or skins[defaultskin].DrawToolTip
	local draw          = self.Draw
	local drawcount     = loveframes.drawcount
	
	loveframes.drawcount = drawcount + 1
	self.draworder = loveframes.drawcount
	
	if show then
	
		if draw then
			draw(self)
		else
			drawfunc(self)
		end
	
		text:draw()
		
	end
	
end

--[[---------------------------------------------------------
	- func: SetFollowCursor(bool)
	- desc: sets whether or not the tooltip should follow the
			cursor
--]]---------------------------------------------------------
function tooltip:SetFollowCursor(bool)

	self.followcursor = bool
	
end

--[[---------------------------------------------------------
	- func: SetObject(object)
	- desc: sets the tooltip's object
--]]---------------------------------------------------------
function tooltip:SetObject(object)

	self.object = object
	
end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the tooltip's text
--]]---------------------------------------------------------
function tooltip:SetText(text)

	self.text:SetText(text)
	self.text2 = text
	
end

--[[---------------------------------------------------------
	- func: SetTextMaxWidth(text)
	- desc: sets the tooltip's text max width
--]]---------------------------------------------------------
function tooltip:SetTextMaxWidth(width)

	self.text:SetMaxWidth(width)
	
end

--[[---------------------------------------------------------
	- func: SetOffsets(xoffset, yoffset)
	- desc: sets the tooltip's x and y offset
--]]---------------------------------------------------------
function tooltip:SetOffsets(xoffset, yoffset)

	self.xoffset = xoffset
	self.yoffset = yoffset
	
end

--[[---------------------------------------------------------
	- func: SetPadding(padding)
	- desc: sets the tooltip's padding
--]]---------------------------------------------------------
function tooltip:SetPadding(padding)

	self.padding = padding
	
end

--[[---------------------------------------------------------
	- func: SetFont(font)
	- desc: sets the tooltip's font
--]]---------------------------------------------------------
function tooltip:SetFont(font)

	self.text:SetFont(font)
	
end