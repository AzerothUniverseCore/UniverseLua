-- Mod_Me_ConvertClient.lua
-- UI de conversion des Breloques Supérieures du site (auc_website.users.dp) en
-- Breloques Supérieures du jeu (item 7000655), quantité choisie par le joueur.
-- Reprend exactement le même habillage livre/parchemin/cadre métal que
-- Mod_Me_PanelClient.lua (Grimoire d'identité) pour rester cohérent visuellement.
local AIO = AIO or require("AIO")
if AIO.AddAddon() then return end

local ConvertHandlers = AIO.AddHandlers("ModMeConvert", {})

local CONVERT_ITEM_ID = 7000655

local ConvertFrame = nil

local function CreateConvertUI()
    if ConvertFrame then
        return ConvertFrame
    end

    -- Échelle du contenu du livre (mêmes proportions que le Grimoire d'identité)
    local S = 0.65
    local SB = 0.75

    local bookW, bookH = 1100 * S, 650 * S

    -- ===================== Frame principale =====================
    local frame = CreateFrame("Frame", "ModMeConvertFrame", UIParent)
    frame:SetSize(bookW, bookH)
    frame:SetPoint("CENTER", 0, 10)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()

    -- ===================== Livre =====================
    local book = CreateFrame("Frame", nil, frame)
    book:SetAllPoints(frame)

    local topBar = book:CreateTexture(nil, "BACKGROUND")
    topBar:SetTexture("Interface\\SpellBook\\SpellbookBackgroundEvergreenPanel")
    topBar:SetSize(bookW, 54 * S)
    topBar:SetPoint("TOPLEFT", book, "TOPLEFT", 0, 0)
    topBar:SetTexCoord(0.000488281, 0.788574, 0.000976562, 0.0576172)

    local bookBGLeft = book:CreateTexture(nil, "BACKGROUND")
    bookBGLeft:SetTexture("Interface\\SpellBook\\SpellbookBackgroundEvergreenPanel")
    bookBGLeft:SetPoint("TOPLEFT", book, "TOPLEFT", 0, -51 * S)
    bookBGLeft:SetPoint("BOTTOMRIGHT", book, "BOTTOM", 0, 0)
    bookBGLeft:SetTexCoord(0.446289, 0.839844, 0.0595703, 0.845703)

    local bookBGRight = book:CreateTexture(nil, "BACKGROUND")
    bookBGRight:SetTexture("Interface\\SpellBook\\SpellbookBackgroundEvergreenPanel")
    bookBGRight:SetPoint("TOPLEFT", book, "TOP", 0, -51 * S)
    bookBGRight:SetPoint("BOTTOMRIGHT", book, "BOTTOMRIGHT", 0, 0)
    bookBGRight:SetTexCoord(0.000488281, 0.394531, 0.0595703, 0.845703)

    local bookmark = book:CreateTexture(nil, "OVERLAY")
    bookmark:SetTexture("Interface\\SpellBook\\SpellbookBackgroundEvergreenPanel")
    bookmark:SetSize(102 * S, 557 * S)
    bookmark:SetPoint("TOPRIGHT", bookBGLeft, "TOPRIGHT", 62 * S, 4 * S)
    bookmark:SetTexCoord(0.395508, 0.445312, 0.0595703, 0.603516)

    local leftPage = CreateFrame("Frame", nil, book)
    leftPage:SetSize(520 * S, 540 * S)
    leftPage:SetPoint("TOPLEFT", book, "TOPLEFT", 60 * S, -80 * S)

    local rightPage = CreateFrame("Frame", nil, book)
    rightPage:SetSize(520 * S, 540 * S)
    rightPage:SetPoint("TOPRIGHT", book, "TOPRIGHT", -30 * S, -80 * S)

    -- ===================== Cadre métallique extérieur =====================
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

    -- ===================== Titre =====================
    frame.title = metalBorder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOP", metalBorder, "TOP", 0, -17 * SB)
    frame.title:SetText("Grimoire de Conversion")

    -- Icône ronde en haut à gauche : icône de classe du joueur (même socle que le Grimoire d'identité)
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

    -- Bouton fermer
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

    -- ===================== En-tête de section =====================
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

    -- Emplacement d'icône avec le cadre "actif" de l'atlas des sorts (même rendu que les
    -- slots Breloques du Grimoire d'identité)
    local function CreateIconSlot(parent, size)
        local holder = CreateFrame("Frame", nil, parent)
        holder:SetSize(size, size)

        local icon = holder:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(holder)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        local activeBorder = holder:CreateTexture(nil, "OVERLAY")
        activeBorder:SetTexture("Interface\\SpellBook\\SpellbookElementsPanel")
        activeBorder:SetSize(size * (46 / 32), size * (44.5 / 32))
        activeBorder:SetPoint("CENTER", holder, "CENTER", -size * (3.3 / 32), -size * (2 / 32))
        activeBorder:SetTexCoord(0.854492, 0.989258, 0.000976562, 0.128906)

        return holder, icon
    end

    -- ===================== Page gauche : solde du site =====================
    local siteHeader, siteBorder = CreateSectionHeader(leftPage, "BRELOQUES DU SITE")
    siteHeader:SetPoint("TOP", leftPage, "TOP", -60, -20)

    local siteIconHolder, siteIcon = CreateIconSlot(leftPage, 48)
    siteIconHolder:SetPoint("TOP", leftPage, "TOP", -35, -95)
    siteIcon:SetTexture("Interface\\Icons\\DP")

    frame.siteValue = 0

    siteIconHolder:EnableMouse(true)
    siteIconHolder:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Breloques Supérieures (site)", 1, 0.82, 0)
        GameTooltip:AddLine("Monnaie obtenue en contribuant au serveur.", 1, 1, 1, true)
        GameTooltip:AddLine("Convertissez-la ici en Breloque Supérieure utilisable en jeu.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Quantité actuel : |cFFFFD700"..tostring(frame.siteValue).."|r", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    siteIconHolder:SetScript("OnLeave", function() GameTooltip:Hide() end)

    frame.siteBalanceLabel = leftPage:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.siteBalanceLabel:SetPoint("TOP", siteIconHolder, "BOTTOM", 0, -16)
    frame.siteBalanceLabel:SetText("|cFFFFD7000|r")

    local siteSubLabel = leftPage:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    siteSubLabel:SetPoint("TOP", frame.siteBalanceLabel, "BOTTOM", 0, -6)
    siteSubLabel:SetText("Breloques Supérieures (site)")

    -- ===================== Page droite : conversion vers l'objet du jeu =====================
    local gameHeader, gameBorder = CreateSectionHeader(rightPage, "BRELOQUES DU JEU")
    gameHeader:SetPoint("TOP", rightPage, "TOP", -20, -20)

    local gameIconHolder, gameIcon = CreateIconSlot(rightPage, 48)
    gameIconHolder:SetPoint("TOP", rightPage, "TOP", 18, -95)
    do
        local iconPath = GetItemIcon(CONVERT_ITEM_ID)
        gameIcon:SetTexture(iconPath or "Interface\\Icons\\INV_Misc_QuestionMark")
    end

    gameIconHolder:EnableMouse(true)
    gameIconHolder:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Breloque Supérieure (jeu)", 1, 0.82, 0)
        GameTooltip:AddLine("Monnaie obtenu en convertissant vos Breloques Supérieures (site).", 1, 1, 1, true)
        GameTooltip:AddLine("Utilisable dans les zones cosmétiques ou la boutique du jeu.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    gameIconHolder:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local gameSubLabel = rightPage:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    gameSubLabel:SetPoint("TOP", gameIconHolder, "BOTTOM", 0, -15)
    gameSubLabel:SetText("Breloques Supérieures (jeu)")

    -- Champ de saisie de la quantité
    local amountLabel = rightPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    amountLabel:SetPoint("TOP", gameSubLabel, "BOTTOM", 0, -14)
    amountLabel:SetText("Quantité à convertir :")

    frame.amountBox = CreateFrame("EditBox", nil, rightPage, "InputBoxTemplate")
    frame.amountBox:SetSize(120, 24)
    frame.amountBox:SetAutoFocus(false)
    frame.amountBox:SetNumeric(true)
    frame.amountBox:SetMaxLetters(9)
    frame.amountBox:SetPoint("TOP", amountLabel, "BOTTOM", 0, -8)
    frame.amountBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Bouton Convertir
    local convertButton = CreateFrame("Button", nil, rightPage, "UIPanelButtonTemplate")
    convertButton:SetSize(140, 26)
    convertButton:SetPoint("TOP", frame.amountBox, "BOTTOM", 0, -14)
    convertButton:SetText("Convertir")

    -- Message de statut (résultat de la dernière tentative de conversion)
    frame.statusText = rightPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.statusText:SetPoint("TOP", convertButton, "BOTTOM", 0, -12)
    frame.statusText:SetWidth(320)
    frame.statusText:SetWordWrap(true)
    frame.statusText:SetText("")

    -- Filet de sécurité anti-blocage : si aucune réponse serveur (ConvertResult)
    -- n'arrive dans les 8 secondes suivant une demande, on débloque l'UI plutôt
    -- que de rester figé sur "Conversion en cours...".
    frame.timeoutFrame = CreateFrame("Frame")
    frame.timeoutFrame:Hide()
    frame.timeoutFrame.elapsed = 0
    frame.timeoutFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed > 8 then
            self:Hide()
            frame.statusText:SetText("|cFFFF0000Aucune réponse du serveur. Réessayez.|r")
        end
    end)

    local function AttemptConvert()
        local amount = tonumber(frame.amountBox:GetText())
        if not amount or amount <= 0 then
            frame.statusText:SetText("|cFFFF0000Entrez une quantité valide.|r")
            return
        end
        if amount > (frame.siteValue or 0) then
            frame.statusText:SetText("|cFFFF0000Solde insuffisant. Vous possédez "..tostring(frame.siteValue or 0).." Breloque(s) Supérieure(s) du site.|r")
            return
        end
        frame.amountBox:ClearFocus()
        frame.statusText:SetText("|cFFFFD700Conversion en cours...|r")
        frame.timeoutFrame.elapsed = 0
        frame.timeoutFrame:Show()
        AIO.Handle("ModMeConvert", "RequestConvert", amount)
    end

    convertButton:SetScript("OnClick", AttemptConvert)
    frame.amountBox:SetScript("OnEnterPressed", AttemptConvert)

    -- ===================== Bouton Actualiser =====================
    local refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refreshButton:SetSize(150, 28)
    refreshButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
    refreshButton:SetFrameLevel(metalBorder:GetFrameLevel() + 1)
    refreshButton:SetText("Actualiser")
    refreshButton:SetScript("OnClick", function()
        AIO.Handle("ModMeConvert", "RequestConvertData")
    end)

    ConvertFrame = frame

    tinsert(UISpecialFrames, "ModMeConvertFrame")

    return frame
end

-- Handler pour afficher l'UI (déclenché par le PNJ 2000040 ou la commande /convert)
function ConvertHandlers.ShowConvertUI()
    local frame = CreateConvertUI()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        frame.statusText:SetText("")
        AIO.Handle("ModMeConvert", "RequestConvertData")
    end
end

-- Handler pour mettre à jour le solde affiché (site)
function ConvertHandlers.UpdateConvertData(player, data)
    local frame = CreateConvertUI()
    if data then
        frame.siteValue = data.dp
        frame.siteBalanceLabel:SetText("|cFFFFD700"..tostring(data.dp).."|r")
    end
end

-- Handler pour afficher le résultat d'une tentative de conversion
function ConvertHandlers.ConvertResult(player, result)
    local frame = CreateConvertUI()
    if frame.timeoutFrame then
        frame.timeoutFrame:Hide()
    end
    if result then
        if result.success then
            frame.statusText:SetText("|cFF00FF00"..tostring(result.message).."|r")
            frame.amountBox:SetText("")
        else
            frame.statusText:SetText("|cFFFF0000"..tostring(result.message).."|r")
        end
        if result.dp then
            frame.siteValue = result.dp
            frame.siteBalanceLabel:SetText("|cFFFFD700"..tostring(result.dp).."|r")
        end
    end
end

-- Commande slash de secours pour ouvrir l'UI sans passer par le PNJ
SLASH_MODMECONVERT1 = "/convert"
SlashCmdList["MODMECONVERT"] = function(msg)
    AIO.Handle("ModMeConvert", "ShowConvertUI")
end
