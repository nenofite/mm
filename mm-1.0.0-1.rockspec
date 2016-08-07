package = "mm"
version = "1.0.0-1"
source = {
   url = "git://github.com/nenofite/mm"
}
description = {
   summary = "A delicious Lua inspector",
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
