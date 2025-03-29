local love = require("love")
local backend = {}

if love then
    backend.graphics = {
        print = function() end,
        rectangle = function() end,
        set_color = function() end
    }
    backend.mouse = {
        is_down = function() end,
    }
end

return backend
