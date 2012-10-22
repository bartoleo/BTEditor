--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

--[[------------------------------------------------
	-- note: the text wrapping of this object is
			 experimental and not final
--]]------------------------------------------------

-- text class
text = class("text", base)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function text:initialize()

	self.type           = "text"
	self.text           = ""
	self.font           = loveframes.basicfont
	self.width          = 5
	self.height         = 5
	self.maxw           = 0
	self.lines          = 1
	self.formattedtext  = {}
	self.original       = {}
	self.internal       = false
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function text:update(dt)

	if not self.visible then
		if not self.alwaysupdate then
			return
		end
	end
	
	local parent = self.parent
	local base   = loveframes.base
	local update = self.Update
	
	self:CheckHover()
	
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
function text:draw()

	if not self.visible then
		return
	end
	
	local skins         = loveframes.skins.available
	local skinindex     = loveframes.config["ACTIVESKIN"]
	local defaultskin   = loveframes.config["DEFAULTSKIN"]
	local selfskin      = self.skin
	local skin          = skins[selfskin] or skins[skinindex]
	local drawfunc      = skin.DrawText or skins[defaultskin].DrawText
	local draw          = self.Draw
	local drawcount     = loveframes.drawcount
	
	-- set the object's draw order
	self:SetDrawOrder()
		
	if draw then
		draw(self)
	else
		drawfunc(self)
	end

	self:DrawText()
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function text:mousepressed(x, y, button)

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
		
	end
	
end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the object's text
--]]---------------------------------------------------------
function text:SetText(t)
	
	local dtype   = type(t)
	local maxw    = self.maxw
	local font    = self.font
	local inserts = {}
	local tdata, prevcolor
	
	self.text          = ""
	self.formattedtext = {}
	
	if dtype == "string" then
		tdata = {t}
		self.original = {t}
	elseif dtype == "number" then
		tdata = {tostring(t)}
		self.original = {tostring(t)}
	elseif dtype == "table" then
		tdata = t
		self.original = t
	else
		return
	end
	
	for k, v in ipairs(tdata) do
		
		local dtype = type(v)
		
		if k == 1 and dtype ~= "table" then
			prevcolor = {0, 0, 0, 255}
		end
		
		if dtype == "table" then
			prevcolor = v
		elseif dtype == "number" then
			
			table.insert(self.formattedtext, {color = prevcolor, text = tostring(v)})
			
		elseif dtype == "string" then
			
			v = v:gsub(string.char(9), "    ")
			v = v:gsub(string.char(92) .. string.char(110), string.char(10))
			
			local parts = loveframes.util.SplitString(v, " ")
					
			for i, j in ipairs(parts) do
				table.insert(self.formattedtext, {color = prevcolor, text = j})
			end
			
		end
		
	end
	
	if maxw > 0 then
	
		for k, v in ipairs(self.formattedtext) do
					
			local data  = v.text
			local width = font:getWidth(data)
			local curw  = 0
			local new   = ""
			local key   = k
			
			if width > maxw then
					
				table.remove(self.formattedtext, k)
				
				for n=1, #data do
							
					local item = data:sub(n, n)
					local itemw = font:getWidth(item)
					
					if n ~= #data then
						
						if (curw + itemw) > maxw then
							table.insert(inserts, {key = key, color = v.color, text = new})
							new = item
							curw = 0 + itemw
							key = key + 1
						else
							new = new .. item
							curw = curw + itemw
						end
						
					else
						new = new .. item
						table.insert(inserts, {key = key, color = v.color, text = new})
					end
							
				end
						
			end
					
		end
		
	end
	
	for k, v in ipairs(inserts) do
		table.insert(self.formattedtext, v.key, {color = v.color, text = v.text})
	end
	
	local textdata       = self.formattedtext
	local maxw           = self.maxw
	local font           = self.font
	local height         = font:getHeight("a")
	local twidth         = 0
	local drawx          = 0
	local drawy          = 0
	local lines          = 0
	local totalwidth     = 0
	local x              = self.x
	local y              = self.y
	local prevtextwidth  = 0
	
	for k, v in ipairs(textdata) do
		
		local text = v.text
		local color = v.color
		
		if type(text) == "string" then
		
			self.text = self.text .. text
			
			local width = font:getWidth(text)
			totalwidth = totalwidth + width
			
			if maxw > 0 then
			
				if k ~= 1 then
					
					if string.byte(text) == 10 then
						twidth = 0
						drawx = 0
						width = 0
						drawy = drawy + height
						text = ""
					elseif (twidth + width) > maxw then
						twidth = 0 + width
						drawx = 0
						drawy = drawy + height
					else
						twidth = twidth + width
						drawx = drawx + prevtextwidth
					end
					
				else
					twidth = twidth + width
				end
				
				prevtextwidth = width
			
				v.x = drawx
				v.y = drawy
				
			else
			
				if k ~= 1 then
					drawx = drawx + prevtextwidth
				end
				
				prevtextwidth = width
				
				v.x = drawx
				v.y = drawy
				
			end
			
		end
	
	end
	
	if maxw > 0 then
		self.width = maxw
	else
		self.width = totalwidth
	end
			
	self.height = drawy + height
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the object's text
--]]---------------------------------------------------------
function text:GetText()

	return self.text
	
end

--[[---------------------------------------------------------
	- func: GetFormattedText()
	- desc: gets the object's formatted text
--]]---------------------------------------------------------
function text:GetFormattedText()

	return self.formattedtext
	
end

--[[---------------------------------------------------------
	- func: Format()
	- desc: formats the text
--]]---------------------------------------------------------
function text:DrawText()

	local textdata = self.formattedtext
	local font     = self.font
	local x        = self.x
	local y        = self.y
	
	for k, v in ipairs(textdata) do
		
		local text  = v.text
		local color = v.color
				
		love.graphics.setFont(font)
		love.graphics.setColor(unpack(color))
		love.graphics.printf(text, x + v.x, y + v.y, 0, "left")
	
	end
	
end

--[[---------------------------------------------------------
	- func: SetMaxWidth(width)
	- desc: sets the object's maximum width
--]]---------------------------------------------------------
function text:SetMaxWidth(width)

	self.maxw = width
	self:SetText(self.original)
	
end

--[[---------------------------------------------------------
	- func: GetMaxWidth()
	- desc: gets the object's maximum width
--]]---------------------------------------------------------
function text:GetMaxWidth()

	return self.maxw
	
end

--[[---------------------------------------------------------
	- func: SetWidth(width)
	- desc: sets the object's width
--]]---------------------------------------------------------
function text:SetWidth(width)

	self:SetMaxWidth(width)
	
end

--[[---------------------------------------------------------
	- func: SetHeight()
	- desc: sets the object's height
--]]---------------------------------------------------------
function text:SetHeight(height)
	
	return
	
end

--[[---------------------------------------------------------
	- func: SetSize()
	- desc: sets the object's size
--]]---------------------------------------------------------
function text:SetSize(width, height)

	self:SetMaxWidth(width)
	
end

--[[---------------------------------------------------------
	- func: SetFont(font)
	- desc: sets the object's font
	- note: font argument must be a font object
--]]---------------------------------------------------------
function text:SetFont(font)

	local original = self.original
	
	self.font = font
	
	if original then
		self:SetText(original)
	end
	
end

--[[---------------------------------------------------------
	- func: GetFont()
	- desc: gets the object's font
--]]---------------------------------------------------------
function text:GetFont()

	return self.font
	
end

--[[---------------------------------------------------------
	- func: GetLines()
	- desc: gets the number of lines the object's text uses
--]]---------------------------------------------------------
function text:GetLines()

	return self.lines
	
end