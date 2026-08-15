local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local DR_SERVER_HANDLER = "DragonRidingServer" -- handlers cibles sur le serveur
local DR_CLIENT_HANDLER = "DragonRidingClient" -- handlers recus depuis le serveur
local MAX_CHARGES_FALLBACK = 5

----------------------------------------------------------------------------
-- Localisation (frFR / enUS)
----------------------------------------------------------------------------
local L
if GetLocale() == "enUS" then
    L = {
        SURGE_TOOLTIP_TITLE = "Skyriding",
        SURGE_TOOLTIP_DESC  = "Consumes 1 Vigor charge to greatly increase your flight speed for a short duration.",
        ERR_NO_VIGOR        = "Not enough Vigor.",
        ERR_NOT_FLYING      = "You must be flying on a flying mount.",
        ERR_UNAVAILABLE     = "Skyriding unavailable.",
    }
else
    L = {
        SURGE_TOOLTIP_TITLE = "Vol dynamique",
        SURGE_TOOLTIP_DESC  = "Consomme 1 charge de Vigueur pour augmenter considérablement la vitesse de vol pendant un court instant.",
        ERR_NO_VIGOR        = "Pas assez de Vigueur.",
        ERR_NOT_FLYING      = "Vous devez être en vol sur une monture volante.",
        ERR_UNAVAILABLE     = "Vol dynamique indisponible.",
    }
end

----------------------------------------------------------------------------
-- Atlas unique (dragonridingvigorwidgets.blp, 512x512) - coordonnees UV
-- calculees a partir des sprites reels de la texture (voir chaque bloc) :
--   PIP        : orbe "vide" teal/argente (grille des orbes repetes)
--   PIP_ALT    : variante d'orbe isolee (coin haut droit de l'atlas)
--   CLAW       : griffe/corne doree (utilisee pour les decors + icone Ruee)
--   ORB_BLUE   : orbe plein (charge disponible)
--   ORB_BLACK  : orbe fonce (etat alternatif / desactive)
--   GLOW_RING  : halo bleu clair (pulsation derriere la prochaine charge)
--   SURGE_FRAME: cadre rond dore (fond du bouton Ruee)
----------------------------------------------------------------------------
local ATLAS = "Interface\\DragonRiding\\Texture\\dragonridingvigorwidgets"
local ATLAS_SIZE = 512

local function UV(x0, y0, x1, y1)
    return { l = x0 / ATLAS_SIZE, r = x1 / ATLAS_SIZE, t = y0 / ATLAS_SIZE, b = y1 / ATLAS_SIZE }
end

local ATLAS_COORDS = {
    PIP         = UV(6,   0,   70,  74),
    PIP_ALT     = UV(399, 0,   461, 72),
    CLAW        = UV(306, 7,   379, 104),
    ORB_BLUE    = UV(304, 119, 366, 191),
    ORB_BLACK   = UV(372, 119, 435, 192),
    GLOW_RING   = UV(19,  389, 103, 487),
    SURGE_FRAME = UV(145, 393, 221, 483),
}

local function ApplyAtlas(tex, key)
    local c = ATLAS_COORDS[key]
    tex:SetTexture(ATLAS)
    tex:SetTexCoord(c.l, c.r, c.t, c.b)
end

-- variante miroir horizontal (pour la griffe de droite, pointee vers l'exterieur)
local function ApplyAtlasFlipped(tex, key)
    local c = ATLAS_COORDS[key]
    tex:SetTexture(ATLAS)
    tex:SetTexCoord(c.r, c.l, c.t, c.b)
end

----------------------------------------------------------------------------
-- Cadre principal (au-dessus de la barre d'action, comme sur la maquette)
----------------------------------------------------------------------------
local PIP_SIZE   = 46
local PIP_GAP    = 8
local CLAW_W     = 50
local CLAW_H     = 66
local NUM_PIPS   = 5

local ROW_W = NUM_PIPS * PIP_SIZE + (NUM_PIPS - 1) * PIP_GAP
local FRAME_W = CLAW_W + 10 + ROW_W + 14 + CLAW_W + 16 + 54 + 10
local FRAME_H = 96

local frame = CreateFrame("Frame", "DragonRidingVigorFrame", UIParent)
frame:SetSize(FRAME_W, FRAME_H)
frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 185) -- au-dessus des barres d'action ; ajustez ce dernier chiffre si besoin
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then self:StartMoving() end
end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
frame:Hide()

----------------------------------------------------------------------------
-- Griffes decoratives (gauche / droite, meme texture, miroir a droite)
----------------------------------------------------------------------------
local clawLeft = frame:CreateTexture(nil, "ARTWORK")
clawLeft:SetSize(CLAW_W, CLAW_H)
clawLeft:SetPoint("LEFT", frame, "LEFT", 4, 0)
ApplyAtlas(clawLeft, "CLAW")

local clawRight = frame:CreateTexture(nil, "ARTWORK")
clawRight:SetSize(CLAW_W, CLAW_H)
clawRight:SetPoint("LEFT", clawLeft, "RIGHT", 10 + ROW_W + 14, 0)
ApplyAtlasFlipped(clawRight, "CLAW")

----------------------------------------------------------------------------
-- Orbes de Vigueur
----------------------------------------------------------------------------
local pips = {}
local glows = {}
local rings = {}

local currentCharges = 0
local maxCharges = MAX_CHARGES_FALLBACK

local function CreatePip(index)
    local holder = CreateFrame("Frame", nil, frame)
    holder:SetSize(PIP_SIZE, PIP_SIZE)
    holder:SetPoint("LEFT", clawLeft, "RIGHT", 10 + (index - 1) * (PIP_SIZE + PIP_GAP), 0)

    local glow = holder:CreateTexture(nil, "BACKGROUND")
    ApplyAtlas(glow, "GLOW_RING")
    glow:SetPoint("CENTER", holder, "CENTER", 0, 0)
    glow:SetSize(PIP_SIZE + 22, PIP_SIZE + 22)
    glow:SetAlpha(0)

    local orb = holder:CreateTexture(nil, "ARTWORK")
    orb:SetAllPoints(true)
    ApplyAtlas(orb, "PIP")

    -- cadre dore (meme sprite que le fond du bouton Ruee) par dessus l'oeuf,
    -- pour l'effet "oeuf serti" visible sur la maquette
    local ring = holder:CreateTexture(nil, "OVERLAY")
    ring:SetPoint("CENTER", holder, "CENTER", 0, 0)
    ring:SetSize(PIP_SIZE + 10, PIP_SIZE + 10)
    ApplyAtlas(ring, "SURGE_FRAME")

    pips[index] = orb
    glows[index] = glow
    rings[index] = ring
    return holder
end

for i = 1, NUM_PIPS do
    CreatePip(i)
end

local function RefreshPips()
    for i = 1, NUM_PIPS do
        local orb = pips[i]
        local glow = glows[i]
        local ring = rings[i]
        if i <= maxCharges then
            orb:Show()
            ring:Show()
            if i <= currentCharges then
                ApplyAtlas(orb, "ORB_BLUE")
                glow:SetAlpha(0)
            else
                ApplyAtlas(orb, "PIP")
                -- petite lueur sur la PROCHAINE charge en train de se remplir
                glow:SetAlpha(i == currentCharges + 1 and 0.55 or 0)
            end
        else
            orb:Hide()
            ring:Hide()
            glow:SetAlpha(0)
        end
    end
end

----------------------------------------------------------------------------
-- Pulsation douce de la lueur (petite touche vivante, purement cosmetique)
----------------------------------------------------------------------------
local pulseT = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    if not self:IsShown() then return end
    pulseT = pulseT + elapsed
    local a = 0.35 + math.abs(math.sin(pulseT * 2)) * 0.35
    for i = 1, maxCharges do
        if i == currentCharges + 1 and i <= maxCharges then
            glows[i]:SetAlpha(a)
        end
    end
end)

----------------------------------------------------------------------------
-- Bouton "Ruee"
----------------------------------------------------------------------------
local surgeBtn = CreateFrame("Button", "DragonRidingSurgeButton", frame)
surgeBtn:SetSize(54, 54)
surgeBtn:SetPoint("LEFT", clawRight, "RIGHT", 16, 0)

local surgeFrameTex = surgeBtn:CreateTexture(nil, "BACKGROUND")
surgeFrameTex:SetAllPoints(true)
ApplyAtlas(surgeFrameTex, "SURGE_FRAME")

local surgeIcon = surgeBtn:CreateTexture(nil, "ARTWORK")
surgeIcon:SetPoint("CENTER", surgeBtn, "CENTER", 0, 0)
surgeIcon:SetSize(30, 30)
ApplyAtlas(surgeIcon, "CLAW")

surgeBtn:SetScript("OnMouseDown", function(self) surgeIcon:SetPoint("CENTER", self, "CENTER", 1, -1) end)
surgeBtn:SetScript("OnMouseUp", function(self) surgeIcon:SetPoint("CENTER", self, "CENTER", 0, 0) end)

local function RequestSurge()
    if not frame:IsShown() then return end
    AIO.Handle(DR_SERVER_HANDLER, "RequestSurge")
end
surgeBtn:SetScript("OnClick", RequestSurge)

surgeBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(L.SURGE_TOOLTIP_TITLE)
    GameTooltip:AddLine(L.SURGE_TOOLTIP_DESC, 1, 1, 1, true)
    GameTooltip:Show()
end)
surgeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

----------------------------------------------------------------------------
-- Slash commands (au cas ou vous preferez une touche a l'action de clic)
----------------------------------------------------------------------------
SLASH_DRAGONRIDINGSURGE1 = "/vigor"
SLASH_DRAGONRIDINGSURGE2 = "/ruee"
SlashCmdList["DRAGONRIDINGSURGE"] = RequestSurge

----------------------------------------------------------------------------
-- Retour visuel simple en cas d'echec de la Ruee
----------------------------------------------------------------------------
local function FlashReason(reason)
    local msg
    if reason == "NO_VIGOR" then
        msg = L.ERR_NO_VIGOR
    elseif reason == "NOT_FLYING" then
        msg = L.ERR_NOT_FLYING
    elseif reason == "COOLDOWN" then
        msg = nil -- trop frequent, on ignore silencieusement
    elseif reason == "ALREADY_ACTIVE" then
        msg = nil -- une Ruee est deja en cours (ramp en cours), on ignore silencieusement
    else
        msg = L.ERR_UNAVAILABLE
    end
    if msg then
        UIErrorsFrame:AddMessage(msg, 0.6, 0.8, 1.0, 1.0, 3)
    end
end

----------------------------------------------------------------------------
-- Handlers AIO (recus depuis DragonRidingServer.lua)
----------------------------------------------------------------------------
local DragonRidingHandlers = AIO.AddHandlers(DR_CLIENT_HANDLER, {})

function DragonRidingHandlers.Show(player, charges, max)
    currentCharges = charges or currentCharges
    maxCharges = max or maxCharges
    RefreshPips()
    frame:Show()
end

function DragonRidingHandlers.Hide(player)
    frame:Hide()
end

function DragonRidingHandlers.Update(player, charges, max)
    currentCharges = charges or currentCharges
    maxCharges = max or maxCharges
    RefreshPips()
end

function DragonRidingHandlers.SurgeResult(player, success, reason)
    if not success then
        FlashReason(reason)
    end
end

----------------------------------------------------------------------------
-- Demande l'etat initial au login / reload UI
----------------------------------------------------------------------------
local evt = CreateFrame("Frame")
evt:RegisterEvent("PLAYER_ENTERING_WORLD")
evt:SetScript("OnEvent", function()
    AIO.Handle(DR_SERVER_HANDLER, "RequestStatus")
end)
