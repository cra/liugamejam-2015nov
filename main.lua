FSM = require("LuaFSM/fsm")
controls = require("spelare_controls")

sp1 = {x = 10, y = 128, step = 48, img = nil,
    lights = {
        {x = 100, y = 20, enabled = false, timer = nil, img = nil},
        {x = 160, y = 20, enabled = false, timer = nil, img = nil},
        {x = 220, y = 20, enabled = false, timer = nil, img = nil},
        {x = 280, y = 20, enabled = false, timer = nil, img = nil},
    },
    lights_wrong = false,
    lights_wrong_timer = nil,
    lights_radius = 16,
    lights_border_color = {100, 100, 100, 255},
    lights_color_right = {0, 255, 0, 255},
    lights_color_wrong = {255, 0, 0, 255},
    light_timer_max = 0.3, -- should be probably outside
    lights_wrong_timer_max = 0.2, -- should be probably outside
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
    sp1.lights_wrong = true
    sp1.lights_wrong_timer = sp1.lights_wrong_timer_max
    for i, light in ipairs(sp1.lights) do
        turn_off_light(sp1, i)
    end
end

function action_move()
    controls.advance_right(sp1)
end

function action_do_nothing()
end

lights_sp1_state_transition_table = {
-- old state   event      new state    action
    {'initial', 'input_right', 'q1', action1},
    {'initial', 'idling', 'initial', action_do_nothing},
    {'initial', 'input_down', 'initial', action_wrong_input},
    {'initial', 'input_left', 'initial', action_wrong_input},

    {'q1', 'input_left', 'q2', action2},
    {'q1', 'idling', 'initial', action_wrong_input},
    {'q1', 'input_right', 'initial', action_wrong_input},
    {'q1', 'input_down', 'initial', action_wrong_input},
    {'q1', 'input_up', 'initial', action_wrong_input},

    {'q2', 'input_up', 'q3', action3},
    {'q2', 'idling', 'initial', action_wrong_input},
    {'q2', 'input_right', 'initial', action_wrong_input},
    {'q2', 'input_down', 'initial', action_wrong_input},
    {'q2', 'input_left', 'initial', action_wrong_input},

    {'q3', 'input_down', 'right_sequence', action4},
    {'q3', 'idling', 'initial', action_wrong_input},
    {'q3', 'input_right', 'initial', action_wrong_input},
    {'q3', 'input_up', 'initial', action_wrong_input},
    {'q3', 'input_left', 'initial', action_wrong_input},

    {'right_sequence', '*', 'initial', action_move},
}

function action_game_ends()
    love.audio.play(staying_alive)
end

game_state_transition_table = {
    {'in_game', 'finish', 'game_end', action_game_ends}
}

-- Init
function love.load(arg)
    -- load assets
    sp1.img = love.graphics.newImage("assets/baby_kangaroo.png")
    sp1.lights[1].img = love.graphics.newImage("assets/right_arrow_key.png")
    sp1.lights[2].img = love.graphics.newImage("assets/left_arrow_key.png")
    sp1.lights[3].img = love.graphics.newImage("assets/up_arrow_key.png")
    sp1.lights[4].img = love.graphics.newImage("assets/down_arrow_key.png")

    road = {}
    road.img = love.graphics.newImage("assets/road_itself.png")
    road.y = (love.graphics.getHeight() - road.img:getHeight()) / 2
    road.img_width = road.img:getWidth()

    the_end = {}
    the_end.img = love.graphics.newImage("assets/the_end.png")
    the_end.x = (love.graphics.getWidth() - the_end.img:getWidth()) / 2
    the_end.y = (love.graphics.getHeight() - the_end.img:getHeight()) / 2

    -- Wind up our finite state machine
    lights_sp1_fsm = FSM.new(lights_sp1_state_transition_table)
    lights_sp1_fsm:set('initial')

    game_fsm = FSM.new(game_state_transition_table)
    game_fsm:set('in_game')
    --game_fsm:set('finish')

    staying_alive = love.audio.newSource("assets/StayinAlive.ogg")
end

-- Updating
function love.update(dt)
    if love.keyboard.isDown('escape', 'q') then
        love.event.push('quit')
    end

    if game_fsm:get() == 'game_end' then
        -- no updates, we won.
        return
    end

    if lights_sp1_fsm:get() == 'right_sequence' then
        lights_sp1_fsm:fire('idling')
    end

    if love.keyboard.isDown("n", 'right') then
        if not sp1.lights[1].enabled then
            lights_sp1_fsm:fire('input_right')
        end
    elseif love.keyboard.isDown("h", 'left') then
        if not sp1.lights[2].enabled then
            lights_sp1_fsm:fire('input_left')
        end
    elseif love.keyboard.isDown("c", 'up') then
        if not sp1.lights[3].enabled then
            lights_sp1_fsm:fire('input_up')
        end
    elseif love.keyboard.isDown("t", 'down') then
        if not sp1.lights[4].enabled then
            lights_sp1_fsm:fire('input_down')
        end
    else
        -- if all lights are off -- fire idling
        if not (sp1.lights[1].enabled or sp1.lights[2].enabled or sp1.lights[3].enabled or sp1.lights[4].enabled) then
            lights_sp1_fsm:fire('idling')
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

    if sp1.lights_wrong then
        sp1.lights_wrong_timer = sp1.lights_wrong_timer - (1 * dt)
        if sp1.lights_wrong_timer < 0 then
            sp1.lights_wrong_timer = 0
            sp1.lights_wrong = false
        end
    end

    if sp1.x + sp1.step > (love.graphics.getWidth() - sp1.img:getWidth()) then
        game_fsm:fire('finish')
    end

end

-- Drawing
function love.draw(dt)
    love.graphics.setBackgroundColor(238, 195, 154)

    if game_fsm:get() == "in_game" then
        local cr, cg, cb, ca = love.graphics.getColor()
        love.graphics.setColor(0, 0, 0, 255)

        love.graphics.print("kangaroo at (" .. tostring(sp1.x) .. ", " .. tostring(sp1.y) .. ")", 600, 10)
        love.graphics.print("Lights FSM: " .. lights_sp1_fsm:get() ..", " .. "Game FSM: " .. game_fsm:get(), 600, 25)
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
            if sp1.lights_wrong then
                local cr, cg, cb, ca = love.graphics.getColor()
                love.graphics.setColor(sp1.lights_color_wrong)
                love.graphics.circle('fill', x, y, r - 2, 20)
                love.graphics.setColor(cr, cg, cb, ca)
            elseif sp1.lights[i].enabled then
                local cr, cg, cb, ca = love.graphics.getColor()
                love.graphics.setColor(sp1.lights_color_right)
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

    if game_fsm:get() == "game_end" then
        love.graphics.draw(the_end.img, the_end.x, the_end.y)
    end

end
