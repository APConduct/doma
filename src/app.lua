local love = require("love")
local doma = nil



local app = {}

function app.init(doma_ref)
    doma = doma_ref
end

-- Default configuration
local default_config = {
    title = "DOMA Application",
    width = 800,
    height = 600,
    background_color = { 0.2, 0.2, 0.2, 1 },
    vsync = true,
    resizable = true,
    exit_on_escape = true
}

function app.create(config)
    if doma then
        local event = doma.event
        local new_app = {
            config = doma.utils.merge(default_config, config or {}),
            scenes = {},
            current_scene = nil,
            callbacks = {
                load = nil,
                update = nil,
                draw = nil,
                quit = nil,
                resize = nil,
                focus = nil
            }
        }

        -- Scene management
        function new_app:add_scene(name, scene)
            self.scenes[name] = scene
            return self
        end

        function new_app:set_scene(name)
            if self.scenes[name] then
                if self.current_scene and self.scenes[self.current_scene] then
                    self.scenes[self.current_scene]:exit()
                end
                self.current_scene = name
                self.scenes[name]:enter()
            end
            return self
        end

        -- Callback setters
        function new_app:on_load(callback)
            self.callbacks.load = callback
            return self
        end

        function new_app:on_update(callback)
            self.callbacks.update = callback
            return self
        end

        function new_app:on_draw(callback)
            self.callbacks.draw = callback
            return self
        end

        function new_app:on_quit(callback)
            self.callbacks.quit = callback
            return self
        end

        function new_app:on_resize(callback)
            self.callbacks.resize = callback
            return self
        end

        function new_app:on_focus(callback)
            self.callbacks.focus = callback
            return self
        end

        -- Run the application
        function new_app:run()
            -- Set up LÖVE callbacks
            love.load = function()
                love.window.setMode(self.config.width, self.config.height, {
                    vsync = self.config.vsync,
                    resizable = self.config.resizable
                })
                love.window.setTitle(self.config.title)
                if self.callbacks.load then self.callbacks.load() end
            end

            love.update = function(dt)
                doma.update(dt)
                if self.current_scene then
                    self.scenes[self.current_scene]:update(dt)
                end
                if self.callbacks.update then self.callbacks.update(dt) end
            end

            love.draw = function()
                if self.config.background_color then
                    love.graphics.setBackgroundColor(unpack(self.config.background_color))
                end
                doma.draw()
                if self.callbacks.draw then self.callbacks.draw() end
            end

            love.quit = function()
                if self.callbacks.quit then
                    return self.callbacks.quit()
                end
            end

            love.resize = function(w, h)
                if self.callbacks.resize then
                    self.callbacks.resize(w, h)
                end
            end

            love.mousepressed = function(x, y, button)
                event.trigger("mousepressed", x, y, button)
            end

            love.mousemoved = function(x, y, dx, dy)
                event.trigger("mousemoved", x, y, dx, dy)
            end

            love.mousereleased = function(x, y, button)
                event.trigger("mousereleased", x, y, button)
            end

            love.keypressed = function(key)
                if key == "escape" and self.config.exit_on_escape then
                    love.event.quit()
                end
                event.trigger("keypressed", key)
            end

            love.textinput = function(t)
                event.trigger("textinput", t)
            end

            return self
        end

        return new_app
    end
end

return app
