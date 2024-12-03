-- Interpolates a string with the given arguments.
function string.interpolate(_Str,_Args)
    return (_Str:gsub('($%b{})', function(w) return _Args[w:sub(3, -2)] or w end))
end

-- Clamps a value between a minimum and maximum value.
function setLimits(_Min,_Value,_Max)
    if _Value < _Min then return _Min end
    if _Value > _Max then return _Max end
    return _Value
end

-- Checks if a value is within a specified range.
function inLimits(_Min,_Value,_Max)
    if _Value < _Min then return false end
    if _Value > _Max then return false end
    return true
end

-- Joins multiple values into a single string.
function strJoin(...)
    local args = {...}
    local str = ""
    for i,v in ipairs(args) do
        str = str .. tostring(v)
    end
    return str
end

-- Draws an image centered at the given coordinates.
function drawCentered(_Draw, _X, _Y, _R, _Sx , _Sy)
    local width, height = _Draw:getDimensions()
    love.graphics.draw(_Draw, _X, _Y, _R, _Sx, _Sy ,width/2, height/2)
end
