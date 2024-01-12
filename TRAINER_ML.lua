-- A table that maps potion names to their corresponding item IDs.
local PotionList = {
    ["ultimate mana potion"] = 23373,
    ["great mana potion"] = 238,
    ["strong mana potion"] = 237,
    ["mana potion"] = 268,
}

-- The threshold amount of potions; if the player has less than this amount, the script will attempt to buy more.
local Amount = 100

-- A timer function named "buy pot" that automates the process of buying potions.
-- It is triggered at a set interval (1000ms in this case) and buys potions based on certain conditions.
-- A table that maps potion names to their corresponding item IDs.
local PotionList = {
    ["ultimate mana potion"] = 23373,
    ["great mana potion"] = 238,
    ["strong mana potion"] = 237,
    ["mana potion"] = 268,
}

-- The threshold amount of potions; if the player has less than this amount, the script will attempt to buy more.
local Amount = 100
local AmountExercise = 1
local ExerciseId = 35289
local TrainML = true
local BuyExercise = false
-- A timer function named "buy pot" that automates the process of buying potions.
-- It is triggered at a set interval (1000ms in this case) and buys potions based on certain conditions.
Timer("buy pot", function()
    local player = Creature(Player.getId())

    -- Select the item ID of the potion to buy from the PotionList table.
    local ItemId = PotionList["great mana potion"]

    -- Get the current amount of the selected potion that the player has.
    local CurrentAmount = Game.getItemCount(ItemId)
    
    -- Check if the player has less than the threshold amount of the selected potion.
    -- If the condition is met, the script initiates a conversation with the NPC to buy more of the selected potion.
    if CurrentAmount and CurrentAmount <= 0 then
        gameTalk("hi", 1)  -- Start the conversation with the NPC.
        wait(500)  --S Optional: wait for a short duration before proceeding to the next line of the conversation. Uncomment if needed.
        gameTalk("service", 12)  -- Proceed to the potion buying dialogue.
        wait(100)
        gameTalk("goods", 12)  -- Proceed to the potion buying dialogue.
        wait(100)
        gameTalk("potions", 12)  -- Proceed to the potion buying dialogue.
        wait(100)
        -- Buy the potion; parameters are item ID, amount to buy, ignore capacity check, ignore money check.
        npcBuy(ItemId, Amount, false, false)
    end
    if BuyExercise then
    local CurrentExercise = Game.getItemCount(ExerciseId)
        if CurrentExercise and CurrentExercise <= 1 then
            gameTalk("hi", 1)  -- Start the conversation with the NPC.
            wait(500)  -- Optional: wait for a short duration before proceeding to the next line of the conversation. Uncomment if needed.
            gameTalk("service", 12)  -- Proceed to the potion buying dialogue.
            wait(100)
            gameTalk("goods", 12)  -- Proceed to the potion buying dialogue.
            wait(100)
            gameTalk("exercises", 12)  -- Proceed to the potion buying dialogue.
            wait(100)
            -- Buy the potion; parameters are item ID, amount to buy, ignore capacity check, ignore money check.
            npcBuy(ExerciseId, AmountExercise, false, false)
        end
    end
end, 1000)

local Vita = Spells.getIdByWords("exura vita") -- Get the spell id
local UtanaVid = Spells.getIdByWords("utana vid") -- Get the spell id
Timer("TrainMl", function()
    if not Spells.groupIsInCooldown(Enums.SpellGroups.SPELLGROUP_HEALING) then
        wait(30)
        if not Spells.isInCooldown(Vita) then
            Game.talk('exura vita',12)
        end
    end
    if not Spells.groupIsInCooldown(Enums.SpellGroups.SPELLGROUP_SUPPORT) then
        wait(30)
        if not Spells.isInCooldown(UtanaVid) then
            Game.talk('utana vid',12)
        end
    end
end, 100,TrainML)