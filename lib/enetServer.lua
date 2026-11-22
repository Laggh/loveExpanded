local server = {}
local enet = require "enet"
require("lib/loveExpanded")
json = require("lib/json")
local _print = print
local print = function(...)_print("[IS]", ...)end

local CHANNEL_COUNT = 2
local RELIABLE_CHANNEL = 0
local UNRELIABLE_CHANNEL = 1

server.config = {
    tickRate = 20,
    timeout = 1000
}

server.clients = {} -- Lista de clientes (peers)
server.clientsCount = 0 -- Contador de clientes conectados  
server.shared = {}             -- Estado global autoritativo

server.maxPacketLog = 100
server._sentPackets = {}
server._recievedPackets = {}

local lastSharedState = {}     -- Para o diffing
local snapshotTimer = 0




--[[PACKET LEVEL]]
function server._handlePacket(packet)
    local functionMap = {
        ["connect"] = server._handleConnectPacket,
        ["disconnect"] = server._handleDisconnectPacket,
        ["receive"] = server._handleReceivePacket
    }
    local noFunction = function(packet)
        print("No handler for event type:",packet.type)
    end
    local functionToRun = functionMap[packet.type] or noFunction
    functionToRun(packet)
end

function server._handleReceivePacket(packet)
    local peer = packet.peer
    local clientId = tostring(peer:connect_id())
    local clientObj = server.clients[clientId]
    local data = json.decode(packet.data)
    

    if not clientObj then print("Cliente não encontrado para o pacote recebido. ID:", clientId) return end

    local functionMap = {
        ["localState"] = server._handlePacketLocalState,
        ["event"] = server._handlePacketEvent
    }
    local noFunction = function(packet, clientObj)
        print("No handler for packet action: " .. tostring(data.action))
    end
    local functionToRun = functionMap[data.action] or noFunction
    functionToRun(packet, clientObj)
end
       
function server._handleConnectPacket(packet)
    print("Novo cliente conectado: ", packet.peer)
    local peer = packet.peer
    local newId = tostring(peer:connect_id())

    local clientObj = {id = newId, peer = peer, ping = peer:round_trip_time()}

    server.clientsCount = server.clientsCount + 1
    server.clients[newId] = clientObj

    peer:send(
        json.encode({action = "innitial", id = newId, shared = server.shared, connectionParams = {tickRate = server.config.tickRate}}),
        RELIABLE_CHANNEL,
        "reliable"
    )
    print("Enviado Innitial para cliente", newId)

end

function server._handleDisconnectPacket(packet)
    local peer = packet.peer
    -- TODO: Remover do server.clients, disparar server.onDisconnect


end


--[[ACTION LEVEL]]
function server._handlePacketLocalState(packet, clientObj)
    local data = json.decode(packet.data)
    print("Recebido localState do cliente", clientObj.id, "conteúdo:", json.encode(data))
    server.shared[clientObj.id] = data.localState
end

function server._handlePacketEvent(packet, clientObj)
    local data = json.decode(packet.data)
    runIfDefined(server.onEvent, clientObj, data.eventName, data.data)
end

--[[INTERNAL]]
function server._sendReliable(peer, data)
    local jsonData = json.encode(data)
    local sent = peer:send(jsonData, RELIABLE_CHANNEL, "reliable")

    table.insert(server._sentPackets, {data = data, sentTime = os.clock(), type = "reliable"})
    if #server._sentPackets > server.maxPacketLog then table.remove(server._sentPackets, 1) end
end

function server._sendUnreliable(peer, data)
    local jsonData = json.encode(data)
    local sent = peer:send(jsonData, UNRELIABLE_CHANNEL, "unreliable")

    table.insert(server._sentPackets, {data = data, sentTime = os.clock(), type = "unreliable"  })
    if #server._sentPackets > server.maxPacketLog then table.remove(server._sentPackets, 1) end
end

function server._syncState(dt)
    for id, client in pairs(server.clients) do
        server._sendUnreliable(
            client.peer,
            {action = "snapshot", shared = server.shared}
        )
    end
end

--[[EXTERNAL]]
function server.start(port)
    --pega o timestamp atual para o snapshotTimer
    snapshotTimer = os.clock()
    print("start chamado. Porta:", port)
    runIfDefined(server.load)
    host = enet.host_create("*:" .. port,2,CHANNEL_COUNT) -- Cria com 2 canais
    print("host criado:", tostring(host), "canais: 2")
    while true do

        local packet = host:service(0.001)
        if packet then
            server._handlePacket(packet)
        end

        local diffTime = os.clock() - snapshotTimer
        if diffTime >= 1/server.config.tickRate then
            snapshotTimer = snapshotTimer + 1/server.config.tickRate
            server._syncState(diffTime)
            runIfDefined(server.tick, diffTime)
        end
    end
end

function server.sendEvent(clientObj, eventName, data)
    -- TODO: Enviar evento específico para um cliente


end

function server.broadcastEvent(eventName, data)
    -- TODO: Enviar evento para todos os clientes conectados

end



--[[
function server.load() end
function server.tick(dt) end
function server.onConnect(client) end
function server.onDisconnect(client, reason) end
function server.onEvent(client, eventName, data) end
]]

return server