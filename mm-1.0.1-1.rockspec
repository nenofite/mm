package = "mm"
version = "1.1.0-1"
source = {
   url = "git://github.com/nenofite/mm",
   tag = "v1.1.0"
}
description = {
   summary = "A delicious Lua inspector",
   detailed = [[
mm writes beautifully indented and color-coded representations of Lua data so 
that you can quickly and clearly understand what's going on. mm doesn't bore 
you with table memory addresses. Instead, mm gives each table a friendly, 
memorable name, so you can instantly make sense of what points where.]],
   license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      mm = "mm.lua"
   }
}
