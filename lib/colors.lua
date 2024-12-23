local lib = {}

-- Transforms an HSV value to RGB
-- (Hue, Saturation, Value) -> (Red, Green, Blue)
function HSVtoRGB(hue, saturation, value)
    local red, green, blue

    -- Integer part of the hue multiplied by 6. Used to determine the color sector.
    local i = math.floor(hue * 6)
    -- Fractional part of the hue multiplied by 6. Used to interpolate between color values.
    local f = hue * 6 - i
    -- Value adjusted by saturation. Represents the color intensity when the hue is at its minimum.
    local p = value * (1 - saturation)
    -- Value adjusted by saturation and fractional part. Represents the color intensity when the hue is decreasing.
    local q = value * (1 - f * saturation)
    -- Value adjusted by saturation and fractional part. Represents the color intensity when the hue is increasing.
    local t = value * (1 - (1 - f) * saturation)

    i = i % 6
    if i == 0 then red, green, blue = value, t, p
    elseif i == 1 then red, green, blue = q, value, p
    elseif i == 2 then red, green, blue = p, value, t
    elseif i == 3 then red, green, blue = p, q, value
    elseif i == 4 then red, green, blue = t, p, value
    elseif i == 5 then red, green, blue = value, p, q
    end
    return red, green, blue
end

if love.graphics then
    -- Sets the color of the graphics to a HSV value
    -- (Hue, Saturation, Value, Alpha) -> ()
    function love.graphics.setColorHSV(hue, saturation, value, alpha)
        local red, green, blue = HSVtoRGB(hue, saturation, value)
        love.graphics.setColor(red, green, blue, alpha)
    end

end

return lib