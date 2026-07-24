-- ============================================================
--  WarchiefCommandHordeClient.lua
--  TrinityCore 3.3.5 — Eluna + AIO
-- ============================================================

local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local WarchiefCommandHordeHandlers = AIO.AddHandlers("WarchiefCommandHordeHandler", {})

-- ------------------------------------------------------------
--  Locale (bilingue frFR / enUS, repli sur frFR)
-- ------------------------------------------------------------
local UI_LOCALE = (GetLocale and GetLocale() == "enUS") and "enUS" or "frFR"
local WarchiefLocales = {
    frFR = {
        MAIN_TITLE   = "Le chef de guerre a besoin de vous ! Prenez un dépliant.",
        EMPTY_STATE  = "Vous avez accompli toutes les missions disponibles.\nRevenez plus tard !",
        DEFAULT_BTN  = "Aller",
    },
    enUS = {
        MAIN_TITLE   = "The Warchief needs you! Take a flyer.",
        EMPTY_STATE  = "You have completed all available missions.\nCome back later!",
        DEFAULT_BTN  = "Go",
    },
}
local WarchiefL = WarchiefLocales[UI_LOCALE] or WarchiefLocales.frFR

-- ------------------------------------------------------------
--  Configuration visuelle — calée sur CaptureH.PNG
--  Fond : hordebfamissionframeUITemplate.blp (612×600)
-- ------------------------------------------------------------
local FRAME_W = 612
local FRAME_H = 600

-- ============================================================
--  LAYOUT — Calé sur le BLP hordebfamissionframeUITemplate (612×600)
--
--  Frame 612px. Les 3 parchemins sont symétriques :
--  Largeur utile : 522px (de x=45 à x=567)
--  Chaque parchemin : 164px de large, gap 15px
--  Col1: 45..209    cx=122
--  Col2: 224..388   cx=306   (centre exact du frame)
--  Col3: 403..567   cx=490
--
--  Symétrie col1/col3 autour de 306 : 306-122=184, 490-306=184 ✓
-- ============================================================
local COL_W = 164
local COLUMNS = {
    { x = 45,  cx = 122, btnCx = 120, descX = 52  },   -- desc col1 : -5px vers la gauche
    { x = 224, cx = 306, btnCx = 306, descX = 236 },   -- desc col2 : inchangé
    { x = 403, cx = 490, btnCx = 492, descX = 420 },   -- desc col3 : +2px vers la droite
}

-- Marge interne du parchemin : contenu à 12px des bords latéraux
local PAD_X     = 12
local CONTENT_W = COL_W - PAD_X * 2   -- 140px

-- Positions Y (depuis TOPLEFT du frame, valeurs négatives)
local MAIN_TITLE_Y = -106   -- bandeau rouge
local COL_TITLE_Y  = -157   -- titres
local COL_TITLE_H  = 20
local IMAGE_Y      = -194   -- images : +4px (descendues)
local IMAGE_W      = 130
local IMAGE_H      = 72
local DESC_Y       = -278   -- desc : +4px (descendues)
local DESC_H       = 200
local BUTTON_Y     = -490   -- boutons

-- Textures
local BG_TEXTURE     = "Interface\\garrison\\hordebfamissionframeUITemplate.blp"
-- Bordure fine style QuestFrame — cadre doré/orange comme HyjalCard
local BORDER_TEXTURE = "Interface\\Common\\UI-QuestTracker-BG"

local FIELDS_PER_FLYER = 11

-- ------------------------------------------------------------
--  État interne
-- ------------------------------------------------------------
local WarchiefBoardFrame = nil
local activeFlyerWidgets = {}

-- ------------------------------------------------------------
--  Nettoyage des widgets dynamiques
-- ------------------------------------------------------------
local function ClearFlyerWidgets()
    for _, w in ipairs(activeFlyerWidgets) do
        if type(w) == "table" and w.Hide then
            w:Hide()
        end
    end
    activeFlyerWidgets = {}
end

-- ------------------------------------------------------------
--  Frame principale (créée une seule fois)
-- ------------------------------------------------------------
local function EnsureMainFrame()
    if WarchiefBoardFrame then return end

    WarchiefBoardFrame = CreateFrame("Frame", "WarchiefCommandBoardHordeFrame", UIParent)
    WarchiefBoardFrame:SetSize(FRAME_W, FRAME_H)
    WarchiefBoardFrame:SetPoint("CENTER")
    WarchiefBoardFrame:SetFrameLevel(100)
    WarchiefBoardFrame:SetMovable(true)
    WarchiefBoardFrame:EnableMouse(true)
    WarchiefBoardFrame:RegisterForDrag("LeftButton")
    WarchiefBoardFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    WarchiefBoardFrame:SetScript("OnDragStop",  function(self) self:StopMovingOrSizing() end)

    WarchiefBoardFrame:SetBackdrop({
        bgFile   = BG_TEXTURE,
        edgeFile = nil,
        tile = false, tileSize = 0, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })

    -- Titre principal dans le bandeau rouge
    local mainTitle = WarchiefBoardFrame:CreateFontString(nil, "OVERLAY")
    mainTitle:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    mainTitle:SetPoint("TOP", WarchiefBoardFrame, "TOP", 0, MAIN_TITLE_Y)
    mainTitle:SetWidth(480)
    mainTitle:SetJustifyH("CENTER")
    --mainTitle:SetTextColor(1, 0.9, 0.7, 1)
    mainTitle:SetText(WarchiefL.MAIN_TITLE)

    -- Bouton fermer
    local closeBtn = CreateFrame("Button", nil, WarchiefBoardFrame, "UIPanelCloseButton")
    closeBtn:SetSize(26, 26)
    closeBtn:SetPoint("TOPRIGHT", WarchiefBoardFrame, "TOPRIGHT", -5, -66)
    closeBtn:SetScript("OnClick", function() WarchiefBoardFrame:Hide() end)

    -- Fermeture sur Echap
    tinsert(UISpecialFrames, "WarchiefCommandBoardHordeFrame")

    WarchiefBoardFrame:Hide()
end

-- ------------------------------------------------------------
--  Construction d'une colonne (un dépliant)
-- ------------------------------------------------------------
local function BuildFlyerColumn(flyer, colIndex)
    local col = COLUMNS[colIndex]
    if not col then return end

    local frame   = WarchiefBoardFrame
    local anchorX = col.x
    local centerX = col.cx
    local btnCx   = col.btnCx or col.cx
    local descX   = col.descX or (col.x + PAD_X)

    -- ── Titre de la colonne ──────────────────────────────────
    -- Ancrage au CENTRE de la colonne pour un centrage fiable sur les 3 colonnes
    local titleFS = frame:CreateFontString(nil, "OVERLAY")
    titleFS:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    titleFS:SetPoint("TOP", frame, "TOPLEFT", centerX, COL_TITLE_Y)
    titleFS:SetWidth(COL_W)
    titleFS:SetHeight(COL_TITLE_H)
    titleFS:SetJustifyH("CENTER")
    titleFS:SetJustifyV("MIDDLE")
    --titleFS:SetTextColor(0.9, 0.75, 0.3, 1)
    titleFS:SetText(flyer.title or "")
    table.insert(activeFlyerWidgets, titleFS)

    -- ── Image centrée dans la colonne ───────────────────────
    -- Ancrage au centre de la colonne, offset vers la gauche de IMAGE_W/2
    local imgFrame = CreateFrame("Frame", nil, frame)
    imgFrame:SetSize(IMAGE_W, IMAGE_H)
    imgFrame:SetPoint("TOP", frame, "TOPLEFT", centerX, IMAGE_Y)
    imgFrame:SetFrameLevel(frame:GetFrameLevel() + 1)

    local imgTex = imgFrame:CreateTexture(nil, "ARTWORK")
    imgTex:SetAllPoints(imgFrame)
    imgTex:SetTexture(flyer.cardImage or "")

    -- Bordure fine dorée/orange style HyjalCard
    -- On utilise UI-Tooltip-Border avec une couleur orange chaude fine
    local borderFrame = CreateFrame("Frame", nil, frame)
    borderFrame:SetPoint("TOPLEFT",     imgFrame, "TOPLEFT",     -2,  2)
    borderFrame:SetPoint("BOTTOMRIGHT", imgFrame, "BOTTOMRIGHT",  2, -2)
    borderFrame:SetFrameLevel(imgFrame:GetFrameLevel() + 2)
    borderFrame:SetBackdrop({
        bgFile   = nil,
        edgeFile = "Interface\\Tooltips\\ui-tooltip-border-corruptedbbm",
        tile     = false, tileSize = 0,
        edgeSize = 12,
        insets   = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    borderFrame:SetBackdropBorderColor(0.55, 0.05, 0.05, 1)

    table.insert(activeFlyerWidgets, imgFrame)
    table.insert(activeFlyerWidgets, borderFrame)

    -- ── Description — ancrée au bord gauche du parchemin ────
    -- IMPORTANT : JustifyH LEFT => ancrage TOPLEFT depuis bord gauche + PAD_X
    local descFS = frame:CreateFontString(nil, "OVERLAY")
    descFS:SetFont("Fonts\\FRIZQT__.TTF", 10, "NONE")
    descFS:SetPoint("TOPLEFT", frame, "TOPLEFT", descX, DESC_Y)
    descFS:SetWidth(CONTENT_W)
    descFS:SetHeight(DESC_H)
    descFS:SetJustifyH("LEFT")
    descFS:SetJustifyV("TOP")
    descFS:SetTextColor(0.32, 0.08, 0.04, 1)
    descFS:SetText(flyer.description or "")
    table.insert(activeFlyerWidgets, descFS)

    -- ── Bouton centré dans la largeur du flyer ──────────────
    local BTN_W = 138
    local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btn:SetSize(BTN_W, 26)
    -- Ancrage au centre de la colonne pour un centrage parfait
    btn:SetPoint("TOP", frame, "TOPLEFT", btnCx, BUTTON_Y)
    btn:SetText(flyer.buttonLabel or WarchiefL.DEFAULT_BTN)

    local questId = flyer.questId
    btn:SetScript("OnClick", function()
        AIO.Handle("WarchiefCommandHordeHandler", "AcceptQuest", questId)
        WarchiefBoardFrame:Hide()
    end)
    table.insert(activeFlyerWidgets, btn)
end

-- ------------------------------------------------------------
--  État vide — toutes missions accomplies
-- ------------------------------------------------------------
local function ShowEmptyState()
    local fs = WarchiefBoardFrame:CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    fs:SetPoint("CENTER", WarchiefBoardFrame, "CENTER", 0, -30)
    fs:SetWidth(400)
    fs:SetJustifyH("CENTER")
    fs:SetTextColor(0.9, 0.75, 0.3, 1)
    fs:SetText(WarchiefL.EMPTY_STATE)
    table.insert(activeFlyerWidgets, fs)
end

-- ------------------------------------------------------------
--  Handler AIO — reçoit les données du serveur
-- ------------------------------------------------------------
function WarchiefCommandHordeHandlers.OpenInterface(player, count, ...)
    EnsureMainFrame()
    ClearFlyerWidgets()

    count = tonumber(count) or 0

    if count == 0 then
        ShowEmptyState()
        WarchiefBoardFrame:Show()
        return
    end

    local args = { ... }

    for i = 1, count do
        local base = (i - 1) * FIELDS_PER_FLYER
        local flyer = {
            title       = args[base + 1],
            description = args[base + 2],
            buttonLabel = args[base + 3],
            cardImage   = args[base + 4],
            questId     = tonumber(args[base + 5]),
            mapId       = tonumber(args[base + 6]),
            posX        = tonumber(args[base + 7]),
            posY        = tonumber(args[base + 8]),
            posZ        = tonumber(args[base + 9]),
            orientation = tonumber(args[base + 10]),
            teleportMsg = args[base + 11],
        }
        BuildFlyerColumn(flyer, i)
    end

    WarchiefBoardFrame:Show()
end
