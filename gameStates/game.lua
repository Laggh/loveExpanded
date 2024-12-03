local thisState = {}

maxId = 0
function spawnAnt(_X, _Y, _Team)
    local newAnt = {
        id = maxId + 1,
        alive = true,
        type = "ant",
        x = _X,
        y = _Y,
        team = _Team,
        speed = 3,
        hp = 100,
        timeSinceHit = 0,
        atackCharge = 0,
        direction = math.random(2*math.pi),
        sprites = loadedFiles.img.ant,
        spriteIndex = 1,
        spriteTime = 0,

        action = "idle",
        movePos = {x = _X, y = _Y},
        atackTarget = nil,
        objective = nil,

    }
    maxId = maxId + 1
    newAnt.direction = 0
    table.insert(entities, newAnt)
    return newAnt.id
end

function runAnt(_Ant)
    _Ant.timeSinceHit = _Ant.timeSinceHit + 1
    if _Ant.hp < 0 or not _Ant.alive then
        _Ant.alive = false
        return
    end
    _Ant.atackCharge = setLimits(0,_Ant.atackCharge + 1,35)
    --Sprite animation
    if _Ant.spriteTime == 10 then
        _Ant.spriteIndex = _Ant.spriteIndex + 1
        if _Ant.spriteIndex > #_Ant.sprites then
            _Ant.spriteIndex = 1
        end
        _Ant.spriteTime = 0
    end

    --Random idle action
    if (_Ant.action == "idle" and math.random(1000) == 1) then
        local randomIndex = math.random(#entities)
        if _Ant.id ~= randomIndex then
            local randomAnt = entities[math.random(#entities)]
            if randomAnt.team == _Ant.team then
                if randomAnt.action == "idle" then
                    _Ant.action = "move"
                    _Ant.movePos = {x = randomAnt.x + math.random(-100,100), y = randomAnt.y + math.random(-100,100)}
                    _Ant.atackTarget = nil
                else
                    _Ant.action = randomAnt.action
                    _Ant.atackTarget = randomAnt.atackTarget
                    _Ant.movePos = {x = randomAnt.x + math.random(-100,100), y = randomAnt.y + math.random(-100,100)} 
                end
            else
                _Ant.action = "atack"
                _Ant.movePos = {x = randomAnt.x + math.random(-100,100), y = randomAnt.y + math.random(-100,100)}
                _Ant.atackTarget = randomAnt.id
            end
        end
    end
    --Calculating the angle and distance to the objective
    local diff = angleDiff(_Ant.direction, math.atan2(_Ant.movePos.y - _Ant.y, _Ant.movePos.x - _Ant.x))
    local dist = math.sqrt((_Ant.movePos.x - _Ant.x)^2 + (_Ant.movePos.y - _Ant.y)^2)
    if diff > 0.1 then
        _Ant.direction = _Ant.direction + 0.1
    elseif diff < -0.1 then
        _Ant.direction = _Ant.direction - 0.1
    end

    --MOVE
    if _Ant.action == "move" then
        _Ant.spriteTime = _Ant.spriteTime + 1

        _Ant.x = _Ant.x + math.cos(_Ant.direction) * _Ant.speed
        _Ant.y = _Ant.y + math.sin(_Ant.direction) * _Ant.speed

        if dist < 10 then
            _Ant.action = "idle"
        end
    end

    --ATACK
    if _Ant.action == "atack" then

        _Ant.x = _Ant.x + math.cos(_Ant.direction) * _Ant.speed
        _Ant.y = _Ant.y + math.sin(_Ant.direction) * _Ant.speed

        _Ant.movePos.x = entities[_Ant.atackTarget].x
        _Ant.movePos.y = entities[_Ant.atackTarget].y

    
        local target = entities[_Ant.atackTarget]
        if target.alive then     
            if dist < 10 and _Ant.atackCharge == 35 then
                target.hp = target.hp - math.random(7,25)
                target.timeSinceHit = 0
                _Ant.atackCharge = 0
            end
        else
            _Ant.atackTarget = nil
            _Ant.action = "move"
            _Ant.movePos = {x = _Ant.x + math.random(-20,20), y = _Ant.y + math.random(-20,20)}
        end


    end
end

function drawAnt(_Ant)
    if _Ant.alive == false then 
        love.graphics.setColor(0.5,0.5,0.5,1) 
        drawCentered(_Ant.sprites[_Ant.spriteIndex], _Ant.x, _Ant.y, _Ant.direction)
        love.graphics.setColor(1,1,1,1)
        return
    end

    drawCentered(_Ant.sprites[_Ant.spriteIndex], _Ant.x, _Ant.y, _Ant.direction)
    local str = string.interpolate("Ant: ${id}-${action}\n${hp}/100 ${charge}/35\n ${target}",
        {id = _Ant.id, action = _Ant.action, hp = _Ant.hp, charge = _Ant.atackCharge, target = _Ant.atackTarget})

    love.graphics.printf(str, _Ant.x, _Ant.y, 100, "center")

    love.graphics.line(_Ant.x, _Ant.y, _Ant.movePos.x, _Ant.movePos.y)

    love.graphics.setColor(1,1,1,0.1)
    love.graphics.circle("line", _Ant.x, _Ant.y, 10)
    love.graphics.setColor(1,1,1,1)

    love.graphics.setColor(1,0,0,1 - (_Ant.timeSinceHit/30))
    love.graphics.rectangle("fill", _Ant.x - 20, _Ant.y - 30, 40, 5)
    love.graphics.setColor(1,1,1,1)
end

function thisState.load(_Level)
    readyToAtackInput = false
    atackInput = ""

    entities = {}
    for team = 1,2 do
        for i = 1,3 do
            local newId = spawnAnt(math.random(100,700), math.random(100,500), team)
            local newAnt = entities[newId]
            newAnt.action = "move"
            newAnt.movePos = {x = math.random(100,700), y = math.random(100,500)}
        end
    end
end

function thisState.update(_Dt)
    globalTime = globalTime + _Dt
    stateTime = stateTime + _Dt

    for i,v in pairs(entities) do
        if v.type == "ant" then runAnt(v) end
    end
end

function thisState.draw()

    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    love.graphics.setColor(1, 1, 1, 1)

    for i,v in ipairs(entities) do
        if v.type == "ant" then drawAnt(v) end
    end

    if readyToAtackInput then
        for i,v in ipairs(entities) do
            if v.type == "ant" and v.team ~= 1 and v.alive then
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.circle("line", v.x, v.y, 10)

                love.graphics.setFont(fonts.medium)
                love.graphics.print(v.id, v.x, v.y)
                love.graphics.setFont(fonts.small)

                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end

end

function thisState.onInput(_Input)
    if readyToAtackInput then
        if tonumber(_Input) then
            local target = entities[tonumber(_Input)]
            if target.alive and target.team ~= 1 then
                for i,v in pairs(entities) do
                    if v.type == "ant" and v.alive then
                        if v.team == 1 then
                            v.action = "atack"
                            v.atackTarget = tonumber(_Input)
                            readyToAtackInput = false
                        end
                    end
                end
            end
        else
            readyToAtackInput = false
        end
    end

    if _Input == "a" then
        readyToAtackInput = true
    end

    if _Input == "i" then
        for i,v in pairs(entities) do
            if v.type == "ant" then
                v.action = "idle"
            end
        end
    end

    if _Input == "m" then
        for i,v in pairs(entities) do
            if v.type == "ant" then
                v.action = "move"
                v.movePos = {x = math.random(100,700), y = math.random(100,500)}
            end
        end
    end

end


return thisState