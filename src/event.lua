local love = require("love")

local event = {
    listeners = {}
}

event.listeners["keydown"] = {}
event.listeners["keypressed"] = {}
event.listeners["keyreleased"] = {}

event.listeners["mousemoved"] = {}
event.listeners["mousereleased"] = {}
event.listeners["mousepressed"] = {}

event.listeners["textinput"] = {}

function event.on(event_type, callback)
    if not event.listeners[event_type] then
        event.listeners[event_type] = {}
    end
    table.insert(event.listeners[event_type], callback)
end

function event.trigger(event_type, ...)
    if event.listeners[event_type] then
        for _, callback in ipairs(event.listeners[event_type]) do
            callback(...)
        end
    end
end

return event
