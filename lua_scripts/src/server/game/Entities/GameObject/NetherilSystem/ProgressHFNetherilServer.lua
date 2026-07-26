local AIO = AIO or require("AIO")

local NETHERIL_GAMEOBJECT_ENTRY = 249570

local ACHIEVEMENT_ID = 5011
local LOCALE_FRFR_ID = 2

local L = {
    enUS = {
        header          = "Netheril Achievement Progress",
        achievementDone = "Achievement completed!",
        critSummary     = "Objectives Completed: %d/%d",
    },
    frFR = {
        header          = "Progression : Haut Fait Netheril",
        achievementDone = "Haut Fait termine !",
        critSummary     = "Objectifs accomplis : %d/%d",
    },
}

local NETHERIL_CRITERIA_BY_ENTRY = {
    [7000603] = { entry = 7000603, quantity = 40, criteriaId = 15024, label = { enUS = "Legion Minion",         frFR = "Sbire de la légion" } },
    [7000604] = { entry = 7000604, quantity = 10, criteriaId = 15025, label = { enUS = "Death Whisperer",       frFR = "Chuchoteuse de la mort" } },
    [7000601] = { entry = 7000601, quantity = 10, criteriaId = 15026, label = { enUS = "Champion of Wrath",     frFR = "Champion du courroux" } },
    [7000602] = { entry = 7000602, quantity = 20, criteriaId = 15027, label = { enUS = "Berserker of Wrath",    frFR = "Berserker du courroux" } },
    [7000609] = { entry = 7000609, quantity = 10, criteriaId = 15028, label = { enUS = "Assault Lieutenant",    frFR = "Lieutenant de l'assaut" } },
    [7000611] = { entry = 7000611, quantity = 10, criteriaId = 15029, label = { enUS = "Terror Assassin",       frFR = "Assassin de terreur" } },
    [7000608] = { entry = 7000608, quantity = 5,  criteriaId = 15030, label = { enUS = "Assault Commander",     frFR = "Commandant d'assaut" } },
    [7000600] = { entry = 7000600, quantity = 5,  criteriaId = 15031, label = { enUS = "Legion General",        frFR = "Général de la légion" } },
    [7000610] = { entry = 7000610, quantity = 5,  criteriaId = 15032, label = { enUS = "Assault Sub-Commander", frFR = "Sous-commandant de l'assaut" } },
    [7000605] = { entry = 7000605, quantity = 15, criteriaId = 15033, label = { enUS = "Siege Infernal",        frFR = "Infernal de siège" } },
    [7000606] = { entry = 7000606, quantity = 20, criteriaId = 15034, label = { enUS = "Demonized Warrior",     frFR = "Guerrier démonisé" } },
    [7000607] = { entry = 7000607, quantity = 20, criteriaId = 15035, label = { enUS = "Mana Drainer",          frFR = "Draineur de mana" } },
}

local NETHERIL_CRITERIA_ORDERED = {
    NETHERIL_CRITERIA_BY_ENTRY[7000603], NETHERIL_CRITERIA_BY_ENTRY[7000604],
    NETHERIL_CRITERIA_BY_ENTRY[7000601], NETHERIL_CRITERIA_BY_ENTRY[7000602],
    NETHERIL_CRITERIA_BY_ENTRY[7000609], NETHERIL_CRITERIA_BY_ENTRY[7000611],
    NETHERIL_CRITERIA_BY_ENTRY[7000608], NETHERIL_CRITERIA_BY_ENTRY[7000600],
    NETHERIL_CRITERIA_BY_ENTRY[7000610], NETHERIL_CRITERIA_BY_ENTRY[7000605],
    NETHERIL_CRITERIA_BY_ENTRY[7000606], NETHERIL_CRITERIA_BY_ENTRY[7000607],
}

CharDBExecute([[
    CREATE TABLE IF NOT EXISTS `custom_netheril_progress` (
        `guid` INT UNSIGNED NOT NULL,
        `criteria_id` INT UNSIGNED NOT NULL,
        `counter` INT UNSIGNED NOT NULL DEFAULT 0,
        PRIMARY KEY (`guid`, `criteria_id`)
    )
]])

local NetherilCache = {}
local PlayerLocale = {}
local UIOpen = {}

-- Apercu "loupe" : au lieu d'essayer d'afficher un widget Model/PlayerModel
-- avec un DisplayID brut (jamais fiable sur ce client, cf tous les essais
-- cote client), on utilise directement le meme mecanisme que la commande GM
-- .morph : Unit:SetDisplayId(displayId) sur le PERSONNAGE DU JOUEUR lui-meme
-- (une vraie unite avec un rendu 3D complet, texture/equipement compris),
-- puis Unit:DeMorph() pour revenir a la normale a la fermeture de l'apercu.
--
-- Whitelist des DisplayID valides (ceux du haut fait Netheril uniquement) :
-- indispensable cote serveur pour ne pas laisser un client modifie demander
-- de se morph en n'importe quel DisplayID arbitraire.
local NETHERIL_PREVIEW_DISPLAY_IDS = {
    [17446] = true,
    [18448] = true,
    [20045] = true,
    [9129]  = true,
    [18699] = true,
    [7950]  = true,
    [22979] = true,
    [6172]  = true,
    [17887] = true,
    [4426]  = true,
    [17287] = true,
    [19200] = true,
}

local PreviewMorphed = {}
local PreviewOriginalPhase = {}

-- Phase dediee a l'apercu, tres improbable d'etre deja utilisee par du
-- phasing de quete normal (bit tres eleve). Le joueur y est seul le temps
-- de l'apercu : plus personne autour ne le voit (ni sa morph, ni lui du
-- tout), pendant que le widget cote client, lui, continue d'afficher son
-- unite normalement (il lit les donnees de l'unite, pas une "vue" du monde).
local PREVIEW_PHASE = 0x80000000

local function LoadPlayerLocale(player)
    local guidLow = player:GetGUIDLow()
    local locale = "enUS"

    local result = AuthDBQuery(string.format(
        "SELECT locale FROM account WHERE id = %d", player:GetAccountId()
    ))
    if result then
        if result:GetUInt8(0) == LOCALE_FRFR_ID then
            locale = "frFR"
        end
    end

    PlayerLocale[guidLow] = locale
    return locale
end

local function GetLocale(guidLow)
    return PlayerLocale[guidLow] or "enUS"
end

local function LoadNetherilCache(player)
    local guidLow = player:GetGUIDLow()
    local cache = {}
    for _, data in ipairs(NETHERIL_CRITERIA_ORDERED) do
        cache[data.criteriaId] = 0
    end

    local result = CharDBQuery(string.format(
        "SELECT criteria_id, counter FROM custom_netheril_progress WHERE guid = %d", guidLow
    ))
    if result then
        repeat
            cache[result:GetUInt32(0)] = result:GetUInt32(1)
        until not result:NextRow()
    end

    NetherilCache[guidLow] = cache
    return cache
end

local function SaveCounter(guidLow, criteriaId, counter)
    CharDBExecute(string.format(
        "INSERT INTO custom_netheril_progress (guid, criteria_id, counter) VALUES (%d, %d, %d) " ..
        "ON DUPLICATE KEY UPDATE counter = VALUES(counter)",
        guidLow, criteriaId, counter
    ))
end

local function GetCounter(guidLow, criteriaId)
    local cache = NetherilCache[guidLow]
    if not cache then
        return 0
    end
    return cache[criteriaId] or 0
end

-- Est-ce que les 12 criteres sont a leur quantite max pour ce joueur ?
local function AllCriteriaDone(guidLow)
    local cache = NetherilCache[guidLow]
    if not cache then
        return false
    end

    for _, data in ipairs(NETHERIL_CRITERIA_ORDERED) do
        if (cache[data.criteriaId] or 0) < data.quantity then
            return false
        end
    end

    return true
end

-- Attribue le haut fait 5011 des que les 12 criteres sont completes.
--
-- Avant ce correctif, `achievementDone` n'etait utilise que pour l'affichage
-- du texte "Haut Fait termine !" dans l'UI cote client : rien n'appelait
-- jamais Player:SetAchievement(), donc le haut fait n'etait jamais realise
-- pour de vrai malgre le 12/12 affiche a l'ecran.
--
-- Appelee a la fois sur kill, connexion et ouverture de l'UI (gossip) pour
-- rattraper aussi les joueurs qui avaient deja 12/12 avant ce correctif.
local function CheckAndGrantAchievement(player)
    if not player or player:HasAchieved(ACHIEVEMENT_ID) then
        return
    end

    local guidLow = player:GetGUIDLow()
    if AllCriteriaDone(guidLow) then
        player:SetAchievement(ACHIEVEMENT_ID)
    end
end

local function BuildProgressPayload(player)
    local guidLow = player:GetGUIDLow()
    if not NetherilCache[guidLow] then
        LoadNetherilCache(player)
    end
    if not PlayerLocale[guidLow] then
        LoadPlayerLocale(player)
    end

    local locale = GetLocale(guidLow)
    local strings = L[locale]

    local rows = {}
    local totalDone = 0
    for _, data in ipairs(NETHERIL_CRITERIA_ORDERED) do
        local counter = GetCounter(guidLow, data.criteriaId)
        if counter > data.quantity then
            counter = data.quantity
        end
        local done = counter >= data.quantity
        if done then
            totalDone = totalDone + 1
        end

        table.insert(rows, {
            entry    = data.entry,
            label    = data.label[locale],
            counter  = counter,
            quantity = data.quantity,
            done     = done,
        })
    end

    local allDone = (totalDone >= #NETHERIL_CRITERIA_ORDERED)

    return {
        header          = strings.header,
        rows            = rows,
        summary         = string.format(strings.critSummary, totalDone, #NETHERIL_CRITERIA_ORDERED),
        achievementDone = allDone,
        doneText        = strings.achievementDone,
    }
end

local function OnLogin(event, player)
    LoadNetherilCache(player)
    LoadPlayerLocale(player)
    CheckAndGrantAchievement(player)
end

-- Annule un apercu en cours (au cas ou le joueur se deconnecte, change de
-- zone, etc. sans avoir ferme proprement la fenetre d'apercu) pour ne
-- jamais laisser un joueur morphe en permanence par accident.
local function EndPreviewMorph(player)
    if not player then
        return
    end
    local guidLow = player:GetGUIDLow()
    if PreviewMorphed[guidLow] then
        player:DeMorph()
        player:SetPhaseMask(PreviewOriginalPhase[guidLow] or 1, true)
        PreviewMorphed[guidLow] = nil
        PreviewOriginalPhase[guidLow] = nil
    end
end

local function OnLogout(event, player)
    EndPreviewMorph(player)
    local guidLow = player:GetGUIDLow()
    NetherilCache[guidLow] = nil
    PlayerLocale[guidLow] = nil
    UIOpen[guidLow] = nil
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then
        return
    end

    local data = NETHERIL_CRITERIA_BY_ENTRY[victim:GetEntry()]
    if not data then
        return
    end

    local guidLow = killer:GetGUIDLow()
    if not NetherilCache[guidLow] then
        LoadNetherilCache(killer)
    end

    local cache = NetherilCache[guidLow]
    local counter = (cache[data.criteriaId] or 0) + 1
    if counter > data.quantity then
        counter = data.quantity
    end
    cache[data.criteriaId] = counter
    SaveCounter(guidLow, data.criteriaId, counter)

    CheckAndGrantAchievement(killer)

    if UIOpen[guidLow] then
        AIO.Handle(killer, "NetherilUI", "ShowProgress", BuildProgressPayload(killer))
    end
end

local NetherilHandlers = AIO.AddHandlers("NetherilUI", {})

function NetherilHandlers.SetUIState(player, isOpen)
    if not player then
        return
    end
    local guidLow = player:GetGUIDLow()
    UIOpen[guidLow] = isOpen and true or nil
    if not isOpen then
        -- Fermer la fenetre principale doit aussi annuler un apercu en cours.
        EndPreviewMorph(player)
    end
end

-- Apercu "loupe" : cf commentaire de NETHERIL_PREVIEW_DISPLAY_IDS plus haut.
function NetherilHandlers.PreviewMorph(player, displayId)
    if not player or not displayId then
        return
    end
    if not NETHERIL_PREVIEW_DISPLAY_IDS[displayId] then
        -- DisplayID hors liste blanche : on ignore silencieusement (client
        -- modifie ou desynchronise), pas d'erreur cote client necessaire.
        return
    end

    local guidLow = player:GetGUIDLow()
    if not PreviewMorphed[guidLow] then
        -- Premiere creature de cette session d'apercu : on memorise la
        -- phase normale du joueur et on le passe dans la phase dediee,
        -- invisible pour tout le monde sauf lui, AVANT de le morph -
        -- comme ca, aucun autre joueur ne voit jamais la transformation.
        PreviewOriginalPhase[guidLow] = player:GetPhaseMask()
        player:SetPhaseMask(PREVIEW_PHASE, true)
    end

    player:SetDisplayId(displayId)
    PreviewMorphed[guidLow] = true
end

function NetherilHandlers.PreviewMorphEnd(player)
    EndPreviewMorph(player)
end

local function OnGossipHello(event, player, gameObject)
    if gameObject:GetEntry() ~= NETHERIL_GAMEOBJECT_ENTRY then
        return
    end

    gameObject:UseDoorOrButton(10000)
    CheckAndGrantAchievement(player)
    AIO.Handle(player, "NetherilUI", "ShowProgress", BuildProgressPayload(player))
    player:GossipComplete()
end

RegisterGameObjectGossipEvent(NETHERIL_GAMEOBJECT_ENTRY, 1, OnGossipHello)

RegisterPlayerEvent(3, OnLogin)
RegisterPlayerEvent(4, OnLogout)
RegisterPlayerEvent(7, OnKillCreature)
