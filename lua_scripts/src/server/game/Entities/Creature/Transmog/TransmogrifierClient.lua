-- TransmogrifierClient.lua
-- Système de Transmogrification optimisé pour TrinityCore 3.3.5 avec AIO
-- Habillage visuel "Transmogrifier" (portage fidèle du layout Cataclysm/moderne).
--
-- v4 : fond de race trop lisible -> voile assombri fortement, panneau noir
-- séparé (couture visible) supprimé. Popup débordait au-dessus du cadre
-- pour les cases du haut -> alignée sur le haut du bouton. Pagination
-- superposée aux boutons Préc/Suiv -> sur sa propre ligne.
--
-- v5 : popup encore débordante (ancrée sur la case -> retombait DANS le
-- cadre) -> ancrée sur le CADRE lui-même. Coins ornés réduits (64->40px).
--
-- v6 (changement majeur) : d'après une démonstration détaillée du joueur
-- sur le vrai client Cataclysm, LE VRAI SYSTÈME N'A PAS DE POPUP DE
-- SÉLECTION. Le joueur glisse lui-même l'objet depuis ses sacs directement
-- sur la case d'emplacement (comme le forgeage/l'incrustation). La popup
-- "Apparences disponibles" est donc entièrement retirée et remplacée par un
-- vrai glisser-déposer (GetCursorInfo/OnReceiveDrag). Le contour orné
-- "EtherealFrameTemplate" (deviné, jamais confirmé par une vraie source
-- Cataclysm pour CE cadre précis) est remplacé par un liseré fin standard
-- (SetBackdrop Tooltip-Border), bien plus proche du contour uniforme et fin
-- vu sur les captures de référence que les gros coins fleuris. Ajout de la
-- rangée d'icônes caméra (zoom avant/arrière, pivot gauche/droite, glisser,
-- position par défaut) vue en haut à gauche du vrai client. Le
-- transmogtoast a été relayé sur les vraies proportions du fichier
-- transmogtoast.blp (256x64, pastille d'icône à gauche + bandeau de texte).
--
-- /!\ Icône ronde rouge en haut à gauche du cadre (visible sur les captures
-- du joueur) : introuvable dans les assets fournis (TransmogClientCataclysmUI.zip
-- ne contient que ButtonSystemTransmog/-Light, tous deux violets, pas
-- rouges) -- probablement un habillage propre au serveur du joueur. On
-- garde ButtonSystemTransmog en attendant le bon fichier.

local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local TransmogHandlers = AIO.AddHandlers("Transmog", {})
local TRANSMOG_WINDOW = "TransmogFrame"

local UI_LOCALE = (GetLocale and GetLocale() == "enUS") and "enUS" or "frFR"

local SLOT_NAMES_FR = {
    [1]  = "Tête",
    [3]  = "Épaules",
    [15] = "Dos",
    [5]  = "Torse",
    [9]  = "Poignets",
    [10] = "Mains",
    [6]  = "Taille",
    [7]  = "Jambes",
    [8]  = "Pieds",
    [16] = "Main droite",
    [17] = "Main gauche",
    [18] = "À distance",
}

local SLOT_NAMES_EN = {
    [1]  = "Head",
    [3]  = "Shoulders",
    [15] = "Back",
    [5]  = "Chest",
    [9]  = "Wrists",
    [10] = "Hands",
    [6]  = "Waist",
    [7]  = "Legs",
    [8]  = "Feet",
    [16] = "Main Hand",
    [17] = "Off Hand",
    [18] = "Ranged",
}

local Locales = {
    frFR = {
        SLOT_NAMES = SLOT_NAMES_FR,
        CAM_ZOOM_IN = "Zoomer",
        CAM_ZOOM_OUT = "Dézoomer",
        CAM_PAN = "Glisser (clic droit + glisser sur le modèle)",
        CAM_ROTATE_LEFT = "Pivoter à gauche",
        CAM_ROTATE_RIGHT = "Pivoter à droite",
        CAM_RESET = "Position par défaut",
        APPLY_BUTTON = "Appliquer",
        RESET_ALL_BUTTON = "Tout réinitialiser",
        COST_LABEL = "Coût par transmogrification :",
        TOOLTIP_NO_ITEM_AVAILABLE = "Aucun objet équipé (objets disponibles)",
        TOOLTIP_NO_ITEM_NONE = "Aucun objet équipé ni disponible",
        TOOLTIP_PENDING = "Changement en attente (Appliquer, clic droit pour annuler)",
        TOOLTIP_DRAG_HINT = "Glissez un objet de même type depuis vos sacs",
        DEFAULT_SUCCESS_MSG = "Transmogrification appliquée",
        DEFAULT_ERROR_MSG = "Erreur de transmogrification",
    },
    enUS = {
        SLOT_NAMES = SLOT_NAMES_EN,
        CAM_ZOOM_IN = "Zoom in",
        CAM_ZOOM_OUT = "Zoom out",
        CAM_PAN = "Pan (right-click + drag on the model)",
        CAM_ROTATE_LEFT = "Rotate left",
        CAM_ROTATE_RIGHT = "Rotate right",
        CAM_RESET = "Default position",
        APPLY_BUTTON = "Apply",
        RESET_ALL_BUTTON = "Reset All",
        COST_LABEL = "Cost per transmogrification:",
        TOOLTIP_NO_ITEM_AVAILABLE = "No item equipped (items available)",
        TOOLTIP_NO_ITEM_NONE = "No item equipped or available",
        TOOLTIP_PENDING = "Pending change (Apply, right-click to cancel)",
        TOOLTIP_DRAG_HINT = "Drag a matching item from your bags",
        DEFAULT_SUCCESS_MSG = "Transmogrification applied",
        DEFAULT_ERROR_MSG = "Transmogrification error",
    },
}

local L = Locales[UI_LOCALE] or Locales.frFR

local OPEN_TALENT_WINDOW_SOUND  = "Sound\\INTERFACE\\UI_Transmogrify_Apply.OGG"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\INTERFACE\\UI_VoidStorage_Undo.OGG"
local GET_ITEM_WINDOW_SOUND     = "Sound\\INTERFACE\\UI_Reforging_Reforge.ogg"

-- ============================================================
-- Assets "design Transmogrifier" (portés depuis TransmogClientCataclysmUI.zip)
-- ============================================================
local TRANSMOG_ART = "Interface\\TansmogUI\\transmogrify\\"

-- Case d'emplacement : cadre bronze orné + icône "indisponible" (rouge),
-- coordonnées mesurées directement dans transmogrify.blp (texture 512x512).
local SLOT_FRAME_COORDS = {447/512, 501/512, 3/512, 56/512}
local SLOT_NO_COORDS    = {395/512, 416/512, 156/512, 177/512}

-- Configuration des slots d'équipement
local SLOTS = {
    {id = 1,  name = L.SLOT_NAMES[1],  slot = "HeadSlot"},
    {id = 3,  name = L.SLOT_NAMES[3],  slot = "ShoulderSlot"},
    {id = 15, name = L.SLOT_NAMES[15], slot = "BackSlot"},
    {id = 5,  name = L.SLOT_NAMES[5],  slot = "ChestSlot"},
    {id = 9,  name = L.SLOT_NAMES[9],  slot = "WristSlot"},
    {id = 10, name = L.SLOT_NAMES[10], slot = "HandsSlot"},
    {id = 6,  name = L.SLOT_NAMES[6],  slot = "WaistSlot"},
    {id = 7,  name = L.SLOT_NAMES[7],  slot = "LegsSlot"},
    {id = 8,  name = L.SLOT_NAMES[8],  slot = "FeetSlot"},
    {id = 16, name = L.SLOT_NAMES[16], slot = "MainHandSlot"},
    {id = 17, name = L.SLOT_NAMES[17], slot = "SecondaryHandSlot"},
    {id = 18, name = L.SLOT_NAMES[18], slot = "RangedSlot"},
}

-- Disposition compacte : colonne gauche / colonne droite / rangée basse,
-- autour d'un petit modèle central (comme la vraie fenêtre Transmogrifier).
local slotPositions = {
    [1]  = {name = L.SLOT_NAMES[1],  x = -100, y =  120},
    [3]  = {name = L.SLOT_NAMES[3],  x = -100, y =   72},
    [15] = {name = L.SLOT_NAMES[15], x = -100, y =   24},
    [5]  = {name = L.SLOT_NAMES[5],  x = -100, y =  -24},
    [9]  = {name = L.SLOT_NAMES[9],  x = -100, y =  -72},
    [10] = {name = L.SLOT_NAMES[10], x =  100, y =   96},
    [6]  = {name = L.SLOT_NAMES[6],  x =  100, y =   48},
    [7]  = {name = L.SLOT_NAMES[7],  x =  100, y =    0},
    [8]  = {name = L.SLOT_NAMES[8],  x =  100, y =  -48},
    [16] = {name = L.SLOT_NAMES[16], x =  -40, y = -125},
    [17] = {name = L.SLOT_NAMES[17], x =    0, y = -125},
    [18] = {name = L.SLOT_NAMES[18], x =   40, y = -125},
}

local slotButtons      = {}
local pendingChanges   = {}   -- [slotId] = itemId en attente de validation ("Appliquer")
local pendingLinks     = {}   -- [slotId] = itemLink (nécessaire pour DressUpModel:TryOn)
local slotHasItems     = {}   -- [slotId] = true/false (au moins un objet compatible en sac)
local appliedAppearances = {} -- [slotId] = itemId de la transmog actuellement appliquée (0/nil = aucune)
local TransmogFrame    = nil
local playerModel      = nil
local applyBtn         = nil

-- ============================================================
-- Fond atmosphérique par race (Interface\TansmogUI\transmogrify\transmogbackground*)
-- /!\ Les tokens des races custom (Nightborne, Zandalari, Vulpera, etc.) sont
-- ceux utilisés par Blizzard en retail ; à vérifier en jeu si ce client custom
-- utilise une nomenclature différente pour ses races ajoutées.
-- ============================================================
local RACE_BG_FILE = {
    HUMAN               = "human",
    DWARF               = "dwarf",
    NIGHTELF            = "nightelf",
    GNOME               = "gnome",
    DRAENEI             = "draenei",
    ORC                 = "orc",
    SCOURGE             = "undead",
    UNDEAD              = "undead",
    TAUREN              = "tauren",
    TROLL               = "troll",
    BLOODELF            = "bloodelf",
    GOBLIN              = "goblin",
    WORGEN              = "worgen",
    PANDARENALLIANCE    = "pandaren",
    PANDARENHORDE       = "pandaren",
    PANDAREN            = "pandaren",
    VOIDELF             = "voidelf",
    LIGHTFORGEDDRAENEI  = "lightforged",
    NIGHTBORNE          = "nightborne",
    HIGHMOUNTAINTAUREN  = "highmountain",
    ZANDALARITROLL      = "zandalari",
    KULTIRAN            = "kultiran",
    DARKIRONDWARF       = "darkirondwarf",
    MAGHARORC           = "maghar",
    MECHAGNOME          = "mechagnome",
    VULPERA             = "vulpera",
    DRACTHYR            = "dracthyr",
    EARTHENDWARF        = "earthen",
    EARTHEN             = "earthen",
}

local function GetTransmogRaceBackground()
    local _, raceFile = UnitRace("player")
    if raceFile then
        local key = strupper(raceFile):gsub("%s+", "")
        local suffix = RACE_BG_FILE[key]
        if suffix then
            return TRANSMOG_ART .. "transmogbackground" .. suffix
        end
    end
    return TRANSMOG_ART .. "transmogbackgroundhuman"
end

-- ============================================================
-- Contour orné (coins fleuris + bordures tuilées), porté du template natif
-- "EtherealFrameTemplate". Coordonnées vérifiées pixel par pixel cette fois
-- (analyse par composantes connexes de Textures.blp, 128x512) plutôt que
-- reprises telles quelles du XML : elles se sont avérées identiques, donc
-- le souci des rounds précédents n'était pas les coordonnées mais la
-- TAILLE (trop réduite en v5) puis la SUPPRESSION pure et simple (v6-v8).
-- ============================================================
local BORDER_ART = "Interface\\Transmogrify\\"

-- BL/TR partagent le même bloc image dans Textures.blp (deux coins accolés
-- sans espace entre eux) -> on découpe la moitié haute (BL) et la moitié
-- basse (TR) de ce bloc.
local CORNER_COORDS = {
    TL = {0/128,  63/128,  1/512,   65/512},
    BR = {2/128,  66/128,  68/512,  131/512},
    BL = {0/128,  66/128,  133/512, 196/512},
    TR = {0/128,  66/128,  196/512, 259/512},
}

local VERT_LEFT_COORDS    = {0.40625000, 0.76562500, 0.0, 1.0}
local VERT_RIGHT_COORDS   = {0.01562500, 0.37500000, 0.0, 1.0}
local HORIZ_TOP_COORDS    = {0.0, 1.0, 0.40625000, 0.76562500}
local HORIZ_BOTTOM_COORDS = {0.0, 1.0, 0.01562500, 0.37500000}

local CORNER_SIZE = 56   -- taille d'affichage (natif ~64px, légèrement réduit pour un cadre compact 340x470)
local EDGE_THICK  = 18

-- Reconstruit à partir de la technique EXACTE du système Void Storage du
-- joueur (VoidStorageClient.lua, fonctionnel et vérifié) : chaque bord est
-- une SEULE texture étirée entre deux coins (deux SetPoint) avec
-- SetHorizTile/SetVertTile pour un motif qui se répète nativement, ancrée
-- directement sous/à côté des coins -- plutôt que ma boucle de segments
-- manuels, qui ne se raccordait pas proprement.
local function ApplyOrnateBorder(frame)
    local cornersFrame = frame.ornateCorners or CreateFrame("Frame", nil, frame)
    cornersFrame:SetAllPoints()
    cornersFrame:SetFrameLevel(frame:GetFrameLevel() + 2)
    frame.ornateCorners = cornersFrame

    local function MakeCorner(point, x, y, coordKey)
        local tex = cornersFrame:CreateTexture(nil, "OVERLAY")
        tex:SetSize(64, 64)
        tex:SetPoint(point, x, y)
        tex:SetTexture(BORDER_ART .. "Textures")
        local c = CORNER_COORDS[coordKey]
        tex:SetTexCoord(c[1], c[2], c[3], c[4])
        return tex
    end

    local cornerTL = MakeCorner("TOPLEFT",     -2, 0, "TL")
    local cornerTR = MakeCorner("TOPRIGHT",     2, 0, "TR")
    local cornerBL = MakeCorner("BOTTOMLEFT",  -2, 0, "BL")
    local cornerBR = MakeCorner("BOTTOMRIGHT",  2, 0, "BR")

    local edgesFrame = CreateFrame("Frame", nil, frame)
    edgesFrame:SetAllPoints()
    edgesFrame:SetFrameLevel(frame:GetFrameLevel() + 1)

    local leftEdge = edgesFrame:CreateTexture(nil, "OVERLAY")
    leftEdge:SetSize(23, 64)
    leftEdge:SetTexture(BORDER_ART .. "VerticalTiles", false, true)
    leftEdge:SetTexCoord(VERT_LEFT_COORDS[1], VERT_LEFT_COORDS[2], VERT_LEFT_COORDS[3], VERT_LEFT_COORDS[4])
    leftEdge:SetPoint("TOPLEFT", cornerTL, "BOTTOMLEFT", 4, 16)
    leftEdge:SetPoint("BOTTOMLEFT", cornerBL, "TOPLEFT", 4, -16)

    local rightEdge = edgesFrame:CreateTexture(nil, "OVERLAY")
    rightEdge:SetSize(23, 64)
    rightEdge:SetTexture(BORDER_ART .. "VerticalTiles", false, true)
    rightEdge:SetTexCoord(VERT_RIGHT_COORDS[1], VERT_RIGHT_COORDS[2], VERT_RIGHT_COORDS[3], VERT_RIGHT_COORDS[4])
    rightEdge:SetPoint("TOPRIGHT", cornerTR, "BOTTOMRIGHT", -4, 16)
    rightEdge:SetPoint("BOTTOMRIGHT", cornerBR, "TOPRIGHT", -4, -16)

    local topEdge = edgesFrame:CreateTexture(nil, "OVERLAY")
    topEdge:SetSize(64, 23)
    topEdge:SetTexture(BORDER_ART .. "HorizontalTiles", true, false)
    topEdge:SetTexCoord(HORIZ_TOP_COORDS[1], HORIZ_TOP_COORDS[2], HORIZ_TOP_COORDS[3], HORIZ_TOP_COORDS[4])
    topEdge:SetPoint("TOPLEFT", cornerTL, "TOPRIGHT", -25, -5)
    topEdge:SetPoint("TOPRIGHT", cornerTR, "TOPLEFT", 25, -5)

    local bottomEdge = edgesFrame:CreateTexture(nil, "OVERLAY")
    bottomEdge:SetSize(64, 23)
    bottomEdge:SetTexture(BORDER_ART .. "HorizontalTiles", true, false)
    bottomEdge:SetTexCoord(HORIZ_BOTTOM_COORDS[1], HORIZ_BOTTOM_COORDS[2], HORIZ_BOTTOM_COORDS[3], HORIZ_BOTTOM_COORDS[4])
    bottomEdge:SetPoint("BOTTOMLEFT", cornerBL, "BOTTOMRIGHT", -21, 5)
    bottomEdge:SetPoint("BOTTOMRIGHT", cornerBR, "BOTTOMLEFT", 21, 5)
end

-- ============================================================
-- Bandeau de confirmation ("toast") — proportions réelles de
-- transmogtoast.blp (256x64) : pastille d'icône à gauche, bandeau de
-- texte dégradé à droite.
-- ============================================================
local transmogToastFrame = nil

local function ShowTransmogToast(message, icon)
    if not transmogToastFrame then
        local frame = CreateFrame("Frame", nil, UIParent)
        -- 4 essais successifs pour étirer/prolonger l'image transmogtoast.blp
        -- sans laisser de raccord visible ont tous échoué (le panneau
        -- d'extension apparaissait comme un rectangle bien visible). Comme
        -- suggéré par le joueur : on abandonne cette texture pour un
        -- bandeau simple (même technique de bordure "tooltip" déjà utilisée
        -- avec succès ailleurs dans ce fichier, boutons caméra/cases) ->
        -- plus aucun risque de raccord, largeur libre.
        frame:SetSize(320, 44)
        frame:SetPoint("TOP", 0, -140)
        frame:SetFrameStrata("TOOLTIP")
        frame:Hide()

        frame:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        })
        frame:SetBackdropColor(0.08, 0.02, 0.1, 0.95)
        frame:SetBackdropBorderColor(0.6, 0.4, 0.8, 1)

        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetSize(30, 30)
        frame.icon:SetPoint("LEFT", 10, 0)

        frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.text:SetPoint("LEFT", frame.icon, "RIGHT", 10, 0)
        frame.text:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
        frame.text:SetJustifyH("LEFT")
        frame.text:SetJustifyV("MIDDLE")
        frame.text:SetWordWrap(true)

        transmogToastFrame = frame
    end

    local frame = transmogToastFrame
    frame.text:SetText(message or L.DEFAULT_SUCCESS_MSG)
    frame.icon:SetTexture(icon or "Interface\\RaidFrame\\ReadyCheck-Ready")
    frame.elapsed = 0
    frame:SetAlpha(1)
    frame:Show()
    frame:SetScript("OnUpdate", function(self, delta)
        self.elapsed = self.elapsed + delta
        if self.elapsed > 2.2 then
            local alpha = 1 - ((self.elapsed - 2.2) / 0.6)
            if alpha <= 0 then
                self:Hide()
                self:SetScript("OnUpdate", nil)
            else
                self:SetAlpha(alpha)
            end
        end
    end)
end

-- ============================================================
-- Petits boutons caméra (zoom / pivot / glisser / réinitialiser),
-- comme la rangée d'icônes en haut à gauche du vrai client.
-- ============================================================
local function CreateCameraButton(parent, label, tooltipText, onClick)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(18, 18)

    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    btn.bg:SetVertexColor(0.15, 0.1, 0.05, 0.9)

    btn:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
    })
    btn:SetBackdropBorderColor(0.6, 0.45, 0.2, 1)

    btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.label:SetPoint("CENTER", 0, 1)
    btn.label:SetText(label)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(tooltipText)
        GameTooltip:Show()
        self:SetBackdropBorderColor(1, 0.82, 0.1, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self:SetBackdropBorderColor(0.6, 0.45, 0.2, 1)
    end)
    btn:SetScript("OnClick", onClick)

    return btn
end

-- NOTE : "SetPortraitZoom" n'existe PAS sur ce client (API absente sur
-- WotLK 3.3.5, méthode introduite bien plus tard chez Blizzard) -> a fait
-- planter tout le reste de CreateUI en v6 (Lua interrompait la fonction dès
-- ce premier appel, donc plus aucune case/plus aucun bouton n'apparaissait).
-- On reproduit le zoom UNIQUEMENT avec SetPosition/SetRotation, deux
-- méthodes Model confirmées disponibles et déjà utilisées avec succès
-- ailleurs dans ce projet (aperçu Armes de la Garde-robe).
--
-- IMPORTANT : les boutons ci-dessous ne capturent PLUS un modèle précis --
-- ils lisent/écrivent l'upvalue partagée `playerModel`, qui est détruite et
-- recréée à chaque ouverture/Appliquer/Réinitialiser (voir RecreateModel
-- plus bas). Sans ça, les boutons resteraient accrochés à l'ANCIEN widget
-- une fois celui-ci recréé.
local function CreateCameraControls(frame)
    local buttons = {}
    local defs = {
        {"+", L.CAM_ZOOM_IN, function()
            if not playerModel then return end
            playerModel.zoomOffset = math.min(2, playerModel.zoomOffset + 0.3)
            playerModel.ApplyCamera()
        end},
        {"-", L.CAM_ZOOM_OUT, function()
            if not playerModel then return end
            playerModel.zoomOffset = math.max(-2, playerModel.zoomOffset - 0.3)
            playerModel.ApplyCamera()
        end},
        {"H", L.CAM_PAN, function() end},
        {"<", L.CAM_ROTATE_LEFT, function()
            if not playerModel then return end
            playerModel.rotation = playerModel.rotation - 0.4
            playerModel.ApplyCamera()
        end},
        {">", L.CAM_ROTATE_RIGHT, function()
            if not playerModel then return end
            playerModel.rotation = playerModel.rotation + 0.4
            playerModel.ApplyCamera()
        end},
        {"R", L.CAM_RESET, function()
            if not playerModel then return end
            playerModel.zoomOffset = 0
            playerModel.rotation   = 0.15
            playerModel.panY, playerModel.panZ = 0, 0
            playerModel.ApplyCamera()
        end},
    }

    -- Rangée centrée horizontalement, juste sous le titre "Transmogrifier"
    -- (elle était plaquée au coin haut-gauche du cadre auparavant).
    local BTN_SIZE, BTN_GAP = 18, 2
    local rowWidth = (#defs * BTN_SIZE) + ((#defs - 1) * BTN_GAP)
    local startX = (frame:GetWidth() - rowWidth) / 2
    for i, def in ipairs(defs) do
        local btn = CreateCameraButton(frame, def[1], def[2], def[3])
        btn:SetPoint("TOPLEFT", frame, "TOPLEFT", startX + (i - 1) * (BTN_SIZE + BTN_GAP), -34)
        buttons[i] = btn
    end
end

-- Initialise la caméra (zoom/pivot par défaut + glisser souris) sur le
-- widget DressUpModel COURANT. Appelée à chaque (re)création du modèle
-- (voir RecreateModel) puisque ces réglages vivent sur l'objet frame
-- lui-même et disparaissent avec lui.
local function InitModelCamera(model)
    model.zoomOffset = 0    -- profondeur caméra (avant/arrière)
    model.rotation   = 0.15
    model.panY       = 0    -- décalage horizontal
    model.panZ       = 0    -- décalage vertical

    model.ApplyCamera = function()
        model:SetPosition(model.zoomOffset, model.panY, model.panZ)
        model:SetRotation(model.rotation)
    end
    model.ApplyCamera()

    -- Glisser (clic droit + déplacement) directement sur le modèle ;
    -- clic gauche + déplacement = rotation (comportement d'origine conservé)
    model:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.isRotating   = true
            self.lastCursorX  = GetCursorPosition()
        elseif button == "RightButton" then
            self.isPanning    = true
            self.lastCursorX, self.lastCursorY = GetCursorPosition()
        end
    end)
    model:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self.isRotating = false
        elseif button == "RightButton" then
            self.isPanning = false
        end
    end)
    model:SetScript("OnUpdate", function(self)
        if self.isRotating then
            -- Rotation (clic gauche) : sens d'origine confirmé correct par
            -- le joueur -> pas de changement de signe ici.
            local cursorX = GetCursorPosition()
            local diff    = cursorX - self.lastCursorX
            self.rotation = self.rotation + (diff * 0.01)
            self:SetRotation(self.rotation)
            self.lastCursorX = cursorX
        elseif self.isPanning then
            -- Glisser (clic droit) : c'était en fait CET axe qui était
            -- inversé (glisser à droite envoyait le personnage à gauche)
            -- -> signe horizontal inversé.
            local cursorX, cursorY = GetCursorPosition()
            local diffX = (cursorX - self.lastCursorX) * 0.003
            local diffY = (cursorY - self.lastCursorY) * 0.003
            self.panY = self.panY + diffX
            self.panZ = self.panZ + diffY
            self:SetPosition(self.zoomOffset, self.panY, self.panZ)
            self.lastCursorX, self.lastCursorY = cursorX, cursorY
        end
    end)
end

-- Les cases d'emplacement s'ancrent sur le CENTRE du modèle 3D -> doivent
-- être ré-ancrées sur le nouveau widget à chaque recréation.
local function RepositionSlotButtons()
    if not playerModel then return end
    for _, btn in ipairs(slotButtons) do
        if btn.slotPos then
            btn:ClearAllPoints()
            btn:SetPoint("CENTER", playerModel, "CENTER", btn.slotPos.x, btn.slotPos.y)
        end
    end
end

-- Détruit et recrée entièrement le widget DressUpModel plutôt que de le
-- réinitialiser sans cesse via ClearModel()/SetUnit() : après trop de
-- réinitialisations successives, ce widget finit par se bloquer en interne
-- sur ce client (le zoom/pivot cesse de répondre correctement, seul un
-- rechargement complet de l'UI -- déco/reco -- le débloquait). Recréer le
-- frame à chaque ouverture de fenêtre / Appliquer / Tout réinitialiser
-- reproduit l'effet "propre" d'un relog sans y être obligé.
local function RecreateModel()
    if not TransmogFrame then return end

    if playerModel then
        playerModel:Hide()
        playerModel:SetScript("OnUpdate", nil)
        playerModel:SetScript("OnMouseDown", nil)
        playerModel:SetScript("OnMouseUp", nil)
        playerModel:SetParent(nil)
    end

    playerModel = CreateFrame("DressUpModel", nil, TransmogFrame)
    playerModel:SetSize(130, 190)
    playerModel:SetPoint("TOP", 0, -105)
    playerModel:EnableMouse(true)
    playerModel:SetUnit("player")

    InitModelCamera(playerModel)
    RepositionSlotButtons()

    -- Ré-applique les aperçus de glisser-déposer en attente (non encore
    -- validés par "Appliquer") sur le nouveau modèle.
    for slotId, link in pairs(pendingLinks) do
        if link then
            playerModel:TryOn(link)
        end
    end
end

-- ============================================================
-- Glisser-déposer : le joueur amène lui-même l'objet depuis ses sacs et
-- le dépose sur la case d'emplacement (pas de popup de sélection).
-- ============================================================
-- Reconstruit l'aperçu du modèle 3D à partir de l'équipement réel du
-- joueur + tous les changements en attente (DressUpModel:TryOn habille
-- visuellement l'objet SANS l'équiper réellement -> prévisualisation
-- avant de cliquer "Appliquer", comme le vrai Transmogrifier).
local function RefreshModelPreview()
    RecreateModel()
end

local function HandleSlotDrop(btn)
    local itemType, itemId, itemLink = GetCursorInfo()
    if itemType ~= "item" or not itemId then
        return
    end
    ClearCursor()

    pendingChanges[btn.slotId] = itemId
    pendingLinks[btn.slotId]   = itemLink

    local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemId)
    if texture then
        btn.itemIcon:SetTexture(texture)
        btn.itemIcon:Show()
    else
        local item = Item:CreateFromItemID(itemId)
        item:ContinueOnItemLoad(function()
            if pendingChanges[btn.slotId] == itemId then
                local _, _, _, _, _, _, _, _, _, tex = GetItemInfo(itemId)
                if tex then
                    btn.itemIcon:SetTexture(tex)
                    btn.itemIcon:Show()
                end
            end
        end)
    end
    btn.availIcon:Hide()
    btn.noIcon:Hide()
    btn.pendingGlow:Show()

    -- Aperçu immédiat sur le modèle 3D (avant validation)
    if itemLink then
        playerModel:TryOn(itemLink)
    end

    PlaySoundFile(GET_ITEM_WINDOW_SOUND)
end

-- ============================================================
-- Création de l'interface principale
-- ============================================================
function TransmogHandlers.CreateUI(player)
    if TransmogFrame then
        TransmogFrame:Show()
        RecreateModel()
        TransmogHandlers.UpdateSlots()
        return
    end

    -- ── Frame principale (format compact, comme la vraie fenêtre Transmogrifier) ──
    TransmogFrame = CreateFrame("Frame", TRANSMOG_WINDOW, UIParent)
    TransmogFrame:SetSize(340, 470)
    TransmogFrame:SetPoint("CENTER")
    TransmogFrame:SetMovable(true)
    TransmogFrame:EnableMouse(true)
    TransmogFrame:RegisterForDrag("LeftButton")
    TransmogFrame:SetScript("OnDragStart", TransmogFrame.StartMoving)
    TransmogFrame:SetScript("OnDragStop",  TransmogFrame.StopMovingOrSizing)
    TransmogFrame:SetFrameStrata("DIALOG")
    TransmogFrame:SetClampedToScreen(true)

    -- Fond : technique EXACTE du système Void Storage du joueur (fonctionnel,
    -- vérifié) -- une texture de marbre tuilable (pas une photo de race, plus
    -- de "moitié claire / moitié sombre" possible puisque c'est un motif
    -- répétitif uniforme), une teinte violette solide par-dessus, et un
    -- motif de lignes éthérées tuilé en détail fin.
    local marbleBg = TransmogFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
    marbleBg:SetPoint("TOPLEFT", 4, -19)
    marbleBg:SetPoint("BOTTOMRIGHT", -4, 4)
    marbleBg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble", true, true)
    marbleBg:SetHorizTile(true)
    marbleBg:SetVertTile(true)

    local tint = TransmogFrame:CreateTexture(nil, "BORDER", nil, -7)
    tint:SetPoint("TOPLEFT", 4, -19)
    tint:SetPoint("BOTTOMRIGHT", -4, 4)
    tint:SetTexture(0.302, 0.102, 0.204, 0.6)

    local lines = TransmogFrame:CreateTexture(nil, "ARTWORK", nil, -8)
    lines:SetPoint("TOPLEFT", 4, -19)
    lines:SetPoint("BOTTOMRIGHT", -4, 4)
    lines:SetTexture(BORDER_ART .. "EtherealLines", true, true)
    lines:SetHorizTile(true)
    lines:SetVertTile(true)
    lines:SetAlpha(0.3)

    -- Contour orné (coins fleuris + bordures tuilées), reconstruit à partir
    -- des vraies textures Textures/VerticalTiles/HorizontalTiles fournies
    -- par le joueur et vérifiées pixel par pixel.
    ApplyOrnateBorder(TransmogFrame)

    -- Icône et titre retirés (demandé) : l'icône n'était pas la bonne de
    -- toute façon (voir note en tête de fichier) et passait derrière le
    -- coin orné.

    -- Bouton de fermeture : niveau de frame explicitement au-dessus des
    -- coins/bords ornés (sinon il rendait DERRIÈRE le coin haut-droit).
    local closeBtn = CreateFrame("Button", nil, TransmogFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -6, -6)
    closeBtn:SetFrameLevel(TransmogFrame:GetFrameLevel() + 10)
    closeBtn:SetScript("OnClick", function()
        TransmogFrame:Hide()
    end)

    -- ── Modèle 3D du personnage (compact, centré) ─────────────
    -- Descendu (était -70) pour mieux centrer tout le bloc (modèle + cases,
    -- qui s'ancrent sur son centre) verticalement dans le cadre -- taille et
    -- position sont fixées dans RecreateModel (SetSize 130x190, TOP 0,-105).

    -- Rangée d'icônes caméra (zoom, pivot, glisser, position par défaut) --
    -- créée UNE SEULE FOIS ; les boutons lisent l'upvalue `playerModel`
    -- partagée, peu importe combien de fois le modèle est recréé ensuite.
    CreateCameraControls(TransmogFrame)
    RecreateModel()

    TransmogFrame:SetScript("OnShow", function()
        AIO.Handle("Transmog", "GetSlotAvailability")
        TransmogHandlers.UpdateSlots()
        PlaySoundFile(OPEN_TALENT_WINDOW_SOUND)
    end)

    TransmogFrame:SetScript("OnHide", function()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    end)

    -- ── Cases d'emplacement (cadre bronze orné + icône) ───────
    for _, slotData in ipairs(SLOTS) do
        local pos = slotPositions[slotData.id]
        if pos then
            local btn = CreateFrame("Button", nil, TransmogFrame)
            btn:SetSize(34, 34)
            btn:SetPoint("CENTER", playerModel, "CENTER", pos.x, pos.y)
            btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

            -- Fond sombre
            btn.background = btn:CreateTexture(nil, "BACKGROUND")
            btn.background:SetAllPoints()
            btn.background:SetTexture(0, 0, 0, 0.6)

            -- Icône de l'objet équipé / en attente (masquée par défaut)
            btn.itemIcon = btn:CreateTexture(nil, "ARTWORK")
            btn.itemIcon:SetSize(34, 34)
            btn.itemIcon:SetPoint("CENTER")
            btn.itemIcon:Hide()

            -- Icône "disponible" (silhouette paperdoll), affichée quand rien
            -- n'est équipé MAIS qu'au moins un objet de transmog est possédé
            btn.availIcon = btn:CreateTexture(nil, "ARTWORK")
            btn.availIcon:SetSize(28, 28)
            btn.availIcon:SetPoint("CENTER")
            btn.availIcon:SetTexture("Interface\\PaperDoll\\UI-PaperDoll-Slot-" .. slotData.slot)
            btn.availIcon:SetAlpha(0.7)
            btn.availIcon:Hide()

            -- Icône "indisponible" (rouge), affichée seulement si le joueur
            -- n'a vraiment aucun objet de transmog compatible en sac
            btn.noIcon = btn:CreateTexture(nil, "ARTWORK", nil, 1)
            btn.noIcon:SetSize(26, 26)
            btn.noIcon:SetPoint("CENTER")
            btn.noIcon:SetTexture(TRANSMOG_ART .. "transmogrify")
            btn.noIcon:SetTexCoord(SLOT_NO_COORDS[1], SLOT_NO_COORDS[2], SLOT_NO_COORDS[3], SLOT_NO_COORDS[4])
            btn.noIcon:Hide()

            -- Cadre bronze orné (case d'emplacement, porté de transmogrify.blp)
            btn.frameTex = btn:CreateTexture(nil, "OVERLAY")
            btn.frameTex:SetSize(40, 40)
            btn.frameTex:SetPoint("CENTER")
            btn.frameTex:SetTexture(TRANSMOG_ART .. "transmogrify")
            btn.frameTex:SetTexCoord(SLOT_FRAME_COORDS[1], SLOT_FRAME_COORDS[2], SLOT_FRAME_COORDS[3], SLOT_FRAME_COORDS[4])

            -- Lueur dorée indiquant un changement en attente de validation
            btn.pendingGlow = btn:CreateTexture(nil, "OVERLAY", nil, -1)
            btn.pendingGlow:SetPoint("CENTER")
            btn.pendingGlow:SetSize(44, 44)
            btn.pendingGlow:SetTexture(TRANSMOG_ART .. "ButtonTM")
            btn.pendingGlow:SetBlendMode("ADD")
            btn.pendingGlow:Hide()

            btn:SetHighlightTexture(TRANSMOG_ART .. "ButtonTM", "ADD")

            btn.slotId   = slotData.id
            btn.slotData = slotData
            btn.slotPos  = pos

            -- Glisser-déposer : dépose directe d'un objet des sacs (pas de
            -- popup). Reproduit exactement le vrai système Cataclysm.
            btn:SetScript("OnReceiveDrag", function(self)
                HandleSlotDrop(self)
            end)
            btn:SetScript("OnClick", function(self, mouseButton)
                if mouseButton == "RightButton" then
                    -- Annule un changement en attente sur cette case
                    if pendingChanges[self.slotId] then
                        pendingChanges[self.slotId] = nil
                        pendingLinks[self.slotId] = nil
                        TransmogHandlers.UpdateSlots()
                        RefreshModelPreview()
                    end
                    return
                end
                if CursorHasItem() then
                    HandleSlotDrop(self)
                end
            end)

            btn:SetScript("OnEnter", function(self)
                local itemLink = GetInventoryItemLink("player", self.slotId)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if itemLink then
                    GameTooltip:SetHyperlink(itemLink)
                else
                    GameTooltip:SetText(pos.name)
                    if slotHasItems[self.slotId] then
                        GameTooltip:AddLine(L.TOOLTIP_NO_ITEM_AVAILABLE, 0.6, 1, 0.6)
                    else
                        GameTooltip:AddLine(L.TOOLTIP_NO_ITEM_NONE, 0.8, 0.8, 0.8)
                    end
                end
                if pendingChanges[self.slotId] then
                    GameTooltip:AddLine(L.TOOLTIP_PENDING, 0.6, 1, 0.6)
                else
                    GameTooltip:AddLine(L.TOOLTIP_DRAG_HINT, 0.7, 0.7, 0.7)
                end
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            slotButtons[#slotButtons + 1] = btn
        end
    end

    -- ── Bouton unique "Appliquer" + réinitialisation ──────────
    applyBtn = CreateFrame("Button", nil, TransmogFrame, "UIPanelButtonTemplate")
    applyBtn:SetSize(120, 28)
    applyBtn:SetPoint("BOTTOM", 60, 33)
    applyBtn:SetText(L.APPLY_BUTTON)
    applyBtn:SetScript("OnClick", function()
        local count = 0
        for slotId, itemId in pairs(pendingChanges) do
            AIO.Handle("Transmog", "ApplyTransmog", slotId, itemId)
            count = count + 1
        end
        if count > 0 then
            PlaySoundFile(GET_ITEM_WINDOW_SOUND)
        end
        pendingChanges = {}
        pendingLinks = {}
        for _, sBtn in ipairs(slotButtons) do
            sBtn.pendingGlow:Hide()
        end
    end)

    local resetAllBtn = CreateFrame("Button", nil, TransmogFrame, "UIPanelButtonTemplate")
    resetAllBtn:SetSize(120, 22)
    resetAllBtn:SetPoint("BOTTOM", -70, 35)
    resetAllBtn:SetText(L.RESET_ALL_BUTTON)
    resetAllBtn:SetScript("OnClick", function()
        pendingChanges = {}
        pendingLinks = {}
        for _, sBtn in ipairs(slotButtons) do
            sBtn.pendingGlow:Hide()
        end
        RefreshModelPreview()
        AIO.Handle("Transmog", "ResetAll")
    end)

    -- ── Affichage du coût ─────────────────────────────────────
    local costFrame = CreateFrame("Frame", nil, TransmogFrame)
    costFrame:SetSize(200, 24)
    costFrame:SetPoint("BOTTOM", -10, 72)

    local costIcon = costFrame:CreateTexture(nil, "ARTWORK")
    costIcon:SetSize(16, 16)
    costIcon:SetPoint("RIGHT", costFrame, "CENTER", -5, 0)
    costIcon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")

    local costText = costFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    costText:SetPoint("LEFT", costFrame, "CENTER", 5, 0)
    costText:SetText("50")
    costText:SetTextColor(1, 0.82, 0)

    local costLabel = costFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    costLabel:SetPoint("BOTTOM", costText, "TOP", 0, 4)
    costLabel:SetText(L.COST_LABEL)
    costLabel:SetTextColor(0.8, 0.8, 0.8)

    -- Fermeture via Escape
    tinsert(UISpecialFrames, TRANSMOG_WINDOW)

    -- Mise à jour initiale des slots
    TransmogHandlers.UpdateSlots()
end

-- ============================================================
-- Mise à jour des slots équipés
-- ============================================================
function TransmogHandlers.UpdateSlots()
    if not TransmogFrame or not slotButtons[1] then return end

    for _, btn in ipairs(slotButtons) do
        if pendingChanges[btn.slotId] then
            -- Un changement est en attente de validation : on ne touche pas
            -- à l'aperçu déjà posé lors du glisser-déposer.
        else
            local texture = nil

            -- La transmogrification ne change PAS l'item réellement équipé
            -- (GetInventoryItemID reste l'item d'origine) : elle ne modifie
            -- que l'apparence visuelle côté serveur (PLAYER_VISIBLE_ITEM).
            -- On doit donc PRIORISER l'apparence appliquée connue du client
            -- (appliedAppearances, envoyée par le serveur) avant de retomber
            -- sur l'item physiquement équipé.
            local appliedId = appliedAppearances[btn.slotId]
            if appliedId and appliedId ~= 0 then
                local _, _, _, _, _, _, _, _, _, tex = GetItemInfo(appliedId)
                if tex then
                    texture = tex
                else
                    local item = Item:CreateFromItemID(appliedId)
                    item:ContinueOnItemLoad(function()
                        TransmogHandlers.UpdateSlots()
                    end)
                end
            end

            if not texture then
                local itemLink = GetInventoryItemLink("player", btn.slotId)
                if itemLink then
                    local itemId = GetInventoryItemID("player", btn.slotId)
                    if itemId then
                        -- IMPORTANT : ne pas combiner "itemId and GetItemInfo(itemId)"
                        -- dans la même expression d'affectation multiple (voir v3).
                        local _, _, _, _, _, _, _, _, _, tex = GetItemInfo(itemId)
                        texture = tex
                    end
                end
            end

            if texture then
                btn.itemIcon:SetTexture(texture)
                btn.itemIcon:Show()
                btn.availIcon:Hide()
                btn.noIcon:Hide()
            elseif slotHasItems[btn.slotId] then
                -- Rien d'équipé, mais le joueur possède au moins un objet
                -- de transmog compatible en sac : repère neutre (paperdoll).
                btn.itemIcon:Hide()
                btn.availIcon:Show()
                btn.noIcon:Hide()
            else
                -- Rien d'équipé ET aucun objet compatible en sac.
                btn.itemIcon:Hide()
                btn.availIcon:Hide()
                btn.noIcon:Show()
            end
        end
    end

    -- NOTE : ne PAS toucher au modèle 3D ici (ni SetUnit, ni caméra) : cette
    -- fonction ne fait que rafraîchir les icônes 2D des cases, et elle est
    -- appelée plusieurs fois de suite pour un même évènement (ouverture UI,
    -- réponse serveur GetSlotAvailability, réponse UpdateAppliedAppearances).
    -- Réinitialiser le modèle à chaque appel provoquait plusieurs
    -- rechargements asynchrones concurrents du modèle -> caméra désynchronisée
    -- de façon aléatoire. Le modèle est désormais rafraîchi UNIQUEMENT aux
    -- 3 points de sortie explicites : réouverture de la fenêtre, annulation
    -- d'un glisser/Tout réinitialiser (RefreshModelPreview), et après
    -- Appliquer/Tout réinitialiser confirmé serveur (ShowSuccess).
end

-- ============================================================
-- Disponibilité des objets de transmog par slot (handler serveur)
-- ============================================================
function TransmogHandlers.UpdateSlotAvailability(player, availability)
    slotHasItems = availability or {}
    TransmogHandlers.UpdateSlots()
end

-- ============================================================
-- Apparences de transmogrification actuellement appliquées (envoyées par
-- le serveur à l'ouverture de l'UI, après "Appliquer" ou réinitialisation)
-- -> permet d'afficher la BONNE icône (celle de la transmog, pas de l'item
-- physiquement équipé) dans chaque case après validation.
-- ============================================================
function TransmogHandlers.UpdateAppliedAppearances(player, appearances)
    appliedAppearances = appearances or {}
    TransmogHandlers.UpdateSlots()
end

-- ============================================================
-- Callbacks succès / erreur
-- ============================================================
function TransmogHandlers.ShowSuccess(player, message, icon)
    ShowTransmogToast(message, icon)

    local delayFrame = CreateFrame("Frame")
    local elapsed    = 0
    delayFrame:SetScript("OnUpdate", function(self, delta)
        elapsed = elapsed + delta
        if elapsed >= 0.3 then
            self:SetScript("OnUpdate", nil)
            AIO.Handle("Transmog", "GetSlotAvailability")
            TransmogHandlers.UpdateSlots()

            if TransmogFrame and TransmogFrame:IsShown() then
                -- Voir RecreateModel : on détruit/recrée le widget plutôt que
                -- de le réinitialiser (ClearModel/SetUnit), pour éviter le
                -- blocage interne qui finissait par nécessiter un déco/reco.
                RecreateModel()
            end
        end
    end)
end

function TransmogHandlers.ShowError(player, message)
    ShowTransmogToast(message or L.DEFAULT_ERROR_MSG, "Interface\\RaidFrame\\ReadyCheck-NotReady")
end

-- ============================================================
-- Ouvrir / Fermer l'interface
-- ============================================================
local function OuvrirFermerInterfaceTransmog()
    if TransmogFrame and TransmogFrame:IsShown() then
        TransmogFrame:Hide()
    else
        AIO.Handle("Transmog", "OpenUI")
    end
end
