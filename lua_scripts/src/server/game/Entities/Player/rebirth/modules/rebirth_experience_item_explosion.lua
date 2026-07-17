local IdItem = 90008;

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
        player:SendNotification('Vous êtes déjà au niveau maximum ! Félicitation !');
    end
end

RegisterItemEvent(IdItem, 2, onUseParcho);
