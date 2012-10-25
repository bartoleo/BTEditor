--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

-- textinput class
textinput = class("textinput", base)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------

function textinput:initialize()

	self.type               = "textinput"
	self.keydown            = "none"
	self.tabreplacement     = "        "
	self.font               = loveframes.basicfont
	self.width              = 200
	self.height             = 25
	self.delay              = 0
	self.offsetx            = 0
	self.offsety            = 0
	self.indincatortime     = 0
	self.indicatornum       = 0
	self.indicatorx         = 0
	self.indicatory         = 0
	self.textx              = 0
	self.texty              = 0
	self.textoffsetx        = 5
	self.textoffsety        = 5
	self.unicode            = 0
	self.limit              = 0
	self.line               = 1
	self.itemwidth          = 0
	self.itemheight         = 0
	self.extrawidth         = 0
	self.extraheight        = 0
	self.rightpadding       = 0
	self.bottompadding      = 0
	self.lastclicktime      = 0
	self.maxx               = 0
	self.usable             = {}
	self.unusable           = {}
	self.lines              = {""}
	self.internals          = {}
	self.showindicator      = true
	self.focus              = false
	self.multiline          = false
	self.vbar               = false
	self.hbar               = false
	self.alltextselected    = false
	self.linenumbers        = true
	self.linenumberspanel   = false
	self.editable           = true
	self.internal           = false
	self.OnEnter            = nil
	self.OnTextChanged      = nil
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function textinput:update(dt)

	local visible      = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local time      = love.timer.getTime()
	local keydown   = self.keydown
	local unicode   = self.unicode
	local parent    = self.parent
	local base      = loveframes.base
	local update    = self.Update
	local theight   = self.font:getHeight("a")
	local delay     = self.delay
	local lines     = self.lines
	local numlines  = #lines
	local multiline = self.multiline
	local width     = self.width
	local height    = self.height
	local vbar      = self.vbar
	local hbar      = self.hbar
	local internals = self.internals
	
	-- check to see if the object is being hovered over
	self:CheckHover()
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	-- keydown check
	if keydown ~= "none" then
		if time > delay then
			self:RunKey(keydown, unicode)
			self.delay = time + 0.02
		end
	end
	
	-- psotion the object's text
	self:PositionText()
	
	-- update the object's text insertion positon indicator
	self:UpdateIndicator()
	
	-- calculations for multiline mode
	if multiline then
	
		local twidth = 0
		local panel = self:GetLineNumbersPanel()
		
		-- get the longest line of text
		for k, v in ipairs(lines) do
			local linewidth = self.font:getWidth(v)
			if linewidth > twidth then
				twidth = linewidth
			end
		end
		
		-- item width calculation
		if vbar then
			self.itemwidth = twidth + 16 + self.textoffsetx * 2
		else
			self.itemwidth = twidth
		end
		
		if panel then
			self.itemwidth = self.itemwidth + panel.width
		end
		
		-- item height calculation
		if hbar then
			self.itemheight = theight * numlines + 16 + self.textoffsety * 2
		else
			self.itemheight = theight * numlines
		end
		
		-- extra width and height calculations
		self.extrawidth  = self.itemwidth - self.width
		self.extraheight = self.itemheight - self.height
	
		local itemwidth = self.itemwidth
		local itemheight = self.itemheight
		
		if itemheight > height then
			if not vbar then
				local scrollbody = scrollbody:new(self, "vertical")
				scrollbody.internals[1].internals[1].autoscroll = false
				table.insert(self.internals, scrollbody)
				self.vbar = true
				if hbar then
					local vbody = self:GetVerticalScrollBody()
					local hbody = self:GetHorizontalScrollBody()
					vbody:SetHeight(vbody:GetHeight() - 15)
					hbody:SetWidth(hbody:GetWidth() - 15)
				end
			end
		else
			if vbar then
				self:GetVerticalScrollBody():Remove()
				self.vbar = false
				self.offsety = 0
				if self.hbar then
					local hbody = self:GetHorizontalScrollBody()
					hbody:SetWidth(hbody:GetWidth() + 15)
				end
			end
		end
		
		if itemwidth > width then
			if not hbar then
				local scrollbody = scrollbody:new(self, "horizontal")
				scrollbody.internals[1].internals[1].autoscroll = false
				table.insert(self.internals, scrollbody)
				self.hbar = true
				if self.vbar then
					local vbody = self:GetVerticalScrollBody()
					local hbody = self:GetHorizontalScrollBody()
					vbody:SetHeight(vbody:GetHeight() - 15)
					hbody:SetWidth(hbody:GetWidth() - 15)
				end
			end
		else
			if hbar then
				self:GetHorizontalScrollBody():Remove()
				self.hbar = false
				self.offsetx = 0
				if vbar then
					local vbody = self:GetVerticalScrollBody()
					if vbody then
						vbody:SetHeight(vbody:GetHeight() + 15)
					end
				end
			end
		end
		
		if self.linenumbers then
			if not self.linenumberspanel then
				local linenumberspanel = linenumberspanel:new(self)
				table.insert(self.internals, linenumberspanel)
				self.linenumberspanel = true
			end
		else
			if self.linenumberspanel then
				table.remove(self.internals, 1)
				self.linenumberspanel = false
			end
		end
		
	end
	
	for k, v in ipairs(internals) do
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
function textinput:draw()

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local skins         = loveframes.skins.available
	local skinindex     = loveframes.config["ACTIVESKIN"]
	local defaultskin   = loveframes.config["DEFAULTSKIN"]
	local stencilfunc   = function() love.graphics.rectangle("fill", self.x, self.y, self.width, self.height) end
	local stencil       = love.graphics.newStencil(stencilfunc)
	local selfskin      = self.skin
	local skin          = skins[selfskin] or skins[skinindex]
	local drawfunc      = skin.DrawTextInput or skins[defaultskin].DrawTextInput
	local drawoverfunc  = skin.DrawOverTextInput or skins[defaultskin].DrawOverTextInput
	local draw          = self.Draw
	local drawcount     = loveframes.drawcount
	local internals     = self.internals
	local vbar          = self.vbar
	local hbar          = self.hbar
	
	-- set the object's draw order
	self:SetDrawOrder()
	
	if vbar and hbar then
		stencilfunc = function() love.graphics.rectangle("fill", self.x, self.y, self.width - 16, self.height - 16) end
	end
	
	love.graphics.setStencil(stencilfunc)
	
	if draw then
		draw(self)
	else
		drawfunc(self)
	end
	
	love.graphics.setStencil()
	
	for k, v in ipairs(internals) do
		v:draw()
	end
	
	if not draw then
		drawoverfunc(self)
	end

end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function textinput:mousepressed(x, y, button)

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local hover = self.hover
	local time  = love.timer.getTime()
	local internals = self.internals
	local vbar = self.vbar
	local hbar = self.hbar
	
	if hover and button == "l" then
	
		local baseparent = self:GetBaseParent()

		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
		
		self.focus = true
		
		if not self.alltextselected then
			if time > self.lastclicktime and time < (self.lastclicktime + 0.25) then
				self.alltextselected = true
			end
		else
			self.alltextselected = false
		end
		
		self.lastclicktime = time
		
		self:GetTextCollisions(x, y)
				
	else
		if not hover then
			self.focus = false
			self.alltextselected = false
		end
	end
	
	if hover then
		if button == "wu" then
			if vbar and not hbar then
				local vbar = self:GetVerticalScrollBody().internals[1].internals[1]
				vbar:Scroll(-5)
			elseif vbar and hbar then
				local vbar = self:GetVerticalScrollBody().internals[1].internals[1]
				vbar:Scroll(-5)
			elseif not vbar and hbar then
				local hbar = self:GetHorizontalScrollBody().internals[1].internals[1]
				hbar:Scroll(-5)
			end
		elseif button == "wd" then
			if vbar and not hbar then
				local vbar = self:GetVerticalScrollBody().internals[1].internals[1]
				vbar:Scroll(5)
			elseif vbar and hbar then
				local vbar = self:GetVerticalScrollBody().internals[1].internals[1]
				vbar:Scroll(5)
			elseif not vbar and hbar then
				local hbar = self:GetHorizontalScrollBody().internals[1].internals[1]
				hbar:Scroll(5)
			end
		end
	end
	
	for k, v in ipairs(internals) do
		v:mousepressed(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function textinput:mousereleased(x, y, button)

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local internals = self.internals
	
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: keypressed(key)
	- desc: called when the player presses a key
--]]---------------------------------------------------------
function textinput:keypressed(key, unicode)

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local time = love.timer.getTime()
	local lctrl = love.keyboard.isDown("lctrl")
	local rctrl = love.keyboard.isDown("rctrl")
	local focus = self.focus
	
	self.delay   = time + 0.80
	self.keydown = key
	
	if (lctrl or rctrl) and focus then
		if key == "a" then
			self.alltextselected = true
		end
	end
	
	self:RunKey(key, unicode)
	
	
end

--[[---------------------------------------------------------
	- func: keyreleased(key)
	- desc: called when the player releases a key
--]]---------------------------------------------------------
function textinput:keyreleased(key)

	local visible = self.visible
	
	if not visible then
		return
	end
	
	self.keydown = "none"
	
end

--[[---------------------------------------------------------
	- func: RunKey(key, unicode)
	- desc: runs a key event on the object
--]]---------------------------------------------------------
function textinput:RunKey(key, unicode)
	
	local visible = self.visible
	local focus   = self.focus
	
	if not visible then
		return
	end
	
	if not self.focus then
		return
	end
	
	local lines           = self.lines
	local line            = self.line
	local numlines        = #lines
	local curline         = lines[line]
	local text            = curline
	local ckey            = ""
	local font            = self.font
	local swidth          = self.width
	local textoffsetx     = self.textoffsetx
	local indicatornum    = self.indicatornum
	local multiline       = self.multiline
	local alltextselected = self.alltextselected
	local editable        = self.editable
	local ontextchanged   = self.OnTextChanged
	local onenter         = self.OnEnter
	
	self.unicode = unicode
	
	if key == "left" then
		self:MoveIndicator(-1)
		local indicatorx = self.indicatorx
		indicatornum = self.indicatornum
		if not multiline then
			if indicatorx <= self.x and indicatornum ~= 0 then
				local width = self.font:getWidth(text:sub(indicatornum, indicatornum + 1))
				self.offsetx = self.offsetx - width
			elseif indicatornum == 0 and self.offsetx ~= 0 then
				self.offsetx = 0
			end
		else
			if indicatornum == 0 then
				if line > 1 then
					self.line = line - 1
					local numchars = #lines[self.line]
					self:MoveIndicator(numchars)
				end
			end
		end
	elseif key == "right" then
		self:MoveIndicator(1)
		local indicatorx = self.indicatorx
		indicatornum = self.indicatornum
		if not multiline then
			if indicatorx >= (self.x + swidth) and indicatornum ~= #text then
				local width = self.font:getWidth(text:sub(indicatornum, indicatornum))
				self.offsetx = self.offsetx + width
			elseif indicatornum == #text and self.offsetx ~= ((0 - font:getWidth(text)) + swidth) and font:getWidth(text) + self.textoffsetx > self.width then
				self.offsetx = ((0 - font:getWidth(text)) + swidth)
			end
		else
			if indicatornum == #text then
				if line < numlines then
					self.line = line + 1
					self:MoveIndicator(0, true)
				end
			end
		end
	elseif key == "up" then
		if multiline then
			if line > 1 then
				self.line = line - 1
				if indicatornum > #lines[self.line] then
					indicatornum = #lines[self.line]
				end
			end
		end
	elseif key == "down" then
		if multiline then
			if line < #lines then
				self.line = line + 1
				if indicatornum > #lines[self.line] then
					indicatornum = #lines[self.line]
				end
			end
		end
	end
			
	-- key input checking system
	if key == "backspace" then
		if not editable then
			return
		end
		local curindicatornum = self.indicatornum
		if alltextselected then
			self:Clear()
			self.alltextselected = false
			indicatornum = self.indicatornum
		else
			if text ~= "" then
				text = self:RemoveFromeText(indicatornum)
				self:MoveIndicator(-1)
				if ontextchanged then
					ontextchanged(self, "")
				end
				lines[line] = text
			end
			if multiline then
				if line > 1 and curindicatornum == 0 then
					local newindicatornum = 0
					local oldtext         = lines[line]
					table.remove(lines, line)
					self.line = line - 1
					if #oldtext > 0 then
						newindicatornum = #lines[self.line]
						lines[self.line] = lines[self.line] .. oldtext
						self:MoveIndicator(newindicatornum)
					else
						self:MoveIndicator(#lines[self.line])
					end
				end
			end
			local cwidth = font:getWidth(text:sub(#text))
			if self.offsetx ~= 0 then
				self.offsetx = self.offsetx - cwidth
			end
		end
	elseif key == "delete" then-- leo
		if not editable then
			return
		end
		local curindicatornum = self.indicatornum
		if alltextselected then
			self:Clear()
			self.alltextselected = false
			indicatornum = self.indicatornum
		else
			if text ~= "" then
				text = self:RemoveFromeText(indicatornum+1)
				if ontextchanged then
					ontextchanged(self, "")
				end
				lines[line] = text
			end
			if multiline then
				if line < #lines and curindicatornum == #lines[self.line] then
					local newindicatornum = 0
					local oldtext         = lines[line+1]
					table.remove(lines, line+1)
					if #oldtext > 0 then
						lines[self.line] = lines[self.line] .. oldtext
					end
				end
			end
			local cwidth = font:getWidth(text:sub(#text))
			if self.offsetx ~= 0 then
				self.offsetx = self.offsetx - cwidth
			end
		end-- leo
	elseif key == "return" or key == "kpenter" then
	
		-- call onenter if it exists
		if onenter then
			onenter(self, text)
		end
		
		if alltextselected then
			self.alltextselected = false
			self:Clear()
			indicatornum = self.indicatornum
		end
		
		-- newline calculations for multiline mode
		if multiline then
			local newtext = "" 
			if indicatornum == 0 then
				newtext = self.lines[line]
				self.lines[line] = ""
			elseif indicatornum > 1 and indicatornum < #self.lines[line] then
				newtext = self.lines[line]:sub(indicatornum + 1, #self.lines[line])
				self.lines[line] = self.lines[line]:sub(1, indicatornum)
			end
			if line ~= #lines then
				table.insert(self.lines, line + 1, newtext)
				self.line = line + 1
			else
				table.insert(self.lines, newtext)
				self.line = line + 1
			end
			self.indicatornum = 0
		end
		
	elseif key == "tab" then
		for i=1, #self.tabreplacement do
			local number = string.byte(self.tabreplacement:sub(i, i))
			self.lines[self.line] = self:AddIntoText(number, self.indicatornum)
			self:MoveIndicator(1)
		end
	else
		if unicode > 31 and unicode < 127 then
		
			if not editable then
				return
			end
		
			if alltextselected then
				self.alltextselected = false
				self:Clear()
				indicatornum = self.indicatornum
				text = ""
				lines = self.lines
				line = self.line
			end
			
			-- do not continue if the text limit has been reached or exceeded
			if #text >= self.limit and self.limit ~= 0 then
				return
			end
			
			-- set the current key
			ckey = string.char(unicode)
				
			-- check for unusable characters
			if #self.usable > 0 then
				local found = false
				for k, v in ipairs(self.usable) do
					if v == ckey then
						found = true
					end
				end
				if found == false then
					return
				end
			end
			
			-- check for usable characters
			if #self.unusable > 0 then
				local found = false
				for k, v in ipairs(self.unusable) do
					if v == ckey then
						found = true
					end
				end
				if found == true then
					return
				end
			end
			
			if indicatornum ~= 0 and indicatornum ~= #text then
				text = self:AddIntoText(unicode, indicatornum)
				lines[line] = text
				self:MoveIndicator(1)
			elseif indicatornum == #text then
				text = text .. ckey
				lines[line] = text
				self:MoveIndicator(1)
			elseif indicatornum == 0 then
				text = self:AddIntoText(unicode, indicatornum)
				lines[line] = text
				self:MoveIndicator(1)
			end
			
			-- call on text changed it if exists
			if ontextchanged then
				ontextchanged(self, ckey)
			end
			
			lines     = self.lines
			line      = self.line
			curline   = lines[line]
			text      = curline
			
			if not multiline then
				local twidth    = font:getWidth(text)
				local cwidth    = font:getWidth(ckey)
				
				-- swidth - 1 is for the "-" character
				if (twidth + textoffsetx) >= (swidth - 1) then
					self.offsetx = self.offsetx + cwidth
				end
			end
		end
	end
	
end

--[[---------------------------------------------------------
	- func: MoveIndicator(num, exact)
	- desc: moves the object's indicator
--]]---------------------------------------------------------
function textinput:MoveIndicator(num, exact)

	local lines        = self.lines
	local line         = self.line
	local curline      = lines[line]
	local text         = curline
	local indicatornum = self.indicatornum
	
	if not exact then
		self.indicatornum = indicatornum + num
	else
		self.indicatornum = num
	end
	
	if self.indicatornum > #text then
		self.indicatornum = #text
	elseif self.indicatornum < 0 then
		self.indicatornum = 0
	end
	
	self.showindicator = true
	
	self:UpdateIndicator()
	
end

--[[---------------------------------------------------------
	- func: UpdateIndicator()
	- desc: updates the object's text insertion position 
			indicator
--]]---------------------------------------------------------
function textinput:UpdateIndicator()

	local time              = love.timer.getTime()
	local indincatortime    = self.indincatortime
	local indicatornum      = self.indicatornum
	local lines             = self.lines
	local line              = self.line
	local curline           = lines[line]
	local text              = curline
	local theight           = self.font:getHeight("a")
	local offsetx           = self.offsetx
	local multiline         = self.multiline
	
	if indincatortime < time then
		if self.showindicator then
			self.showindicator = false
		else
			self.showindicator = true
		end
		self.indincatortime = time + 0.50
	end
	
	if self.alltextselected then
		self.showindicator = false
	end
	
	local width = 0
	
	for i=1, indicatornum do
		width = width + self.font:getWidth(text:sub(i, i))
	end
	
	if multiline then
		self.indicatorx = self.textx + width
		self.indicatory	= self.texty + theight * line - theight
	else
		self.indicatorx = self.textx + width
		self.indicatory	= self.texty
	end
	
end

--[[---------------------------------------------------------
	- func: AddIntoText(t, p)
	- desc: adds text into the object's text a given 
			position
--]]---------------------------------------------------------
function textinput:AddIntoText(t, p)

	local lines    = self.lines
	local line     = self.line
	local curline  = lines[line]
	local text     = curline
	local part1    = text:sub(1, p)
	local part2    = text:sub(p + 1)
	local new      = part1 .. string.char(t) .. part2
	
	return new
	
end

--[[---------------------------------------------------------
	- func: RemoveFromeText(p)
	- desc: removes text from the object's text a given 
			position
--]]---------------------------------------------------------
function textinput:RemoveFromeText(p)

	local lines        = self.lines
	local line         = self.line
	local curline      = lines[line]
	local text         = curline
	local indicatornum = self.indicatornum
	
	if indicatornum ~= 0 then
		local part1 = text:sub(1, p - 1)
		local part2 = text:sub(p + 1)
		local new = part1 .. part2
		return new
	end
	
	return text
	
end

--[[---------------------------------------------------------
	- func: GetTextCollisions(x, y)
	- desc: gets text collisions with the mouse
--]]---------------------------------------------------------
function textinput:GetTextCollisions(x, y)

	local font      = self.font
	local lines     = self.lines
	local numlines  = #lines
	local line      = self.line
	local curline   = lines[line]
	local text      = curline
	local xpos      = 0
	local line      = 0
	local vbar      = self.vbar
	local hbar      = self.hbar
	local multiline = self.multiline
	
	if multiline then
		
		local theight = self.font:getHeight("a")
		local liney   = 0
		local selfcol
		
		if vbar and not hbar then
			selfcol = loveframes.util.BoundingBox(self.x, x, self.y, y, self.width - 16, 1, self.height, 1)
		elseif hbar and not vbar then
			selfcol = loveframes.util.BoundingBox(self.x, x, self.y, y, self.width, 1, self.height - 16, 1)
		elseif not vbar and not hbar then
			selfcol = loveframes.util.BoundingBox(self.x, x, self.y, y, self.width, 1, self.height, 1)
		elseif vbar and hbar then
			selfcol = loveframes.util.BoundingBox(self.x, x, self.y, y, self.width - 16, 1, self.height - 16, 1)
		end
		
		if selfcol then
			
			for i=1, numlines do
				local linecol = loveframes.util.BoundingBox(self.x, x, (self.y - self.offsety) + self.textoffsety + (theight * i) - theight, y, self.width, 1, theight, 1)
				if linecol then
					liney = (self.y - self.offsety) + self.textoffsety + (theight * i) - theight
					self.line = i
				end
			end
			
			local line    = self.line
			local curline = lines[line]
			
			for i=1, #curline do
		
				local width  = font:getWidth(curline:sub(i, i))
				local height = font:getHeight(curline:sub(i, i))
				local tx     = self.textx + xpos
				local ty     = self.texty
				local col    = loveframes.util.BoundingBox(tx, x, liney, y, width, 1, height, 1)
				
				xpos = xpos + width
				
				if col then
					self:MoveIndicator(i - 1, true)
					break
				else
					self.indicatornum = #curline
				end
				
				if x < tx then
					self:MoveIndicator(0, true)
				end
				
				if x > (tx + width) then
					self:MoveIndicator(#curline, true)
				end
				
			end
			
			if #curline == 0 then
				self.indicatornum = 0
			end
	
		end
		
	else
		
		for i=1, #text do
			
			local width  = font:getWidth(text:sub(i, i))
			local height = font:getHeight(text:sub(i, i))
			local tx     = self.textx + xpos
			local ty     = self.texty
			local col    = loveframes.util.BoundingBox(tx, x, ty, y, width, 1, height, 1)
			
			xpos = xpos + width
			
			if col then
				self:MoveIndicator(i - 1, true)
				break
			end
			
			if x < tx then
				self:MoveIndicator(0, true)
			end
			
			if x > (tx + width) then
				self:MoveIndicator(#text, true)
			end
			
		end
		
	end
	
end

--[[---------------------------------------------------------
	- func: PositionText()
	- desc: positions the object's text
--]]---------------------------------------------------------
function textinput:PositionText()

	local multiline        = self.multiline
	local x                = self.x
	local y                = self.y
	local offsetx          = self.offsetx
	local offsety          = self.offsety
	local textoffsetx      = self.textoffsetx
	local textoffsety      = self.textoffsety
	local linenumberspanel = self.linenumberspanel
	
	if multiline then
		if linenumberspanel then
			local panel = self:GetLineNumbersPanel()
			self.textx = ((x + panel.width) - offsetx) + textoffsetx
			self.texty = (y - offsety) + textoffsety
		else
			self.textx = (x - offsetx) + textoffsetx
			self.texty = (y - offsety) + textoffsety
		end
	else
		self.textx = (x - offsetx) + textoffsetx
		self.texty = (y - offsety) + textoffsety
	end
	
end

--[[---------------------------------------------------------
	- func: SetTextOffsetX(num)
	- desc: sets the object's text x offset
--]]---------------------------------------------------------
function textinput:SetTextOffsetX(num)

	self.textoffsetx = num
	
end

--[[---------------------------------------------------------
	- func: SetTextOffsetY(num)
	- desc: sets the object's text y offset
--]]---------------------------------------------------------
function textinput:SetTextOffsetY(num)

	self.textoffsety = num
	
end

--[[---------------------------------------------------------
	- func: SetFont(font)
	- desc: sets the object's font
--]]---------------------------------------------------------
function textinput:SetFont(font)

	self.font = font
	
end

--[[---------------------------------------------------------
	- func: GetFont()
	- desc: gets the object's font
--]]---------------------------------------------------------
function textinput:GetFont()

	return self.font
	
end

--[[---------------------------------------------------------
	- func: SetFocus(focus)
	- desc: sets the object's focus
--]]---------------------------------------------------------
function textinput:SetFocus(focus)

	self.focus = focus
	
end

--[[---------------------------------------------------------
	- func: GetFocus()
	- desc: gets the object's focus
--]]---------------------------------------------------------
function textinput:GetFocus()

	return self.focus
	
end

--[[---------------------------------------------------------
	- func: GetIndicatorVisibility()
	- desc: gets the object's indicator visibility
--]]---------------------------------------------------------
function textinput:GetIndicatorVisibility()

	return self.showindicator
	
end

--[[---------------------------------------------------------
	- func: SetLimit(limit)
	- desc: sets the object's text limit
--]]---------------------------------------------------------
function textinput:SetLimit(limit)

	self.limit = limit
	
end

--[[---------------------------------------------------------
	- func: SetUsable(usable)
	- desc: sets what characters can be used for the 
			object's text
--]]---------------------------------------------------------
function textinput:SetUsable(usable)

	self.usable = usable
	
end

--[[---------------------------------------------------------
	- func: GetUsable()
	- desc: gets what characters can be used for the 
			object's text
--]]---------------------------------------------------------
function textinput:GetUsable()

	return self.usable
	
end

--[[---------------------------------------------------------
	- func: SetUnusable(unusable)
	- desc: sets what characters can not be used for the 
			object's text
--]]---------------------------------------------------------
function textinput:SetUnusable(unusable)

	self.unusable = unusable
	
end

--[[---------------------------------------------------------
	- func: GetUnusable()
	- desc: gets what characters can not be used for the 
			object's text
--]]---------------------------------------------------------
function textinput:GetUnusable()

	return self.unusable
	
end

--[[---------------------------------------------------------
	- func: Clear()
	- desc: clears the object's text
--]]---------------------------------------------------------
function textinput:Clear()

	self.lines          = {""}
	self.line           = 1
	self.offsetx        = 0
	self.offsety        = 0
	self.indicatornum   = 0
	
end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the object's text
--]]---------------------------------------------------------
function textinput:SetText(text)

	local tabreplacement = self.tabreplacement
	local multiline      = self.multiline
	
	-- replace any tabs character with spaces
	text = text:gsub(string.char(9), tabreplacement)
	
	-- remove any carriage returns
	text = text:gsub(string.char(13), "")
	
	if multiline then
		text = text:gsub(string.char(92) .. string.char(110), string.char(10))
		local t = loveframes.util.SplitString(text, string.char(10))
		if text==nil or text=="" then --leo
			t={""} -- leo
		end -- leo
		self.lines = t
	else
		text = text:gsub(string.char(92) .. string.char(110), "")
		text = text:gsub(string.char(10), "")
		self.lines = {text}
		self.line  = 1
	end
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the object's text
--]]---------------------------------------------------------
function textinput:GetText()

	local multiline = self.multiline
	local lines     = self.lines
	local text      = ""
	
	if multiline then
		for k, v in ipairs(lines) do
			if k > 1 then-- leo
				text = text .. string.char(10)-- leo
			end-- leo
			text = text .. v
		end
	else
		text = lines[1]
	end
	
	return text
	
end

--[[---------------------------------------------------------
	- func: SetMultiline(bool)
	- desc: enables or disables allowing multiple lines for
			text entry
--]]---------------------------------------------------------
function textinput:SetMultiline(bool)

	local text  = ""
	local lines = self.lines
	
	self.multiline = bool
	
	if bool then
		self:Clear()
	else
		for k, v in ipairs(lines) do
			text = text .. v
		end
		self:SetText(text)
		self.internals = {}
		self.vbar = false
		self.hbar = false
		self.linenumberspanel = false
	end

end

--[[---------------------------------------------------------
	- func: GetMultiLine()
	- desc: gets whether or not the object is using multiple
			lines
--]]---------------------------------------------------------
function textinput:GetMultiLine()

	return self.multiline
	
end

--[[---------------------------------------------------------
	- func: GetVerticalScrollBody()
	- desc: gets the object's vertical scroll body
--]]---------------------------------------------------------
function textinput:GetVerticalScrollBody()

	local vbar      = self.vbar
	local internals = self.internals
	local item      = false
	
	if vbar then
		for k, v in ipairs(internals) do
			if v.type == "scrollbody" and v.bartype == "vertical" then
				item = v
			end
		end
	end
	
	return item

end

--[[---------------------------------------------------------
	- func: GetHorizontalScrollBody()
	- desc: gets the object's horizontal scroll body
--]]---------------------------------------------------------
function textinput:GetHorizontalScrollBody()

	local hbar      = self.hbar
	local internals = self.internals
	local item      = false
	
	if hbar then
		for k, v in ipairs(internals) do
			if v.type == "scrollbody" and v.bartype == "horizontal" then
				item = v
			end
		end
	end
	
	return item

end

--[[---------------------------------------------------------
	- func: HasVerticalScrollBar()
	- desc: gets whether or not the object has a vertical
			scroll bar
--]]---------------------------------------------------------
function textinput:HasVerticalScrollBar()

	return self.vbar
	
end

--[[---------------------------------------------------------
	- func: HasHorizontalScrollBar()
	- desc: gets whether or not the object has a horizontal
			scroll bar
--]]---------------------------------------------------------
function textinput:HasHorizontalScrollBar()

	return self.hbar
	
end

--[[---------------------------------------------------------
	- func: GetLineNumbersPanel()
	- desc: gets the object's line numbers panel
--]]---------------------------------------------------------
function textinput:GetLineNumbersPanel()

	local panel     = self.linenumberspanel
	local internals = self.internals
	local item      = false
	
	if panel then
		for k, v in ipairs(internals) do
			if v.type == "linenumberspanel" then
				item = v
			end
		end
	end
	
	return item
	
end

--[[---------------------------------------------------------
	- func: ShowLineNumbers(bool)
	- desc: sets whether or not to show line numbers when
			using multiple lines
--]]---------------------------------------------------------
function textinput:ShowLineNumbers(bool)

	local multiline = self.multiline
	
	if multiline then
		self.linenumbers = bool
	end
	
end

--[[---------------------------------------------------------
	- func: GetTextX()
	- desc: gets the object's text x
--]]---------------------------------------------------------
function textinput:GetTextX()

	return self.textx
	
end

--[[---------------------------------------------------------
	- func: GetTextY()
	- desc: gets the object's text y
--]]---------------------------------------------------------
function textinput:GetTextY()

	return self.texty
	
end

--[[---------------------------------------------------------
	- func: IsAllTextSelected()
	- desc: gets whether or not all of the object's text is
			selected
--]]---------------------------------------------------------
function textinput:IsAllTextSelected()

	return self.alltextselected
	
end

--[[---------------------------------------------------------
	- func: GetLines()
	- desc: gets the object's lines
--]]---------------------------------------------------------
function textinput:GetLines()

	return self.lines
	
end

--[[---------------------------------------------------------
	- func: GetOffsetX()
	- desc: gets the object's x offset
--]]---------------------------------------------------------
function textinput:GetOffsetX()

	return self.offsetx
	
end

--[[---------------------------------------------------------
	- func: GetOffsetY()
	- desc: gets the object's y offset
--]]---------------------------------------------------------
function textinput:GetOffsetY()

	return self.offsety
	
end

--[[---------------------------------------------------------
	- func: GetIndicatorX()
	- desc: gets the object's indicator's xpos
--]]---------------------------------------------------------
function textinput:GetIndicatorX()

	return self.indicatorx
	
end

--[[---------------------------------------------------------
	- func: GetIndicatorY()
	- desc: gets the object's indicator's ypos
--]]---------------------------------------------------------
function textinput:GetIndicatorY()

	return self.indicatory
	
end

--[[---------------------------------------------------------
	- func: GetLineNumbersEnabled()
	- desc: gets whether line numbers are enabled on the
			object or not
--]]---------------------------------------------------------
function textinput:GetLineNumbersEnabled()

	return self.linenumbers
	
end

--[[---------------------------------------------------------
	- func: GetItemWidth()
	- desc: gets the object's item width
--]]---------------------------------------------------------
function textinput:GetItemWidth()

	return self.itemwidth
	
end

--[[---------------------------------------------------------
	- func: GetItemHeight()
	- desc: gets the object's item height
--]]---------------------------------------------------------
function textinput:GetItemHeight()

	return self.itemheight
	
end

--[[---------------------------------------------------------
	- func: SetTabReplacement(tabreplacement)
	- desc: sets a string to replace tabs with
--]]---------------------------------------------------------
function textinput:SetTabReplacement(tabreplacement)

	self.tabreplacement = tabreplacement
	
end

--[[---------------------------------------------------------
	- func: GetTabReplacement()
	- desc: gets the object's tab replacement
--]]---------------------------------------------------------
function textinput:GetTabReplacement()

	return self.tabreplacement
	
end

--[[---------------------------------------------------------
	- func: SetEditable(bool)
	- desc: sets whether or not the user can edit the
			object's text
--]]---------------------------------------------------------
function textinput:SetEditable(bool)

	self.editable = bool
	
end

--[[---------------------------------------------------------
	- func: GetEditable
	- desc: gets whether or not the user can edit the
			object's text
--]]---------------------------------------------------------
function textinput:GetEditable()

	return self.editable
	
end