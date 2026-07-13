local removedItems = {}
local removedAuras = {150420, 150421, 150422, 150423, 150424, 150425, 150426, 150427, 150428, 150430, 150431, 150432, 150410, 150411, 150412, 150413, 150414, 150415, 150416, 150417, 150418, 150400, 150401, 150402, 150403, 150404, 150405, 150406, 150407, 150408, 258981, 484701, 480741, 613161, 481621, 258980, 484700, 480740, 613160, 481620, 1500950, 237691, 237690, 150095, 1500980, 150098, 1500970, 1500990, 150097, 150099, 1501000, 1500960, 150100, 150096, 237680, 677550, 1502026, 1502026, 1502031, 633640, 1502027, 1502034, 1502027, 1502034, 1502032, 150094, 1502028, 150092, 1502029, 150093, 1502030, 313050, 1502033, 1502035}

local function removeAurasOnBattleground(event, player)
    local map = player:GetMap()
    if map:IsBattleground() or map:IsArena() then
        for _, auraId in ipairs(removedAuras) do
            player:RemoveAura(auraId)
        end

        --table.insert(removedItems, {90004, 1})
        --table.insert(removedItems, {80001, 1})

        for _, item in ipairs(removedItems) do
            --player:RemoveItem(item[1], item[2])
        end
    else
        for _, item in ipairs(removedItems) do
            --player:AddItem(item[1], item[2])
        end
        removedItems = {}
    end
end

RegisterPlayerEvent(28, removeAurasOnBattleground)
