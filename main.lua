FSM = require("LuaFSM/fsm")
controls = require("spelare_controls")

sp1 = {x = 20, y = 100, img = nil,
    lights = {
            {x = 100, y = 10, enabled = false, timer = nil},
            {x = 140, y = 10, enabled = false, timer = nil},
            {x = 180, y = 10, enabled = false, timer = nil},
            {x = 220, y = 10, enabled = false, timer = nil},
        },
    lights_radius = 10,
    lights_color = {0, 255, 0, 255},
    light_timer_max = 1
}

function love.load(arg)
    sp1.img = love.graphics.newImage("images/baby_kangaroo.png")
end

function toggle_light(spelare, light_index)
    cur_state = spelare.lights[light_index].enabled
    spelare.lights[light_index].enabled = not spelare.lights[light_index].enabled
    spelare.lights[light_index].timer = spelare.light_timer_max
end

-- Updating
function love.update(dt)
    if love.keyboard.isDown('escape', 'q') then
        love.event.push('quit')
    end

    if love.keyboard.isDown("n", 'right') then
        controls.advance_right(sp1)
        if not sp1.lights[1].enabled then
            toggle_light(sp1, 1)
        end
    end
    if love.keyboard.isDown("h", 'left') then
        controls.advance_left(sp1)
        if not sp1.lights[2].enabled then
            toggle_light(sp1, 2)
        end
    end

    if love.keyboard.isDown("c", 'up') then
        sp1.y = sp1.y - 10;
        if not sp1.lights[3].enabled then
            toggle_light(sp1, 3)
        end
    end
    if love.keyboard.isDown("t", 'down') then
        sp1.y = sp1.y + 10;
        if not sp1.lights[4].enabled then
            toggle_light(sp1, 4)
        end
    end

    if first_light_enabled then
        first_light_timer = first_light_timer - (1 * dt)
        if first_light_timer <= 0 then
            first_light_enabled = false
            first_light_timer = 0
        end
    end

    for i, light in ipairs(sp1.lights) do
        if light.enabled then
            light.timer = light.timer - (1 * dt)
            if light.timer < 0 then
                toggle_light(sp1, i)
            end
        end
    end

end

-- Drawing
function love.draw(dt)
    love.graphics.print("Run baby kangaroo, run", 300, 10)
    --love.graphics.setBackgroundColor(100, 100, 100)
    love.graphics.print("kangaroo at (" .. tostring(sp1.x) .. ", " .. tostring(sp1.y) .. ")", 300, 25)

    love.graphics.draw(sp1.img, sp1.x, sp1.y)
    
    for i = 1, 4 do
        local x = sp1.lights[i].x
        local r = sp1.lights_radius
        love.graphics.circle('line', x, 10, r, 20)

        if sp1.lights[i].enabled then
            local cr, cg, cb, ca = love.graphics.getColor()
            love.graphics.setColor(sp1.lights_color)
            love.graphics.circle('fill', x, 10, r - 2, 20)
            love.graphics.setColor(cr, cg, cb, ca)
        end
    end

end
