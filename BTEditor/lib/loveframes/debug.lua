--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

-- debug library
loveframes.debug = {}

local font            = love.graphics.newFont(10)
local changelog, size = love.filesystem.read( loveframes.config["DIRECTORY"].."/changelog.txt")
local loremipsum      = 
[[
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin dui enim, porta eget facilisis quis, laoreet sit amet urna. Maecenas lobortis venenatis euismod. Sed at diam sit amet odio feugiat pretium nec quis libero. Quisque auctor semper imperdiet. Maecenas risus eros, varius pharetra volutpat in, fermentum scelerisque lacus. Proin lectus erat, luctus non facilisis vel, hendrerit vitae nisl. Aliquam vulputate scelerisque odio id faucibus.
]]


--[[---------------------------------------------------------
	- func: draw()
	- desc: draws debug information
--]]---------------------------------------------------------
function loveframes.debug.draw()

	-- get the current debug setting
	local debug = loveframes.config["DEBUG"]
	
	-- do not draw anthing if debug is off
	if not debug then
		return
	end
	
	local cols 				= loveframes.util.GetCollisions()
	local topcol 			= cols[#cols] or {type = none, children = {}, x = 0, y = 0, width = 0, height = 0}
	local objects 			= loveframes.util.GetAllObjects()
	local author			= loveframes.info.author
	local version			= loveframes.info.version
	local stage				= loveframes.info.stage
	local basedir			= loveframes.config["DIRECTORY"]
	local loveversion		= love._version
	local fps				= love.timer.getFPS()
	local deltatime			= love.timer.getDelta()
	
	-- font for debug text
	love.graphics.setFont(font)
	
	love.graphics.setColor(0, 0, 0, 150)
	love.graphics.rectangle("fill", 5, 5, 200, 250)
	
	love.graphics.setColor(0, 0, 0, 50)
	love.graphics.rectangle("fill", 10, 10, 190, 20)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.print("Library Information", 15, 15)
	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("Author: " ..author, 15, 30)
	love.graphics.print("Version: " ..version, 15, 40)
	love.graphics.print("Stage: " ..stage, 15, 50)
	love.graphics.print("Base Directory: " ..basedir, 15, 60)
	
	-- object information box
	love.graphics.setColor(0, 0, 0, 50)
	love.graphics.rectangle("fill", 10, 80, 190, 20)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.print("Object Information", 15, 85)
	
	love.graphics.setColor(255, 255, 255, 255)
	
	if #cols > 0 then
		love.graphics.print("Type: " ..topcol.type, 15, 100)
	else
		love.graphics.print("Type: none", 10, 100)
	end
	
	if topcol.children then
		love.graphics.print("# of children: " .. #topcol.children, 15, 110)
	else
		love.graphics.print("# of children: 0", 15, 110)
	end
	
	if topcol.internals then
		love.graphics.print("# of internals: " .. #topcol.internals, 15, 120)
	else
		love.graphics.print("# of internals: 0", 15, 120)
	end
	
	love.graphics.print("X: " ..topcol.x, 15, 130)
	love.graphics.print("Y: " ..topcol.y, 15, 140)
	love.graphics.print("Width: " ..topcol.width, 15, 150)
	love.graphics.print("Height: " ..topcol.height, 15, 160)
	
	-- Miscellaneous box
	love.graphics.setColor(0, 0, 0, 50)
	love.graphics.rectangle("fill", 10, 190, 190, 20)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.print("Miscellaneous", 15, 195)
	
	love.graphics.setColor(255, 255, 255, 255)
	
	love.graphics.print("LOVE Version: " ..loveversion, 15, 210)
	love.graphics.print("FPS: " ..fps, 15, 220)
	love.graphics.print("Delta Time: " ..deltatime, 15, 230)
	love.graphics.print("Total Objects: " ..#objects, 15, 240)
	
	-- outline the object that the mouse is hovering over
	love.graphics.setColor(255, 204, 51, 255)
	love.graphics.setLine(2, "smooth")
	love.graphics.rectangle("line", topcol.x - 1, topcol.y - 1, topcol.width + 2, topcol.height + 2)

end

--[[---------------------------------------------------------
	- func: ExamplesMenu()
	- desc: generates a list of examples of LÖVE Frames
			objects
--]]---------------------------------------------------------
function loveframes.debug.ExamplesMenu()
	
	------------------------------------
	-- examples frame
	------------------------------------
	local examplesframe = loveframes.Create("frame")
	examplesframe:SetName("Examples List")
	examplesframe:SetSize(200, love.graphics.getHeight() - 330)
	examplesframe:SetPos(5, 325)
	
	------------------------------------
	-- examples list
	------------------------------------
	local exampleslist = loveframes.Create("list", examplesframe)
	exampleslist:SetSize(200, exampleslist:GetParent():GetHeight() - 25)
	exampleslist:SetPos(0, 25)
	exampleslist:SetPadding(5)
	exampleslist:SetSpacing(5)
	exampleslist:SetDisplayType("vertical")
	
	------------------------------------
	-- button example
	------------------------------------
	local buttonexample = loveframes.Create("button")
	buttonexample:SetText("Button")
	buttonexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Button")
		frame1:Center()
		
		local button1 = loveframes.Create("button", frame1)
		button1:SetWidth(200)
		button1:SetText("Button")
		button1:Center()
		button1.OnClick = function(object2, x, y)
			object2:SetText("You clicked the button!")
		end
		button1.OnMouseEnter = function(object2)
			object2:SetText("The mouse entered the button.")
		end
		button1.OnMouseExit = function(object2)
			object2:SetText("The mouse exited the button.")
		end
		
	end
	exampleslist:AddItem(buttonexample)
	
	------------------------------------
	-- checkbox example
	------------------------------------
	local checkboxexample = loveframes.Create("button")
	checkboxexample:SetText("Checkbox")
	checkboxexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Checkbox")
		frame1:Center()
		frame1:SetHeight(85)
		
		local checkbox1 = loveframes.Create("checkbox", frame1)
		checkbox1:SetText("Checkbox 1")
		checkbox1:SetPos(5, 30)
		checkbox1.OnChanged = function(object2)
		end
		
		local checkbox2 = loveframes.Create("checkbox", frame1)
		checkbox2:SetText("Checkbox 2")
		checkbox2:SetPos(5, 60)
		checkbox2.OnChanged = function(object3)
		end
		
	end
	exampleslist:AddItem(checkboxexample)
	
	------------------------------------
	-- collapsible category example
	------------------------------------
	local collapsiblecategoryexample = loveframes.Create("button")
	collapsiblecategoryexample:SetText("Collapsible Category")
	collapsiblecategoryexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Collapsible Category")
		frame1:SetSize(500, 300)
		frame1:Center()
		
		local panel1 = loveframes.Create("panel")
		panel1:SetHeight(230)
			
		local collapsiblecategory1 = loveframes.Create("collapsiblecategory", frame1)
		collapsiblecategory1:SetPos(5, 30)
		collapsiblecategory1:SetSize(490, 265)
		collapsiblecategory1:SetText("Category 1")
		collapsiblecategory1:SetObject(panel1)
		
	end
	exampleslist:AddItem(collapsiblecategoryexample)
	
	------------------------------------
	-- cloumnlist example
	------------------------------------
	local cloumnlistexample = loveframes.Create("button")
	cloumnlistexample:SetText("Column List")
	cloumnlistexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Column List")
		frame1:SetSize(500, 300)
		frame1:Center()
		
		local list1 = loveframes.Create("columnlist", frame1)
		list1:SetPos(5, 30)
		list1:SetSize(490, 265)
		list1:AddColumn("Column 1")
		list1:AddColumn("Column 2")
		list1:AddColumn("Column 3")
		list1:AddColumn("Column 4")
		
		for i=1, 20 do
			list1:AddRow("Row " ..i.. ", column 1", "Row " ..i.. ", column 2", "Row " ..i.. ", column 3", "Row " ..i.. ", column 4")
		end
		
	end
	exampleslist:AddItem(cloumnlistexample)
	
	------------------------------------
	-- frame example
	------------------------------------
	local frameexample = loveframes.Create("button")
	frameexample:SetText("Frame")
	frameexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Frame")
		frame1:Center()
		
		local text1 = loveframes.Create("text", frame1)
		text1:SetText("This is an example frame.")
		text1.Update = function(object2, dt)
			object2:CenterX()
			object2:SetY(40)
		end
		
		local button1 = loveframes.Create("button", frame1)
		button1:SetText("Modal")
		button1:SetWidth(100)
		button1:Center()
		button1.Update = function(object2, dt)
			local modal = object2:GetParent():GetModal()
			
			if modal == true then
				object2:SetText("Remove Modal")
				object2.OnClick = function()
					object2:GetParent():SetModal(false)
				end
			else
				object2:SetText("Set Modal")
				object2.OnClick = function()
					object2:GetParent():SetModal(true)
				end
			end
		end
		
	end
	exampleslist:AddItem(frameexample)
	
	------------------------------------
	-- image example
	------------------------------------
	local imageexample = loveframes.Create("button")
	imageexample:SetText("Image")
	imageexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Image")
		frame1:SetSize(138, 163)
		frame1:Center()
		
		local image1 = loveframes.Create("image", frame1)
		image1:SetImage("resources/images/carlsagan.png")
		image1:SetPos(5, 30)
		
	end
	exampleslist:AddItem(imageexample)
	
	------------------------------------
	-- image button example
	------------------------------------
	local imagebuttonexample = loveframes.Create("button")
	imagebuttonexample:SetText("Image Button")
	imagebuttonexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Image Button")
		frame1:SetSize(138, 163)
		frame1:Center()
		
		local imagebutton1 = loveframes.Create("imagebutton", frame1)
		imagebutton1:SetImage("resources/images/carlsagan.png")
		imagebutton1:SetPos(5, 30)
		imagebutton1:SizeToImage()
		
	end
	exampleslist:AddItem(imagebuttonexample)
	
	------------------------------------
	-- list example
	------------------------------------
	local listexample = loveframes.Create("button")
	listexample:SetText("List")
	listexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("List")
		frame1:SetSize(500, 455)
		frame1:Center()
		
		local list1 = loveframes.Create("list", frame1)
		list1:SetPos(5, 30)
		list1:SetSize(490, 300)
		
		local panel1 = loveframes.Create("panel", frame1)
		panel1:SetPos(5, 335)
		panel1:SetSize(490, 115)
		
		local slider1 = loveframes.Create("slider", panel1)
		slider1:SetPos(5, 20)
		slider1:SetWidth(480)
		slider1:SetMinMax(0, 100)
		slider1:SetText("Padding")
		slider1:SetDecimals(0)
		slider1.OnValueChanged = function(object2, value)
			list1:SetPadding(value)
		end
		
		local text1 = loveframes.Create("text", panel1)
		text1:SetPos(5, 5)
		text1:SetFont(love.graphics.newFont(10))
		text1:SetText(slider1:GetText())
		
		local text2 = loveframes.Create("text", panel1)
		text2:SetFont(love.graphics.newFont(10))
		text2.Update = function(object, dt)
			object:SetPos(slider1:GetWidth() - object:GetWidth(), 5)
			object:SetText(slider1:GetValue())
		end
		
		local slider2 = loveframes.Create("slider", panel1)
		slider2:SetPos(5, 60)
		slider2:SetWidth(480)
		slider2:SetMinMax(0, 100)
		slider2:SetText("Spacing")
		slider2:SetDecimals(0)
		slider2.OnValueChanged = function(object2, value)
			list1:SetSpacing(value)
		end
		
		local text3 = loveframes.Create("text", panel1)
		text3:SetPos(5, 45)
		text3:SetFont(love.graphics.newFont(10))
		text3:SetText(slider2:GetText())
		
		local text4 = loveframes.Create("text", panel1)
		text4:SetFont(love.graphics.newFont(10))
		text4.Update = function(object, dt)
			object:SetPos(slider2:GetWidth() - object:GetWidth(), 45)
			object:SetText(slider2:GetValue())
		end
		
		local button1 = loveframes.Create("button", panel1)
		button1:SetPos(5, 85)
		button1:SetSize(480, 25)
		button1:SetText("Change List Type")
		button1.OnClick = function(object2, x, y)
			if list1:GetDisplayType() == "vertical" then
				list1:SetDisplayType("horizontal")
			else
				list1:SetDisplayType("vertical")
			end
		end
		
		for i=1, 50 do
			local button2 = loveframes.Create("button")
			button2:SetText(i)
			list1:AddItem(button2)
		end
		
	end
	exampleslist:AddItem(listexample)
	
	------------------------------------
	-- multichoice example
	------------------------------------
	local multichoiceexample = loveframes.Create("button")
	multichoiceexample:SetText("Multichoice")
	multichoiceexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Multichoice")
		frame1:SetSize(210, 60)
		frame1:Center()
		
		local multichoice1 = loveframes.Create("multichoice", frame1)
		multichoice1:SetPos(5, 30)
		
		for i=1, 20 do
			multichoice1:AddChoice(i)
		end
		
	end
	exampleslist:AddItem(multichoiceexample)
	
	------------------------------------
	-- panel example
	------------------------------------
	local panelexample = loveframes.Create("button")
	panelexample:SetText("Panel")
	panelexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Panel")
		frame1:SetSize(210, 85)
		frame1:Center()
		
		local panel1 = loveframes.Create("panel", frame1)
		panel1:SetPos(5, 30)
		
	end
	exampleslist:AddItem(panelexample)
	
	------------------------------------
	-- progressbar example
	------------------------------------
	local progressbarexample = loveframes.Create("button")
	progressbarexample:SetText("Progress Bar")
	progressbarexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Progress Bar")
		frame1:SetSize(500, 160)
		frame1:Center()
		
		local progressbar1 = loveframes.Create("progressbar", frame1)
		progressbar1:SetPos(5, 30)
		progressbar1:SetWidth(490)
		progressbar1:SetLerpRate(1)
		
		local button1 = loveframes.Create("button", frame1)
		button1:SetPos(5, 60)
		button1:SetWidth(490)
		button1:SetText("Change bar value")
		button1.OnClick = function(object2, x, y)
			progressbar1:SetValue(math.random(progressbar1:GetMin(), progressbar1:GetMax()))
		end
		
		local button2 = loveframes.Create("button", frame1)
		button2:SetPos(5, 90)
		button2:SetWidth(490)
		button2:SetText("Toggle bar lerp")
		button2.OnClick = function(object2, x, y)
			if progressbar1:GetLerp() == true then
				progressbar1:SetLerp(false)
			else
				progressbar1:SetLerp(true)
			end
		end
		
		local slider1 = loveframes.Create("slider", frame1)
		slider1:SetPos(5, 135)
		slider1:SetWidth(490)
		slider1:SetText("Progressbar lerp rate")
		slider1:SetMinMax(1, 50)
		slider1:SetDecimals(0)
		slider1.OnValueChanged = function(object2, value)
			progressbar1:SetLerpRate(value)
		end
		
		local text1 = loveframes.Create("text", frame1)
		text1:SetPos(5, 120)
		text1:SetText("Lerp Rate")
		text1:SetFont(love.graphics.newFont(10))
		
		local text2 = loveframes.Create("text", frame1)
		text2:SetFont(love.graphics.newFont(10))
		text2.Update = function(object, dt)
			object:SetPos(slider1:GetWidth() - object:GetWidth(), 120)
			object:SetText(slider1:GetValue())
		end
		
	end
	exampleslist:AddItem(progressbarexample)
	
	------------------------------------
	-- slider example
	------------------------------------
	local sliderexample = loveframes.Create("button")
	sliderexample:SetText("Slider")
	sliderexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Slider")
		frame1:SetSize(300, 275)
		frame1:Center()
		
		local slider1 = loveframes.Create("slider", frame1)
		slider1:SetPos(5, 30)
		slider1:SetWidth(290)
		slider1:SetMinMax(0, 100)
		
		local slider2 = loveframes.Create("slider", frame1)
		slider2:SetPos(5, 60)
		slider2:SetHeight(200)
		slider2:SetMinMax(0, 100)
		slider2:SetButtonSize(20, 10)
		slider2:SetSlideType("vertical")
		slider2.Update = function(object, dt)
			object:CenterX()
		end
		
	end
	exampleslist:AddItem(sliderexample)
	
	------------------------------------
	-- tabs example
	------------------------------------
	local tabsexample = loveframes.Create("button")
	tabsexample:SetText("Tabs")
	tabsexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Tabs")
		frame1:SetSize(500, 300)
		frame1:Center()
		
		local tabs1 = loveframes.Create("tabs", frame1)
		tabs1:SetPos(5, 30)
		tabs1:SetSize(490, 265)
		
		local images = {"accept.png", "add.png", "application.png", "building.png", "bin.png", "database.png", "box.png", "brick.png"}
		
		for i=1, 20 do
		
			local panel1 = loveframes.Create("panel")
			panel1.Draw = function()
			end
			
			local text1 = loveframes.Create("text", panel1)
			text1:SetText("Tab " ..i)
			tabs1:AddTab("Tab " ..i, panel1, "Tab " ..i, "resources/images/" ..images[math.random(1, #images)])
			text1:SetAlwaysUpdate(true)
			text1.Update = function(object, dt)
				object:Center()
			end
			
		end
		
	end
	exampleslist:AddItem(tabsexample)
	
	------------------------------------
	-- text example
	------------------------------------
	local textexample = loveframes.Create("button")
	textexample:SetText("Text")
	textexample.OnClick = function(object1, x, y)
	
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Text")
		frame1:SetSize(500, 300)
		frame1:Center()
		
		local list1 = loveframes.Create("list", frame1)
		list1:SetPos(5, 30)
		list1:SetSize(490, 265)
		list1:SetPadding(5)
		list1:SetSpacing(5)
		
		for i=1, 5 do
			local text1 = loveframes.Create("text")
			text1:SetText(loremipsum)
			list1:AddItem(text1)
		end
		
	end
	exampleslist:AddItem(textexample)
	
	------------------------------------
	-- text input example
	------------------------------------
	local textinputexample = loveframes.Create("button")
	textinputexample:SetText("Text Input")
	textinputexample.OnClick = function(object1, x, y)
		
		local frame1 = loveframes.Create("frame")
		frame1:SetName("Text Input")
		frame1:SetSize(500, 90)
		frame1:Center()
		
		local textinput1 = loveframes.Create("textinput", frame1)
		textinput1:SetPos(5, 30)
		textinput1:SetWidth(490)
		textinput1.OnEnter = function(object)
			if not textinput1.multiline then
				object:Clear()
			end
		end
		textinput1:SetFont(love.graphics.newFont(12))
		
		local togglebutton = loveframes.Create("button", frame1)
		togglebutton:SetPos(5, 60)
		togglebutton:SetWidth(490)
		togglebutton:SetText("Toggle Multiline")
		togglebutton.OnClick = function(object)
			if textinput1.multiline then
				frame1:SetHeight(90)
				frame1:Center()
				togglebutton:SetPos(5, 60)
				textinput1:SetMultiline(false)
				textinput1:SetHeight(25)
				textinput1:SetText("")
			else
				frame1:SetHeight(365)
				frame1:Center()
				togglebutton:SetPos(5, 335)
				textinput1:SetMultiline(true)
				textinput1:SetHeight(300)
				textinput1:SetText(changelog)
			end
		end
		
	end
	exampleslist:AddItem(textinputexample)

end

--[[---------------------------------------------------------
	- func: SkinSelector()
	- desc: opens a skin selector menu
--]]---------------------------------------------------------
function loveframes.debug.SkinSelector()

	local skins = loveframes.skins.available
	
	local frame = loveframes.Create("frame")
	frame:SetName("Skin Selector")
	frame:SetSize(200, 60)
	frame:SetPos(5, 260)

	local skinslist = loveframes.Create("multichoice", frame)
	skinslist:SetPos(5, 30)
	skinslist:SetWidth(190)
	skinslist:SetChoice("Choose a skin")
	skinslist.OnChoiceSelected = function(object, choice)
		loveframes.util.SetActiveSkin(choice)
	end
	
	for k, v in pairs(skins) do
		skinslist:AddChoice(v.name)
	end
	
end