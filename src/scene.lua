local scene = {}
local doma = nil

function scene.init(doma_ref)
    doma = doma_ref
end

function scene.create()
    local new_scene = {
        elements = {},
        update_callbacks = nil,
        enter_callbacks = nil,
        exit_callbacks = nil,
    }

    function new_scene:on_update(callback)
        self.update_callback = callback
        return self
    end

    function new_scene:on_enter(callback)
        self.enter_callback = callback
        return self
    end

    function new_scene:on_exit(callback)
        self.exit_callback = callback
        return self
    end

    function new_scene:enter()
        if doma then
            doma.clear()
        end
        if self.enter_callback then
            self.enter_callback(self)
        end
    end

    function new_scene:exit()
        if self.exit_callback then
            self.exit_callback(self)
        end
    end

    function new_scene:update(dt)
        if self.update_callback then
            self.update_callback(dt)
        end
    end

    return new_scene
end

return scene
