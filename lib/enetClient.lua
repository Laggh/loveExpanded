local client = {}
local enet = require "enet"
local json = require("lib/json")
require("lib/loveExpanded")

local CHANNEL_COUNT = 2
local RELIABLE_CHANNEL = 0
local UNRELIABLE_CHANNEL = 1

local _print = print
local print = function(...)_print("[IC]", ...)end
-- ==========================================
-- VARIÁVEIS DE ESTADO (API Pública)
-- ==========================================

client.connectionState = "disconnected" -- disconnected, connecting, connected
client.id = nil
client.shared = {}       -- Somente leitura (verdade do servidor)
client.rawShared = {}    -- Verdade do servidor sem Interpolação (no momneto é IGUAL a .shared)
client.localState = {}   -- Previsão local do cliente
client._bufferedPackets = {} -- Pacotes recebidos do servidor que ainda não foram processados

client.maxPacketLog = 100
client._sentPackets = {}
client._recievedPackets = {}

client.updateRate = nil
client._deltaSinceUpdate = 0

client.host = nil
client.serverPeer = nil









--[[[PACKET LEVEL]]
function client._handlePacket(packet)
  print("recebido pacote do tipo "..packet.type)
  local functionMap = {
    ["receive"] = client._handleReceivePacket,
    ["connect"] = client._handleConnectPacket,
    ["disconnect"] = client._handleDisconnectPacket
  }
  local function noFunction(packet)
    print("No handler for packet type: " .. packet.type)
  end
  local functionToRun = functionMap[packet.type] or noFunction
  functionToRun(packet)
end

function client._handleReceivePacket(packet)
  print("Got message: ", packet.data, packet.peer)

  local functionMap = {
    ["innitial"] = client._handleInnitialAction,
    ["event"] = client._handleEventAction,
    ["snapshot"] = client._handleSnapshotAction
  }
  local noFunction = function(packet)
    print("No handler for message type: " .. packet.type)
  end

  local data = json.decode(packet.data)
  print("decodificado. action:", data.action, "conteúdo:", packet.data)

  if client.connectionState ~= "connected" and data.action ~= "innitial" then
    print("Buffering event of action", packet.type)
    table.insert(client._bufferedPackets, packet)
    return
  end

  local functionToRun = functionMap[data.action] or noFunction
  functionToRun(data)
end

function client._handleConnectPacket(packet)
  client.connectionState = "waiting_for_innitial"
  print(packet.peer, "connected.")
end

function client._handleDisconnectPacket(packet)
  client.connectionState = "disconnected"
  print(packet.peer, "disconnected.")
end


--[[ACTION LEVEL]]
function client._handleInnitialAction(packet)
  client.connectionState = "connected"
  client.id = packet.id
  client.updateRate = packet.connectionParams.tickRate
  client.rawShared = packet.shared
  client.shared = packet.shared

  --Roda os eventos que estavam em buffer (antes de receber o innitial)
  for _, bufferedPacket in ipairs(client._bufferedPackets) do
    client._handleReceivePacket(bufferedPacket)
  end

  if client.onConnect then
    client.onConnect(client.id, packet.connectionParams)
  end

end

function client._handleEventAction(event)
  runIfDefined(client.onEvent, event.eventName, event.data)
end

function client._handleSnapshotAction(event)
  client._applySnapshot(event.shared)
end
  

--[[INTERNAL]]
function client._sendReliable(data)
  local jsonData = json.encode(data)
  local sent = client.serverPeer:send(jsonData, RELIABLE_CHANNEL, "reliable")

  table.insert(client._sentPackets, {data = data, sentTime = os.clock(), type = "reliable"})
  if #client._sentPackets > client.maxPacketLog then table.remove(client._sentPackets, 1) end
end
function client._sendUnreliable(data)
  local jsonData = json.encode(data)
  local sent = client.serverPeer:send(jsonData, UNRELIABLE_CHANNEL, "unreliable")

  table.insert(client._sentPackets, {data = data, sentTime = os.clock(), type = "unreliable"  })
  if #client._sentPackets > client.maxPacketLog then table.remove(client._sentPackets, 1) end
end

function client._sendLocalState()
  if client.connectionState ~= "connected" then print("Cannot send local state, client not connected") return end

  client._sendUnreliable({
    action = "localState",
    localState = client.localState
  })
end
  
function client._applySnapshot(data)
  for k,v in pairs(data) do
    client.shared[k] = v
  end
end

function client._applyDiff(data)

end

--[[EXTERNAL]]
function client.tryConnect(address)
  print("tryConnect chamado. Endereço:", address)
  client.host = enet.host_create(nil, 1, CHANNEL_COUNT)
  client.serverPeer = client.host:connect(address, CHANNEL_COUNT)
  print("host criado:", tostring(client.host))
  print("pedido de conexão enviado para:", address)
  print("peer do servidor:", tostring(client.serverPeer))
end

function client.update(dt)
  --print("update chamado. dt:", dt, "estado:", client.connectionState)
  --Lida com pacotes
  local packet = client.host:service(0)

  while packet do
    client._handlePacket(packet)
    packet = client.host:service()
  end
  --Para se não estiver conectado
  if client.connectionState ~= "connected" then return end

  --Lida com o Estado do Cliente
  local timeForUpdate = 1/client.updateRate
  client._deltaSinceUpdate = client._deltaSinceUpdate + dt
  if client._deltaSinceUpdate < timeForUpdate then return end
  
  client._deltaSinceUpdate = client._deltaSinceUpdate - timeForUpdate

  client._applySnapshot(client.rawShared)
  client._sendLocalState()
  --No futuro isso vai mudar para poder ter apenas diffs, mas no moment é só snapshot (pq ta em json)
end

function client.sendEvent(eventName, data)
  if client.connectionState ~= "connected" then print("Cannot send event, client not connected") return end
  
  local dataToSent = {
    action = "event",
    eventName = eventName,
    data = data
  }

  local jsonData = json.encode(dataToSent)
  client.serverPeer:send(jsonData, RELIABLE_CHANNEL, "reliable")
end


--[[CALBACKS]]

--[[
function client.onConnect(meuId, connectionParams) end
function client.onDisconnect(reason) end
function client.onOverride(data) end
function client.onEvent(eventName, data) end
]]

return client