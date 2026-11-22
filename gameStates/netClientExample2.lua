local thisState = {}

-- Cada cliente precisa de uma execução Lua independente do módulo.
-- Usar require duas vezes devolveria a mesma tabela/mesmo estado.
local chunk1 = assert(love.filesystem.load("lib/enetClient.lua"))
local chunk2 = assert(love.filesystem.load("lib/enetClient.lua"))
local net1 = chunk1()
local net2 = chunk2()

local json = require("lib/json")

local SERVER_THREAD = nil
local clientId1 = nil
local clientId2 = nil

local player1 = { x = 100, y = 100 }
local player2 = { x = 100, y = 100 }

local function isConnected(net)
    return net.connectionState == "connected"
end

function net1.onConnect(meuId, connectionParams)
    clientId1 = meuId
    print("[C1] Conectado. ID:", meuId, "params:", json.encode(connectionParams))
    net1.localState = {}
end

function net2.onConnect(meuId, connectionParams)
    clientId2 = meuId
    print("[C2] Conectado. ID:", meuId, "params:", json.encode(connectionParams))
    net2.localState = {}
end

function thisState.load()
    SERVER_THREAD = love.thread.newThread("server/main.lua")
    SERVER_THREAD:start()

    net1.tryConnect("localhost:6789")
    net2.tryConnect("localhost:6789")
end

function thisState.update(dt)
    if isConnected(net1) then
        if love.keyboard.isDown("a") then player1.x = player1.x - 200 * dt end
        if love.keyboard.isDown("d") then player1.x = player1.x + 200 * dt end
        if love.keyboard.isDown("w") then player1.y = player1.y - 200 * dt end
        if love.keyboard.isDown("s") then player1.y = player1.y + 200 * dt end

        net1.localState = { x = player1.x, y = player1.y }
        net1.update(dt)
    else
        -- Continua processando a conexão inicial enquanto não estiver conectado.
        net1.update(dt)
    end

    if isConnected(net2) then
        if love.keyboard.isDown("left") then player2.x = player2.x - 200 * dt end
        if love.keyboard.isDown("right") then player2.x = player2.x + 200 * dt end
        if love.keyboard.isDown("up") then player2.y = player2.y - 200 * dt end
        if love.keyboard.isDown("down") then player2.y = player2.y + 200 * dt end

        net2.localState = { x = player2.x, y = player2.y }
        net2.update(dt)
    else
        -- Continua processando a conexão inicial enquanto não estiver conectado.
        net2.update(dt)
    end
end

local function drawClientPanel(net, player, playerId, label, viewportX, viewportWidth)
    love.graphics.push()
    love.graphics.setScissor(viewportX, 0, viewportWidth, love.graphics.getHeight())
    love.graphics.translate(viewportX, 0)

    love.graphics.setColor(0.08, 0.08, 0.10)
    love.graphics.rectangle("fill", 0, 0, viewportWidth, love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(label .. " - Estado: " .. net.connectionState, 10, 10)
    love.graphics.print("ID: " .. (playerId or "Aguardando..."), 10, 30)
    love.graphics.print("Local: " .. json.encode(net.localState), 10, 50)

    if isConnected(net) then
        for id, sharedPlayer in pairs(net.shared) do
            if id ~= net.id then
                love.graphics.setColor(0.2, 0.6, 1)
                love.graphics.rectangle("fill", sharedPlayer.x, sharedPlayer.y, 32, 32)
            end
        end

        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", player.x, player.y, 32, 32)
    end

    love.graphics.pop()
    love.graphics.setScissor()
end

function thisState.draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local halfWidth = math.floor(width / 2)

    drawClientPanel(net1, player1, clientId1, "Cliente 1 - WASD", 0, halfWidth)
    drawClientPanel(net2, player2, clientId2, "Cliente 2 - SETAS", halfWidth, width - halfWidth)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", halfWidth - 1, 0, 2, height)
end

return thisState
