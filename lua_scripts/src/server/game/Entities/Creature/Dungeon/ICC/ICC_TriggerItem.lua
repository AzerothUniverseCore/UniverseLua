local ITEM_TRIGGER = 338009 -- L'ID de l'item qui déclenche la suppression
local ITEM_TO_DELETE = 338008 -- L'ID de l'item à supprimer

local function OnItemClick(event, player, item, target)
    if item:GetEntry() == ITEM_TRIGGER then
        local count = player:GetItemCount(ITEM_TO_DELETE)
        if count > 0 then
            player:RemoveItem(ITEM_TO_DELETE, count)
            player:SendBroadcastMessage("L'item a été supprimé de vos sacs.")
        else
            player:SendBroadcastMessage("Vous ne possédez pas l'item à supprimer.")
        end
    end
end

RegisterItemEvent(ITEM_TRIGGER, 2, OnItemClick)
