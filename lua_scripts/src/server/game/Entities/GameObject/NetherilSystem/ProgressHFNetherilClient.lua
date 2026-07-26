local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local ROW_COUNT = 12
local NetherilFrame = nil
local ModelPreviewFrame = nil

local BACKGROUND_TEXTURE = "Interface\\NetherilUI\\NetherilUI"
local MAGNIFIER_TEXTURE = "Interface\\Common\\UI-Searchbox-Icon"

local PhaseNoticeFrame = nil

-- Textes purement cote client (pas lies aux donnees serveur) : localises
-- via GetLocale() (langue de l'interface du client), pas besoin d'aller
-- demander la locale au serveur pour ces deux-la.
local CLIENT_L = {
    enUS = {
        dragHint     = "Drag to rotate",
        phaseNotice  = "You have been temporarily isolated to view the Netheril creatures",
    },
    frFR = {
        dragHint     = "Glisser pour tourner",
        phaseNotice  = "Vous avez été temporairement isolé(e) pour visualiser les créatures de Netheril",
    },
}

local function GetClientStrings()
    local locale = GetLocale and GetLocale() or "enUS"
    return CLIENT_L[locale] or CLIENT_L.enUS
end

-- ID de creature -> DisplayID.
--
-- APRES DE NOMBREUX ESSAIS (Model:SetCreature, PlayerModel:SetDisplayInfo,
-- SetModel(chemin .mdx), widget "DressUpModel" + templates PKBT_ModelTemplate,
-- emprunt du widget modele d'Encounter Journal...) qui se sont tous averes
-- peu fiables ou visuellement casses sur ce client, on change completement
-- d'approche a la demande de l'utilisateur :
--
-- Au lieu d'essayer d'afficher un widget "Model" independant avec un
-- DisplayID brut, on utilise EXACTEMENT le meme mecanisme que la commande
-- GM ".morph" (dont on a demontre plusieurs fois qu'elle affiche TOUJOURS
-- correctement n'importe quel DisplayID, texture/equipement compris) :
-- on morph le PERSONNAGE DU JOUEUR lui-meme (Unit:SetDisplayId cote
-- serveur, cf ProgressHFNetherilServer.lua) et on affiche ce joueur (donc
-- son unite reelle, avec le vrai pipeline de rendu du jeu) dans un widget
-- PlayerModel classique via :SetUnit("player"). On revient a l'apparence
-- normale (Unit:DeMorph) a la fermeture de l'apercu.
local ROW_DISPLAY_IDS = {
    [7000600] = 17446,
    [7000601] = 18448,
    [7000602] = 20045,
    [7000603] = 9129,
    [7000604] = 18699,
    [7000605] = 7950,
    [7000606] = 22979,
    [7000607] = 6172,
    [7000608] = 17887,
    [7000609] = 4426,
    [7000610] = 17287,
    [7000611] = 19200,
}

local function NotifyServerState(isOpen)
    AIO.Handle("NetherilUI", "SetUIState", isOpen)
end

-- Grand message au centre de l'ecran, affiche pendant qu'un apercu de
-- creature Netheril est ouvert, pour prevenir que le joueur a ete
-- temporairement isole dans sa propre phase (cf ProgressHFNetherilServer.lua
-- : PREVIEW_PHASE) le temps de la visualisation.
local function CreatePhaseNoticeFrame()
    if PhaseNoticeFrame then
        return PhaseNoticeFrame
    end

    local frame = CreateFrame("Frame", "NetherilPhaseNoticeFrame", UIParent)
    frame:SetSize(500, 40)
    frame:SetPoint("TOP", UIParent, "TOP", 0, -130)
    frame:SetFrameStrata("HIGH")
    frame:Hide()

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.text:SetWidth(500)
    frame.text:SetJustifyH("CENTER")
    frame.text:SetText("|cffffd200" .. GetClientStrings().phaseNotice .. "|r")

    PhaseNoticeFrame = frame
    return frame
end

-- Petite fenetre d'apercu (loupe) : affiche le personnage du joueur,
-- morphe cote serveur en la creature choisie.
local function CreateModelPreviewFrame()
    if ModelPreviewFrame then
        return ModelPreviewFrame
    end

    local frame = CreateFrame("Frame", "NetherilModelPreviewFrame", UIParent)
    frame:SetSize(260, 360)
    frame:SetPoint("LEFT", NetherilFrame, "RIGHT", 12, 0)
    -- Meme habillage visuel que la fenetre principale (Interface\NetherilUI).
    frame:SetBackdrop({
        bgFile = BACKGROUND_TEXTURE,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetBackdropColor(1, 1, 1, 1)
    frame:Hide()
    frame:SetScript("OnHide", function()
        -- Revient a l'apparence normale des que l'apercu se ferme (croix,
        -- fermeture de la fenetre principale, etc.).
        AIO.Handle("NetherilUI", "PreviewMorphEnd")
        if PhaseNoticeFrame then
            PhaseNoticeFrame:Hide()
        end
    end)

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)
    closeButton:SetScript("OnClick", function() frame:Hide() end)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- Descendu pour tomber dans la bande decorative du haut de la texture
    -- Interface\NetherilUI (etait trop haut, au-dessus de la bande) :
    -- -16 -> -26 -> -41 -> -44.
    frame.title:SetPoint("TOP", frame, "TOP", 0, -44)
    frame.title:SetWidth(220)
    frame.title:SetJustifyH("CENTER")

    -- PlayerModel classique (widget de base, toujours fiable pour afficher
    -- une VRAIE unite comme "player") + drag-to-rotate a la souris.
    local turnSpeed = 34
    local model = CreateFrame("PlayerModel", nil, frame)
    model:SetPoint("CENTER", frame, "CENTER", 0, -10)
    model:SetSize(222, 267)
    model:SetPosition(0, 0, 0)
    model:EnableMouse(true)
    model:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            local startX = ({ GetCursorPosition() })[1]
            self:SetScript("OnUpdate", function(self)
                local curX = ({ GetCursorPosition() })[1]
                self:SetFacing(((curX - startX) / turnSpeed) + self:GetFacing())
                startX = curX
            end)
        end
    end)
    model:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    -- Des que le serveur applique (ou annule) le morph, l'apparence du
    -- joueur change reellement -> l'evenement UNIT_MODEL_CHANGED se
    -- declenche, on rafraichit alors le widget pour refleter le changement.
    model:RegisterEvent("UNIT_MODEL_CHANGED")
    model:SetScript("OnEvent", function(self, event, unit)
        if event == "UNIT_MODEL_CHANGED" and unit == "player" and frame:IsShown() then
            self:SetUnit("player")
            self:SetFacing(0)
        end
    end)

    frame.model = model

    local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    -- Remonte de 6px a la demande (10 -> 16).
    hint:SetPoint("BOTTOM", frame, "BOTTOM", 0, 16)
    hint:SetText(GetClientStrings().dragHint)
    frame.hint = hint

    ModelPreviewFrame = frame
    return frame
end

local function ShowModelPreview(label, displayId)
    if not displayId then
        return
    end

    local frame = CreateModelPreviewFrame()

    frame.title:SetText(label or "")
    frame.model:SetUnit("player")
    frame.model:SetFacing(0)
    frame:Show()

    CreatePhaseNoticeFrame():Show()

    -- Demande au serveur de morpher le joueur en la creature choisie
    -- (Unit:SetDisplayId, meme mecanisme que ".morph"). Le widget se
    -- rafraichit tout seul via UNIT_MODEL_CHANGED une fois applique.
    AIO.Handle("NetherilUI", "PreviewMorph", displayId)

    if PlaySound then
        PlaySound("INTERFACESOUND_GAMESCROLLBUTTON", "Master")
    end
end

local function CreateNetherilFrame()
    if NetherilFrame then
        return NetherilFrame
    end

    local frame = CreateFrame("Frame", "NetherilProgressFrame", UIParent)
    frame:SetSize(460, 460)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(100)
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnHide", function()
        NotifyServerState(false)
        if ModelPreviewFrame then
            ModelPreviewFrame:Hide()
        end
    end)
    frame:SetScript("OnShow", function() NotifyServerState(true) end)
    frame:Hide()

    tinsert(UISpecialFrames, "NetherilProgressFrame")

    frame:SetBackdrop({
        bgFile = BACKGROUND_TEXTURE,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetBackdropColor(1, 1, 1, 1)

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -26, -26)
    closeButton:SetScript("OnClick", function() frame:Hide() end)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -57)
    frame.title:SetText("Netheril")

    frame.rows = {}
    frame.magnifiers = {}
    local yOffset = -115
    for i = 1, ROW_COUNT do
        local row = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 58, yOffset)
        row:SetPoint("RIGHT", frame, "RIGHT", -58, 0)
        row:SetJustifyH("LEFT")
        frame.rows[i] = row

        local magnifier = CreateFrame("Button", nil, frame)
        magnifier:SetSize(14, 14)
        magnifier:SetPoint("TOPLEFT", frame, "TOPLEFT", 38, yOffset - 2)
        magnifier:SetNormalTexture(MAGNIFIER_TEXTURE)
        magnifier:SetHighlightTexture(MAGNIFIER_TEXTURE)
        magnifier:GetHighlightTexture():SetBlendMode("ADD")
        magnifier:Hide()
        magnifier:SetScript("OnClick", function(self)
            local entry = self.creatureEntry
            local label = self.creatureLabel
            if not entry then
                return
            end
            ShowModelPreview(label, ROW_DISPLAY_IDS[entry])
        end)
        frame.magnifiers[i] = magnifier

        yOffset = yOffset - 21
    end

    frame.summary = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.summary:SetPoint("BOTTOM", frame, "BOTTOM", 0, 47)

    frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    -- Descendu de 8px puis 5px de plus a la demande (40 -> 32 -> 27).
    frame.status:SetPoint("BOTTOM", frame, "BOTTOM", 0, 27)

    NetherilFrame = frame
    return frame
end

local function ShowProgress(player, data)
    if not data then
        return
    end

    local frame = CreateNetherilFrame()
    frame.title:SetText(data.header or "Netheril")

    for i = 1, ROW_COUNT do
        local fs = frame.rows[i]
        local magnifier = frame.magnifiers[i]
        local entry = data.rows and data.rows[i]
        if fs and entry then
            local color = entry.done and "|cff00ff00" or "|cff00ccff"
            fs:SetText(string.format("%s  %s%d/%d|r", entry.label, color, entry.counter, entry.quantity))

            if magnifier then
                magnifier.creatureEntry = entry.entry
                magnifier.creatureLabel = entry.label
                if entry.entry and ROW_DISPLAY_IDS[entry.entry] then
                    magnifier:Show()
                else
                    magnifier:Hide()
                end
            end
        elseif fs then
            fs:SetText("")
            if magnifier then
                magnifier:Hide()
            end
        end
    end

    frame.summary:SetText(data.summary or "")

    if data.achievementDone then
        frame.status:SetText("|cff00ff00" .. (data.doneText or "") .. "|r")
    else
        frame.status:SetText("")
    end

    frame:Show()
end

local NetherilHandlers = AIO.AddHandlers("NetherilUI", {})
NetherilHandlers.ShowProgress = ShowProgress

CreateNetherilFrame()
CreateModelPreviewFrame()
CreatePhaseNoticeFrame()
