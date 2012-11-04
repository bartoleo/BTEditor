assetloader =  {}
assetloader.initialized = false
assetloader.assets =  {}

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
      if func==require then
        targettable[v:sub(1, -5)] = func(path .. "/" .. v:sub(1, -5))
      else
        targettable[v:sub(1, -5)] = func(path .. "/" .. v)
      end
    end
  end
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

function lazyload(pkey,pdir,pextensions,pfunction)
  local f
  for _,v in pairs(pextensions) do
    if love.filesystem.exists( pdir.."/"..pkey..v  ) then
      f = pfunction( pdir.."/"..pkey..v )
      break
    else
      local filesearch=recursiveSearchFile(pdir.."/",pkey..v)
      if filesearch ~= "" then
        f = pfunction( filesearch )
        break
      end
    end
  end
  return f
end

function addAssetLoader(pTableName,pPath,pExtensions,pFunction)
  if _G[pTableName] == nil then
    _G[pTableName] = {}
  end
  _G[pTableName].__path = pPath
  _G[pTableName].__extensions = pExtensions
  _G[pTableName].__function = pFunction
  setmetatable(_G[pTableName], {__index = function(t,k)
    local f = lazyload(k,t.__path,t.__extensions,t.__function)
    rawset(t, k, f)
    return f
  end })
  if assetloader.assets[pTableName]==nil then
    assetloader.assets[pTableName]=true
  end
end

if fonts == nil then
  fonts = {}
end

-- lazy font loading
setmetatable(fonts, {__index = function(t,k)
  local s = split(k,",")
  local f
  local ss = tonumber(s[2])
  if (s[1]=="" or s[1]==nil) then
    f = love.graphics.newFont(ss)
  else
    f = love.graphics.newFont(s[1],ss)
  end
  rawset(t, k, f)
  return f
end })

addAssetLoader("images","images",{".png",".jpg",".gif"},love.graphics.newImage)
addAssetLoader("gamestates","states",{".lua"},require)
addAssetLoader("classes","classes",{".lua"},require)
addAssetLoader("sounds","sounds",{".ogg"},love.sound.newSoundData)
addAssetLoader("musics","music",{".ogg"},love.audio.newSource)

function assetloader.load()
  loadfromdir(gamestates, "states", "lua", require)
  loadfromdir(classes, "classes", "lua", require)
  loadfromdir(images, "images/autoload", "png", love.graphics.newImage)
  loadfromdir(sounds, "sounds/autoload", "ogg", love.sound.newSoundData)
  loadfromdir(musics, "music/autoload", "ogg", love.audio.newSource)
  assetloader.initialized = true
end

function assetloader.reload()
  for k,v in pairs(assetloader.assets) do
    if _G[k] and _G[k].__function~=require then
      for kk,vv in pairs(_G[k]) do
        if string.sub(kk,2)~="__" then
          local f = lazyload(k,_G[k].__path,_G[k].__extensions,_G[k].__function)
          if f then
            rawset(_G[k], k, f)
          end
        end
      end
    end
  end
end