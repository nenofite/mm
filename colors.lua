local function wrap (codes)
  local c27 = string.char (27)
  for k, v in pairs (codes) do
    codes [k] = c27 .. '[' .. tostring (v) .. 'm'
  end
  return codes
end


return wrap {
  e = 0, -- reset

  -- Text attributes.
  br = 1, -- bright
  di = 2, -- dim
  it = 3, -- italics
  un = 4, -- underscore
  bl = 5, -- blink
  re = 7, -- reverse
  hi = 8, -- hidden

  -- Text colors.
  k = 30, -- black
  r = 31, -- red
  g = 32, -- green
  y = 33, -- yellow
  b = 34, -- blue
  m = 35, -- magenta
  c = 36, -- cyan
  w = 37, -- white

  -- Background colors.
  _k = 40, -- black
  _r = 41, -- red
  _g = 42, -- green
  _y = 43, -- yellow
  _b = 44, -- blue
  _m = 45, -- magenta
  _c = 46, -- cyan
  _w = 47  -- white
}
