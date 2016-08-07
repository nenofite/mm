# mm: a delicious Lua inspector

Quickly understand your Lua data in a beautiful, tasty way.

![some delicious output from mm](screenshots/main.png)

## mm is not a serializer

There already exist [many](1) [great](2) [serializers](3) for Lua, which do 
amazing jobs of displaying Lua values in nicely-indented Lua syntax while 
handling messy tables, detecting cyclical references, and making you a cup of 
coffee on the side. These tools output Lua syntax, so you can stick the result 
back into a Lua interpreter and produce the same value.

That's not what mm does. The goal of mm is to produce comfortable, 
easily-understood, human-friendly output. By parting with the Lua syntax, mm 
can output values in a much friendlier way. That's why it's an inspector, not a 
serializer.

[1]: http://notebook.kulchenko.com/programming/serpent-lua-serializer-pretty-printer
[2]: https://github.com/gvx/Ser
[3]: http://lua-users.org/wiki/TableSerialization

## Features

- Human-friendly names for cyclical and redundant references.
- Syntax highlighting.
- Indentation and wrapping to fit nicely in a terminal.
- Easily extended to present custom data types.
- 100% delicious.

## How to use mm

Simply pass the function any Lua value to have it printed. For a quick demo, 
try:

```lua
require 'mm' (_G)
```
