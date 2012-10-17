--- recursively load all files in the a dir and run them through a function
-- @param targettable target store table
-- @param path path of files
-- @param extension extension of files
-- @param func func to call for every file
function loadfromdir(targettable, path, extension, func)
  local extmatch = "%." .. extension .. "$"
  for i, v in ipairs(love.filesystem.enumerate(path)) do
    if love.filesystem.isDirectory(path .. "/" .. v) then
      targettable[v] = {}
      loadfromdir(targettable[v], path .. "/" .. v, extension, func)
    elseif v:match(extmatch) then
      targettable[v:sub(1, -5)] = func(path .. "/" .. v)
    end
  end
end

--- rotate box
-- @param a table with x,y,w,ox,oy,h,r
-- @return table with 4 elements x,y
function rotatebox(a)
  local quad = {{}, {}, {}, {}}
  quad[1].x = a.x
  quad[1].y = a.y
  quad[2].x = a.x+a.w
  quad[2].y = a.y
  quad[3].x = a.x+a.w
  quad[3].y = a.y+a.h
  quad[4].x = a.x
  quad[4].y = a.y+a.h
  local x, y = a.x+a.ox, a.y+a.oy
  for i = 1, 4 do
    local dist = math.sqrt((quad[i].x-x)^2+(quad[i].y-y)^2)
    local angle = math.atan2(quad[i].y-y, quad[i].x-x)
    angle = angle + a.r
    quad[i].x = math.cos(angle)*dist+x
    quad[i].y = math.sin(angle)*dist+y
  end
  return quad
end

--- box to circle
-- @param b table with x,y,w,h
-- @return table with x,y,r
local function boxtocircle(b)
  local circle = {}
  circle.x = (b.x + b.w) / 2
  circle.y = (b.y + b.h) / 2
  circle.r = math.sqrt((b.h^2) + (b.w^2))
  return circle
end

--- Circle Circle Collision 
-- @param a table with x,y,r
-- @param b table with x,y,r
-- @return boolean collision
function CircleCircleCollision(a, b)
  local t_radius = math.sqrt(a.r + b.r)
  local t_distance = math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)

  return t_distance < t_radius
end

--- array to box 
-- @param a table with 5 elements
-- @return table with x,y,w,h,r
local function arraytobox(a)
  return {x = a[1], y = a[2], w = a[1]+a[3], h = a[2]+a[4], r = a[5]}
end

--- Box Box Collision
-- @param a table box with 5 elements
-- @param b table box with 5 elements
-- @return boolean circle collison of a and b
function BoxBoxCollision(a, b)
  a = arraytobox(a)
  b = arraytobox(b)

  return CircleCircleCollision(boxtocircle(a), boxtocircle(b))

end

--- isOnSegment (LUADOC TODO add resume)
-- isOnSegment (LUADOC TODO add description)
-- @param xi (LUADOC TODO add xi desctiption) 
-- @param yi (LUADOC TODO add yi desctiption) 
-- @param xj (LUADOC TODO add xj desctiption) 
-- @param yj (LUADOC TODO add yj desctiption) 
-- @param xk (LUADOC TODO add xk desctiption) 
-- @param yk (LUADOC TODO add yk desctiption) 
-- @return (LUADOC TODO add return desctiption) 
function isOnSegment(xi, yi, xj, yj, xk, yk)
  return (xi <= xk or xj <= xk) and (xk <= xi or xk <= xj) and (yi <= yk or yj <= yk) and (yk <= yi or xk <= yj)
end

--- computeDirection (LUADOC TODO add resume)
-- computeDirection (LUADOC TODO add description)
-- @param xi (LUADOC TODO add xi desctiption) 
-- @param yi (LUADOC TODO add yi desctiption) 
-- @param xj (LUADOC TODO add xj desctiption) 
-- @param yj (LUADOC TODO add yj desctiption) 
-- @param xk (LUADOC TODO add xk desctiption) 
-- @param yk (LUADOC TODO add yk desctiption) 
-- @return (LUADOC TODO add return desctiption) 
function computeDirection(xi, yi, xj, yj, xk, yk)
  local a = (xk - xi) * (yj - yi)
  local b = (xj - xi) * (yk - yi)
  if a < b then return -1 elseif a > b then return 1 else return 0 end
end

--- doLineSegmentsIntersect (LUADOC TODO add resume)
-- doLineSegmentsIntersect (LUADOC TODO add description)
-- @param x1 (LUADOC TODO add x1 desctiption) 
-- @param y1 (LUADOC TODO add y1 desctiption) 
-- @param x2 (LUADOC TODO add x2 desctiption) 
-- @param y2 (LUADOC TODO add y2 desctiption) 
-- @param x3 (LUADOC TODO add x3 desctiption) 
-- @param y3 (LUADOC TODO add y3 desctiption) 
-- @param x4 (LUADOC TODO add x4 desctiption) 
-- @param y4 (LUADOC TODO add y4 desctiption) 
-- @return (LUADOC TODO add return desctiption) 
function doLineSegmentsIntersect(x1, y1, x2, y2, x3, y3, x4, y4)
  local d1 = computeDirection(x3, y3, x4, y4, x1, y1)
  local d2 = computeDirection(x3, y3, x4, y4, x2, y2)
  local d3 = computeDirection(x1, y1, x2, y2, x3, y3)
  local d4 = computeDirection(x1, y1, x2, y2, x4, y4)
  return (((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and
           ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0))) or
  (d1 == 0 and isOnSegment(x3, y3, x4, y4, x1, y1)) or
  (d2 == 0 and isOnSegment(x3, y3, x4, y4, x2, y2)) or
  (d3 == 0 and isOnSegment(x1, y1, x2, y2, x3, y3)) or
  (d4 == 0 and isOnSegment(x1, y1, x2, y2, x4, y4))
end

--- quadsColliding (LUADOC TODO add resume)
-- quadsColliding (LUADOC TODO add description)
-- @param a (LUADOC TODO add a desctiption) 
-- @param b (LUADOC TODO add b desctiption) 
-- @return (LUADOC TODO add return desctiption) 
function quadsColliding( a, b )
  for i = 1, 4 do
    local nextI = i+1
    if nextI == 5 then nextI = 1 end
    for j = 1, 4 do
      local nextJ = j+1
      if nextJ == 5 then nextJ = 1 end
      if doLineSegmentsIntersect(a[i].x, a[i].y, a[nextI].x, a[nextI].y, b[j].x, b[j].y, b[nextJ].x, b[nextJ].y) then
        return true
      end
    end
  end
  return false
end

--- copy tables
-- copy input table in new table 
-- @param t table input
-- @return new table
function table_copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end


-- 
---Converts an arbitrary data type into a string. Will recursively convert 
-- tables. 
-- 
--@param data   The data to convert. 
--@param indent (optional) The number of times to indent the line. Default 
--              is 0. 
--@return A string representation of a data, will be one or more full lines. 
function to_string(data, indent) 
    local str = "" 

    if(indent == nil) then 
        indent = 0 
    end 

    -- Check the type 
    if(type(data) == "string") then 
        str = str .. (" "):rep(indent) .. data .. "\n" 
    elseif(type(data) == "number") then 
        str = str .. (" "):rep(indent) .. data .. "\n" 
    elseif(type(data) == "boolean") then 
        if(data == true) then 
            str = str .. "true" 
        else 
            str = str .. "false" 
        end 
    elseif(type(data) == "table") then 
        local i, v 
        for i, v in pairs(data) do 
            -- Check for a table in a table 
            if(type(v) == "table") then 
                str = str .. (" "):rep(indent) .. i .. ":\n" 
                str = str .. to_string(v, indent + 2) 
            else 
                str = str .. (" "):rep(indent) .. i .. ": " .. 
to_string(v, 0) 
            end 
        end 
    else 
        print( "Error: unknown data type: ".. type(data)) 
    end 

    return str 
end 

function truefalse(booleano,returntrue,returnfalse) 
  if (booleano) then
    return returntrue
  end
  return returnfalse
end
function truefalseother(booleano,returntrue,returnfalse,returnother) 
  if (booleano==true) then
    return returntrue
  elseif (booleano==false) then
    return returnfalse
  else
    return returnother
  end
end

function nvl(object,return_ifnil) 
  if (object==nil) then
    return return_ifnil
  end
  return object
end

-- Compatibility: Lua-5.0
function split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

-- This function search for a file in the folder and in all subfolders
function recursiveSearchFile(folder, filesearched)
    local lfs = love.filesystem
    local filesTable = lfs.enumerate(folder)
    for i,v in ipairs(filesTable) do
        local file = folder.."/"..v
        if string.upper(v)==string.upper(filesearched) then
		  return folder.."/"..v
		end
        if lfs.isDirectory(file) then
            local filetrovato = recursiveSearchFile(file, filesearched)
			if filetrovato ~= "" then
			  return filetrovato
			end
        end
    end
    return ""
end

function getScreenMode()
    _G.screen_width, _G.screen_height, _G.screen_fullscreen, _G.screen_vsync, _G.screen_fsaa = love.graphics.getMode( )
	_G.screen_middlex=_G.screen_width/2
	_G.screen_middley=_G.screen_height/2
    -- graphics features supported
    _G.canvas_supported = love.graphics.isSupported("canvas")
    _G.pixeleffect_supported = love.graphics.isSupported("pixeleffect")
    _G.npot_supported = love.graphics.isSupported("npot")
    _G.subtractive_supported = love.graphics.isSupported("subtractive")
end

function changeScreenMode(ptable)
  if ptable then
    return love.graphics.setMode( ptable.width, ptable.height, ptable.fullscreen, ptable.vsync, ptable.fsaa )
  else
    return false
  end
end

function readScreenMode(pfile)
	if love.filesystem.exists(pfile)==false then
	  saveScreenMode(pfile)
	end
	if love.filesystem.exists(pfile) then
	  local _config = love.filesystem.read(pfile)
	  if (_config) then
  	    local screenconfig =  json.decode(_config)
	    if screenconfig then
    	    changeScreenMode(screenconfig)
	    end
	  end
	end	
	getScreenMode()
end

function saveScreenMode(pfile)
  _table = {}
  _table.width, _table.height, _table.fullscreen,_table.vsync, _table.fsaa = love.graphics.getMode( )
  if pfile then
	return love.filesystem.write(pfile,json.encode(_table))
  else
    return false
  end
end

function testCollision(userdata1,userdata2,attribute,test1,test2) 
  if (userdata1[attribute]==test1 and userdata2[attribute]==test2) then
    return true
  elseif (userdata1[attribute]==test2 and userdata2[attribute]==test1) then
    return true
  end
  return false
end

function getCollisionObject(userdata1,userdata2,attribute,test) 
  if userdata1[attribute]==test then
    return userdata1
  elseif userdata2[attribute]==test then
    return userdata2
  end
  return nil
end

function generateId(ptype)
  if _G.counterid == nil then
    _G.counterid = 0
  end
  _G.counterid = _G.counterid + 1
  return ptype.._G.counterid
end