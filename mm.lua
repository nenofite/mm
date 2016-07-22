local INDENT = "   "
local CYCLE = "<cycle>"
local METATABLE = "<metatable>"

local STR_HALF = 30
local MAX_STR_LEN = STR_HALF * 2


local BOPEN, BSEP, BCLOSE = 1, 2, 3


-- Pieces are either frames (with brackets), sequences (no brackets), or 
-- strings.

-- Frames are displayed either short-form as { a = 1 } or long-form as
-- {
--   a = 1
-- }.

test_frame = {
  bracket = { "<A> {", ",", "}" },
  { "<metatable>", "=", "{}" },
  { "1", "=", "1" },
  {
    {
      bracket = { "{", ",", "}" },
      { "a","=","1" }
    },
    "=",
    "<table A>"
  },
  {
    '"foo dum"',
    "=",
    {
      bracket = { "{", ",", "}" },
      { 
        '"faoeliaorecihaolerreci"..."loalorechmmaoaoeiaoeiaoeiaoeiaoeiaoeiaoeiaoeiaoeiaoeikcoceiholer"', 
        "=", "true" },
      { '"lrocemolericoemaoeioei"..."lrocemolericoemaoeioei"', "=", "false" }
    }
  }
}

--~ local min_len
--~ 
--~ local display, display_frame, display_sequence, display_string
--~ local display_frame_short, display_frame_long
--~ local new_context, newline, newline_no_indent, write, space_here, space_newline


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

    -- Open and close brackets, plus a space for each.
    result = result + #piece.bracket[BOPEN] + #piece.bracket[BCLOSE] + 2

    -- A separator between each item, plus a space for each.
    result = result + (#piece - 1) * (#piece.bracket[BSEP] + 1)
  else
    -- This is a sequence.

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


function new_context ()
  return {
    functions_occur = {},
    functions_named = {},
    tables_occur = {},
    tables_named = {},

    prev_indent = '',
    next_indent = INDENT,
    line_len = 0,
    max_width = 80,

    result = ''
  }
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


return nil

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
