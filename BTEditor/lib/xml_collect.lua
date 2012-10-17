---taken from http://lua-users.org/wiki/LuaXml
---added code to flatten and chaged regxp for attributes with "-" in the name
-----------------------------------------------------------------------------------------
-- LUA only XmlParser from Alexander Makeev
-----------------------------------------------------------------------------------------
XmlParser = {};

function XmlParser:ToXmlString(value)
	value = string.gsub (value, "&", "&amp;");		-- '&' -> "&amp;"
	value = string.gsub (value, "<", "&lt;");		-- '<' -> "&lt;"
	value = string.gsub (value, ">", "&gt;");		-- '>' -> "&gt;"
	--value = string.gsub (value, "'", "&apos;");	-- '\'' -> "&apos;"
	value = string.gsub (value, "\"", "&quot;");	-- '"' -> "&quot;"
	-- replace non printable char -> "&#xD;"
   	value = string.gsub(value, "([^%w%&%;%p%\t% ])",
       	function (c) 
       		return string.format("&#x%X;", string.byte(c)) 
       		--return string.format("&#x%02X;", string.byte(c)) 
       		--return string.format("&#%02d;", string.byte(c)) 
       	end);
	return value;
end

function XmlParser:FromXmlString(value)
  	value = string.gsub(value, "&#x([%x]+)%;",
      	function(h) 
      		return string.char(tonumber(h,16)) 
      	end);
  	value = string.gsub(value, "&#([0-9]+)%;",
      	function(h) 
      		return string.char(tonumber(h,10)) 
      	end);
	value = string.gsub (value, "&quot;", "\"");
	value = string.gsub (value, "&apos;", "'");
	value = string.gsub (value, "&gt;", ">");
	value = string.gsub (value, "&lt;", "<");
	value = string.gsub (value, "&amp;", "&");
	return value;
end
   
function XmlParser:ParseArgs(s)
  local arg = {}
  string.gsub(s, "([%w%-]+)=([\"'])(.-)%2", function (w, _, a)
    	arg[w] = self:FromXmlString(a);
  	end)
  return arg
end

function XmlParser:ParseXmlText(xmlText)
  local stack = {}
  local top = {Name=nil,Value=nil,Attributes={},ChildNodes={}}
  table.insert(stack, top)
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
    ni,j,c,label,xarg, empty = string.find(xmlText, "<(%/?)([%w:]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(xmlText, i, ni-1);
    if not string.find(text, "^%s*$") then
      top.Value=(top.Value or "")..self:FromXmlString(text);
    end
    if empty == "/" then  -- empty element tag
      table.insert(top.ChildNodes, {Name=label,Value=nil,Attributes=self:ParseArgs(xarg),ChildNodes={}})
    elseif c == "" then   -- start tag
      top = {Name=label, Value=nil, Attributes=self:ParseArgs(xarg), ChildNodes={}}
      table.insert(stack, top)   -- new level
      --log("openTag ="..top.Name);
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      --log("closeTag="..toclose.Name);
      top = stack[#stack]
      if #stack < 1 then
        error("XmlParser: nothing to close with "..label)
      end
      if toclose.Name ~= label then
        error("XmlParser: trying to close "..toclose.Name.." with "..label)
      end
      table.insert(top.ChildNodes, toclose)
    end
    i = j+1
  end
  local text = string.sub(xmlText, i);
  if not string.find(text, "^%s*$") then
      stack[#stack].Value=(stack[#stack].Value or "")..self:FromXmlString(text);
  end
  if #stack > 1 then
    error("XmlParser: unclosed "..stack[stack.n].Name)
  end
  return stack[1].ChildNodes[1];
end

--------------------------------------------------------------------------------

function xmlflat(_flattable,_xmlnode,id,level,parentid)
  for i,v in pairs(_xmlnode) do
    if type(v)=="table" and v.Name then
      local _tag = {}
	  _tag.Name = v.Name
	  id.id=id.id+1
	  _tag.Attributes = {}
	  _tag.__id = id.id
	  _tag.__level = level
	  _tag.__parentid = parentid
	  if v.Attributes then
	    for ii,vv in pairs(v.Attributes) do
          _tag.Attributes[ii]=vv
	    end
	  end
	  table.insert(_flattable,_tag)
	  if v.ChildNodes then
	     xmlflat(_flattable,v.ChildNodes,id,level+1,_tag.__id)
      end
	else
	  if type(v)=="table" then
	    xmlflat(_flattable,v,id,level+1,parentid)
	  end
	end
  end
end

function xmlcollect_and_flatten(s)
  local _xmltable = XmlParser:ParseXmlText(s)
  local _flattable = {}
  local _id = {id=0}
  xmlflat(_flattable,{_xmltable},_id,0,nil) --dirty hack
  return _flattable
end
