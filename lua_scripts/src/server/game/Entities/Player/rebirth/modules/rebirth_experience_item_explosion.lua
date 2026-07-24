local IdItem = 90008;
local RebirthHook = require("rebirth_hook")

-- Localized per player (see rebirth_hook.lua's GetPlayerLocale / NOTICES).
local MAX_LEVEL_NOTICE = {
    frFR = 'Vous êtes déjà au niveau maximum ! Félicitation !',
    enUS = 'You are already at the maximum level! Congratulations!',
}

local function onReceiveExp(event, player, amount)
    player:GiveXP(250);
    return amount;
end


local function onUseParcho(event, player, item)
  local iEntry = item:GetEntry();
  local pLevel = player:GetLevel();

    if (pLevel <= 79) then
        onReceiveExp(event, player, amount, victim);
        player:RemoveItem( IdItem, 1);
    else
        local locale = RebirthHook.GetPlayerLocale(player)
        player:SendNotification(MAX_LEVEL_NOTICE[locale] or MAX_LEVEL_NOTICE.frFR);
    end
end

RegisterItemEvent(IdItem, 2, onUseParcho);
