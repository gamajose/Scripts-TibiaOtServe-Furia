dofile('HUD\\OberonAutoSay.lua')
dofile('HUD\\DepositAll.lua')
dofile('HUD\\Loot_Sell.lua')
dofile('HUD\\CB.lua')
dofile('HUD\\alarmPlayer.lua')
dofile('HUD\\Auto_Recording.lua')

local function updateAllScriptsHud()
    updateOberonHUD()
    updateCavebotHUD()
    updateAlarmHUD()
    updatePathHUD()
end

local function createHUD(x, y, icon, text, callback)
    local hudName = HUD.new(x, y, text)
    local hudItem = HUD.new(x, y-10, icon)

    hudName:setColor(255, 255, 255)
    hudItem:setDraggable(false)
    hudName:setPos(x, y)

    hudItem:setCallback(callback)
    hudName:setCallback(callback)

    return hudItem, hudName
end

local entries = {
    { x = 40, y = 100, icon = 3043, text = "Sell Loot", action = function() SellAllItens() end },
    { x = 40, y = 150, icon = 2995, text = "Deposit All", action = function() depositAll() end },
    { x = 40, y = 200, icon = 28853, text = "Oberon (OFF)", action = function() OberonSayToggle() end },
    { x = 40, y = 250, icon = 28724, text = "Cavebot (OFF)", action = function() CavebotToggle() end },
    { x = 40, y = 300, icon = 25782, text = "Alarm (OFF)", action = function() alarmToggle() end },
    { x = 40, y = 350, icon = 22705, text = "Recording (OFF)", action = function() pathToggle() end },
}

local huds = {}

for i, entry in ipairs(entries) do
    local x = entry.x
    local y = entry.y
    local icon = entry.icon
    local text = entry.text
    local action = entry.action

    local hudItem, hudName = createHUD(x, y, icon, text, action)

    if text == "Oberon (OFF)" then
        oberonHUD = { item = hudItem, name = hudName }
    elseif text == "Organize Items (OFF)" then
        organizeHUD = { item = hudItem, name = hudName }
    elseif text == "Alarm (OFF)" then
        alarmHUD = { item = hudItem, name = hudName }
        -- updateAllScriptsHud()
    elseif text == "Cavebot (OFF)" then
        cavebotHUD = { item = hudItem, name = hudName }
    elseif text == "Recording (OFF)" then
        pathHUD = { item = hudItem, name = hudName }
    else
        huds[i] = { item = hudItem, name = hudName }
    end
end
updateAllScriptsHud()