local spelare_controls = {}

function spelare_controls.advance_left(spelare)
    if spelare.x > 0 then
        spelare.x = spelare.x - spelare.step;
    end
end

function spelare_controls.advance_right(spelare)
    if spelare.x < (love.graphics.getWidth() - spelare.img:getWidth()) then
        spelare.x = spelare.x + spelare.step;
    end
end

return spelare_controls
