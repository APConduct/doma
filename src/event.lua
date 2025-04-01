local love = require("love")

local event = {
    listeners = {},
    queue = {},
    focused_element = nil
}

event.listeners["keydown"] = {}
event.listeners["keypressed"] = {}
event.listeners["keyreleased"] = {}

event.listeners["mousemoved"] = {}
event.listeners["mousereleased"] = {}
event.listeners["mousepressed"] = {}

event.listeners["textinput"] = {}

function event.on(event_type, callback, priority)
    if not event.listeners[event_type] then
        event.listeners[event_type] = {}
    end

    table.insert(event.listeners[event_type], {
        callback = callback,
        priority = priority or 0
    })

    -- Sort the listeners by priority in descending order
    table.sort(event.listeners[event_type], function(a, b)
        return a.priority > b.priority
    end)
end

function event.off(event_type, callback)
    if event.listeners[event_type] then
        for i, listener in ipairs(event.listeners[event_type]) do
            if listener.callback == callback then
                table.remove(event.listeners[event_type], i)
                break
            end
        end
    end
end

function event.trigger(event_type, ...)
    if event.listeners[event_type] then
        local args = { ... }
        local event_data = {
            type = event_type,
            cancelled = false,
            stop_propagation = function()
                event_data.cancelled = true
            end
        }

        for _, listener in ipairs(event.listeners[event_type]) do
            listener.callback(event_data, unpack(args))
            if event_data.cancelled then
                break
            end
        end
        return not event_data.cancelled
    end
    return true
end

event.queue.queue_event = function(event_type, ...)
    local current_event = event.queue
    event.queue = {}

    for _, queued in ipairs(current_event) do
        event.trigger(queued.type, unpack(queued.args))
    end
end

return event
