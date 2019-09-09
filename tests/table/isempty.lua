local tablex = require('pl.tablex')

-- This file is fixure for luajit2's table.isempty function.
-- This function might not be same as original table.isempty implementation,
-- but it'ss OK beucase our function will use as just checking table size is zero or not
local function isempty(tbl)
  return tablex.size(tbl) == 0
end

return isempty
