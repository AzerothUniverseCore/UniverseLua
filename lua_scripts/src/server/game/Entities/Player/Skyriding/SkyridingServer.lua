local AIO = AIO or require("AIO")

if AIO.IsMainState and not AIO.IsMainState() then
    return
end

----------------------------------------------------------------------------
-- CONFIGURATION
----------------------------------------------------------------------------
local DR_SERVER_HANDLER   = "DragonRidingServer" -- handlers recus depuis le client
local DR_CLIENT_HANDLER   = "DragonRidingClient" -- handlers cibles sur le client
local VIGOR_MAX_CHARGES   = 5              -- nombre max de charges de Vigueur (5 emplacements sur la maquette)
local VIGOR_REGEN_SECONDS = 12             -- secondes pour regagner 1 charge (monte + en vol)
local TICK_SECONDS        = 1              -- frequence de la boucle de mise a jour

local REQUIRE_FLYING      = true           -- true = doit etre reellement en train de voler (pas juste monte au sol)
local SURGE_COOLDOWN_MS   = 600            -- anti-spam entre deux clics Ruee (ms), en plus du cout en charge

-- UnitMoveType : utilise uniquement pour le debug (verifier si le
-- changement de cran a un effet mesurable sur la vitesse calculee).
local MOVE_FLIGHT = 6

-- DEBUG : affiche dans le chat du joueur ce que le script fait.
local DEBUG = false
----------------------------------------------------------------------------

local ALL_FLYING_MOUNT_SPELLS = {
    3363,31700,32235,32239,32240,32242,32243,32244,32245,32246,32289,32290,32292,32295,32296,
    32297,32345,37015,39798,39800,39801,39802,39803,40192,40212,41513,41514,41515,41516,41517,
    41518,42667,42668,43810,43927,44151,44153,44317,44744,44824,44825,44827,46197,46199,48023,
    49193,51617,51960,54726,54727,55164,58615,59567,59568,59569,59570,59571,59650,59961,59976,
    59996,60002,60021,60024,60025,61229,61230,61294,61309,61451,61996,61997,62048,63796,63844,
    63956,63963,64681,64761,64927,65439,66087,66088,67336,69395,71346,71347,71810,72283,72284,72807,
    72808,75596,75617,75618,75957,75972,76153,76154,87090,87091,93326,103195,103196,121820,142761,
    142767,142768,142771,142774,142775,142776,142777,142778,142779,142781,142785,142786,142787,150020,150022,
    150024,150025,150030,150034,150037,150053,150054,150055,150057,150058,150059,150060,150143,150144,150145,150146,
    150147,150169,150248,150505,150506,150507,150508,150509,150510,150511,150512,150513,150514,150515,150516,
    150517,150518,150519,150520,150521,150522,150523,150524,150525,150526,150527,150528,150529,150530,150531,
    150534,150535,150536,150537,180100,180101,180102,180103,180104,180105,180106,180107,180108,180109,180110,
    180111,180120,180121,180122,180123,180124,180125,180126,180127,180128,180129,180130,180131,180132,180133,
    180134,180135,180136,180137,180138,190023,190025,294197,320557,320558,320559,320560,320570,559180,636218,3088331,
    3088335,3088718,3088741,3088742,3088744,3088746,3088990,3093326,3093623,3096503,3097359,3097493,3097501,3097560,3098727,
    3101282,3101821,3102514,3107203,3107516,3107517,3107842,3107844,3107845,3110039,3110051,3113120,3113199,3118737,3120043,
    3121820,3121836,3121837,3121838,3121839,3123992,3123993,3124408,3124550,3124659,3126507,3126508,3127154,3127156,3127158,
    3127161,3127164,3127165,3127169,3127170,3129552,3129918,3130092,3130985,3132036,3132117,3132118,3132119,3133023,3134359,
    3134573,3135416,3135418,3136163,3136164,3136400,3136505,3139407,3139442,3139448,3139595,3142073,3142266,3142478,3142878,
    3142910,3148392,3148476,3148618,3148619,3148620,3149801,3153489,3155741,3163024,3163025,3169952,3171828,3171847,3175700,
    3180545,3182912,3183117,3189999,3191633,3194046,3194464,3201098,
}

-- vigor[guidLow] = {
--   charges, mounted, flying, regenTimer, activeStacks, lastSurgeAt,
--   appliedStack, mountSpellId
-- }
-- activeStacks  : nombre de crans de vitesse demandes (0 au debut de chaque
--                 vol, +1 par clic sur Ruee, -1 a chaque charge regeneree).
-- appliedStack  : le StackAmount actuellement pose sur l'aura de la monture
--                 (1 = normal/aucun bonus, jusqu'a 1+VIGOR_MAX_CHARGES).
--                 Sert a ne rappeler SetStackAmount() que si necessaire.
-- mountSpellId  : le spell ID de la monture actuellement identifie pour ce
--                 vol (resolu via ALL_FLYING_MOUNT_SPELLS + HasAura() a
--                 chaque decollage), nil si la monture n'a pas ete reconnue.
local vigor = {}

local function GetState(guidLow)
    local s = vigor[guidLow]
    if not s then
        s = { charges = VIGOR_MAX_CHARGES, mounted = false, flying = false, regenTimer = 0,
              activeStacks = 0, lastSurgeAt = 0, appliedStack = 1, mountSpellId = nil }
        vigor[guidLow] = s
    end
    return s
end

local function IsPlayerMounted(player)
    local ok, mounted = pcall(function() return player:IsMounted() end)
    if ok then return mounted end
    return false
end

local function IsPlayerFlying(player)
    local ok, flying = pcall(function() return player:IsFlying() end)
    if ok then return flying end
    return false
end

local function DebugMsg(player, text)
    if not DEBUG or not player then return end
    pcall(function() player:SendBroadcastMessage("|cff33ccff[DragonRiding]|r " .. text) end)
end

-- Retrouve le spell ID de la monture actuelle du joueur en testant
-- directement player:HasAura(id) pour chaque sort de monture volante connu
-- (ALL_FLYING_MOUNT_SPELLS). Pas de devinette via displayId (non fiable
-- sur ce fork pour les montures custom, verifie par debug). Renvoie nil si
-- aucun des sorts connus n'est actif.
local function ResolveMountSpellId(player)
    for _, spellId in ipairs(ALL_FLYING_MOUNT_SPELLS) do
        local ok, has = pcall(function() return player:HasAura(spellId) end)
        if ok and has then
            return spellId
        end
    end
    return nil
end

-- Ajuste le nombre de crans de l'aura de monture DEJA ACTIVE du joueur (sans
-- jamais la retirer ni recaster quoi que ce soit). 1 = normal, 2 a
-- 1+VIGOR_MAX_CHARGES = boost progressif.
local function ApplySurgeStack(player, state)
    local desired = 1 + state.activeStacks
    if desired == state.appliedStack then return end

    if not state.mountSpellId then
        state.mountSpellId = ResolveMountSpellId(player)
    end
    if not state.mountSpellId then
        DebugMsg(player, "Vigor Surge (stack) : monture non reconnue (aucun sort de ALL_FLYING_MOUNT_SPELLS actif) - aucun effet de vitesse possible.")
        return
    end

    local aura
    local okGet = pcall(function() aura = player:GetAura(state.mountSpellId) end)
    if not aura then
        DebugMsg(player, string.format(
            "Vigor Surge (stack) : aura de monture %d introuvable (GetAura ok=%s) - re-detection au prochain essai.",
            state.mountSpellId, tostring(okGet)))
        state.mountSpellId = nil
        return
    end

    local okBefore, before = pcall(function() return player:GetSpeed(MOVE_FLIGHT) end)
    local okSet = pcall(function() aura:SetStackAmount(desired) end)
    local stackNow = "?"
    local okSA, sa = pcall(function() return aura:GetStackAmount() end)
    if okSA then stackNow = tostring(sa) end
    local okAfter, after = pcall(function() return player:GetSpeed(MOVE_FLIGHT) end)

    DebugMsg(player, string.format(
        "Vigor Surge (stack) : sort=%d cran voulu=%d reel=%s | SetStackAmount ok=%s | GetSpeed avant=%s apres=%s",
        state.mountSpellId, desired, stackNow, tostring(okSet),
        okBefore and string.format("%.4f", before) or "ERR",
        okAfter and string.format("%.4f", after) or "ERR"))

    state.appliedStack = desired
end

----------------------------------------------------------------------------
-- Boucle principale (1x / seconde) : etat monte/vol + regeneration
----------------------------------------------------------------------------
local function TickPlayer(player)
    if not player or not player:IsInWorld() then return end

    local guidLow = player:GetGUIDLow()
    local state = GetState(guidLow)

    local mounted = IsPlayerMounted(player)
    local flying = mounted and IsPlayerFlying(player) or false
    local eligible = mounted and (not REQUIRE_FLYING or flying)
    local wasFlying = state.flying

    if flying and not wasFlying then
        -- debut de vol : on repart TOUJOURS de zero cran (aucun changement
        -- de vitesse tant qu'on n'a pas clique sur Ruee), et on redetecte la
        -- monture actuelle (elle a pu changer depuis le dernier vol).
        state.activeStacks = 0
        state.appliedStack = 1
        state.mountSpellId = nil
    elseif not flying and wasFlying then
        -- fin de vol (atterrissage / demontage) : on repose le cran normal
        -- si un boost etait actif, pour repartir propre au prochain envol.
        state.activeStacks = 0
        if state.appliedStack ~= 1 then
            ApplySurgeStack(player, state)
        end
    end

    -- changement d'etat monte/vol -> on montre/cache le widget cote client
    if mounted ~= state.mounted or flying ~= state.flying then
        state.mounted = mounted
        state.flying = flying
        if eligible then
            AIO.Handle(player, DR_CLIENT_HANDLER, "Show", state.charges, VIGOR_MAX_CHARGES)
        else
            AIO.Handle(player, DR_CLIENT_HANDLER, "Hide")
        end
    end

    -- regeneration de vigueur
    if eligible and state.charges < VIGOR_MAX_CHARGES then
        state.regenTimer = state.regenTimer + TICK_SECONDS
        if state.regenTimer >= VIGOR_REGEN_SECONDS then
            state.regenTimer = 0
            state.charges = math.min(VIGOR_MAX_CHARGES, state.charges + 1)
            AIO.Handle(player, DR_CLIENT_HANDLER, "Update", state.charges, VIGOR_MAX_CHARGES)
            -- une charge vient de se regenerer -> on retire un cran (la
            -- vitesse redescend d'un palier, jusqu'a revenir pile a la
            -- normale quand il n'y a plus aucun cran actif)
            if state.activeStacks > 0 then
                state.activeStacks = state.activeStacks - 1
                if flying then
                    ApplySurgeStack(player, state)
                end
            end
        end
    else
        state.regenTimer = 0
    end
end

local function TickAll()
    local ok, players = pcall(GetPlayersInWorld)
    if ok and players then
        for _, player in pairs(players) do
            pcall(TickPlayer, player)
        end
    end
    return TICK_SECONDS * 1000 -- reprogramme le prochain tick
end

CreateLuaEvent(TickAll, TICK_SECONDS * 1000, 0)

----------------------------------------------------------------------------
-- Handlers AIO
----------------------------------------------------------------------------
local DragonRidingHandlers = AIO.AddHandlers(DR_SERVER_HANDLER, {})

-- Le client demande son etat actuel (ex : au login / reload UI). On ne
-- touche pas state.mounted/state.flying ici : c'est TickPlayer (1x/s) qui
-- gere la transition proprement.
function DragonRidingHandlers.RequestStatus(player)
    if not player then return end
    local state = GetState(player:GetGUIDLow())
    local mounted = IsPlayerMounted(player)
    local flying = mounted and IsPlayerFlying(player) or false
    if mounted and (not REQUIRE_FLYING or flying) then
        AIO.Handle(player, DR_CLIENT_HANDLER, "Show", state.charges, VIGOR_MAX_CHARGES)
    else
        AIO.Handle(player, DR_CLIENT_HANDLER, "Hide")
    end
end

-- Le client demande a declencher une Ruee : consomme 1 charge et augmente
-- le cran de vitesse (cumulatif, on peut recliquer tant qu'il reste des
-- charges - la seule limite est le cooldown anti-spam et le stock de
-- charges).
function DragonRidingHandlers.RequestSurge(player)
    if not player then return end

    local state = GetState(player:GetGUIDLow())
    local now = os.time() * 1000

    local mounted = IsPlayerMounted(player)
    local flying = mounted and IsPlayerFlying(player) or false

    DebugMsg(player, string.format("RequestSurge recu : mounted=%s flying=%s charges=%d activeStacks=%d",
        tostring(mounted), tostring(flying), state.charges, state.activeStacks))

    if not mounted or (REQUIRE_FLYING and not flying) then
        DebugMsg(player, "-> rejete : NOT_FLYING")
        AIO.Handle(player, DR_CLIENT_HANDLER, "SurgeResult", false, "NOT_FLYING")
        return
    end

    -- TickPlayer ne verifie le decollage qu'1x/seconde : si le joueur clique
    -- sur Ruee dans cette fenetre (juste apres avoir decolle, avant que
    -- TickPlayer ait rattrape l'etat), on rattrape nous-meme l'etat de vol
    -- ICI pour eviter que le prochain TickPlayer n'efface le cran qu'on
    -- vient d'appliquer en croyant detecter un decollage.
    if not state.flying then
        state.activeStacks = 0
        state.mounted = true
        state.flying = true
        state.mountSpellId = nil
        AIO.Handle(player, DR_CLIENT_HANDLER, "Show", state.charges, VIGOR_MAX_CHARGES)
    end

    if now - state.lastSurgeAt < SURGE_COOLDOWN_MS then
        DebugMsg(player, string.format("-> rejete : COOLDOWN (%dms restants)", SURGE_COOLDOWN_MS - (now - state.lastSurgeAt)))
        AIO.Handle(player, DR_CLIENT_HANDLER, "SurgeResult", false, "COOLDOWN")
        return
    end

    if state.charges <= 0 then
        DebugMsg(player, "-> rejete : NO_VIGOR")
        AIO.Handle(player, DR_CLIENT_HANDLER, "SurgeResult", false, "NO_VIGOR")
        return
    end

    state.charges = state.charges - 1
    state.lastSurgeAt = now
    state.activeStacks = math.min(VIGOR_MAX_CHARGES, state.activeStacks + 1)
    -- applique immediatement le nouveau cran (SetStackAmount sur l'aura deja active)
    ApplySurgeStack(player, state)

    AIO.Handle(player, DR_CLIENT_HANDLER, "SurgeResult", true)
    AIO.Handle(player, DR_CLIENT_HANDLER, "Update", state.charges, VIGOR_MAX_CHARGES)
end

----------------------------------------------------------------------------
-- Nettoyage a la deconnexion (evite un etat fantome si le joueur se
-- reconnecte tres vite, et repose le cran normal au cas ou)
----------------------------------------------------------------------------
local function OnLogout(event, player)
    if not player then return end
    local state = vigor[player:GetGUIDLow()]
    if state and state.appliedStack ~= 1 and state.mountSpellId then
        local aura
        pcall(function() aura = player:GetAura(state.mountSpellId) end)
        if aura then
            pcall(function() aura:SetStackAmount(1) end)
        end
    end
end
RegisterPlayerEvent(4, OnLogout) -- PLAYER_EVENT_ON_LOGOUT
