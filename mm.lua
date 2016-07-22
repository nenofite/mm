local INDENT = "   "
local CYCLE = "<cycle>"
local METATABLE = "<metatable>"

local STR_HALF = 30
local MAX_STR_LEN = STR_HALF * 2


local display, display_function, display_table, display_string


function display_function (el, indent, stack)
  return tostring (el)
end


function display_table (el, indent, stack)
  local next_indent = indent .. INDENT

  local contents = {}

  local mt = getmetatable (el)
  if mt ~= nil then
    local str_mt = display (mt, next_indent, stack)
    table.insert (contents, METATABLE .. " = " .. str_mt)
  end

  for k, v in pairs (el) do
    local str_k = display (k, next_indent, stack)
    local str_v = display (v, next_indent, stack)
    table.insert (contents, str_k .. " = " .. str_v)
  end

  if #contents == 0 then
    return "{}"
  else
    for i, v in ipairs (contents) do
      contents [i] = next_indent .. v
    end
    return "{\n" .. table.concat (contents, ",\n") .. "\n" .. indent .. "}"
  end
end


function display_string (el, indent, stack)
  if #el > MAX_STR_LEN then
    return string.format ('%q...%q',
      string.sub (el, 1, STR_HALF),
      string.sub (el, -STR_HALF))
  else
    return string.format ('%q', el)
  end
end


function display (el, indent, stack)
  if stack [el] then
    return CYCLE
  else
    stack [el] = true
  end

  local typ = type (el)
  local result
  if typ == 'function' then
    result = display_function (el, indent, stack)
  elseif typ == 'table' then
    result = display_table (el, indent, stack)
  elseif typ == 'string' then
    result = display_string (el, indent, stack)
  elseif typ == 'nil' then
    result = "nil"
  else
    result = tostring (el)
  end

  stack [el] = nil
  return result
end


function mm (el)
  if el == nil then
    print (nil)
  else
    print (display (el, '', {}))
  end
end
