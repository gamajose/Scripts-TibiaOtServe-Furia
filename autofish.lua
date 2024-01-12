local WaterIds = {
    ["4597"] = true,
	["4610"] = true,
	["4611"] = true,
        ["4602"] = true,
}

function CheckCoordsIds(x, y, z)
    local things = Map.getThings(x, y, z)
    local IsWater = false
    for i, v in pairs(things) do
        if WaterIds[tostring(v.id)] then
            IsWater = true
            break
        end
    end
    return IsWater
end

Timer("fishing", function()
    local player = Creature(Player.getId())
    local playerPos = player:getPosition()
    local WaterPositions = {}
    if playerPos then
        for x = -7, 7 do
            for y = -5, 5 do
                if CheckCoordsIds(playerPos.x + x, playerPos.y + y, playerPos.z) then
                    table.insert(WaterPositions, {x = playerPos.x + x, y = playerPos.y + y, z = playerPos.z})
                end
            end
        end
        if #WaterPositions > 0 then
            local Random = math.random(1, #WaterPositions)
            local RandomPos = WaterPositions[Random]
            if RandomPos then
                Game.useItemOnGround(3483, RandomPos.x, RandomPos.y, RandomPos.z)
            end
        end
    end
end, 100)