-- ============================================================
--  Script Eluna - Quete "Reveil en fanfare" (ID 29772)
--  GameObject : Gong du village (entry 209626)
--  TrinityCore 3.3.5a - Mode MULTISTATE (ElunaTrinityWotlk)
--
--  ON_USE = event 14, signature : function(event, go, player)
--  Validation complete :
--    1) KillGOCredit(209626)       -> coche l'objectif GO
--    2) KilledMonsterCredit(55546) -> credit creature pour
--       valider vraiment la quete (Gong Ring Credit)
-- ============================================================

local QUEST_ID        = 29772   -- Reveil en fanfare
local GO_ENTRY        = 209626  -- Gong du village
local CREDIT_CREATURE = 55546   -- Gong Ring Credit (kill credit NPC)

local GO_EVENT_ON_USE = 14      -- ON_USE : (event, go, player)

-- ============================================================
--  Handler : declenche quand le joueur clique sur le Gong
-- ============================================================
local function OnGongUse(event, go, player)

    -- Securite : le joueur doit avoir la quete active
    if not player:HasQuest(QUEST_ID) then
        return
    end

    -- 1) Coche l'objectif "Faire retentir le Gong" dans le journal
    player:KillGOCredit(GO_ENTRY)

    -- 2) Credit creature qui permet la validation reelle de la quete
    player:KilledMonsterCredit(CREDIT_CREATURE)

    -- 3) Tente de completer la quete (tous objectifs remplis)
    player:AreaExploredOrEventHappens(QUEST_ID)

    -- Feedback dore dans le chat (optionnel)
    player:SendBroadcastMessage(
        "|cffFFD700Le Gong du village retentit fierement ! Quete accomplie.|r"
    )

    -- Declenche l'animation et le son natif du gong
    go:UseDoorOrButton()
end

-- ============================================================
--  Enregistrement MULTISTATE (MAP state)
-- ============================================================
RegisterGameObjectEvent(GO_ENTRY, GO_EVENT_ON_USE, OnGongUse)