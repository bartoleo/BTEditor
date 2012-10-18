--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012 Kenny Shields --
--]]------------------------------------------------

-- templates
loveframes.templates = {}

-- default template
loveframes.templates.default =
{
	x = 0,
	y = 0,
	width = 5,
	height = 5,
	staticx	= 5,
	staticy	= 5,
	draworder = 0,
	internal = false,
	visible	= true,
	hover = false,
	alwaysupdate = false,
	retainsize = false,
	calledmousefunc = false,
	skin = nil,
	clickbounds = nil,
	Draw = nil,
	Update = nil,
	OnMouseEnter = nil,
	OnMouseExit = nil,
}