local animation = {
    active = {},
    next_id = 1
}

local EASING = {
    linear = function(t) return t end,

    in_quad = function(t) return t * t end,
    out_quad = function(t) return t * (2 - t) end,
    in_out_quad = function(t)
        t = t * 2
        if t < 1 then return 0.5 * t * t end
        t = t - 1
        return -0.5 * (t * (t - 2) - 1)
    end,

    in_cubic = function(t) return t * t * t end,
    out_cubic = function(t) return (t - 1) * (t - 1) * (t - 1) + 1 end,
    in_out_cubic = function(t)
        t = t * 2
        if t < 1 then return 0.5 * t * t * t end
        t = t - 2
        return 0.5 * (t * t * t + 2)
    end,

    in_elastic = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return -math.pow(2, 10 * (t - 1)) * math.sin((t - 1.1) * 5 * math.pi)
    end,

    out_elastic = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return math.pow(2, -10 * t) * math.sin((t - 0.1) * 5 * math.pi) + 1
    end,

    in_out_elastic = function(t)
        if t < 0.5 then
            return 0.5 * math.sin(13 * math.pi / 2 * (2 * t)) * math.pow(2, 10 * ((2 * t) - 1))
        else
            return 0.5 * (math.sin(-13 * math.pi / 2 * ((2 * t - 1) + 1)) * math.pow(2, -10 * (2 * t - 1)) + 2)
        end
    end
}

function animation.tween(target, property, from, to, duration, options)
    options = options or {}
    local easing = options.easing or "linear"
    local delay = options.delay or 0
    local easing_func = EASING[easing] or EASING.linear

    local id = animation.next_id
    animation.next_id = animation.next_id + 1

    animation.active[id] = {
        target = target,
        property = property,
        from = from,
        to = to,
        duration = duration,
        elapsed = -delay,
        easing = easing_func,
        on_complete = options.on_complete,
        on_update = options.on_update,
        repeat_count = options.repeat_count or 0,
        repeat_delay = options.repeat_delay or 0,
        current_repeat = 0,
        completed = false
    }

    return id
end

function animation.cancel(id)
    animation.active[id] = nil
end

function animation.update(dt)
    for id, anim in pairs(animation.active) do
        anim.elapsed = anim.elapsed + dt

        if anim.elapsed >= 0 then
            local progress = math.min(1, anim.elapsed / anim.duration)
            local eased_progress = anim.easing(progress)

            if type(anim.from) == "number" and type(anim.to) == "number" then
                -- Numeric values
                local value = anim.from + (anim.to - anim.from) * eased_progress
                anim.target.props[anim.property] = value
            elseif type(anim.from) == "table" and type(anim.to) == "table" then
                -- Table values (like colors)
                if not anim.target.props[anim.property] then
                    anim.target.props[anim.property] = {}
                end

                for i = 1, #anim.from do
                    if type(anim.from[i]) == "number" and type(anim.to[i]) == "number" then
                        anim.target.props[anim.property][i] = anim.from[i] + (anim.to[i] - anim.from[i]) * eased_progress
                    end
                end
            end

            if anim.on_update then
                anim.on_update(anim.target, eased_progress)
            end

            if progress >= 1 then
                if anim.repeat_count > 0 and anim.current_repeat < anim.repeat_count then
                    -- Handle repeating animation
                    anim.current_repeat = anim.current_repeat + 1
                    anim.elapsed = -anim.repeat_delay
                else
                    -- Mark as completed
                    anim.completed = true
                    if anim.on_complete then
                        anim.on_complete(anim.target)
                    end
                    animation.active[id] = nil
                end
            end
        end
    end
end

-- Keyframe animation system
function animation.keyframes(target, property, keyframes, options)
    options = options or {}
    local duration = options.duration or 1
    local delay = options.delay or 0

    -- Sort keyframes by time
    table.sort(keyframes, function(a, b) return a.time < b.time end)

    local id = animation.next_id
    animation.next_id = animation.next_id + 1

    animation.active[id] = {
        target = target,
        property = property,
        keyframes = keyframes,
        duration = duration,
        elapsed = -delay,
        on_complete = options.on_complete,
        on_update = options.on_update,
        repeat_count = options.repeat_count or 0,
        repeat_delay = options.repeat_delay or 0,
        current_repeat = 0,
        completed = false
    }

    return id
end

return animation
