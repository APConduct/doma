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
            -- Handle regular tweens
            if not anim.keyframes then
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
                            anim.target.props[anim.property][i] = anim.from[i] +
                            (anim.to[i] - anim.from[i]) * eased_progress
                        end
                    end
                end

                if anim.on_update then
                    anim.on_update(anim.target, eased_progress)
                end
            else
                -- Handle keyframe animations
                local normalizedTime = (anim.elapsed / anim.duration) % 1
                if normalizedTime == 0 and anim.elapsed > 0 then normalizedTime = 1 end

                -- Find the keyframes that bracket the current time
                local prevKeyframe = nil
                local nextKeyframe = nil

                for i, kf in ipairs(anim.keyframes) do
                    if kf.time <= normalizedTime then
                        prevKeyframe = kf
                    end
                    if kf.time >= normalizedTime and not nextKeyframe then
                        nextKeyframe = kf
                    end
                end

                -- If at or past the last keyframe, use the last one
                if not nextKeyframe and prevKeyframe then
                    nextKeyframe = prevKeyframe
                end

                -- If before the first keyframe, use the first one
                if not prevKeyframe and nextKeyframe then
                    prevKeyframe = nextKeyframe
                end

                -- If we have both keyframes
                if prevKeyframe and nextKeyframe then
                    local segmentDuration = nextKeyframe.time - prevKeyframe.time
                    local segmentProgress = 0

                    if segmentDuration > 0 then
                        segmentProgress = (normalizedTime - prevKeyframe.time) / segmentDuration
                    end

                    local easingFunc = EASING["linear"]
                    if type(anim.easing) == "function" then
                        easingFunc = anim.easing
                    elseif type(anim.easing) == "string" and EASING[anim.easing] then
                        easingFunc = EASING[anim.easing]
                    end

                    local easedProgress = easingFunc(segmentProgress)

                    -- Calculate the interpolated value
                    if type(prevKeyframe.value) == "number" and type(nextKeyframe.value) == "number" then
                        -- Numeric values
                        local value = prevKeyframe.value + (nextKeyframe.value - prevKeyframe.value) * easedProgress
                        anim.target.props[anim.property] = value
                    elseif type(prevKeyframe.value) == "table" and type(nextKeyframe.value) == "table" then
                        -- Table values (like colors)
                        if not anim.target.props[anim.property] then
                            anim.target.props[anim.property] = {}
                        end

                        for i = 1, #prevKeyframe.value do
                            if i <= #nextKeyframe.value and
                                type(prevKeyframe.value[i]) == "number" and
                                type(nextKeyframe.value[i]) == "number" then
                                anim.target.props[anim.property][i] =
                                    prevKeyframe.value[i] +
                                    (nextKeyframe.value[i] - prevKeyframe.value[i]) *
                                    easedProgress
                            end
                        end
                    end

                    if anim.on_update then
                        anim.on_update(anim.target, easedProgress)
                    end
                end
            end

            -- Handle completion and repeats for both types of animations
            if anim.elapsed >= anim.duration then
                if anim.repeat_count == -1 or (anim.repeat_count > 0 and anim.current_repeat < anim.repeat_count) then
                    -- Handle repeating animation
                    if anim.repeat_count > 0 then
                        anim.current_repeat = anim.current_repeat + 1
                    end
                    anim.elapsed = anim.elapsed - anim.duration
                    if anim.repeat_delay > 0 then
                        anim.elapsed = -anim.repeat_delay
                    end
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
    local easing = options.easing or "linear"

    -- Convert easing string to function if needed
    local easing_func = type(easing) == "function" and easing or EASING[easing] or EASING.linear

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
        easing = easing_func, -- Add the easing function here
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
