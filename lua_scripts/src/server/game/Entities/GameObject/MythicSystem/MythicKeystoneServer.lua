-- ============================================================
--  MythicKeystoneServer.lua  –  Côté SERVEUR (AIO)
--  TrinityCore 3.3.5 + Eluna + AIO
--
--  Intègre SystemTimer :
--    • Le compte à rebours MK (10 s) est géré via le moteur
--      SystemTimer (stockage activeTimers, pause/reprise).
--    • Les handlers SystemTimer (StartTimer / TogglePause /
--      StopTimer / RequestState) restent disponibles pour
--      un usage autonome (/timer).
-- ============================================================

local AIO = AIO or require("AIO")
local MKS = {}

-- ─────────────────────────────────────────────────────────────
-- CONFIGURATION
-- ─────────────────────────────────────────────────────────────
MKS.Config = {
    KEYSTONE_ITEM_ID  = 138019,
    KEYSTONE_GO_ENTRY = 246779,
    MAX_LEVEL          = 20,
    COUNTDOWN_SECONDS  = 10,
    DEBUG              = false,

    DUNGEONS = {
	-- [S0 - M0] Les Terres de Fyra
        [1] = {
            mapId = 732, name = "Les Terres de Fyra", bossCount = 14, timer = 2400,
            bosses = {
                [7000110]=true, 
				[7000143]=true, 
				[7000103]=true, 
				[7000102]=true, 
				[7000100]=true,
                [7000131]=true, 
				[7000113]=true, 
				[7000111]=true, 
				[7000109]=true, 
				[7000108]=true,
				[7000112]=true,
				[7000139]=true,
				[7000130]=true,
				[7000129]=true,
            },
        },
	-- [S1 - M1] Les Terres de Feu
        [2] = {
            mapId = 736, name = "Les Terres de Feu", bossCount = 14, timer = 2700,
            bosses = {
                [8000110]=true,
				[8000143]=true,
				[8000103]=true,
				[8000102]=true,
				[8000100]=true,
				[8000131]=true,
				[8000113]=true,
				[8000111]=true,
				[8000109]=true,
				[8000108]=true,
				[8000139]=true,
				[8000112]=true,
				[8000130]=true,
				[8000129]=true,
            },
        },
	-- [S2 - M2] Palais Mogu'Shan
        [3] = {
            mapId = 750, name = "Palais Mogu'Shan", bossCount = 10, timer = 2700,
            bosses = {
                [9100014]=true, 
				[9100029]=true, 
				[9100024]=true, 
				[9100030]=true, 
				[9100016]=true, 
				[9100017]=true,
				[9100020]=true,
				[9100033]=true,
				[9100034]=true,
				[9100018]=true,
            },
        },
	-- [S2 - M2] Serpent de jade
        [4] = {
            mapId = 763, name = "Serpent de jade", bossCount = 4, timer = 1800,
            bosses = {
                [9100003]=true, 
				[9100001]=true, 
				[9000022]=true, 
				[9100013]=true,
            },
        },
	-- [S3 - M3] Caveaux Mogu'Shan
        [5] = {
            mapId = 751, name = "Caveaux Mogu'Shan", bossCount = 7, timer = 2700,
            bosses = {
                [5100104]=true,
				[5100106]=true,
				[5100110]=true,
				[5100117]=true,
				[5100123]=true,
				[5100122]=true,
				[5100116]=true,
            },
        },
	-- [S3 - M3] Cognefort
		[6] = {
            mapId = 734, name = "Cognefort", bossCount = 11, timer = 2700,
            bosses = {
                [650014]=true,
				[5100124]=true,
				[5100125]=true,
				[5100126]=true,
				[5100127]=true,
				[5100148]=true,
				[5100128]=true,
				[9000359]=true,
				[9000371]=true,
				[9000386]=true,
				[9000384]=true,
            },
        },
	-- [S4 - M4] Coeur de la peur
		[7] = {
            mapId = 779, name = "Coeur de la peur", bossCount = 6, timer = 2700,
            bosses = {
                [62980]=true,
				[62543]=true,
				[62164]=true,
				[62397]=true,
				[62511]=true,
				[62837]=true,
            },
        },
	-- [S4 - M4] Quais de Fer
		[8] = {
            mapId = 791, name = "Quais de Fer", bossCount = 2, timer = 2700,
            bosses = {
                [170115]=true,
				[170551]=true,
            },
        },
	-- [S5 - M5] La cime du Vortex
		[9] = {
            mapId = 776, name = "La cime du Vortex", bossCount = 1, timer = 2700,
            bosses = {
                [43875]=true,
            },
        },
	-- [S5 - M5] Terrasse Printanière
		[10] = {
            mapId = 765, name = "Terrasse Printanière", bossCount = 6, timer = 2700,
            bosses = {
                [60583]=true,
				[60585]=true,
				[60586]=true,
				[62983]=true,
				[62442]=true,
				[60999]=true,
            },
        },
	-- [S6 - M6] Temple de Niuzao
		[11] = {
            mapId = 778, name = "Temple de Niuzao", bossCount = 3, timer = 2700,
            bosses = {
                [61567]=true,
				[61485]=true,
				[62205]=true,
            },
        },
	-- [S6 - M6] Orée du Ciel
		[12] = {
            mapId = 795, name = "Orée du Ciel", bossCount = 3, timer = 2700,
            bosses = {
                [184720]=true,
				[194285]=true,
				[184730]=true,
            },
        },
	-- [S7 - M7] Puits d'éternité
		[13] = {
            mapId = 794, name = "Puits d'éternité", bossCount = 2, timer = 2700,
            bosses = {
                [55085]=true,
				[54853]=true,
            },
        },
	-- [S7 - M7] Salles des Valeureux
		[14] = {
            mapId = 796, name = "Salles des Valeureux", bossCount = 3, timer = 2700,
            bosses = {
                [94960]=true,
				[106320]=true,
				[99868]=true,
            },
        },
	-- [S8 - M8] Palais Sacrenuit
		[15] = {
            mapId = 797, name = "Palais Sacrenuit", bossCount = 6, timer = 2700,
            bosses = {
                [102263]=true,
				[112255]=true,
				[104288]=true,
				[104881]=true,
				[111210]=true,
				[101002]=true,
            },
        },
	-- [M+FULL] Antorus Trone Ardent
		[16] = {
            mapId = 737, name = "Antorus", bossCount = 12, timer = 2700,
            bosses = {
                [122366]=true,
				[122469]=true,
				[122468]=true,
				[122467]=true,
				[121975]=true,
				[124828]=true,
				[126268]=true,
				[125886]=true,
				[126267]=true,
				[125885]=true,
				[125893]=true,
				[126266]=true,
            },
        },
    },

    DIFFICULTY_MULT = {
        [1]=1.00,  [2]=1.08,  [3]=1.18,  [4]=1.28,  [5]=1.40,
        [6]=1.54,  [7]=1.68,  [8]=1.84,  [9]=2.00,  [10]=2.20,
        [11]=2.40, [12]=2.62, [13]=2.86, [14]=3.10, [15]=3.40,
        [16]=3.70, [17]=4.00, [18]=4.35, [19]=4.70, [20]=5.10,
    },

    AFFIXES = {
        [2]  = { id=1, name="Fortifié",       icon="ability_toughness",            desc="Les unités ennemies normales ont 20 % de PV supplémentaires et infligent jusqu'à 20 % de dégâts supplémentaires." },
        [4]  = { id=2, name="Tyrannique",     icon="achievement_boss_archaedas",   desc="Les boss ont 25 % de PV supplémentaires. Leurs dégâts sont augmentés de 15 % au maximum." },
        [7]  = { id=3, name="Tourbillonnant", icon="spell_nature_cyclone",         desc="En combat, les ennemis invoquent périodiquement des tourbillons dévastateurs." },
        [10] = { id=4, name="Explosif",       icon="spell_fire_felflamering_red",  desc="En combat, les ennemis invoquent périodiquement des orbes explosifs." },
        [14] = { id=5, name="Orgueilleux",    icon="spell_animarevendreth_buff",   desc="Vaincre des ennemis remplit les joueurs de fierté, créant une manifestation de l'orgueil." },
    },

    -- REWARDS supprimé : le loot est désormais tiré aléatoirement
    -- depuis la table `mythic_loot` en DB (voir GiveRewards ci-dessous).


}

-- ─────────────────────────────────────────────────────────────
-- ÉTAT DES RUNS
-- ─────────────────────────────────────────────────────────────
MKS.Runs       = {}
MKS.PlayerData = {}

-- ─────────────────────────────────────────────────────────────
-- SYSTEMTIMER – MOTEUR INTERNE
--   activeTimers[guid] = { duration, startTime, label,
--                          paused, pausedAt, elapsed }
--
--  Utilisé :
--    1) par les handlers /timer (usage autonome)
--    2) par MK pour gérer le countdown pré-run
-- ─────────────────────────────────────────────────────────────
local activeTimers = {}

local function ST_GetTime()    return os.time() end
local function ST_GUID(player) return player:GetGUIDLow() end

-- Démarre (ou redémarre) un timer pour le joueur
local function ST_Start(player, duration, label)
    local guid = ST_GUID(player)
    label = tostring(label or "Timer")
    activeTimers[guid] = {
        duration  = duration,
        startTime = ST_GetTime(),
        label     = label,
        paused    = false,
        pausedAt  = nil,
        elapsed   = 0,
    }
    -- Notifie le client SystemTimer (overlay visuel)
    AIO.Handle(player, "SystemTimer", "TimerStarted", duration, label, ST_GetTime())
end

-- Arrête et nettoie le timer
local function ST_Stop(player)
    local guid = ST_GUID(player)
    activeTimers[guid] = nil
    AIO.Handle(player, "SystemTimer", "TimerStopped")
end

-- ─────────────────────────────────────────────────────────────
-- HANDLERS SYSTEMTIMER (usage autonome : /timer)
-- ─────────────────────────────────────────────────────────────
local TimerHandlers = AIO.AddHandlers("SystemTimer", {})

function TimerHandlers.StartTimer(player, duration, label)
    if not player or not duration then return end
    duration = tonumber(duration)
    if not duration or duration <= 0 or duration > 86400 then
        AIO.Handle(player, "SystemTimer", "Error", "Durée invalide (1-86400 secondes).")
        return
    end
    ST_Start(player, duration, label)
end

function TimerHandlers.TogglePause(player)
    if not player then return end
    local guid = ST_GUID(player)
    local t = activeTimers[guid]
    if not t then
        AIO.Handle(player, "SystemTimer", "Error", "Aucun timer actif.")
        return
    end
    local now = ST_GetTime()
    if t.paused then
        local pauseDuration = now - t.pausedAt
        t.startTime = t.startTime + pauseDuration
        t.paused    = false
        t.pausedAt  = nil
        AIO.Handle(player, "SystemTimer", "TimerResumed", t.startTime)
    else
        t.paused   = true
        t.pausedAt = now
        local elapsed = now - t.startTime
        AIO.Handle(player, "SystemTimer", "TimerPaused", elapsed)
    end
end

function TimerHandlers.StopTimer(player)
    if not player then return end
    ST_Stop(player)
end

function TimerHandlers.RequestState(player)
    if not player then return end
    local guid = ST_GUID(player)
    local t = activeTimers[guid]
    if not t then
        AIO.Handle(player, "SystemTimer", "NoTimer")
        return
    end
    AIO.Handle(player, "SystemTimer", "StateSync",
        t.duration,
        t.startTime,
        t.label,
        t.paused,
        t.pausedAt or 0
    )
end

-- ─────────────────────────────────────────────────────────────
-- UTILITAIRES MK
-- ─────────────────────────────────────────────────────────────
local function Log(msg)
    if MKS.Config.DEBUG then print("[MKS] " .. tostring(msg)) end
end

local function GetPlayerByGUIDLow(guidLow)
    local players = GetPlayersInWorld and GetPlayersInWorld() or {}
    for _, p in ipairs(players) do
        if p and p:GetGUIDLow() == guidLow then return p end
    end
    return nil
end

local function GetDungeonByMap(mapId)
    for id, d in pairs(MKS.Config.DUNGEONS) do
        if d.mapId == mapId then return id, d end
    end
    return nil, nil
end

local function GetTimeRemaining(run)
    return math.max(0, run.timer - (os.time() - run.startTime))
end

local function GetActiveAffixes(level)
    local list = {}
    for minLvl, aff in pairs(MKS.Config.AFFIXES) do
        if level >= minLvl then
            table.insert(list, { id=aff.id, name=aff.name, icon=aff.icon, desc=aff.desc })
        end
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

-- ─────────────────────────────────────────────────────────────
-- HELPERS AFFIXES
-- ─────────────────────────────────────────────────────────────

-- Retourne true si l'affix de nom donné est actif pour ce niveau de run
local function HasAffix(level, name)
    for minLvl, aff in pairs(MKS.Config.AFFIXES) do
        if level >= minLvl and aff.name == name then return true end
    end
    return false
end

-- Retourne true si l'entry est un boss du donjon du run
local function IsBoss(run, entry)
    local dungeon = MKS.Config.DUNGEONS[run.dungeonId]
    return dungeon and dungeon.bosses and dungeon.bosses[entry] == true
end

-- ─────────────────────────────────────────────────────────────
-- PERSISTANCE JOUEUR
-- ─────────────────────────────────────────────────────────────
local function LoadPlayerData(player)
    local guid = player:GetGUIDLow()
    if MKS.PlayerData[guid] then return end
    -- Structure : { Dungeon=id_actif, Levels={ [dungeonId]=niveau, ... } }
    MKS.PlayerData[guid] = { Dungeon=0, Levels={} }
    local q = CharDBQuery(string.format(
        "SELECT `value` FROM `character_mythic` WHERE `guid`=%d AND `source`='MK_Data'", guid))
    if q then
        local raw = q:GetString(0)
        -- Nouveau format : "dungeonActif|1:5,2:3,3:1"
        local dg, levelsStr = raw:match("^(%d+)|(.*)$")
        if dg then
            MKS.PlayerData[guid].Dungeon = tonumber(dg) or 0
            for part in levelsStr:gmatch("[^,]+") do
                local id, lv = part:match("^(%d+):(%d+)$")
                if id and lv then
                    MKS.PlayerData[guid].Levels[tonumber(id)] = tonumber(lv)
                end
            end
        else
            -- Ancien format "level,dungeon" – migration automatique
            local lv, oldDg = raw:match("^(%d+),(%d+)$")
            if lv and oldDg then
                local did = tonumber(oldDg) or 0
                local lvl = tonumber(lv) or 0
                MKS.PlayerData[guid].Dungeon = did
                if did > 0 and lvl > 0 then
                    MKS.PlayerData[guid].Levels[did] = lvl
                end
            end
        end
    end
end

local function SavePlayerData(player)
    local guid = player:GetGUIDLow()
    local d    = MKS.PlayerData[guid]
    if not d then return end
    -- Format : "dungeonActif|dungeonId:niveau,..."
    local parts = {}
    for id, lv in pairs(d.Levels or {}) do
        if lv and lv > 0 then
            table.insert(parts, id .. ":" .. lv)
        end
    end
    local val = string.format("%d|%s", d.Dungeon or 0, table.concat(parts, ","))
    CharDBExecute(string.format(
        "REPLACE INTO `character_mythic` (`guid`,`source`,`value`) VALUES (%d,'MK_Data','%s')",
        guid, val))
end

-- GetVar("Level")  > niveau du donjon actif
-- GetVar("Dungeon") > id du donjon actif
-- GetDungeonLevel(player, dungeonId) > niveau spécifique d'un donjon
local function GetVar(player, key)
    LoadPlayerData(player)
    local d = MKS.PlayerData[player:GetGUIDLow()]
    if key == "Level" then
        local did = d.Dungeon or 0
        return (did > 0 and d.Levels and d.Levels[did]) or 0
    end
    return d[key] or 0
end

local function GetDungeonLevel(player, dungeonId)
    LoadPlayerData(player)
    local d = MKS.PlayerData[player:GetGUIDLow()]
    return (d.Levels and d.Levels[dungeonId]) or 0
end

local function SetVar(player, key, val)
    LoadPlayerData(player)
    local d = MKS.PlayerData[player:GetGUIDLow()]
    if key == "Level" then
        local did = d.Dungeon or 0
        if did > 0 then
            if not d.Levels then d.Levels = {} end
            d.Levels[did] = tonumber(val) or 0
        end
    else
        d[key] = tonumber(val) or 0
    end
    SavePlayerData(player)
end

-- SetDungeonLevel : fixe le niveau d'un donjon précis (indépendant du donjon actif)
local function SetDungeonLevel(player, dungeonId, level)
    LoadPlayerData(player)
    local d = MKS.PlayerData[player:GetGUIDLow()]
    if not d.Levels then d.Levels = {} end
    d.Levels[dungeonId] = tonumber(level) or 0
    SavePlayerData(player)
end

-- ─────────────────────────────────────────────────────────────
-- BROADCAST
-- ─────────────────────────────────────────────────────────────
local function BroadcastRun(instanceId, handler, ...)
    local run = MKS.Runs[instanceId]
    if not run then return end
    for guidLow in pairs(run.players) do
        local p = GetPlayerByGUIDLow(guidLow)
        if p and p:IsInWorld() then
            AIO.Handle(p, "MKClient", handler, ...)
        end
    end
end

-- ─────────────────────────────────────────────────────────────
-- PAYLOAD UI
-- ─────────────────────────────────────────────────────────────
local function BuildUIPayload(player)
    local level     = GetVar(player, "Level")
    local dungeonId = GetVar(player, "Dungeon")
    local dungeon   = MKS.Config.DUNGEONS[dungeonId]
    if not dungeon then return nil end
    return {
        level     = level,
        dungeonId = dungeonId,
        dungeon   = dungeon.name,
        timer     = dungeon.timer,
        affixes   = GetActiveAffixes(level),
        mult      = MKS.Config.DIFFICULTY_MULT[level] or 1.0,
    }
end

local function SendOpenUI(player)
    local payload = BuildUIPayload(player)
    if not payload then
        AIO.Handle(player, "MKClient", "NoKeystone")
        return
    end
    AIO.Handle(player, "MKClient", "OpenUI", payload)
end

local function SendSelectDungeon(player)
    LoadPlayerData(player)
    local guid = player:GetGUIDLow()
    local levels = MKS.PlayerData[guid] and MKS.PlayerData[guid].Levels or {}
    -- Enrichit chaque donjon avec le niveau actuel du joueur
    local dungeonsWithLevel = {}
    for id, info in pairs(MKS.Config.DUNGEONS) do
        dungeonsWithLevel[id] = {
            mapId      = info.mapId,
            name       = info.name,
            bossCount  = info.bossCount,
            timer      = info.timer,
            playerLevel = levels[id] or 0,
        }
    end
    AIO.Handle(player, "MKClient", "OpenSelectDungeon", { dungeons = dungeonsWithLevel })
end

local function SendTimerUpdate(instanceId)
    local run = MKS.Runs[instanceId]
    if not run or not run.activated or run.completed then return end
    BroadcastRun(instanceId, "UpdateTimer", {
        remaining  = GetTimeRemaining(run),
        depleted   = run.depleted,
        bossKilled = run.bossesKilled,
        totalBoss  = run.totalBosses,
    })
end

-- ─────────────────────────────────────────────────────────────
-- RÉCOMPENSES
-- ─────────────────────────────────────────────────────────────
-- Correspondance dungeonId -> tier DB mythic_loot
-- (basé sur le palier du donjon, pas le niveau de clé)
local DUNGEON_TO_TIER = {
    [1]  = "M0",     -- Terres de Fyra
    [2]  = "M+1",    -- Terres de Feu
    [3]  = "M+2",    -- Palais Mogu'Shan
    [4]  = "M+2",    -- Serpent de jade
    [5]  = "M+3",    -- Caveaux Mogu'Shan
    [6]  = "M+3",    -- Cognefort
    [7]  = "M+4",    -- Coeur de la peur
    [8]  = "M+4",    -- Quais de Fer
    [9]  = "M+5",    -- La cime du Vortex
    [10] = "M+5",    -- Terrasse Printaniere
    [11] = "M+6",    -- Temple de Niuzao
    [12] = "M+6",    -- Oree du Ciel
    [13] = "M+7",    -- Puits d'eternite
    [14] = "M+7",    -- Salles des Valeureux
    [15] = "M+8",    -- Palais Sacrenuit
	[16] = "M+FULL", -- Antorus Trone Ardent
}

-- Nombre d'items à distribuer selon le niveau de clé
local function GetLootCount(level)
    if level <= 5  then return 1 end
    if level <= 10 then return 2 end
    if level <= 15 then return 3 end
    return 4
end

local function GiveRewards(player, level, dungeonId)
    -- Le tier est uniquement déterminé par le donjon.
    -- M+FULL s'obtient exclusivement sur le Palais Sacrenuit (dungeonId 16).
    local tier = DUNGEON_TO_TIER[dungeonId]
    if not tier then
        Log("GiveRewards: pas de tier pour dungeonId=" .. tostring(dungeonId))
        return
    end

    -- Récupère TOUS les item_id disponibles pour ce tier + donjon
    local query = CharDBQuery(string.format(
        "SELECT `item_id` FROM `mythic_loot` WHERE `tier`='%s' AND `dungeon_id`=%d",
        tier, dungeonId or 0
    ))

    -- Fallback : si aucun item pour ce donjon spécifique, prend tout le tier
    if not query then
        query = CharDBQuery(string.format(
            "SELECT `item_id` FROM `mythic_loot` WHERE `tier`='%s'",
            tier
        ))
    end

    if not query then
        Log("GiveRewards: aucun loot trouvé pour tier=" .. tier)
        return
    end

    -- Construit la liste des item_id disponibles
    local pool = {}
    repeat
        table.insert(pool, query:GetUInt32(0))
    until not query:NextRow()

    if #pool == 0 then
        Log("GiveRewards: pool vide pour tier=" .. tier)
        return
    end

    -- Tire aléatoirement N items distincts (sans remise)
    local count   = GetLootCount(level)
    local picked  = {}
    local usedIdx = {}

    math.randomseed(os.time() + player:GetGUIDLow())

    for i = 1, math.min(count, #pool) do
        local idx
        repeat
            idx = math.random(1, #pool)
        until not usedIdx[idx]
        usedIdx[idx] = true
        table.insert(picked, pool[idx])
    end

    for _, itemId in ipairs(picked) do
        local added = player:AddItem(itemId, 1)
        if added then
            Log(string.format("GiveRewards: joueur %s reçoit item %d (tier=%s donjon=%d)",
                player:GetName(), itemId, tier, dungeonId or 0))
        else
            -- Inventaire plein : envoi par boîte aux lettres via Eluna natif
            SendMail(
                "Récompense Mythic+",
                "Votre inventaire était plein. Voici votre récompense de fin de donjon.",
                player:GetGUIDLow(),
                0,       -- expéditeur système
                61,      -- stationery neutre
                0,       -- délai immédiat
                0,       -- argent
                0,       -- COD
                itemId,
                1
            )
            Log(string.format("GiveRewards: inventaire plein – item %d envoyé par mail à %s",
                itemId, player:GetName()))
        end
    end
end

-- ─────────────────────────────────────────────────────────────
-- COMPLÉTION DE RUN
-- ─────────────────────────────────────────────────────────────
local function CompleteRun(instanceId)
    local run = MKS.Runs[instanceId]
    if not run or run.completed then return end
    run.completed = true

    local remaining    = GetTimeRemaining(run)
    local inTime       = (remaining > 0)
    local upgradeBonus = 0
    if inTime then
        upgradeBonus = (remaining / run.timer >= 0.4) and 2 or 1
    end

    for guidLow in pairs(run.players) do
        local player = GetPlayerByGUIDLow(guidLow)
        if player and player:IsInWorld() then
            local rewardLevel = inTime and run.level or math.max(1, run.level - 2)
            GiveRewards(player, rewardLevel, run.dungeonId)
            local newLevel = run.level
            if upgradeBonus > 0 then
                newLevel = math.min(run.level + upgradeBonus, MKS.Config.MAX_LEVEL)
            end
            player:RemoveItem(MKS.Config.KEYSTONE_ITEM_ID, 1)
            if inTime then
                player:AddItem(MKS.Config.KEYSTONE_ITEM_ID, 1)
                -- Sauvegarde le nouveau niveau pour ce donjon spécifiquement
                SetDungeonLevel(player, run.dungeonId, newLevel)
            else
                -- Run déplété : remet le donjon actif à 0 mais conserve
                -- la progression de tous les autres donjons
                SetVar(player, "Dungeon", 0)
            end
            AIO.Handle(player, "MKClient", "RunComplete", {
                inTime       = inTime,
                remaining    = remaining,
                upgradeBonus = upgradeBonus,
                newLevel     = newLevel,
                oldLevel     = run.level,
                dungeonId    = run.dungeonId,
                dungeon      = MKS.Config.DUNGEONS[run.dungeonId] and MKS.Config.DUNGEONS[run.dungeonId].name or "?",
            })
            -- Nettoie le SystemTimer de ce joueur si actif (cleanup sécurisé)
            ST_Stop(player)
        end
    end

    Log("Run terminé – instance=" .. instanceId .. "  inTime=" .. tostring(inTime))
    CreateLuaEvent(function() MKS.Runs[instanceId] = nil end, 30000, 1)
end

-- ─────────────────────────────────────────────────────────────
-- SCALING DES CRÉATURES
-- ─────────────────────────────────────────────────────────────
local function ApplyScalingToMap(map, mult)
    -- GetCreatures() n'existe pas dans l'API Eluna TrinityCore 3.3.5.
    -- Le scaling est appliqué créature par créature via OnCreatureSpawn.
    if not map then return end
    Log("Scaling x" .. tostring(mult) .. " enregistré – appliqué via OnCreatureSpawn")
end

local function OnCreatureSpawn(event, creature)
    local run = MKS.Runs[creature:GetInstanceId()]
    if not run or not run.activated then return end

    local level = run.level
    local mult  = MKS.Config.DIFFICULTY_MULT[level] or 1.0
    local entry = creature:GetEntry()
    local boss  = IsBoss(run, entry)

    -- ── Multiplicateurs de base (difficulté de la clé) ────────
    local hpMult  = mult
    local dmgMult = mult

    -- ── Affix Fortifié : trash +20% PV et +20% dégâts ─────────
    if not boss and HasAffix(level, "Fortifié") then
        hpMult  = hpMult  * 1.20
        dmgMult = dmgMult * 1.20
    end

    -- ── Affix Tyrannique : boss +25% PV et +15% dégâts ────────
    if boss and HasAffix(level, "Tyrannique") then
        hpMult  = hpMult  * 1.25
        dmgMult = dmgMult * 1.15
    end

    -- ── Application des PV ────────────────────────────────────
    local hp = math.floor(creature:GetMaxHealth() * hpMult)
    creature:SetMaxHealth(hp)
    creature:SetHealth(hp)

    -- ── Application des dégâts (bonus attackpower flat) ───────
    -- SetModifierValue n'existe pas en Eluna 3.3.5 ; on passe par
    -- un aura de buff de stats si dmgMult > mult, sinon on logge.
    -- Le moyen le plus fiable sans spell custom est de stocker le
    -- facteur dans le run pour l'utiliser dans un hook OnDamage.
    if not run.dmgScaling then run.dmgScaling = {} end
    run.dmgScaling[entry] = dmgMult

    Log(string.format("Spawn entry=%d boss=%s hpMult=%.2f dmgMult=%.2f",
        entry, tostring(boss), hpMult, dmgMult))
end

-- ── Modificateur de dégâts appliqué à la volée ────────────────
-- Eluna 3.3.5 expose OnDamage (event 6) sur les créatures.
-- On l'enregistre globalement via RegisterCreatureEvent sur chaque
-- boss ; pour le trash on utilise un hook de map via
-- RegisterMapEvent si disponible, sinon on se limite aux boss.
local function OnCreatureDamage(event, creature, target, damage)
    local run = MKS.Runs[creature:GetInstanceId()]
    if not run or not run.dmgScaling then return damage end
    local entry  = creature:GetEntry()
    local factor = run.dmgScaling[entry]
    if not factor or factor <= 1.0 then return damage end
    -- Le facteur stocké inclut déjà mult de base ; on applique
    -- uniquement le surplus au-delà du mult de base.
    local base  = MKS.Config.DIFFICULTY_MULT[run.level] or 1.0
    local bonus = factor / base   -- ex : 1.20 pour Fortifié seul
    return math.floor(damage * bonus)
end

-- ─────────────────────────────────────────────────────────────
-- MORT DE BOSS
-- ─────────────────────────────────────────────────────────────
local function OnCreatureDeath(event, creature, killer)
    local entry      = creature:GetEntry()
    local instanceId = creature:GetInstanceId()
    local run        = MKS.Runs[instanceId]
    if not run or run.completed then return end

    -- Vérifie que ce boss appartient bien au donjon du run en cours
    local dungeon = MKS.Config.DUNGEONS[run.dungeonId]
    if not dungeon or not dungeon.bosses or not dungeon.bosses[entry] then return end

    if run.killedEntries[entry] then
        Log("Boss " .. entry .. " déjà compté – ignoré")
        return
    end
    run.killedEntries[entry] = true
    run.bossesKilled = run.bossesKilled + 1
    BroadcastRun(instanceId, "BossKilled", run.bossesKilled, run.totalBosses)
    Log("Boss " .. entry .. " tué – " .. run.bossesKilled .. "/" .. run.totalBosses)
    if run.bossesKilled >= run.totalBosses then
        CompleteRun(instanceId)
    end
end

-- ─────────────────────────────────────────────────────────────
-- ENTRÉE EN INSTANCE
-- ─────────────────────────────────────────────────────────────
local function OnMapChange(event, player, ...)
    local mapId      = player:GetMapId()
    local instanceId = player:GetInstanceId()
    local dungeonId, dungeonData = GetDungeonByMap(mapId)
    if not dungeonId then return end
    local level    = GetVar(player, "Level")
    local pDungeon = GetVar(player, "Dungeon")
    if level <= 0 or pDungeon ~= dungeonId then return end

    if not MKS.Runs[instanceId] then
        MKS.Runs[instanceId] = {
            level        = level,
            dungeonId    = dungeonId,
            startTime    = nil,
            timer        = dungeonData.timer,
            bossesKilled = 0,
            totalBosses  = dungeonData.bossCount,
            killedEntries = {},
            players      = {},
            pending      = true,
            activated    = false,
            depleted     = false,
            completed    = false,
        }
        Log("Run pending – instance=" .. instanceId .. "  level=" .. level)
        ApplyScalingToMap(player:GetMap(), MKS.Config.DIFFICULTY_MULT[level] or 1.0)
    end

    local run = MKS.Runs[instanceId]
    run.players[player:GetGUIDLow()] = true
    SendOpenUI(player)
end

-- ─────────────────────────────────────────────────────────────
-- SORTIE D'INSTANCE
-- ─────────────────────────────────────────────────────────────
local function OnMapLeave(event, player, ...)
    local instanceId = player:GetInstanceId()
    local run        = MKS.Runs[instanceId]
    if not run then return end
    run.players[player:GetGUIDLow()] = nil
    local count = 0
    for _ in pairs(run.players) do count = count + 1 end
    if count == 0 then
        MKS.Runs[instanceId] = nil
        Log("Instance vide – nettoyage " .. instanceId)
    end
end

-- ─────────────────────────────────────────────────────────────
-- TICK GLOBAL (5 s)
-- ─────────────────────────────────────────────────────────────
local function TimerTick()
    for instanceId, run in pairs(MKS.Runs) do
        if run.activated and not run.completed then
            local remaining = GetTimeRemaining(run)
            if remaining <= 0 and not run.depleted then
                run.depleted = true
                BroadcastRun(instanceId, "RunDepleted")
                Log("Run déplété – instance=" .. instanceId)
            end
            SendTimerUpdate(instanceId)
        end
    end
end

-- ─────────────────────────────────────────────────────────────
-- INTERACTION GAMEOBJECT
-- ─────────────────────────────────────────────────────────────

-- Activé à chaque clic sur le GO (event 2 = GAMEOBJECT_EVENT_ON_USE)
-- Équivalent de la commande GM : .gob activate <guid>
-- Déclenche l'animation du GO (ouverture, particules, son…)
local function OnGOGossipHello(event, player, gameObject)
    -- Déclenche l'animation du GO et la maintient ouverte 5 secondes (5000 ms).
    -- Sans délai explicite, data0 = 0 dans la DB > le GO se referme instantanément.
    gameObject:UseDoorOrButton(10000)

    local level     = GetVar(player, "Level")
    local dungeonId = GetVar(player, "Dungeon")
    if level > 0 and dungeonId > 0 then
        SendOpenUI(player)
    else
        SendSelectDungeon(player)
    end
    player:GossipComplete()
end

-- ─────────────────────────────────────────────────────────────
-- HANDLERS CLIENT > SERVEUR  (MK)
-- ─────────────────────────────────────────────────────────────
local MKHandlers = AIO.AddHandlers("MKServer", {})

function MKHandlers.OpenUI(player)
    local level     = GetVar(player, "Level")
    local dungeonId = GetVar(player, "Dungeon")
    if level > 0 and dungeonId > 0 then
        SendOpenUI(player)
    else
        SendSelectDungeon(player)
    end
end

-- "Changer donjon" : retire le Keystone, remet Dungeon=0.
-- Les niveaux de chaque donjon restent intacts dans Levels{}.
function MKHandlers.ChangeDungeon(player)
    if player:HasItem(MKS.Config.KEYSTONE_ITEM_ID) then
        player:RemoveItem(MKS.Config.KEYSTONE_ITEM_ID, 1)
    end
    SetVar(player, "Dungeon", 0)
    SendSelectDungeon(player)
end

function MKHandlers.RequestStatus(player)
    local instanceId = player:GetInstanceId()
    local run        = MKS.Runs[instanceId]
    if not run then
        AIO.Handle(player, "MKClient", "NoActiveRun")
        return
    end
    AIO.Handle(player, "MKClient", "UpdateTimer", {
        remaining  = GetTimeRemaining(run),
        depleted   = run.depleted,
        bossKilled = run.bossesKilled,
        totalBoss  = run.totalBosses,
    })
end

function MKHandlers.GiveKeystone(player, dungeonId)
    dungeonId     = tonumber(dungeonId) or 0
    local dungeon = MKS.Config.DUNGEONS[dungeonId]
    if not dungeon then
        AIO.Handle(player, "MKClient", "Error", "Donjon invalide.")
        return
    end
    if player:HasItem(MKS.Config.KEYSTONE_ITEM_ID) then
        AIO.Handle(player, "MKClient", "Error", "Vous devez détruire votre Clé mythique.")
        return
    end
    -- Récupère le niveau propre à CE donjon (0 si jamais fait > niveau 1)
    local level = GetDungeonLevel(player, dungeonId)
    if level <= 0 then level = 1 end
    player:AddItem(MKS.Config.KEYSTONE_ITEM_ID, 1)
    SetVar(player, "Dungeon", dungeonId)
    SetDungeonLevel(player, dungeonId, level)
    AIO.Handle(player, "MKClient", "KeystoneGranted", {
        level     = level,
        dungeonId = dungeonId,
        dungeon   = dungeon.name,
        timer     = dungeon.timer,
        affixes   = GetActiveAffixes(level),
        mult      = MKS.Config.DIFFICULTY_MULT[level] or 1.0,
    })
    Log("Clé mythique donné à " .. player:GetName() .. " – " .. dungeon.name .. " niv." .. level)
end

function MKHandlers.UpgradeKeystone(player)
    local level = GetVar(player, "Level")
    if level <= 0 then
        AIO.Handle(player, "MKClient", "Error", "Pas de Clé mythique actif.")
        return
    end
    if level >= MKS.Config.MAX_LEVEL then
        AIO.Handle(player, "MKClient", "Error", "Niveau maximum atteint.")
        return
    end
    local cost = level * 500000
    if player:GetMoney() < cost then
        AIO.Handle(player, "MKClient", "Error",
            string.format("Il vous faut %dg pour améliorer.", level * 50))
        return
    end
    player:ModifyMoney(-cost)
    local newLevel  = level + 1
    SetVar(player, "Level", newLevel)
    local dungeonId = GetVar(player, "Dungeon")
    local dungeon   = MKS.Config.DUNGEONS[dungeonId]
    AIO.Handle(player, "MKClient", "KeystoneUpgraded", {
        level     = newLevel,
        dungeonId = dungeonId,
        dungeon   = dungeon and dungeon.name or "?",
        timer     = dungeon and dungeon.timer or 0,
        affixes   = GetActiveAffixes(newLevel),
        mult      = MKS.Config.DIFFICULTY_MULT[newLevel] or 1.0,
    })
    Log("Clé mythique amélioré " .. level .. " > " .. newLevel .. " par " .. player:GetName())
end

-- ─────────────────────────────────────────────────────────────
-- ACTIVATION DU RUN
--   Utilise ST_Start() pour lancer l'overlay SystemTimer côté
--   client (chiffre + logo faction + sablier) pendant le
--   compte à rebours, puis démarre le vrai timer MK.
-- ─────────────────────────────────────────────────────────────
function MKHandlers.ActivateRun(player, itemID)
    itemID = tonumber(itemID)
    if not itemID or itemID ~= MKS.Config.KEYSTONE_ITEM_ID then
        AIO.Handle(player, "MKClient", "Error", "Item invalide.")
        return
    end
    if not player:HasItem(MKS.Config.KEYSTONE_ITEM_ID) then
        AIO.Handle(player, "MKClient", "Error", "Clé mythique introuvable dans l'inventaire.")
        return
    end

    local mapId     = player:GetMapId()
    local dungeonId = GetVar(player, "Dungeon")
    local dungeon   = MKS.Config.DUNGEONS[dungeonId]

    if not dungeon or dungeon.mapId ~= mapId then
        AIO.Handle(player, "MKClient", "Error",
            "Vous devez entrez dans le donjon avant d'activer votre Clé mythique.")
        return
    end

    local instanceId = player:GetInstanceId()
    local run        = MKS.Runs[instanceId]

    if not run then
        local level = GetVar(player, "Level")
        MKS.Runs[instanceId] = {
            level        = level,
            dungeonId    = dungeonId,
            startTime    = nil,
            timer        = dungeon.timer,
            bossesKilled = 0,
            totalBosses  = dungeon.bossCount,
            killedEntries = {},
            players      = {},
            pending      = true,
            activated    = false,
            depleted     = false,
            completed    = false,
        }
        run = MKS.Runs[instanceId]
        ApplyScalingToMap(player:GetMap(), MKS.Config.DIFFICULTY_MULT[level] or 1.0)
        Log("Run créé à l'activation – instance=" .. instanceId .. "  level=" .. level)
    else
        -- Run déjà créé par OnMapChange : s'assure que le joueur y est enregistré
        run.players[player:GetGUIDLow()] = true
    end

    if run.activated then
        AIO.Handle(player, "MKClient", "Error", "Un run est déjà en cours dans cette instance.")
        return
    end
    if run.completed then
        AIO.Handle(player, "MKClient", "Error", "Ce run est déjà terminé.")
        return
    end

    run.players[player:GetGUIDLow()] = true   -- ajout AVANT la boucle broadcast
    run.pending = false

    local cdSec = MKS.Config.COUNTDOWN_SECONDS

    -- ── Lancer le compte à rebours via SystemTimer ────────────
    -- Chaque joueur du run reçoit l'overlay visuel SystemTimer
    -- (chiffre doré + logo faction + sablier).
    -- Le handler MKClient.StartCountdown est envoyé EN MÊME TEMPS
    -- pour que l'interface MK masque son bouton Activer.
    for guidLow in pairs(run.players) do
        local p = GetPlayerByGUIDLow(guidLow)
        if p and p:IsInWorld() then
            -- Overlay SystemTimer (chiffres + sablier)
            ST_Start(p, cdSec, "Mythic+ commence dans…")
            -- Notification à la frame MK (masque btnActivate, etc.)
            AIO.Handle(p, "MKClient", "StartCountdown", cdSec)
        end
    end
    Log("Countdown SystemTimer lancé – instance=" .. instanceId)

    -- ── Après cdSec secondes : démarrage effectif du run ─────
    CreateLuaEvent(function()
        local r = MKS.Runs[instanceId]
        if not r or r.completed then return end
        r.activated = true
        r.startTime = os.time()

        -- Arrête l'overlay SystemTimer pour tous les joueurs
        -- et lance le timer live MK
        for guidLow in pairs(r.players) do
            local p = GetPlayerByGUIDLow(guidLow)
            if p and p:IsInWorld() then
                ST_Stop(p)   -- ferme l'overlay SystemTimer
                AIO.Handle(p, "MKClient", "RunActivated", {
                    timer     = r.timer,
                    level     = r.level,
                    dungeonId = r.dungeonId,
                })
            end
        end
        Log("Run activé – instance=" .. instanceId)
    end, cdSec * 1000, 1)
end

-- ─────────────────────────────────────────────────────────────
-- COMMANDE .mk
-- ─────────────────────────────────────────────────────────────
local function OnPlayerCommand(event, player, command)
    if command == "mk" then
        MKHandlers.OpenUI(player)
        return false
    end
end

-- ─────────────────────────────────────────────────────────────
-- ENREGISTREMENTS ELUNA
-- ─────────────────────────────────────────────────────────────
RegisterGameObjectGossipEvent(MKS.Config.KEYSTONE_GO_ENTRY, 1, OnGOGossipHello)

RegisterPlayerEvent(3, function(event, player)
    LoadPlayerData(player)
    -- Restaure l'état du SystemTimer si le joueur avait un timer actif
    local guid = ST_GUID(player)
    if activeTimers[guid] then
        local t = activeTimers[guid]
        AIO.Handle(player, "SystemTimer", "StateSync",
            t.duration, t.startTime, t.label, t.paused, t.pausedAt or 0)
    end
end)

RegisterPlayerEvent(4, function(event, player)
    MKS.PlayerData[player:GetGUIDLow()] = nil
    -- On conserve activeTimers[guid] pour la reconnexion.
    -- Commenter la ligne suivante pour supprimer le timer à la déco :
    -- activeTimers[ST_GUID(player)] = nil
end)

RegisterPlayerEvent(16, OnMapChange)
RegisterPlayerEvent(17, OnMapLeave)
RegisterPlayerEvent(42, OnPlayerCommand)

-- Enregistre dynamiquement tous les boss de tous les donjons
for _, dungeon in pairs(MKS.Config.DUNGEONS) do
    if dungeon.bosses then
        for entry in pairs(dungeon.bosses) do
            RegisterCreatureEvent(entry, 4, OnCreatureDeath)
            RegisterCreatureEvent(entry, 3, OnCreatureSpawn)
            RegisterCreatureEvent(entry, 6, OnCreatureDamage)
        end
    end
end

CreateLuaEvent(TimerTick, 5000, 0)

-- ─────────────────────────────────────────────────────────────
-- INITIALISATION DB
-- ─────────────────────────────────────────────────────────────
CharDBExecute([[
    CREATE TABLE IF NOT EXISTS `character_mythic` (
        `guid`   INT(10) UNSIGNED NOT NULL,
        `source` VARCHAR(64)      NOT NULL,
        `value`  VARCHAR(255)     NOT NULL DEFAULT '',
        PRIMARY KEY (`guid`, `source`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
]])

Log("MythicKeystoneLoaded.")
--print("[Mythic+] Loaded configured gameobject entry=" .. MKS.Config.KEYSTONE_GO_ENTRY)
