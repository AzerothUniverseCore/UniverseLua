-- Mod_Me_PanelClient.lua
local AIO = AIO or require("AIO")
if AIO.AddAddon() then return end

local PanelHandlers = AIO.AddHandlers("ModMePanel", {})

local PanelFrame = nil
local isInitialized = false

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
    frame.title:SetText("Grimoire d'identité")

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

    -- ===================== Bloc Breloques (page gauche, bas — à la place de Compte) =====================
    local breloquesHeader, breloquesBorder = CreateSectionHeader(leftPage, "BRELOQUES")
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
    frame.dpLabel:SetText("|cFFFFD700Supérieures|r")

    -- Le nombre de points s'affiche desormais au survol de l'icone (tooltip) plutot
    -- que directement sur le livre.
    frame.dpValue = 0
    dpHolder:EnableMouse(true)
    dpHolder:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Breloques supérieures", 1, 0.82, 0)
        GameTooltip:AddLine("Monnaie obtenue en contribuant au serveur.", 1, 1, 1, true)
		GameTooltip:AddLine(" ")
        GameTooltip:AddLine("S'échange à la banque contre des Breloques supérieures à dépenser dans les zones cosmétiques ou la boutique du jeu.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Quantité actuel : |cFFFFD700"..tostring(frame.dpValue).."|r", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    dpHolder:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local vpHolder = CreateBreloqueSlot("Interface\\Icons\\VP", dpHolder, 0, -20)
    frame.vpLabel = vpHolder:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.vpLabel:SetPoint("LEFT", vpHolder, "RIGHT", 6, -6)
    frame.vpLabel:SetWidth(280)
    frame.vpLabel:SetWordWrap(true)
    frame.vpLabel:SetJustifyH("LEFT")
    frame.vpLabel:SetText("|cFFC0C0C0Inférieures|r")

    frame.vpValue = 0
    vpHolder:EnableMouse(true)
    vpHolder:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Breloques inférieures", 1, 0.82, 0)
        GameTooltip:AddLine("Monnaie obtenue en votant pour le serveur.", 1, 1, 1, true)
		GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Automatiquement convertie en Breloques supérieures à chaque connexion.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Quantité actuel : |cFFC0C0C0"..tostring(frame.vpValue).."|r", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    vpHolder:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- ===================== Bloc Compte (page droite, haut — à la place de Personnage) =====================
    local compteHeader, compteBorder = CreateSectionHeader(rightPage, "COMPTE")
    compteHeader:SetPoint("TOPLEFT", rightPage, "TOPLEFT", 55, -20)

    frame.accountIdLabel = rightPage:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.accountIdLabel:SetPoint("TOPLEFT", compteBorder, "BOTTOMLEFT", 14 * S, -14)
    frame.accountIdLabel:SetJustifyH("LEFT")
    frame.accountIdLabel:SetText("ID Compte: ")

    frame.accountNameLabel = rightPage:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.accountNameLabel:SetPoint("TOPLEFT", frame.accountIdLabel, "BOTTOMLEFT", 0, -8)
    frame.accountNameLabel:SetJustifyH("LEFT")
    frame.accountNameLabel:SetText("Nom du compte: ")

    -- ===================== Bloc Personnage (page droite, bas — à la place de Breloques) =====================
    local personnageHeader, personnageBorder = CreateSectionHeader(rightPage, "PERSONNAGE")
    personnageHeader:SetPoint("TOP", frame.accountNameLabel, "BOTTOM", -20, -34)

    frame.charIdLabel = rightPage:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.charIdLabel:SetPoint("TOPLEFT", personnageBorder, "BOTTOMLEFT", 14 * S, -14)
    frame.charIdLabel:SetJustifyH("LEFT")
    frame.charIdLabel:SetText("ID Personnage: ")

    frame.charNameLabel = rightPage:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.charNameLabel:SetPoint("TOPLEFT", frame.charIdLabel, "BOTTOMLEFT", 0, -8)
    frame.charNameLabel:SetJustifyH("LEFT")
    frame.charNameLabel:SetText("Nom: ")

    -- ===================== Bouton Actualiser (remonté pour rester sur le livre) =====================
    local refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refreshButton:SetSize(150, 28)
    refreshButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
    refreshButton:SetFrameLevel(metalBorder:GetFrameLevel() + 1)
    refreshButton:SetText("Actualiser")
    refreshButton:SetScript("OnClick", function()
        AIO.Handle("ModMePanel", "RequestPanelData")
    end)

    PanelFrame = frame

	tinsert(UISpecialFrames, "ModMePanelFrame")

    return frame
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
        AIO.Handle("ModMePanel", "RequestPanelData")
    end
end

-- Handler pour mettre à jour les données
function PanelHandlers.UpdatePanelData(player, data)
    local frame = CreatePanelUI()

    if data then
        frame.accountIdLabel:SetText("|cFFFFFFFFID Compte:|r |cFF00FF00"..data.accountId.."|r")
        frame.accountNameLabel:SetText("|cFFFFFFFFNom du compte:|r |cFF00FF00"..data.accountName.."|r")
        frame.charIdLabel:SetText("|cFFFFFFFFID Personnage:|r |cFF00FF00"..data.charId.."|r")
        frame.charNameLabel:SetText("|cFFFFFFFFNom:|r |cFF00FF00"..data.charName.."|r")
        frame.dpValue = data.dp
        frame.vpValue = data.vp
    end
end

-- Commande slash pour ouvrir le panel
SLASH_MODMEPANEL1 = "/panel"
SLASH_MODMEPANEL2 = "/modmepanel"
SlashCmdList["MODMEPANEL"] = function(msg)
    AIO.Handle("ModMePanel", "ShowPanel")
end


