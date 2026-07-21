-- Mod_Me_PanelClient.lua
local AIO = AIO or require("AIO")
if AIO.AddAddon() then return end

local PanelHandlers = AIO.AddHandlers("ModMePanel", {})

local PanelFrame = nil
local isInitialized = false

-- Table partagee (globale) entre Mod_Me_PanelClient.lua et Mod_Me_ConvertClient.lua :
-- permet aux onglets "Identite"/"Banque" de chaque livre d'ouvrir l'autre,
-- sans passer par un aller-retour serveur -- les deux fichiers tournent dans
-- le meme client, il suffit de s'exposer mutuellement une fonction
-- d'ouverture "forcee" (pas un toggle).
_G.ModMeUI = _G.ModMeUI or {}
local ModMeUI = _G.ModMeUI

-- ===================== Localisation (frFR / enUS) =====================
-- Detection de la langue du client via l'API native GetLocale() : ce meme
-- module tourne aussi bien sur un client frFR que enUS (developpement en
-- cours sur enUS), donc tous les textes d'interface passent par cette table
-- plutot que d'etre codes en dur en francais. Repli sur frFR pour toute
-- autre locale (comportement identique a avant pour un client non enUS).
local UI_LOCALE = (GetLocale and GetLocale() == "enUS") and "enUS" or "frFR"

local L = ({
    frFR = {
        TITLE = "Grimoire d'identité",
        BRELOQUES = "BRELOQUES",
        SUP_LABEL = "|cFFFFD700Supérieures|r",
        INF_LABEL = "|cFFC0C0C0Inférieures|r",
        DP_TITLE = "Breloques supérieures",
        DP_DESC1 = "Monnaie obtenue en contribuant au serveur.",
        DP_DESC2 = "S'échange à la banque contre des Breloques supérieures à dépenser dans les zones cosmétiques ou la boutique du jeu.",
        QUANTITE = "Quantité actuel : ",
        VP_TITLE = "Breloques inférieures",
        VP_DESC1 = "Monnaie obtenue en votant pour le serveur.",
        VP_DESC2 = "Automatiquement convertie en Breloques supérieures à chaque connexion.",
        COMPTE = "COMPTE",
        ID_COMPTE = "ID Compte:",
        NOM_COMPTE = "Nom du compte:",
        PERSONNAGE = "PERSONNAGE",
        ID_PERSONNAGE = "ID Personnage:",
        NOM = "Nom:",
        ACTUALISER = "Actualiser",
        IDENTITE = "Identité",
        BANQUE = "Banque",
        NIVEAU = "Niveau",
    },
    enUS = {
        TITLE = "Identity Grimoire",
        BRELOQUES = "CHARMS",
        SUP_LABEL = "|cFFFFD700Greater|r",
        INF_LABEL = "|cFFC0C0C0Lesser|r",
        DP_TITLE = "Greater Charms",
        DP_DESC1 = "Currency earned by contributing to the server.",
        DP_DESC2 = "Exchanged at the bank for Greater Charms to spend in cosmetic areas or the in-game shop.",
        QUANTITE = "Current amount: ",
        VP_TITLE = "Lesser Charms",
        VP_DESC1 = "Currency earned by voting for the server.",
        VP_DESC2 = "Automatically converted into Greater Charms on every login.",
        COMPTE = "ACCOUNT",
        ID_COMPTE = "Account ID:",
        NOM_COMPTE = "Account Name:",
        PERSONNAGE = "CHARACTER",
        ID_PERSONNAGE = "Character ID:",
        NOM = "Name:",
        ACTUALISER = "Refresh",
        IDENTITE = "Identity",
        BANQUE = "Bank",
        NIVEAU = "Level",
    },
})[UI_LOCALE]

-- Couleurs des onglets "Identite"/"Banque" : l'onglet du livre actuellement
-- ouvert reste "allume" (dore), l'autre est "eteint" (gris) tant qu'on ne
-- passe pas la souris dessus. La texture de surbrillance native du template
-- (UI-Character-Tab-RealHighlight) est desactivee au profit de ce simple
-- changement de couleur : elle s'affichait mal proportionnee (rectangle
-- bleu) sur ce client.
local TAB_COLOR_ACTIVE   = { 1, 0.82, 0 }
local TAB_COLOR_INACTIVE = { 0.6, 0.6, 0.6 }
local TAB_COLOR_HOVER    = { 1, 0.92, 0.6 }

local function SetupModMeTab(tab, isActive, onClickFn)
    local hl = tab:GetHighlightTexture()
    if hl then
        hl:SetTexture(nil)
    end

    -- Sur ce client, Button n'expose pas de methode SetTextColor : il faut
    -- passer par le FontString sous-jacent (toujours valide, quel que soit
    -- l'etat active/desactive du bouton, car Normal/Highlight/Disabled ne
    -- sont que des styles appliques a ce meme FontString).
    local fontString = tab:GetFontString()

    if isActive then
        PanelTemplates_SelectTab(tab)
        if fontString then
            fontString:SetTextColor(unpack(TAB_COLOR_ACTIVE))
        end
    else
        PanelTemplates_DeselectTab(tab)
        if fontString then
            fontString:SetTextColor(unpack(TAB_COLOR_INACTIVE))
        end
        tab:SetScript("OnEnter", function(self)
            local fs = self:GetFontString()
            if fs then fs:SetTextColor(unpack(TAB_COLOR_HOVER)) end
        end)
        tab:SetScript("OnLeave", function(self)
            local fs = self:GetFontString()
            if fs then fs:SetTextColor(unpack(TAB_COLOR_INACTIVE)) end
        end)
        tab:SetScript("OnClick", onClickFn)
    end
end

-- Fonction pour créer le panel UI
local function CreatePanelUI()
    if PanelFrame then
        return PanelFrame
    end

    -- Échelle du contenu du livre (proportions telles quelles depuis SpellBook.xml, PlayerSpellsFrame = 1100x650)
    local S = 0.65
    -- Échelle du cadre métallique extérieur (UITemplate2X.xml, MetalFrame2X)
    local SB = 0.75

    local bookW, bookH = 1100 * S, 650 * S

    -- ===================== Frame principale (= zone de contenu, le cadre métal déborde autour) =====================
    local frame = CreateFrame("Frame", "ModMePanelFrame", UIParent)
    frame:SetSize(bookW, bookH)
    frame:SetPoint("CENTER", 0, 10)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()

    -- ===================== Livre (structure exacte de SpellBookFrameTemplate, texture réelle) =====================
    local book = CreateFrame("Frame", nil, frame)
    book:SetAllPoints(frame)

    -- Barre du haut (reliure en bois)
    local topBar = book:CreateTexture(nil, "BACKGROUND")
    topBar:SetTexture("Interface\\SpellBook\\SpellbookBackgroundEvergreenPanel")
    topBar:SetSize(bookW, 54 * S)
    topBar:SetPoint("TOPLEFT", book, "TOPLEFT", 0, 0)
    topBar:SetTexCoord(0.000488281, 0.788574, 0.000976562, 0.0576172)

    -- Page de gauche (fond)
    local bookBGLeft = book:CreateTexture(nil, "BACKGROUND")
    bookBGLeft:SetTexture("Interface\\SpellBook\\SpellbookBackgroundEvergreenPanel")
    bookBGLeft:SetPoint("TOPLEFT", book, "TOPLEFT", 0, -51 * S)
    bookBGLeft:SetPoint("BOTTOMRIGHT", book, "BOTTOM", 0, 0)
    bookBGLeft:SetTexCoord(0.446289, 0.839844, 0.0595703, 0.845703)

    -- Page de droite (fond)
    local bookBGRight = book:CreateTexture(nil, "BACKGROUND")
    bookBGRight:SetTexture("Interface\\SpellBook\\SpellbookBackgroundEvergreenPanel")
    bookBGRight:SetPoint("TOPLEFT", book, "TOP", 0, -51 * S)
    bookBGRight:SetPoint("BOTTOMRIGHT", book, "BOTTOMRIGHT", 0, 0)
    bookBGRight:SetTexCoord(0.000488281, 0.394531, 0.0595703, 0.845703)

    -- Ruban marque-page central
    local bookmark = book:CreateTexture(nil, "OVERLAY")
    bookmark:SetTexture("Interface\\SpellBook\\SpellbookBackgroundEvergreenPanel")
    bookmark:SetSize(102 * S, 557 * S)
    bookmark:SetPoint("TOPRIGHT", bookBGLeft, "TOPRIGHT", 62 * S, 4 * S)
    bookmark:SetTexCoord(0.395508, 0.445312, 0.0595703, 0.603516)

    -- Pages de contenu (zones de texte), mêmes proportions que PageView1/PageView2
    local leftPage = CreateFrame("Frame", nil, book)
    leftPage:SetSize(520 * S, 540 * S)
    leftPage:SetPoint("TOPLEFT", book, "TOPLEFT", 60 * S, -80 * S)

    local rightPage = CreateFrame("Frame", nil, book)
    rightPage:SetSize(520 * S, 540 * S)
    rightPage:SetPoint("TOPRIGHT", book, "TOPRIGHT", -30 * S, -80 * S)

    -- ===================== Cadre métallique extérieur (MetalFrame2X) =====================
    local metalBorder = CreateFrame("Frame", nil, frame)
    metalBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -15 * SB, 30 * SB)
    metalBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5 * SB, -5 * SB)
    metalBorder:SetFrameLevel(frame:GetFrameLevel() + 10)

    local cornerTL = metalBorder:CreateTexture(nil, "OVERLAY")
    cornerTL:SetTexture("Interface\\FrameGeneral\\uiframemetal2xPanel")
    cornerTL:SetSize(75 * SB, 75 * SB)
    cornerTL:SetPoint("TOPLEFT", metalBorder, "TOPLEFT", 0, 0)
    cornerTL:SetTexCoord(0.00195312, 0.294922, 0.298828, 0.591797)

    local cornerTR = metalBorder:CreateTexture(nil, "OVERLAY")
    cornerTR:SetTexture("Interface\\FrameGeneral\\uiframemetal2xPanel")
    cornerTR:SetSize(75 * SB, 75 * SB)
    cornerTR:SetPoint("TOPRIGHT", metalBorder, "TOPRIGHT", 0, 0)
    cornerTR:SetTexCoord(0.298828, 0.591797, 0.00195312, 0.294922)

    local cornerBL = metalBorder:CreateTexture(nil, "OVERLAY")
    cornerBL:SetTexture("Interface\\FrameGeneral\\uiframemetal2xPanel")
    cornerBL:SetSize(32 * SB, 32 * SB)
    cornerBL:SetPoint("BOTTOMLEFT", metalBorder, "BOTTOMLEFT", 0, 0)
    cornerBL:SetTexCoord(0.298828, 0.423828, 0.298828, 0.423828)

    local cornerBR = metalBorder:CreateTexture(nil, "OVERLAY")
    cornerBR:SetTexture("Interface\\FrameGeneral\\uiframemetal2xPanel")
    cornerBR:SetSize(32 * SB, 32 * SB)
    cornerBR:SetPoint("BOTTOMRIGHT", metalBorder, "BOTTOMRIGHT", 0, 0)
    cornerBR:SetTexCoord(0.427734, 0.552734, 0.298828, 0.423828)

    local borderTop = metalBorder:CreateTexture(nil, "OVERLAY")
    borderTop:SetTexture("Interface\\FrameGeneral\\uiframemetalhorizontal2xPanel")
    borderTop:SetHeight(75 * SB)
    borderTop:SetPoint("TOPLEFT", cornerTL, "TOPRIGHT", 0, 0)
    borderTop:SetPoint("TOPRIGHT", cornerTR, "TOPLEFT", 0, 0)
    borderTop:SetTexCoord(0, 0.5, 0.00390625, 0.589844)
    borderTop:SetHorizTile(true)

    local borderLeft = metalBorder:CreateTexture(nil, "OVERLAY")
    borderLeft:SetTexture("Interface\\FrameGeneral\\uiframemetalvertical2xPanel")
    borderLeft:SetWidth(75 * SB)
    borderLeft:SetPoint("TOPLEFT", cornerTL, "BOTTOMLEFT", 0, 0)
    borderLeft:SetPoint("BOTTOMLEFT", cornerBL, "TOPLEFT", 0, 0)
    borderLeft:SetTexCoord(0.00195312, 0.294922, 0, 1)
    borderLeft:SetVertTile(true)

    local borderRight = metalBorder:CreateTexture(nil, "OVERLAY")
    borderRight:SetTexture("Interface\\FrameGeneral\\uiframemetalvertical2xPanel")
    borderRight:SetWidth(75 * SB)
    borderRight:SetPoint("TOPRIGHT", cornerTR, "BOTTOMRIGHT", 0, 0)
    borderRight:SetPoint("BOTTOMRIGHT", cornerBR, "TOPRIGHT", 0, 0)
    borderRight:SetTexCoord(0.298828, 0.591797, 0, 1)
    borderRight:SetVertTile(true)

    local borderBottom = metalBorder:CreateTexture(nil, "OVERLAY")
    borderBottom:SetTexture("Interface\\FrameGeneral\\uiframemetalhorizontal2xPanel")
    borderBottom:SetHeight(32 * SB)
    borderBottom:SetPoint("BOTTOMLEFT", cornerBL, "BOTTOMRIGHT", 0, 0)
    borderBottom:SetPoint("BOTTOMRIGHT", cornerBR, "BOTTOMLEFT", 0, 0)
    borderBottom:SetTexCoord(0, 1, 0.597656, 0.847656)
    borderBottom:SetHorizTile(true)

    -- ===================== Titre (posé sur la barre en bois, plus d'encadré Blizzlike WotLK) =====================
    frame.title = metalBorder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOP", metalBorder, "TOP", 0, -17 * SB)
    frame.title:SetText(L.TITLE)

    -- Icône ronde en haut à gauche (socle prévu par le cadre métallique) : icône de classe du joueur,
    -- avec repli sûr si la classe custom n'a pas d'entrée dans CLASS_ICON_TCOORDS
    local classIconFrame = CreateFrame("Frame", nil, metalBorder)
    classIconFrame:SetSize(64 * SB, 64 * SB)
    classIconFrame:SetPoint("CENTER", cornerTL, "CENTER", 3 * SB, -2 * SB)

    local classIcon = classIconFrame:CreateTexture(nil, "ARTWORK")
    classIcon:SetAllPoints(classIconFrame)

    local _, classToken = UnitClass("player")
    local classCoords = classToken and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classToken]
    if classCoords then
        classIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        classIcon:SetTexCoord(classCoords[1], classCoords[2], classCoords[3], classCoords[4])
    else
        classIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        classIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    -- Bouton fermer (croix rouge du cadre métallique)
    local xButton = CreateFrame("Button", nil, metalBorder)
    xButton:SetSize(24 * SB, 24 * SB)
    xButton:SetPoint("TOPRIGHT", metalBorder, "TOPRIGHT", -4 * SB, -17 * SB)
    xButton:SetNormalTexture("Interface\\Buttons\\redbutton2xPanel")
    xButton:GetNormalTexture():SetTexCoord(0.152344, 0.292969, 0.0078125, 0.304688)
    xButton:SetPushedTexture("Interface\\Buttons\\redbutton2xPanel")
    xButton:GetPushedTexture():SetTexCoord(0.152344, 0.292969, 0.632812, 0.929688)
    xButton:SetHighlightTexture("Interface\\Buttons\\redbutton2xPanel", "ADD")
    xButton:GetHighlightTexture():SetTexCoord(0.449219, 0.589844, 0.0078125, 0.304688)
    xButton:SetScript("OnClick", function() frame:Hide() end)

    -- ===================== En-tête de section (reprend SpellBookHeaderTemplate) =====================
    local function CreateSectionHeader(parent, text)
        local h = CreateFrame("Frame", nil, parent)
        h:SetSize(250 * S, 51 * S)

        local backplate = h:CreateTexture(nil, "BACKGROUND")
        backplate:SetTexture("Interface\\SpellBook\\SpellbookElementsPanel")
        backplate:SetSize(416 * S, 106 * S)
        backplate:SetPoint("LEFT", h, "LEFT", -85 * S, 10 * S)
        backplate:SetAlpha(0.65)
        backplate:SetTexCoord(0.000976562, 0.30957, 0.305664, 0.40918)

        local fs = h:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        fs:SetPoint("TOPLEFT", h, "TOPLEFT", -8 * S, 0)
        fs:SetPoint("TOPRIGHT", h, "TOPRIGHT", -60 * S, 0)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)

        local border = h:CreateTexture(nil, "ARTWORK")
        border:SetTexture("Interface\\SpellBook\\SpellbookElementsPanel")
        border:SetHeight(11 * S)
        border:SetPoint("BOTTOMLEFT", h, "BOTTOMLEFT", -32 * S, 15 * S)
        border:SetPoint("BOTTOMRIGHT", h, "BOTTOMRIGHT", -100 * S, 15 * S)
        border:SetTexCoord(0.24707, 0.888672, 0.411133, 0.421875)

        return h, border
    end

    -- ===================== Portrait du personnage (page gauche, haut) =====================
    local portraitFrame = CreateFrame("Frame", nil, leftPage)
    portraitFrame:SetSize(72, 72)
    portraitFrame:SetPoint("TOP", leftPage, "TOP", -10, 0)

    -- Portrait tete/epaules via la fonction native du client (utilisee partout ailleurs
    -- dans ce client pour les portraits : CharacterFrame, PaperDollFrame, DressUpFrame,
    -- boutons micro...). Fonctionne pour n'importe quelle race sans donnees de camera a
    -- part, et sans les soucis de chargement asynchrone d'un PlayerModel manuel.
    frame.portraitTexture = portraitFrame:CreateTexture(nil, "ARTWORK")
    frame.portraitTexture:SetAllPoints(portraitFrame)
    SetPortraitTexture(frame.portraitTexture, "player")

    -- Cadre ornemental (même pièce d'atlas que le cadre "passif" des sorts, agrandie)
    local portraitBorder = portraitFrame:CreateTexture(nil, "OVERLAY")
    portraitBorder:SetTexture("Interface\\SpellBook\\SpellbookElementsPanel")
    portraitBorder:SetSize(72 * (46 / 32), 72 * (44.5 / 32))
    portraitBorder:SetPoint("CENTER", portraitFrame, "CENTER", -72 * (3.3 / 32), -72 * (2 / 32))
    portraitBorder:SetTexCoord(0.000976562, 0.133789, 0.411133, 0.535156)

    -- Tooltip au survol du portrait : nom (colore par classe), niveau/race/
    -- classe, et guilde si le personnage en a une.
    portraitFrame:EnableMouse(true)
    -- Traduction fr : le nom de la race est fourni par le serveur
    -- (frame.raceName), lu directement dans `auc_spell`.`chrraces` (colonne
    -- Name3 = frFR, meme convention que chrclasses pour les classes). On ne
    -- retombe sur UnitRace() que si la donnee serveur n'est pas encore
    -- arrivee.

    portraitFrame:SetScript("OnEnter", function(self)
        local name = UnitName("player")
        local level = UnitLevel("player")
        local _, classToken = UnitClass("player")
        local classDisplayName = UnitClass("player")
        local raceLocalized = UnitRace("player")
        local raceDisplayName = frame.raceName or raceLocalized
        local classColor = (RAID_CLASS_COLORS and classToken and RAID_CLASS_COLORS[classToken]) or { r = 1, g = 1, b = 1 }

        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(name, classColor.r, classColor.g, classColor.b)
        GameTooltip:AddLine(L.NIVEAU .. " " .. tostring(level) .. " " .. tostring(raceDisplayName) .. " " .. tostring(classDisplayName), 1, 1, 1)

        local guildName = GetGuildInfo("player")
        if guildName then
            GameTooltip:AddLine("<" .. guildName .. ">", 0, 1, 0)
        end

        GameTooltip:Show()
    end)
    portraitFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- ===================== Bloc Breloques (page gauche, bas — à la place de Compte) =====================
    local breloquesHeader, breloquesBorder = CreateSectionHeader(leftPage, L.BRELOQUES)
    breloquesHeader:SetPoint("TOP", portraitFrame, "BOTTOM", -60, -30)

    -- Slot d'icône avec le cadre "actif" de l'atlas des sorts (même proportion que dans SpellBookItemTemplate)
    local function CreateBreloqueSlot(iconPath, anchorTo, offsetX, offsetY)
        local holder = CreateFrame("Frame", nil, leftPage)
        holder:SetSize(32, 32)
        holder:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", offsetX, offsetY)

        local icon = holder:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(holder)
        icon:SetTexture(iconPath)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        local activeBorder = holder:CreateTexture(nil, "OVERLAY")
        activeBorder:SetTexture("Interface\\SpellBook\\SpellbookElementsPanel")
        activeBorder:SetSize(32 * (46 / 32), 32 * (44.5 / 32))
        activeBorder:SetPoint("CENTER", holder, "CENTER", -32 * (3.3 / 32), -32 * (2 / 32))
        activeBorder:SetTexCoord(0.854492, 0.989258, 0.000976562, 0.128906)

        return holder
    end

    local dpHolder = CreateBreloqueSlot("Interface\\Icons\\DP", breloquesBorder, 32 * S - 4, -20)
    -- Le label est créé sur dpHolder lui-même (pas leftPage) pour dessiner APRES activeBorder
    -- dans la même pile de calques : sinon le frame enfant dpHolder passe toujours au-dessus
    -- des éléments propres de leftPage, quel que soit le décalage demandé (texte caché sous l'icône).
    frame.dpLabel = dpHolder:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.dpLabel:SetPoint("LEFT", dpHolder, "RIGHT", 6, -6)
    frame.dpLabel:SetWidth(280)
    frame.dpLabel:SetWordWrap(true)
    frame.dpLabel:SetJustifyH("LEFT")
    frame.dpLabel:SetText(L.SUP_LABEL)

    -- Le nombre de points s'affiche desormais au survol de l'icone (tooltip) plutot
    -- que directement sur le livre.
    frame.dpValue = 0
    dpHolder:EnableMouse(true)
    dpHolder:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.DP_TITLE, 1, 0.82, 0)
        GameTooltip:AddLine(L.DP_DESC1, 1, 1, 1, true)
		GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L.DP_DESC2, 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L.QUANTITE.."|cFFFFD700"..tostring(frame.dpValue).."|r", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    dpHolder:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local vpHolder = CreateBreloqueSlot("Interface\\Icons\\VP", dpHolder, 0, -20)
    frame.vpLabel = vpHolder:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.vpLabel:SetPoint("LEFT", vpHolder, "RIGHT", 6, -6)
    frame.vpLabel:SetWidth(280)
    frame.vpLabel:SetWordWrap(true)
    frame.vpLabel:SetJustifyH("LEFT")
    frame.vpLabel:SetText(L.INF_LABEL)

    frame.vpValue = 0
    vpHolder:EnableMouse(true)
    vpHolder:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.VP_TITLE, 1, 0.82, 0)
        GameTooltip:AddLine(L.VP_DESC1, 1, 1, 1, true)
		GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L.VP_DESC2, 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L.QUANTITE.."|cFFC0C0C0"..tostring(frame.vpValue).."|r", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    vpHolder:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- ===================== Bloc Compte (page droite, haut — à la place de Personnage) =====================
    local compteHeader, compteBorder = CreateSectionHeader(rightPage, L.COMPTE)
    compteHeader:SetPoint("TOPLEFT", rightPage, "TOPLEFT", 55, -20)

    frame.accountIdLabel = rightPage:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.accountIdLabel:SetPoint("TOPLEFT", compteBorder, "BOTTOMLEFT", 14 * S, -14)
    frame.accountIdLabel:SetJustifyH("LEFT")
    frame.accountIdLabel:SetText(L.ID_COMPTE.." ")

    frame.accountNameLabel = rightPage:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.accountNameLabel:SetPoint("TOPLEFT", frame.accountIdLabel, "BOTTOMLEFT", 0, -8)
    frame.accountNameLabel:SetJustifyH("LEFT")
    frame.accountNameLabel:SetText(L.NOM_COMPTE.." ")

    -- ===================== Bloc Personnage (page droite, bas — à la place de Breloques) =====================
    local personnageHeader, personnageBorder = CreateSectionHeader(rightPage, L.PERSONNAGE)
    personnageHeader:SetPoint("TOP", frame.accountNameLabel, "BOTTOM", -20, -34)

    frame.charIdLabel = rightPage:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.charIdLabel:SetPoint("TOPLEFT", personnageBorder, "BOTTOMLEFT", 14 * S, -14)
    frame.charIdLabel:SetJustifyH("LEFT")
    frame.charIdLabel:SetText(L.ID_PERSONNAGE.." ")

    frame.charNameLabel = rightPage:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.charNameLabel:SetPoint("TOPLEFT", frame.charIdLabel, "BOTTOMLEFT", 0, -8)
    frame.charNameLabel:SetJustifyH("LEFT")
    frame.charNameLabel:SetText(L.NOM.." ")

    -- ===================== Bouton Actualiser =====================
    local refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refreshButton:SetSize(150, 28)
    refreshButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
    refreshButton:SetFrameLevel(metalBorder:GetFrameLevel() + 1)
    refreshButton:SetText(L.ACTUALISER)
    refreshButton:SetScript("OnClick", function()
        AIO.Handle("ModMePanel", "RequestPanelData", UI_LOCALE)
    end)

    -- ===================== Onglets "Identité" / "Banque" côte à côte =====================
    -- Même habillage que les onglets Montures/Familiers/.../Transmogrification
    -- du Journal de Collection (CharacterFrameTabButtonTemplate). Ce livre EST
    -- le Grimoire d'identité : son onglet "Identité" reste affiché "allumé"
    -- (dore, non cliquable) ; l'onglet "Banque" est "éteint" (gris) et ferme
    -- ce livre pour ouvrir le Grimoire de Conversion.
    local identityTab = CreateFrame("Button", "ModMePanelIdentityTab", metalBorder, "CharacterFrameTabButtonTemplate")
    identityTab:SetPoint("TOPLEFT", metalBorder, "BOTTOMLEFT", 11, 4)
    identityTab:SetText(L.IDENTITE)

    local bankTab = CreateFrame("Button", "ModMePanelBankTab", metalBorder, "CharacterFrameTabButtonTemplate")
    bankTab:SetPoint("LEFT", identityTab, "RIGHT", -16, 0)
    bankTab:SetText(L.BANQUE)

    SetupModMeTab(identityTab, true, nil)
    SetupModMeTab(bankTab, false, function()
        frame:Hide()
        if ModMeUI.ShowConvert then
            ModMeUI.ShowConvert()
        end
    end)

    PanelFrame = frame

	tinsert(UISpecialFrames, "ModMePanelFrame")

    return frame
end

-- Point d'entrée "affichage forcé" (jamais un toggle), exposé immédiatement
-- au chargement du fichier (pas seulement après un premier CreatePanelUI())
-- pour que l'onglet "Identité" du Grimoire de Conversion puisse toujours
-- ouvrir ce livre, même si ce dernier n'a encore jamais été affiché --
-- notamment maintenant que le PNJ 2000040 n'est plus le point d'entrée
-- obligatoire des deux systèmes.
ModMeUI.ShowPanel = function()
    local f = CreatePanelUI()
    f:Show()
    if f.portraitTexture then
        SetPortraitTexture(f.portraitTexture, "player")
    end
    AIO.Handle("ModMePanel", "RequestPanelData", UI_LOCALE)
end

-- Handler pour initialiser le système
function PanelHandlers.Initialize()
    if not isInitialized then
        isInitialized = true
        -- print("|cFF00FF00Mod Me Panel|r chargé. Tapez |cFFFFFF00/panel|r pour ouvrir le panneau.")
    end
end

-- Handler pour afficher le panel
function PanelHandlers.ShowPanel()
    local frame = CreatePanelUI()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        if frame.portraitTexture then
            SetPortraitTexture(frame.portraitTexture, "player")
        end
        AIO.Handle("ModMePanel", "RequestPanelData", UI_LOCALE)
    end
end

-- Handler pour mettre à jour les données
function PanelHandlers.UpdatePanelData(player, data)
    local frame = CreatePanelUI()

    if data then
        frame.accountIdLabel:SetText("|cFFFFFFFF"..L.ID_COMPTE.."|r |cFF00FF00"..data.accountId.."|r")
        frame.accountNameLabel:SetText("|cFFFFFFFF"..L.NOM_COMPTE.."|r |cFF00FF00"..data.accountName.."|r")
        frame.charIdLabel:SetText("|cFFFFFFFF"..L.ID_PERSONNAGE.."|r |cFF00FF00"..data.charId.."|r")
        frame.charNameLabel:SetText("|cFFFFFFFF"..L.NOM.."|r |cFF00FF00"..data.charName.."|r")
        frame.dpValue = data.dp
        frame.vpValue = data.vp
        frame.raceName = data.raceName
    end
end

-- Commande slash pour ouvrir le panel
SLASH_MODMEPANEL1 = "/panel"
SLASH_MODMEPANEL2 = "/modmepanel"
SlashCmdList["MODMEPANEL"] = function(msg)
    AIO.Handle("ModMePanel", "ShowPanel")
end


