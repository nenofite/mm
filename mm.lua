local METATABLE = "<metatable>"
local INDENT = "   "

local BOPEN, BSEP, BCLOSE = 1, 2, 3

local STR_HALF = 30
local MAX_STR_LEN = STR_HALF * 2

local FUNCTION_NAMES = {
  "Theodora",
  "Lizzette",
  "Eleanora",
  "Alexandra",
  "Dulce",
  "Arletta",
  "Vanna",
  "Laurette",
  "Tamara",
  "Shonna",
  "Ione",
  "Ursula",
  "Serena",
  "Elza",
  "Estrella",
  "Jerrica",
  "Ranae",
  "Chieko",
  "Terra",
  "Candelaria"
}

local TABLE_NAMES = {
  "Lou",
  "Oswaldo",
  "Ruben",
  "Jewel",
  "Hilton",
  "Mitchel",
  "Frederic",
  "Adolph",
  "Lincoln",
  "Joaquin",
  "Eliseo",
  "Randell",
  "Burt",
  "Felipe",
  "Brock",
  "Dorian",
  "Huey",
  "Duane",
  "Lynwood",
  "Claude"
}


--
-- Namers
--


function new_namer (list)
  local index = 1
  local suffix = 1
  return function ()
    local result = list [index]

    if suffix > 1 then
      result = result .. " " .. tostring (suffix)
    end

    index = index + 1
    if index > #list then
      index = 1
      suffix = suffix + 1
    end

    return result
  end
end


--
-- Context
--


local function new_context ()
  return {
    named = {},
    occur = {},

    next_function_name = new_namer (FUNCTION_NAMES),
    next_table_name = new_namer (TABLE_NAMES),

    prev_indent = '',
    next_indent = INDENT,
    line_len = 0,
    max_width = 80,

    result = ''
  }
end


--
-- Translating into pieces
--

-- Translaters take any Lua value and create pieces to represent them.

-- Some values should only be serialized once, both to prevent cycles and to 
-- prevent redundancy. Or in other cases, these values cannot be serialized 
-- (such as functions) but if they appear multiple times we want to express 
-- that they are the same.
--
-- When a translater encounters such a value for the first time, it is 
-- registered in the context in `occur`. If it is serializable, like a table, 
-- then it is translated as usual. However, an additional `id` field in the 
-- frame points to the original table. If it is unserializable, like a 
-- function, then it is put in a `ref` field of a plain table.
--
-- When a translater encounters such a value again, for the second, third, 
-- fourth, etc. time, then it requests and assigns a name to that value. Then 
-- it puts the value into the `ref` field of a plain table, without even trying 
-- to serialize it.
--
-- In the cleaning stage, these `id` fields and `ref` fields are replaced with 
-- their names.

local translaters = {}
local translate


function translate (val, ctx)
  -- Try to find a type-specific translater.
  local by_type = translaters [type (val)]

  if by_type then
    -- If there is a type-specific translater, call it.
    return by_type (val, ctx)
  else
    -- Otherwise just return the built-in tostring.
    return tostring (val)
  end
end


translaters ['function'] = function (val, ctx)
  -- Check whether we've already encountered this function.
  if ctx.occur [val] then
    -- We have; give it a name.
    ctx.named [val] = ctx.next_function_name ()
  else
    -- We haven't; mark it as encountered.
    ctx.occur [val] = true
  end

  -- Return the unserialized function.
  return { ref = val }
end


function translaters.table (val, ctx)
  -- Check whether we've already encountered this table.
  if ctx.occur [val] then
    -- We have; give it a name.
    ctx.named [val] = ctx.next_table_name ()

    -- Return the unserialized table.
    return { ref = val }
  else
    -- We haven't; mark it as encountered.
    ctx.occur [val] = true

    -- Construct the frame for this table.
    local result = {
      id = val,
      bracket = { "{", ",", "}" }
    }

    -- Represent the metatable, if present.
    local mt = getmetatable (val)
    if mt then
      table.insert (result, { METATABLE, "=", translate (mt, ctx) })
    end

    -- Represent the contents.
    for k, v in pairs (val) do
      table.insert (result, { translate (k, ctx), "=", translate (v, ctx) })
    end

    return result
  end
end


function translaters.string (val, ctx)
  local result
  if #val <= MAX_STR_LEN then
    result = string.format ('%q', val)
  else
    result = string.format ('%q...%q',
      string.sub (val, 1, STR_HALF),
      string.sub (val, -STR_HALF))
  end

  result = string.gsub (result, '\n', 'n')
  return result
end


--
-- Cleaning pieces
--


local function clean (piece, ctx)
  if type (piece) == 'table' then
    -- Check if it's a ref.
    if piece.ref then
      local name = ctx.named [piece.ref]
      if name then
        return string.format ('<%s %s>', type (piece.ref), name)
      else
        return string.format ('<%s>', type (piece.ref))
      end

    -- Check if it's a frame with an id.
    elseif piece.id then
      local name = ctx.named [piece.id]
      if name then
        -- Update the open bracket to show the name.
        piece.bracket[BOPEN] = string.format ('<%s %s> %s',
          type (piece.id),
          name,
          piece.bracket[BOPEN])
      end

      -- Strip out the id field.
      piece.id = nil

      -- Clean each child.
      for i, child in ipairs (piece) do
        piece [i] = clean (child, ctx)
      end
      return piece

    -- Otherwise it's a sequence, so clean each child.
    else
      for i, child in ipairs (piece) do
        piece [i] = clean (child, ctx)
      end
      return piece
    end
  else
    return piece
  end
end


--
-- Displaying pieces
--


-- Pieces are either frames (with brackets), sequences (no brackets), or 
-- strings.

-- Frames are displayed either short-form as { a = 1 } or long-form as
-- {
--   a = 1
-- }.


-- Declare all the local functions first, so they can refer to each other.
local min_len, display, display_frame, display_sequence, display_string,
      display_frame_short, display_frame_long, newline, newline_no_indent, 
      write, space_here, space_newline


-- Dispatch based on the piece's type.
function display (piece, ctx)
  if type (piece) == 'string' then
    -- String.
    return display_string (piece, ctx)
  elseif piece.bracket then
    -- Frame.
    return display_frame (piece, ctx)
  else
    -- Sequence.
    return display_sequence (piece, ctx)
  end
end


-- Display a frame.
function display_frame (frame, ctx)
  if #frame == 0 then
    -- If the frame is empty, just display it like a string.
    local str = frame.bracket[BOPEN] .. frame.bracket[BCLOSE]
    return display_string (str, ctx)
  end

  local ml = min_len (frame)

  -- Try to fit the frame short-form on this line.
  if ml <= space_here (ctx) then
    return display_frame_short (frame, ctx)

  -- Otherwise try to fit it short-form on the next line.
  elseif ml <= space_newline (ctx) then
    newline (ctx)
    return display_frame_short (frame, ctx)

  -- Otherwise display it long-form.
  else
    return display_frame_long (frame, ctx)
  end
end


function display_frame_short (frame, ctx)
  -- Short-form frames never wrap onto new lines, so we don't need to do any 
  -- length checking (it's already been done for us).

  -- Write the open bracket.
  write (frame.bracket[BOPEN] .. " ", ctx)

  -- Display the first child.
  display (frame [1], ctx)

  -- Display the remaining children.
  for i = 2, #frame do
    local child = frame [i]

    -- Write the separator.
    write (frame.bracket[BSEP] .. " ", ctx)

    -- Display the child.
    display (child, ctx)
  end

  -- Write the close bracket.
  write (" " .. frame.bracket[BCLOSE], ctx)
end


function display_frame_long (frame, ctx)
  -- Remember the original value of next_indent.
  local old_old_indent = ctx.prev_indent
  local old_indent = ctx.next_indent

  -- Display the open bracket as a string piece, so it will wrap if needed.
  display_string (frame.bracket[BOPEN], ctx)

  -- Increase the indentation.
  ctx.prev_indent = old_indent
  ctx.next_indent = old_indent .. INDENT

  -- For all but the last child...
  for i = 1, #frame - 1 do
    local child = frame [i]

    -- Start a new line with old indentation.
    newline_no_indent (ctx)
    write (old_indent, ctx)

    -- Display the child.
    display (child, ctx)

    -- Write the separator.
    write (frame.bracket[BSEP], ctx)
  end

  -- For the last child...
  do
    local child = frame [#frame]

    -- Start a new line with old indentation.
    newline_no_indent (ctx)
    write (old_indent, ctx)

    -- Display the child.
    display (child, ctx)
    -- No separator.
  end

  -- Write the close bracket.
  newline_no_indent (ctx)
  write (old_old_indent, ctx)
  write (frame.bracket[BCLOSE], ctx)

  -- Return to the old indentation.
  ctx.prev_indent = old_old_indent
  ctx.next_indent = old_indent
end


function display_sequence (piece, ctx)
  if #piece > 0 then
    -- Display the first child.
    display (piece [1], ctx)

    -- For each following children:
    for i = 2, #piece do
      local child = piece [i]

      -- If there's room, write a space.
      if space_here (ctx) >= 1 then
        write (" ", ctx)
      end

      -- Then display the child.
      display (child, ctx)
    end
  end
end


function display_string (piece, ctx)
  local ml = min_len (piece)

  -- Check whether the string will fit on this line.
  if ml <= space_here (ctx) then
    -- It will fit; write it.
    write (piece, ctx)

  -- It won't fit; try it on the next line.
  elseif ml <= space_newline (ctx) then
    newline (ctx)
    write (piece, ctx)

  -- It won't fit on either line; write it on the original line (and let it 
  -- overflow).
  else
    write (piece, ctx)
  end
end


-- The minimum length to display this piece, if it is placed all on one line.
function min_len (piece, ctx)
  -- For strings, simply return their length.
  if type (piece) == 'string' then
    return #piece
  end

  -- Otherwise, we have some calculations to do.
  local result = 0

  if piece.bracket then
    -- This is a frame.

    -- If it's an empty frame, just the open and close brackets.
    if #piece == 0 then
      return #piece.bracket[BOPEN] + #piece.bracket[BCLOSE]
    end

    -- Open and close brackets, plus a space for each.
    result = result + #piece.bracket[BOPEN] + #piece.bracket[BCLOSE] + 2

    -- A separator between each item, plus a space for each.
    result = result + (#piece - 1) * (#piece.bracket[BSEP] + 1)
  else
    -- This is a sequence.

    -- If it's an empty sequence, then nothing.
    if #piece == 0 then
      return 0
    end

    -- A single space between each item.
    result = result + (#piece - 1)
  end

  -- For both frames and sequences:
  -- Find the minimum length of each child.
  for _, child in ipairs (piece) do
    result = result + min_len (child, ctx)
  end

  return result
end


function newline (ctx)
  ctx.result = ctx.result .. "\n"
  ctx.line_len = 0
  write (ctx.next_indent, ctx)
end


function newline_no_indent (ctx)
  ctx.result = ctx.result .. "\n"
  ctx.line_len = 0
end


function write (str, ctx)
  ctx.result = ctx.result .. str
  ctx.line_len = ctx.line_len + #str
end


function space_here (ctx)
  return math.max (0, ctx.max_width - ctx.line_len)
end


function space_newline (ctx)
  return math.max (0, ctx.max_width - #ctx.next_indent)
end


--
-- Main function
--


return function (val)
  if val == nil then
    print (nil)
  else
    local ctx = new_context ()
    local piece = translate (val, ctx)
    piece = clean (piece, ctx)
    display (piece, ctx)
    print (ctx.result)
  end
end

-- example frame
--[[

to show:
<A> {
  <metatable> = {},
  1 = 1,
  { a = 1 } = <table A>,
  "foo dum" = {
    "faoeliaorecihaolerreci"..."loalorechmmkcoceiholer" = true,
    "lrocemolericoemaoeioei"..."lrocemolericoemaoeioei" = false
  }
}

frame:

{
  bracket = { "<A> {", ", ", "}" },
  { "<metatable>", "=", "{}" },
  { "1", "=", "1" },
  { { [brackets], { "a","=","1" } }, "=", "<table A>" },
  { '"foo dum"', "=", { [brackets],
    { '"faoeliaorecihaolerreci"..."loalorechmmkcoceiholer"', "=", "true" },
    { '"lrocemolericoemaoeioei"..."lrocemolericoemaoeioei"', "=", "false" }
  } }
}

]]
