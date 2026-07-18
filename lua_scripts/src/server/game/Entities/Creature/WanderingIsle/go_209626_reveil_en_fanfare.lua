local QUEST_ID        = 29772   -- Reveil en fanfare
local GO_ENTRY        = 209626  -- Gong du village
local CREDIT_CREATURE = 55546   -- Gong Ring Credit (kill credit NPC)

local GO_EVENT_ON_USE = 14      -- ON_USE : (event, go, player)

local function OnGongUse(event, go, player)

    if not player:HasQuest(QUEST_ID) then
        return
    end

    player:KillGOCredit(GO_ENTRY, 0)

    player:KilledMonsterCredit(CREDIT_CREATURE, 0)

    player:AreaExploredOrEventHappens(QUEST_ID)

    player:SendBroadcastMessage(
        "|cffFFD700Le Gong du village retentit fierement ! Quete accomplie.|r"
    )

    go:UseDoorOrButton()
end

RegisterGameObjectEvent(GO_ENTRY, GO_EVENT_ON_USE, OnGongUse)
