--sp1 = Spelare:new{x = 20, y = 100}
sp1 = {x = 20, y = 100, img = nil,
    lights = {
            {x = 260, y = 10, enabled = false},
            {x = 300, y = 10, enabled = false},
            {x = 340, y = 10, enabled = true},
            {x = 380, y = 10, enabled = false},
        },
    lights_radius = 10,
    lights_color = {0, 255, 0, 255}
}

function love.load(arg)
    sp1.img = love.graphics.newImage("images/baby_kangaroo.png")
end

function advance_right(spelare)
    if spelare.x < (love.graphics.getWidth() - spelare.img:getWidth()) then
        spelare.x = spelare.x + 10;
        spelare.lights[1].enabled = true
    end
end

function advance_left(spelare)
    if spelare.x > 0 then
        spelare.x = spelare.x - 10;
    end
end

-- Updating
function love.update(dt)
    if love.keyboard.isDown('escape', 'q') then
        love.event.push('quit')
    end

    if love.keyboard.isDown("n", 'right') then
        advance_right(sp1)
        button_was_pressed = true
    end
    if love.keyboard.isDown("h", 'left') then
        advance_left(sp1)
    end

    if love.keyboard.isDown("c", 'up') then
        sp1.y = sp1.y - 10;
    end
    if love.keyboard.isDown("t", 'down') then
        sp1.y = sp1.y + 10;
    end
end

-- Drawing
function love.draw(dt)
    love.graphics.print("Run baby cangaroo run", 0, 10)
    --love.graphics.setBackgroundColor(100, 100, 100)
    love.graphics.print("cangaroo at (" .. tostring(sp1.x) .. ", " .. tostring(sp1.y) .. ")", 0, 25)

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
