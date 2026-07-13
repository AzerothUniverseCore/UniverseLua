require('sys_player_informations');

local InstanceLevel = {};
local contribMount = {49322};

local function learnContribMount(event, player)
  local playerInfo = playerInformations[player:GetGUIDLow()]
  if playerInfo and playerInfo.rank == 1 then
    for _, mount in ipairs(contribMount) do
      if not player:HasSpell(mount) then
        player:LearnSpell(mount)
        player:AddItem(9017, 1)
        player:AddItem(90180, 1)
        player:AddItem(90007, 1)
        player:AddItem(200008, 1)
        player:AddItem(23162, 4)
        player:AddItem(900010, 1)
        player:AddItem(900011, 1)
        player:AddItem(10360, 1)
		--player:AddItem(335808, 1)
      end
    end
  end
end
RegisterPlayerEvent(3, learnContribMount)

local function addContribGold(event, player, amount)
  local playerInfo = playerInformations[player:GetGUIDLow()]
  if playerInfo and playerInfo.rank == 1 then
    return amount * 1.50;
  end
end
RegisterPlayerEvent(37, addContribGold)

local function addContribBuff(event, player)
  local playerInfo = playerInformations[player:GetGUIDLow()]
  if playerInfo and playerInfo.rank == 1 then
    for _, value in pairs(InstanceLevel) do
      if player:GetMap():IsDungeon() or player:GetMap():IsRaid() then
        if value[1] == player:GetMapId() then
          local levelDiff = player:GetLevel() - value[2]
          if levelDiff >= 0 then
            player:AddAura(29521, player)
            player:AddAura(31305, player)
            player:AddAura(45444, player)
            player:AddAura(67741, player)
          end
        end
      else
        player:RemoveAura(29521)
        player:RemoveAura(31305)
        player:RemoveAura(45444)
        player:RemoveAura(67741)
      end
    end
  end
end
RegisterPlayerEvent(28, addContribBuff)

local function onServerStart(event)
  local getInstanceLevel_query = WorldDBQuery('SELECT mapId, level_min FROM access_requirement')
  repeat
    local instanceLevel_data = getInstanceLevel_query:GetRow()
    local mapId = instanceLevel_data["mapId"]
    local level_min = instanceLevel_data["level_min"]
    table.insert(InstanceLevel, {mapId, level_min})
  until not getInstanceLevel_query:NextRow()
end
RegisterServerEvent(33, onServerStart)

local function onCommand (event, player, command)
  local playerInfo = playerInformations[player:GetGUIDLow()]
  if playerInfo and playerInfo.rank == 1 and command == 'rush' then
    addContribBuff(event, player)
    return false;
  end
end
RegisterPlayerEvent(42, onCommand)
