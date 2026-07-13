-- TransmogrifierClient.lua
-- Système de Transmogrification optimisé pour TrinityCore 3.3.5 avec AIO
-- Background DressUp en 4 tuiles (style natif WoW DressUpFrame / CharacterFrame)

local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local TransmogHandlers = AIO.AddHandlers("Transmog", {})
local TRANSMOG_WINDOW = "TransmogFrame"

local OPEN_TALENT_WINDOW_SOUND  = "Sound\\INTERFACE\\UI_Transmogrify_Apply.OGG"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\INTERFACE\\UI_VoidStorage_Undo.OGG"
local GET_ITEM_WINDOW_SOUND     = "Sound\\INTERFACE\\UI_Reforging_Reforge.ogg"
local SELECT_EQUIP_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_715_brawlers_guild_purchase_upgrade.ogg"

-- Configuration des slots d'équipement
local SLOTS = {
    {id = 1,  name = "Tête",        slot = "HeadSlot"},
    {id = 3,  name = "Épaules",     slot = "ShoulderSlot"},
    {id = 15, name = "Dos",         slot = "BackSlot"},
    {id = 5,  name = "Torse",       slot = "ChestSlot"},
    {id = 9,  name = "Poignets",    slot = "WristSlot"},
    {id = 10, name = "Mains",       slot = "HandsSlot"},
    {id = 6,  name = "Taille",      slot = "WaistSlot"},
    {id = 7,  name = "Jambes",      slot = "LegsSlot"},
    {id = 8,  name = "Pieds",       slot = "FeetSlot"},
    {id = 16, name = "Main droite", slot = "MainHandSlot"},
    {id = 17, name = "Main gauche", slot = "SecondaryHandSlot"},
    {id = 18, name = "À distance",  slot = "RangedSlot"},
}

-- Slots autour du modèle du joueur
local slotPositions = {
    [1]  = {name = "Tête",        x = -140, y =  160},
    [3]  = {name = "Épaules",     x = -140, y =  100},
    [15] = {name = "Dos",         x = -140, y =   40},
    [5]  = {name = "Torse",       x = -140, y =  -20},
    [9]  = {name = "Poignets",    x = -140, y =  -80},
    [10] = {name = "Mains",       x =  140, y =  100},
    [6]  = {name = "Taille",      x =  140, y =   40},
    [7]  = {name = "Jambes",      x =  140, y =  -20},
    [8]  = {name = "Pieds",       x =  140, y =  -80},
    [16] = {name = "Main droite", x = -148, y = -150},
    [17] = {name = "Main gauche", x =  148, y = -150},
    [18] = {name = "À distance",  x =    0, y = -220},
}

local SelectedSlot  = nil
local CurrentPage   = 1
local TotalPages    = 1
local slotButtons   = {}
local itemButtons   = {}
local TransmogFrame = nil
local playerModel   = nil
local pageText      = nil
local prevPageBtn   = nil
local nextPageBtn   = nil

-- ============================================================
-- Helper : retourne le nom de fichier de background DressUp
-- (même logique HACK que DressUpFrame.lua natif de WoW)
-- ============================================================
local function GetDressUpTexturePath()
    local _, fileName = UnitRace("player")
    if not fileName then
        fileName = "Orc"
    else
        -- HACK Blizzard : Gnome → Dwarf, Troll → Orc (textures manquantes)
        local upper = strupper(fileName)
        if upper == "GNOME" then
            fileName = "Dwarf"
        elseif upper == "TROLL" then
            fileName = "Orc"
        end
    end
    return "Interface\\DressUpFrame\\DressUpBackground-" .. fileName
end

-- ============================================================
-- Applique le fond 4-tuiles sur les 4 textures du playerModel
-- (exactement comme SetDressUpBackground() dans DressUpFrame.lua)
-- ============================================================
local function SetTransmogDressUpBackground(bgTopLeft, bgTopRight, bgBotLeft, bgBotRight)
    local path = GetDressUpTexturePath()
    bgTopLeft :SetTexture(path .. "1")
    bgTopRight:SetTexture(path .. "2")
    bgBotLeft :SetTexture(path .. "3")
    bgBotRight:SetTexture(path .. "4")
end

-- ============================================================
-- Création de l'interface principale
-- ============================================================
function TransmogHandlers.CreateUI(player)
    if TransmogFrame then
        TransmogFrame:Show()
        TransmogHandlers.UpdateSlots()
        return
    end

    -- ── Frame principale ───────────────────────────────────────
    TransmogFrame = CreateFrame("Frame", TRANSMOG_WINDOW, UIParent)
    TransmogFrame:SetSize(810, 600)
    TransmogFrame:SetPoint("CENTER")
    TransmogFrame:SetMovable(true)
    TransmogFrame:EnableMouse(true)
    TransmogFrame:RegisterForDrag("LeftButton")
    TransmogFrame:SetScript("OnDragStart", TransmogFrame.StartMoving)
    TransmogFrame:SetScript("OnDragStop",  TransmogFrame.StopMovingOrSizing)
    TransmogFrame:SetFrameStrata("DIALOG")
    TransmogFrame:SetClampedToScreen(true)

    -- Background général
    local mainBg = TransmogFrame:CreateTexture(nil, "BACKGROUND")
    mainBg:SetAllPoints()
    mainBg:SetTexture("Interface\\TansmogUI\\transmogrify\\collectionsbackgroundtile")

    -- Header
    local header = TransmogFrame:CreateTexture(nil, "ARTWORK")
    header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    header:SetWidth(300)
    header:SetHeight(64)
    header:SetPoint("TOP", 0, 12)

    local title = TransmogFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", header, "TOP", 0, -14)
    title:SetText("Transmogrification")

    -- Bouton de fermeture
    local closeBtn = CreateFrame("Button", nil, TransmogFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -15, -15)
    closeBtn:SetScript("OnClick", function()
        TransmogFrame:Hide()
    end)

    -- ── Modèle 3D du personnage ───────────────────────────────
    playerModel = CreateFrame("DressUpModel", nil, TransmogFrame)
    playerModel:SetSize(220, 380)
    playerModel:SetPoint("TOPLEFT", 120, -80)
    playerModel:SetUnit("player")
    playerModel:SetRotation(0.61)

    playerModel.rotation    = 0.61
    playerModel.isDragging  = false

    -- Rotation souris
    playerModel:EnableMouse(true)
    playerModel:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.isDragging  = true
            self.lastCursorX = GetCursorPosition()
        end
    end)
    playerModel:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self.isDragging = false
        end
    end)
    playerModel:SetScript("OnUpdate", function(self)
        if self.isDragging then
            local cursorX = GetCursorPosition()
            local diff    = cursorX - self.lastCursorX
            self.rotation = self.rotation + (diff * 0.01)
            self:SetRotation(self.rotation)
            self.lastCursorX = cursorX
        end
    end)

    -- ── DressUp Background en 4 tuiles (style DressUpFrame natif) ──
    --
    -- DressUpFrame.xml place ses 4 textures dans le layer OVERLAY,
    -- positionnées à partir d'un coin fixe (TOPLEFT + offset 22, -76).
    -- Ici on les positionne de la même façon MAIS relatives au playerModel,
    -- en les clipant à l'intérieur de ses insets (4 px de chaque côté).
    --
    -- Dimensions d'origine dans DressUpFrame.xml :
    --   TopLeft  : 256 x 255
    --   TopRight :  62 x 255
    --   BotLeft  : 256 x 128
    --   BotRight :  62 x 128
    --
    -- Le modèle fait 220 x 380 (insets 4 px) → zone utile 212 x 372.
    -- On scale proportionnellement pour couvrir toute la zone :
    --   total width  = 256+62  = 318  → scale W = 212/318 ≈ 0.667
    --   total height = 255+128 = 383  → scale H = 372/383 ≈ 0.971
    --
    -- En pratique WoW 3.3.5 ne supporte pas SetSize fractionnaire proprement
    -- sur les textures dans DressUpModel ; on utilise SetAllPoints / ancres
    -- pour laisser le moteur gérer le découpage.
    -- ----------------------------------------------------------------

    -- Conteneur interne pour les 4 tuiles (même strate que le modèle,
    -- dessiné AVANT le personnage grâce au sous-layer BACKGROUND/-8)
    local bgContainer = CreateFrame("Frame", nil, playerModel)
    bgContainer:SetAllPoints()
    bgContainer:SetFrameLevel(playerModel:GetFrameLevel())

    -- Calcul des tailles relatives à la zone utile du modèle
    -- (les 4 textures doivent ensemble couvrir exactement la zone)
    local modelW = 212  -- 220 - 4*2 insets
    local modelH = 372  -- 380 - 4*2 insets

    local origW  = 256 + 62   -- largeur totale de la mosaïque Blizzard
    local origH  = 255 + 128  -- hauteur totale

    local tileTopLeftW  = math.floor(modelW * 256 / origW)
    local tileTopRightW = modelW - tileTopLeftW
    local tileTopH      = math.floor(modelH * 255 / origH)
    local tileBotH      = modelH - tileTopH

    -- TopLeft
    local bgTopLeft = bgContainer:CreateTexture(nil, "BACKGROUND", nil, -8)
    bgTopLeft:SetWidth(tileTopLeftW)
    bgTopLeft:SetHeight(tileTopH)
    bgTopLeft:SetPoint("TOPLEFT", playerModel, "TOPLEFT", 4, -4)

    -- TopRight
    local bgTopRight = bgContainer:CreateTexture(nil, "BACKGROUND", nil, -8)
    bgTopRight:SetWidth(tileTopRightW)
    bgTopRight:SetHeight(tileTopH)
    bgTopRight:SetPoint("TOPLEFT", bgTopLeft, "TOPRIGHT", 0, 0)

    -- BotLeft
    local bgBotLeft = bgContainer:CreateTexture(nil, "BACKGROUND", nil, -8)
    bgBotLeft:SetWidth(tileTopLeftW)
    bgBotLeft:SetHeight(tileBotH)
    bgBotLeft:SetPoint("TOPLEFT", bgTopLeft, "BOTTOMLEFT", 0, 0)

    -- BotRight
    local bgBotRight = bgContainer:CreateTexture(nil, "BACKGROUND", nil, -8)
    bgBotRight:SetWidth(tileTopRightW)
    bgBotRight:SetHeight(tileBotH)
    bgBotRight:SetPoint("TOPLEFT", bgTopLeft, "BOTTOMRIGHT", 0, 0)

    -- Application des textures selon la race (même logique que DressUpFrame.lua)
    SetTransmogDressUpBackground(bgTopLeft, bgTopRight, bgBotLeft, bgBotRight)

    -- Rafraîchir si la race change via OnShow du TransmogFrame
    TransmogFrame:SetScript("OnShow", function()
        SetTransmogDressUpBackground(bgTopLeft, bgTopRight, bgBotLeft, bgBotRight)
        TransmogHandlers.UpdateSlots()
        PlaySoundFile(OPEN_TALENT_WINDOW_SOUND)
    end)

    -- Son de fermeture dans tous les cas (bouton, Echap)
    TransmogFrame:SetScript("OnHide", function()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    end)

    -- ── Container slots d'équipement (milieu) ─────────────────
    local slotContainer = CreateFrame("Frame", nil, TransmogFrame)
    slotContainer:SetSize(180, 450)
    slotContainer:SetPoint("LEFT", playerModel, "RIGHT", 25, 0)

    local slotTitle = slotContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    slotTitle:SetPoint("TOP", -220, -10)
    slotTitle:SetText("Équipement")

    -- Création des boutons de slots
    for _, slotData in ipairs(SLOTS) do
        local pos = slotPositions[slotData.id]
        if pos then
            local btn = CreateFrame("Button", nil, TransmogFrame)
            btn:SetSize(42, 42)
            btn:SetPoint("CENTER", playerModel, "CENTER", pos.x, pos.y)

            -- Fond style inventaire WoW
            btn.background = btn:CreateTexture(nil, "BACKGROUND")
            btn.background:SetAllPoints()
            btn.background:SetTexture("Interface\\Buttons\\UI-EmptySlot-Disabled")
            btn.background:SetAlpha(0.8)

            -- Icône du slot (vide)
            btn.slotIcon = btn:CreateTexture(nil, "ARTWORK")
            btn.slotIcon:SetSize(38, 38)
            btn.slotIcon:SetPoint("CENTER")
            btn.slotIcon:SetTexture("Interface\\PaperDoll\\UI-PaperDoll-Slot-" .. slotData.slot)

            -- Icône de l'objet équipé
            btn.itemIcon = btn:CreateTexture(nil, "ARTWORK")
            btn.itemIcon:SetSize(36, 36)
            btn.itemIcon:SetPoint("CENTER")
            btn.itemIcon:Hide()

            -- Bordure de sélection dorée
            btn.border = btn:CreateTexture(nil, "OVERLAY")
            btn.border:SetAllPoints()
            btn.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            btn.border:SetBlendMode("ADD")
            btn.border:SetVertexColor(1, 0.8, 0)
            btn.border:Hide()

            btn:SetHighlightTexture("Interface\\TansmogUI\\transmogrify\\ButtonTM", "ADD")

            btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            btn.label:SetPoint("TOP", btn, "BOTTOM", 0, -2)
            btn.label:SetText(pos.name)

            btn.slotId   = slotData.id
            btn.slotData = slotData

            -- Clic → sélection + demande d'items
            btn:SetScript("OnClick", function(self)
                for _, otherBtn in pairs(slotButtons) do
                    otherBtn.border:Hide()
                end
                SelectedSlot = self.slotId
                self.border:Show()
                CurrentPage  = 1
                AIO.Handle("Transmog", "GetItems", self.slotId, CurrentPage)
                PlaySoundFile(SELECT_EQUIP_WINDOW_SOUND)
            end)

            -- Tooltip
            btn:SetScript("OnEnter", function(self)
                local itemLink = GetInventoryItemLink("player", self.slotId)
                if itemLink then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetHyperlink(itemLink)
                    GameTooltip:Show()
                end
            end)
            btn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            slotButtons[#slotButtons + 1] = btn
        end
    end

    -- ── Grille d'items disponibles (droite) ───────────────────
    local itemGrid = CreateFrame("Frame", nil, TransmogFrame)
    itemGrid:SetSize(300, 450)
    itemGrid:SetPoint("LEFT", slotContainer, "RIGHT", -90, -110)

    local itemTitle = itemGrid:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    itemTitle:SetPoint("TOP", 0, -5)
    itemTitle:SetText("Apparences disponibles")

    -- Grille 4×2 (8 items)
    for i = 1, 8 do
        local btn = CreateFrame("Button", nil, itemGrid)
        btn:SetSize(55, 55)

        local row = math.floor((i - 1) / 4)
        local col = (i - 1) % 4
        btn:SetPoint("TOPLEFT", 15 + (col * 65), -40 - (row * 65))

        btn.background = btn:CreateTexture(nil, "BACKGROUND")
        btn.background:SetAllPoints()
        btn.background:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        btn.background:SetVertexColor(0.1, 0.1, 0.1, 0.8)

        btn.icon = btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetSize(50, 50)
        btn.icon:SetPoint("CENTER")
        btn.icon:Hide()

        btn.border = btn:CreateTexture(nil, "OVERLAY")
        btn.border:SetAllPoints()
        btn.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        btn.border:SetBlendMode("ADD")
        btn.border:SetVertexColor(0, 1, 0)
        btn.border:Hide()

        btn:SetHighlightTexture("Interface\\TansmogUI\\transmogrify\\ButtonTM", "ADD")

        btn.itemId   = nil
        btn.itemLink = nil

        btn:SetScript("OnClick", function(self)
            if self.itemId and SelectedSlot then
                AIO.Handle("Transmog", "ApplyTransmog", SelectedSlot, self.itemId)
                PlaySoundFile(GET_ITEM_WINDOW_SOUND)
            end
        end)

        btn:SetScript("OnEnter", function(self)
            if self.itemId then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if self.itemLink then
                    GameTooltip:SetHyperlink(self.itemLink)
                else
                    GameTooltip:SetItemByID(self.itemId)
                end
                GameTooltip:Show()
            end
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        itemButtons[i] = btn
    end

    -- ── Pagination ────────────────────────────────────────────
    prevPageBtn = CreateFrame("Button", nil, itemGrid, "UIPanelButtonTemplate")
    prevPageBtn:SetSize(90, 25)
    prevPageBtn:SetPoint("TOPLEFT", 0, -175)
    prevPageBtn:SetText("< Précédent")
    prevPageBtn:SetScript("OnClick", function()
        if CurrentPage > 1 and SelectedSlot then
            CurrentPage = CurrentPage - 1
            AIO.Handle("Transmog", "GetItems", SelectedSlot, CurrentPage)
        end
    end)

    nextPageBtn = CreateFrame("Button", nil, itemGrid, "UIPanelButtonTemplate")
    nextPageBtn:SetSize(90, 25)
    nextPageBtn:SetPoint("TOPRIGHT", -20, -175)
    nextPageBtn:SetText("Suivant >")
    nextPageBtn:SetScript("OnClick", function()
        if CurrentPage < TotalPages and SelectedSlot then
            CurrentPage = CurrentPage + 1
            AIO.Handle("Transmog", "GetItems", SelectedSlot, CurrentPage)
        end
    end)

    pageText = itemGrid:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    pageText:SetPoint("TOP", itemGrid, "TOP", -12, -178)
    pageText:SetText("Page 1 / 1")

    -- ── Boutons Reset ─────────────────────────────────────────
    local resetSlotBtn = CreateFrame("Button", nil, TransmogFrame, "UIPanelButtonTemplate")
    resetSlotBtn:SetSize(140, 30)
    resetSlotBtn:SetPoint("BOTTOM", -80, 20)
    resetSlotBtn:SetText("Réinitialiser slot")
    resetSlotBtn:SetScript("OnClick", function()
        if SelectedSlot then
            AIO.Handle("Transmog", "ResetSlot", SelectedSlot)
        end
    end)

    local resetAllBtn = CreateFrame("Button", nil, TransmogFrame, "UIPanelButtonTemplate")
    resetAllBtn:SetSize(140, 30)
    resetAllBtn:SetPoint("BOTTOM", 80, 20)
    resetAllBtn:SetText("Tout réinitialiser")
    resetAllBtn:SetScript("OnClick", function()
        AIO.Handle("Transmog", "ResetAll")
    end)

    -- ── Affichage du coût ─────────────────────────────────────
    local costFrame = CreateFrame("Frame", nil, TransmogFrame)
    costFrame:SetSize(300, 30)
    costFrame:SetPoint("BOTTOM", 180, 120)

    local costIcon = costFrame:CreateTexture(nil, "ARTWORK")
    costIcon:SetSize(20, 20)
    costIcon:SetPoint("RIGHT", costFrame, "CENTER", -5, 0)
    costIcon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")

    local costText = costFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    costText:SetPoint("LEFT", costFrame, "CENTER", 5, 0)
    costText:SetText("50")
    costText:SetTextColor(1, 0.82, 0)

    local costLabel = costFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    costLabel:SetPoint("BOTTOM", costText, "TOP", 0, 10)
    costLabel:SetText("Coût par transmogrification:")
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

    for _, btn in pairs(slotButtons) do
        local itemLink = GetInventoryItemLink("player", btn.slotId)
        if itemLink then
            local itemId = GetInventoryItemID("player", btn.slotId)
            if itemId then
                local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemId)
                if texture then
                    btn.itemIcon:SetTexture(texture)
                    btn.itemIcon:Show()
                    btn.slotIcon:Hide()
                else
                    btn.itemIcon:Hide()
                    btn.slotIcon:Show()
                end
            end
        else
            btn.itemIcon:Hide()
            btn.slotIcon:Show()
        end
    end

    if playerModel and TransmogFrame:IsShown() then
        playerModel:SetUnit("player")
        playerModel:SetRotation(playerModel.rotation or 0.61)
    end
end

-- ============================================================
-- Mise à jour de la grille d'items disponibles
-- ============================================================
function TransmogHandlers.UpdateItemGrid(player, itemList, page, totalPages)
    CurrentPage = page       or 1
    TotalPages  = totalPages or 1

    if pageText then
        pageText:SetText(string.format("Page %d / %d", CurrentPage, TotalPages))
    end

    if prevPageBtn then
        if CurrentPage <= 1 then prevPageBtn:Disable() else prevPageBtn:Enable() end
    end
    if nextPageBtn then
        if CurrentPage >= TotalPages then nextPageBtn:Disable() else nextPageBtn:Enable() end
    end

    for i = 1, 8 do
        local itemId = itemList[i]
        local btn    = itemButtons[i]

        if itemId and itemId > 0 then
            btn.itemId = itemId

            local _, _, _, _, _, _, _, _, _, texture, _, _, _, _, itemLink = GetItemInfo(itemId)

            if texture then
                btn.icon:SetTexture(texture)
                btn.icon:Show()
                btn:Show()
                btn.itemLink = itemLink
            else
                -- Chargement asynchrone si l'item n'est pas encore dans le cache
                local item = Item:CreateFromItemID(itemId)
                item:ContinueOnItemLoad(function()
                    if btn and btn.itemId == itemId then
                        local _, lnk, _, _, _, _, _, _, _, tex = GetItemInfo(itemId)
                        if tex then
                            btn.icon:SetTexture(tex)
                            btn.icon:Show()
                            btn:Show()
                            btn.itemLink = lnk
                        end
                    end
                end)
            end
        else
            btn.itemId   = nil
            btn.itemLink = nil
            btn.icon:Hide()
            btn.border:Hide()
            btn:Hide()
        end
    end
end

-- ============================================================
-- Callbacks succès / erreur
-- ============================================================
function TransmogHandlers.ShowSuccess(player, message)
    local delayFrame = CreateFrame("Frame")
    local elapsed    = 0
    delayFrame:SetScript("OnUpdate", function(self, delta)
        elapsed = elapsed + delta
        if elapsed >= 0.3 then
            self:SetScript("OnUpdate", nil)
            TransmogHandlers.UpdateSlots()

            if playerModel and TransmogFrame and TransmogFrame:IsShown() then
                playerModel:ClearModel()
                playerModel:SetUnit("player")
                playerModel:SetRotation(playerModel.rotation or 0.61)
            end
        end
    end)
end

function TransmogHandlers.ShowError(player, message)
    -- Implémentation optionnelle (message d'erreur dans l'UI)
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

-- ============================================================
-- Tooltip localisé
-- ============================================================
-- local function GetTransmogTooltipText()
--     local locale = GetLocale()
--     local texts  = {
--         frFR = "|cffffffffTransmogrification|r\n\nModifiez l'apparence de votre équipement\nsans en changer les statistiques.",
--         enUS = "|cffffffffTransmogrification|r\n\nChange the appearance of your equipment\nwithout changing its stats.",
--     }
--     return texts[locale] or texts["enUS"]
-- end

-- ============================================================
-- Bouton sur le CharacterFrame (PaperDollFrame)
-- ============================================================
-- local transmogCharacterFrameContainer = CreateFrame("Frame", "TransmogCharacterFrameContainer", PaperDollFrame)
-- transmogCharacterFrameContainer:SetSize(48, 48)
-- transmogCharacterFrameContainer:SetPoint("TOP", 103, -18)
-- transmogCharacterFrameContainer:SetFrameLevel(5)
-- transmogCharacterFrameContainer:SetMovable(false)
-- transmogCharacterFrameContainer:EnableMouse(true)
-- transmogCharacterFrameContainer:SetClampedToScreen(true)
-- 
-- local transmogCharacterFrameBorder = CreateFrame("Button", "TransmogCharacterFrameBorder", transmogCharacterFrameContainer)
-- transmogCharacterFrameBorder:SetSize(50, 50)
-- transmogCharacterFrameBorder:SetNormalTexture("Interface\\TansmogUI\\ButtonSystemTransmog")
-- transmogCharacterFrameBorder:SetHighlightTexture("Interface\\TansmogUI\\ButtonSystemTransmogLight")
-- transmogCharacterFrameBorder:SetPoint("CENTER", 0, 0)
-- transmogCharacterFrameBorder:SetFrameLevel(7)
-- 
-- local transmogCharacterFrameBackground = CreateFrame("Frame", "TransmogCharacterFrameBackground", transmogCharacterFrameBorder)
-- transmogCharacterFrameBackground:SetSize(39, 39)
-- transmogCharacterFrameBackground:SetBackdrop({
--     bgFile = "Interface\\TansmogUI\\ButtonSystemTransmog",
--     insets = {left = 0, right = 0, top = 0, bottom = 0},
-- })
-- transmogCharacterFrameBackground:SetPoint("CENTER", 0, 0)
-- transmogCharacterFrameBackground:SetFrameLevel(6)
-- 
-- transmogCharacterFrameBorder:SetScript("OnEnter", function(self)
--     GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR", 1, 5)
--     GameTooltip:SetText(GetTransmogTooltipText())
--     GameTooltip:Show()
-- end)
-- transmogCharacterFrameBorder:SetScript("OnLeave", function()
--     GameTooltip:Hide()
-- end)
-- transmogCharacterFrameBorder:SetScript("OnMouseUp", OuvrirFermerInterfaceTransmog)
