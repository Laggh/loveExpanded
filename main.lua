constants = require("constants")
config = require("config")
loadedFiles = require("fileLoader")

screenLib = require("lib/screen")
json = require("lib/json")

love.window.setMode(800,600, {resizable=true, vsync=true, minwidth=400, minheight=300})

gameStates = {}
gameState = {}

for i,v in pairs(constants.gameStatesNames) do
    gameStates[v] = require("gameStates/"..v)
    print("loaded: ",i,v)
end

img = loadedFiles.img
sfx = loadedFiles.sfx
fonts = loadedFiles.font

function string.interpolate(_Str,_Args)
    return (_Str:gsub('($%b{})', function(w) return _Args[w:sub(3, -2)] or w end))
end
function angleDiff(_Orr, _Dest)
    local diff = _Dest - _Orr
    if diff > math.pi then
        diff = diff - 2 * math.pi
    end
    if diff < -math.pi then
        diff = diff + 2 * math.pi
    end
    return diff end

function changeGameState(_State,_Arg)
    for i,v in pairs(gameStates) do
        print(i,tostring(v))
    end
    gameState = gameStates[_State]
    gameState.load(_Arg)
    love.window.setTitle(_State)
    stateTime = 0
end

function setLimits(_Min,_Value,_Max)
    if _Value < _Min then return _Min end
    if _Value > _Max then return _Max end
    return _Value end

function inLimits(_Min,_Value,_Max)
    if _Value < _Min then return false end
    if _Value > _Max then return false end
    return true end


function strJoin(...)
    local args = {...}
    local str = ""
    for i,v in ipairs(args) do
        str = str .. tostring(v)
    end
    return str end

function drawCentered(_Draw, _X, _Y, _R, _Sx , _Sy)
    local width, height = _Draw:getDimensions()

    love.graphics.draw(_Draw, _X, _Y, _R, _Sx, _Sy ,width/2, height/2)

end
function checkInput()
    if input then 
        inputLenght = inputLenght + 1
        noInputLength = 0
    else 
        if inputLenght > 0 then
            table.insert(inputArr, inputLenght)
            inputLenght = 0
        end
        noInputLength = noInputLength + 1
    end
    if noInputLength > config.maxMorseCodeLength and #inputArr >= 1 then

        noInputLength = 0
        local morseStr = arrToMorseCode(inputArr)
        local character = morseCodeToCharacter(morseStr) or ""
        onInput(string.lower(character))
        inputArr = {}
    end
    if #inputArr > 0 or inputLenght > 1 then
        morseStartTimer = morseStartTimer + 1
    else
        morseStartTimer = 0
    end 
end

function characterToMorseCode(_Character)
    return constants.morseCodeTable[_Character] end

function morseCodeToCharacter(_MorseCode)
    for i, v in pairs(constants.morseCodeTable) do
        if v == _MorseCode then return i end 
    end end
function arrToMorseCode(_Arr)
    local morseCode = ""
    for i, v in ipairs(_Arr) do
        --ew goto i hate them but i need them bruh 😭
        if v > config.maxMorseCodeLength then
            goto continue
        end
        if v > config.minDashLength then
            morseCode = morseCode .. "-"
        else
            morseCode = morseCode .. "."
        end
        ::continue::
    end
    return morseCode end

function love.keypressed(_Key) input = true end
function love.keyreleased(_Key) input = false end

function love.load()
    input = false
    inputLenght = 0
    noInputLength = 0
    inputArr = {}
    morseStartTimer = 0

    changeGameState("introScreen")
    stateTime = 0
    globalTime = 0
    changeGameState("game")
end

function onInput(_Input)
    print("Input: ",_Input)
    gameState.onInput(_Input)
end

function love.update(dt)
    checkInput()
    gameState.update(dt)

end

function love.draw(dt)

    screenLib.setScreen(800, 600)

    gameState.draw(dt)
    local morseCode = arrToMorseCode(inputArr) or ""
    if morseStartTimer > 0 then
        local width = 200
        local height = 40
        local x = 0
        local y = 600 - setLimits(0, morseStartTimer^3, height)

        love.graphics.rectangle("line", x, y, width, height)
        love.graphics.setFont(fonts.monospace.medium)

        local character = morseCodeToCharacter(morseCode) or "?"
        character = strJoin("(", character, ")")

        love.graphics.printf(morseCode, x, y + 5, width, "left")
        love.graphics.printf(character, x, y + 5, width, "right")


        if config.showMorsePredictions then
            local arrayOfAllTheNextPossibleCharacters = {}
            for i, v in pairs(constants.morseCodeTable) do
                if string.sub(v, 1, #morseCode) == morseCode then
                    table.insert(arrayOfAllTheNextPossibleCharacters, strJoin("(",i,")",v))
                end
            end

            while #arrayOfAllTheNextPossibleCharacters > config.maxMorsePredictions do
                table.remove(arrayOfAllTheNextPossibleCharacters)
            end
            table.sort(arrayOfAllTheNextPossibleCharacters, function(a, b)
                return #a < #b
            end)

            love.graphics.setFont(fonts.monospace.small)
            for i, v in ipairs(arrayOfAllTheNextPossibleCharacters) do
                love.graphics.print(v, x, y - 5 - i * 10)
            end
        end

        love.graphics.setFont(fonts.small)

    end
    screenLib.createBorder()
end