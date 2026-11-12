local thisState = {}
local net = require("lib/enetClient")
local json = require("lib/json")

local myConnectionId = nil
local myPlayer = {x = 100, y = 100}

function thisState.load()
    net.tryConnect("localhost:6789")
end

-- 2. Motor avisa quando está pronto
function net.onConnect(meuId, connectionParams)
    print("Oba! Conectei. Meu ID é: " .. meuId)
    myConnectionId = meuId
    net.localState = {}
end

function thisState.update(dt)
    if not net.connectionState == "connected" then return end

    if love.keyboard.isDown("left") then myPlayer.x = myPlayer.x - (200 * dt) end
    if love.keyboard.isDown("up") then myPlayer.y = myPlayer.y - (200 * dt) end
    if love.keyboard.isDown("down") then myPlayer.y = myPlayer.y + (200 * dt) end
    if love.keyboard.isDown("right") then myPlayer.x = myPlayer.x + (200 * dt) end

    net.localState = {
        x = myPlayer.x,
        y = myPlayer.y
    }
    
    net.update(dt) 
end

function net.onOverride(data)
    print("O servidor corrigiu minha posição!")
    myPlayer.x = data.x
    myPlayer.y = data.y
end

function thisState.draw()
    love.graphics.print("Estado de conexão: " .. net.connectionState, 10, 30)
    love.graphics.print("local: "..json.encode(net.localState), 10, 50)
    love.graphics.print("shared: "..json.encode(net.shared), 10, 70)

    if net.connectionState ~= "connected" then
        love.graphics.print("Conectando...", 10, 10)
        return
    end
    love.graphics.print("Conectado! Meu ID: " .. (myConnectionId or "NULO"), 10, 10)

    -- Desenha os OUTROS jogadores e inimigos usando a verdade do servidor
    for id, player in pairs(net.shared) do -- é para ser net.shared.player no futuro
        if id ~= net.meuId then
            love.graphics.rectangle("fill", player.x, player.y, 32, 32)
        end
    end

    -- Desenha o MEU jogador usando a previsão local (resposta imediata na tela, sem lag)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", myPlayer.x, myPlayer.y, 32, 32)
end

return thisState