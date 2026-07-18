local SHU_ENTRY        = 65493
local SPELL_WATER_JET  = 117063
local QUEST_ID         = 29679
local KILL_CREDIT      = 60488

local WATER_SPOUT_BUNNY_ENTRY = 60488
local BUNNY_DESPAWN_MS        = 9000
local BUNNY_SPAWN_TYPE        = 3      -- TEMPSUMMON_TIMED_DESPAWN

local SPELL_WATER_SPOUT_WARNING     = 116695
local SPELL_WATER_SPOUT_BURST       = 116696
local SPELL_WATER_SPOUT_GEYSER_AURA = 117057

local SPELL_LAUNCH = 1841409

local PLATFORM_RADIUS  = 6.0
local POLL_MS          = 400
local POLL_REPEATS     = 5
local WAIT_BEFORE_CAST_MS = 4000
local CYCLE_INTERVAL_MS   = 10000

local PLATFORM_POSITIONS = {
    { x = 1102.05, y = 2882.11, z = 94.32, o = 0.11, bx = 1105.79, by = 2885.37, bz = 92.2235 },
    { x = 1120.01, y = 2883.20, z = 96.44, o = 4.17, bx = 1113.78, by = 2886.40, bz = 92.2235 },
    { x = 1128.09, y = 2859.44, z = 97.64, o = 2.51, bx = 1134.37, by = 2858.65, bz = 92.2235 },
    { x = 1111.52, y = 2849.84, z = 94.84, o = 1.94, bx = 1117.52, by = 2848.44, bz = 92.2235 },
}

local AIUPDATE_EVENT_ID = 7

pcall(function() math.randomseed(os.time()) end)

local shuState = {} -- [guid] = { started = bool }

local function dist2D(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

local function playerHasQuestActive(player)
    local ok, status = pcall(function() return player:GetQuestStatus(QUEST_ID) end)
    return ok and status == 3
end

local function CreditNearbyPlayers(creature, platform)
    local credited = {}

    creature:RegisterEvent(function(eventId, delay, repeats, creatureArg)
        if not creatureArg then return end

        local okWorld, inWorld = pcall(function() return creatureArg:IsInWorld() end)
        if not okWorld or not inWorld then return end

        local okMap, map = pcall(function() return creatureArg:GetMap() end)
        if not okMap or not map then return end

        local okPlayers, players = pcall(function() return map:GetPlayers() end)
        if not okPlayers or not players then return end

        for _, player in ipairs(players) do
            if player and playerHasQuestActive(player) then
                local pguid = player:GetGUIDLow()
                if not credited[pguid] then
                    local d = dist2D(player:GetX(), player:GetY(), platform.x, platform.y)
                    if d <= PLATFORM_RADIUS then
                        credited[pguid] = true
                        pcall(function() player:KilledMonsterCredit(KILL_CREDIT) end)

                        local okPlayerCast, errPlayerCast = pcall(function()
                            creatureArg:CastSpell(player, SPELL_WATER_JET, false)
                        end)
                        if not okPlayerCast then
                            --print("|cffff0000[Shu]|r CastSpell(joueur, Water Jet) a echoue : " .. tostring(errPlayerCast))
                        end
                    end
                end
            end
        end
    end, POLL_MS, POLL_REPEATS)
end

local function KnockbackNearbyPlayers(creature, platform)
    local okMap, map = pcall(function() return creature:GetMap() end)
    if not okMap or not map then return end

    local okPlayers, players = pcall(function() return map:GetPlayers() end)
    if not okPlayers or not players then return end

    for _, player in ipairs(players) do
        if player then
            local d = dist2D(player:GetX(), player:GetY(), platform.x, platform.y)
            if d <= PLATFORM_RADIUS then
                local okLaunch, errLaunch = pcall(function()
                    player:CastSpell(player, SPELL_LAUNCH, true)
                end)
                if not okLaunch then
                    --print("|cffff0000[Shu]|r Projection (CastSpell KNOCK_BACK) a echoue : " .. tostring(errLaunch))
                end
            end
        end
    end
end

local function RunShuCycle(creature)
    if not creature then return end
    local okWorld, inWorld = pcall(function() return creature:IsInWorld() end)
    if not okWorld or not inWorld then return end

    local platform = PLATFORM_POSITIONS[math.random(#PLATFORM_POSITIONS)]

    local okJump, errJump = pcall(function()
        creature:MoveJump(platform.x, platform.y, platform.z, 10, 10)
    end)
    if not okJump then
        --print("|cffffcc00[Shu]|r MoveJump indisponible (" .. tostring(errJump) .. "), repli sur NearTeleport.")
        local okTp, errTp = pcall(function()
            creature:NearTeleport(platform.x, platform.y, platform.z, platform.o)
        end)
        if not okTp then
            --print("|cffff0000[Shu]|r NearTeleport a aussi echoue : " .. tostring(errTp))
        end
    end

    local okBunny, bunny = pcall(function()
        return creature:SpawnCreature(WATER_SPOUT_BUNNY_ENTRY, platform.bx, platform.by, platform.bz, platform.o, BUNNY_SPAWN_TYPE, BUNNY_DESPAWN_MS)
    end)
    if not okBunny then
        --print("|cffffcc00[Shu]|r SpawnCreature(Water Spout Bunny, 60488) indisponible (" .. tostring(bunny) .. ").")
    elseif not bunny then
        --print("|cffffcc00[Shu]|r SpawnCreature(Water Spout Bunny, 60488) a renvoye nil (aucune Bunny creee).")
    else
        pcall(function() bunny:SetData(0, 1) end)

        -- Cast direct (bypass SmartAI) de l'aura d'avertissement, tout
        -- de suite apres le spawn -- meme tick, reference garantie valide.
        local okWarn, errWarn = pcall(function()
            bunny:CastSpell(bunny, SPELL_WATER_SPOUT_WARNING, false)
        end)
        if not okWarn then
            --print("|cffff0000[Shu]|r CastSpell(Bunny, Water Spout Warning) a echoue : " .. tostring(errWarn))
        end

        bunny:RegisterEvent(function(eventId, delay, repeats, bunnyArg)
            if not bunnyArg then return end
            local okBunnyWorld, bunnyInWorld = pcall(function() return bunnyArg:IsInWorld() end)
            if not okBunnyWorld or not bunnyInWorld then return end

            local okBurst, errBurst = pcall(function()
                bunnyArg:CastSpell(bunnyArg, SPELL_WATER_SPOUT_BURST, false)
            end)
            if not okBurst then
                --print("|cffff0000[Shu]|r CastSpell(Bunny, Water Spout Burst) a echoue : " .. tostring(errBurst))
            end

            local okGeyser, errGeyser = pcall(function()
                bunnyArg:CastSpell(bunnyArg, SPELL_WATER_SPOUT_GEYSER_AURA, false)
            end)
            if not okGeyser then
                --print("|cffff0000[Shu]|r CastSpell(Bunny, Water Spout Geyser Aura) a echoue : " .. tostring(errGeyser))
            end

            bunnyArg:RegisterEvent(function(eventId2, delay2, repeats2, bunnyArg2)
                if not bunnyArg2 then return end
                pcall(function() bunnyArg2:RemoveAura(SPELL_WATER_SPOUT_WARNING) end)
            end, 2000, 1)
        end, WAIT_BEFORE_CAST_MS, 1)
    end

    creature:RegisterEvent(function(eventId, delay, repeats, creatureArg)
        if not creatureArg then return end
        local okWorld2, inWorld2 = pcall(function() return creatureArg:IsInWorld() end)
        if not okWorld2 or not inWorld2 then return end

        CreditNearbyPlayers(creatureArg, platform)

        -- Projection au DEBUT du cast (correction demandee : c'est a ce
        -- moment que les eclaboussures apparaissent, pas a la fin).
        KnockbackNearbyPlayers(creatureArg, platform)

        local okCast, errCast = pcall(function()
            creatureArg:CastSpell(creatureArg, SPELL_WATER_JET, false)
        end)
        if not okCast then
            --print("|cffff0000[Shu]|r CastSpell a echoue : " .. tostring(errCast))
        end

        local okAoF, errAoF = pcall(function()
            creatureArg:CastSpellAoF(platform.x, platform.y, platform.z, SPELL_WATER_JET, false)
        end)
        if not okAoF then
            --print("|cffffcc00[Shu]|r CastSpellAoF indisponible pour l'eclaboussure au sol (" .. tostring(errAoF) .. ").")
        end
    end, WAIT_BEFORE_CAST_MS, 1)

    creature:RegisterEvent(function(eventId, delay, repeats, creatureArg)
        if not creatureArg then return end
        RunShuCycle(creatureArg)
    end, CYCLE_INTERVAL_MS, 1)
end

local function OnShuAIUpdate(event, creature, diff)
    local guid = creature:GetGUIDLow()
    if not shuState[guid] then
        shuState[guid] = { started = true }
        --print("|cff00ff88[Shu]|r Cycle demarre pour Shu (guid=" .. tostring(guid) .. ").")
        RunShuCycle(creature)
    end
end

local ok, err = pcall(function()
    RegisterCreatureEvent(SHU_ENTRY, AIUPDATE_EVENT_ID, OnShuAIUpdate)
end)
if not ok then
    --print("|cffff0000[Shu]|r RegisterCreatureEvent a echoue : " .. tostring(err))
end

local cooldown_players = {}

local function OnQuestAccept(event, player, questId)
    if questId ~= QUEST_ID then return end
    cooldown_players[player:GetGUIDLow()] = nil
end

local function OnQuestAbandon(event, player, questId)
    if questId ~= QUEST_ID then return end
    cooldown_players[player:GetGUIDLow()] = nil
end

RegisterPlayerEvent(19, OnQuestAccept)
RegisterPlayerEvent(20, OnQuestAbandon)
