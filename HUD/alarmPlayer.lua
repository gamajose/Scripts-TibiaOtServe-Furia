-- Tempo de cooldown em segundos antes que o alarme possa ser acionado novamente
isOnAlarm = false
alarmHUD = nil
local cooldownTime = 5
local lastTriggered = 0
local enabled = false

function alarmToggle()
    isOnAlarm = not isOnAlarm
    if isOnAlarm then
        enabled = true
        Client.showMessage("Alarm (ON)")
    else
        enabled = false
        Client.showMessage("Alarm (OFF)")
    end
    updateAlarmHUD() -- Atualiza o estado da HUD do Oberon Say
end

function updateAlarmHUD()
    if isOnAlarm then
        alarmHUD.name:setText("Alarm (ON)")
        alarmHUD.name:setColor(127, 255, 0)
    else
        alarmHUD.name:setText("Alarm (OFF)")
        alarmHUD.name:setColor(255, 0, 0)
    end
end

local function checkPlayersAndPlayAlarm()
    
    if not Client.isConnected() then
        return
    end

    local playerIds = Map.getCreatureIds(true, true)
    local myPlayerId = Player.getId()

    local currentTime = os.time()
    if os.difftime(currentTime, lastTriggered) >= cooldownTime then
        local otherPlayersExist = false
        if playerIds then
            for _, playerId in ipairs(playerIds) do
                if playerId ~= myPlayerId then
                    otherPlayersExist = true
                    break
                end
            end
        end

        if otherPlayersExist then
            Sound.play("C:\\Users\\josel\\OneDrive\\Documentos\\ZeroBot\\Sounds\\PlayerOnScreen.wav")
            print("Jogador detectado")
            lastTriggered = currentTime
        end
    end
end

-- Definir o intervalo para verificar jogadores (a cada 500 milissegundos)
local intervalo = 500
Timer("PlayerCheckTimer", function() 
    if enabled then 
        checkPlayersAndPlayAlarm()
    end
end
, intervalo, 1)
