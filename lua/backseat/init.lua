--[[

Not automatically executed, but can be required with require("backseat")
If there was another file in the lua/backseat directory, it would be required with require("backseat.otherfile")
require loads a file once, and caches the return value. Running require on that file again will return the cached value but not execute the file's code.
unless you do `package.loaded["backseat"] = nil` to clear the cache.

The M (module) table is returned by the file, and is the module's public interface.

--]]
local M = {}

function M.setup()
    print("backseat setup")
end

return M
