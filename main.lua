FSM = require("LuaFSM/fsm")
controls = require("spelare_controls")

sp1 = {x = 10, y = 128, step = 20, img = nil,
    lights = {
        {x = 100, y = 20, enabled = false, timer = nil, img = nil},
        {x = 160, y = 20, enabled = false, timer = nil, img = nil},
        {x = 220, y = 20, enabled = false, timer = nil, img = nil},
        {x = 280, y = 20, enabled = false, timer = nil, img = nil},
    },
    lights_radius = 16,
    lights_border_color = {100, 100, 100, 255},
    lights_color = {0, 255, 0, 255},
    light_timer_max = 1, -- should be probably outside
}

-- light controls

function turn_off_light(spelare, light_index)
    spelare.lights[light_index].enabled = false
    spelare.lights[light_index].timer = nil
end

function turn_on_light(spelare, light_index)
    spelare.lights[light_index].enabled = true
    spelare.lights[light_index].timer = spelare.light_timer_max
end

function toggle_light(spelare, light_index)
    cur_state = spelare.lights[light_index].enabled
    if cur_state then
        turn_off_light(spelare, light_index)
    else
        turn_on_light(spelare, light_index)
    end
end

-- FSM actions that control the lights, nothing fancy
function action1()
    toggle_light(sp1, 1)
end
function action2()
    toggle_light(sp1, 2)
end
function action3()
    toggle_light(sp1, 3)
end
function action4()
    toggle_light(sp1, 4)
end

function action_wrong_input()
    print("Flashing the lights. Wrong input. Going to 'initial'")
    turn_off_light(sp1, 1)
    turn_off_light(sp1, 2)
end

function action_move()
    controls.advance_right(sp1)
end

lights_sp1_state_transition_table = {
-- old state   event      new state    action
    {'initial', 'input_right', 'q1', action1},

    {'q1', 'input_left', 'q2', action2},
    {'q1', 'input_right', 'q3', action_wrong_input},

    {'q2', 'input_up', 'q3', action3},
    {'q3', 'input_down', 'right_sequence', action4},

    {'right_sequence', 'idling', 'initial', action_move},
}

-- Init
function love.load(arg)
    -- load assets
    sp1.img = love.graphics.newImage("images/baby_kangaroo.png")
    sp1.lights[1].img = love.graphics.newImage("images/right_arrow_key.png")
    sp1.lights[2].img = love.graphics.newImage("images/left_arrow_key.png")
    sp1.lights[3].img = love.graphics.newImage("images/up_arrow_key.png")
    sp1.lights[4].img = love.graphics.newImage("images/down_arrow_key.png")

    road = {}
    road.img = love.graphics.newImage("images/road_itself.png")
    road.y = (love.graphics.getHeight() - road.img:getHeight()) / 2
    road.img_width = road.img:getWidth()

    -- Wind up our finite state machine
    lights_sp1_fsm = FSM.new(lights_sp1_state_transition_table)
    lights_sp1_fsm:set('initial')
end

-- Updating
function love.update(dt)
    if love.keyboard.isDown('escape', 'q') then
        love.event.push('quit')
    end

    if lights_sp1_fsm:get() == 'right_sequence' then
        lights_sp1_fsm:fire('idling')
    end

    if love.keyboard.isDown("n", 'right') then
        if not sp1.lights[1].enabled then
            lights_sp1_fsm:fire('input_right')
        end
    end
    if love.keyboard.isDown("h", 'left') then
        if not sp1.lights[2].enabled then
            lights_sp1_fsm:fire('input_left')
        end
    end
    if love.keyboard.isDown("c", 'up') then
        if not sp1.lights[3].enabled then
            lights_sp1_fsm:fire('input_up')
        end
    end
    if love.keyboard.isDown("t", 'down') then
        if not sp1.lights[4].enabled then
            lights_sp1_fsm:fire('input_down')
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
    love.graphics.setBackgroundColor(238, 195, 154)
    local cr, cg, cb, ca = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0, 255)

    love.graphics.print("kangaroo at (" .. tostring(sp1.x) .. ", " .. tostring(sp1.y) .. ")", 600, 10)
    love.graphics.print("Lights FSM state: " .. lights_sp1_fsm:get(), 600, 25)
    love.graphics.setColor(cr, cg, cb, ca)

    local x = 0
    local Xmax = love.graphics.getWidth()
    while x < Xmax do
        love.graphics.draw(road.img, x, road.y)
        x = x + road.img_width
    end

    love.graphics.draw(sp1.img, sp1.x, sp1.y)

    -- draw all the lights and a keymap
    for i, light in ipairs(sp1.lights) do
        local x = light.x
        local y = light.y
        local r = sp1.lights_radius

        -- lights border
        local cr, cg, cb, ca = love.graphics.getColor()
        love.graphics.setColor(sp1.lights_border_color)
        love.graphics.circle('line', x, y, r, 20)
        love.graphics.setColor(cr, cg, cb, ca)

        -- filling
        if sp1.lights[i].enabled then
            local cr, cg, cb, ca = love.graphics.getColor()
            love.graphics.setColor(sp1.lights_color)
            love.graphics.circle('fill', x, y, r - 2, 20)
            love.graphics.setColor(cr, cg, cb, ca)
        end

        -- keymap
        love.graphics.draw(
            light.img,
            x - light.img:getWidth() / 2 ,
            y + r + 4
        )

    end

end
