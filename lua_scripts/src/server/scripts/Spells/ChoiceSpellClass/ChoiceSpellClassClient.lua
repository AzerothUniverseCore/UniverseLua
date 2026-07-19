local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local ChoiceSpellClassHandlers = AIO.AddHandlers("ChoiceSpellClassHandler", {})

local CLIENT_CATALOG = {
    Cavalier = {
        { key = "attaque_sournoise", id = 53 },
        { key = "attaque_pernicieuse", id = 1752 },
        { key = "evisceration", id = 2098 },
        { key = "garrot", id = 703 },
        { key = "coup_de_pied", id = 1766 },
        { key = "debiter", id = 5171 },
        { key = "coup_bas", id = 1833 },
        { key = "camouflage", id = 1785 },
        { key = "feinte", id = 1966 },
        { key = "vol_a_la_tire", id = 921 },
        { key = "distraction", id = 1725 },
        { key = "embuscade", id = 8676 },
        { key = "aiguillon_perfide", id = 408 },
        { key = "exposer_armure", id = 8647 },
        { key = "rupture", id = 1943 },
        { key = "hemorragie", id = 16511 },
        { key = "demantelement", id = 51722 },
        { key = "cape_d_ombre", id = 31224 },
        { key = "premeditation", id = 14183 },
        { key = "danse_de_l_ombre", id = 51713 },
        { key = "eventail_de_couteaux", id = 51723 },
        { key = "frappe_fantome", id = 33925 },
    },
    Chronomancer = {
        { key = "eclair_de_givre", id = 116 },
        { key = "cone_de_froid", id = 120 },
        { key = "blizzard", id = 10 },
        { key = "barriere_de_glace", id = 11426 },
        { key = "metamorphose", id = 118 },
        { key = "nova_de_givre", id = 122 },
        { key = "contresort", id = 2139 },
        { key = "javelot_de_glace", id = 30455 },
        { key = "ralentissement", id = 10855 },
        { key = "armure_de_givre", id = 168 },
        { key = "bloc_de_glace", id = 45438 },
        { key = "veines_glaciales", id = 12472 },
    },
    Dompteur = {
        { key = "attaque_du_raptor", id = 2973 },
        { key = "morsure_de_serpent", id = 1978 },
        { key = "tir_des_arcanes", id = 3044 },
        { key = "fleches_multiples", id = 2643 },
        { key = "marque_du_chasseur", id = 1130 },
        { key = "guerison_du_familier", id = 136 },
        { key = "aspect_du_faucon", id = 13165 },
        { key = "visee", id = 19434 },
        { key = "piege_explosif", id = 13813 },
        { key = "piege_givrant", id = 1499 },
        { key = "tir_tranquillisant", id = 19801 },
        { key = "tir_assure", id = 56641 },
        { key = "trait_de_choc", id = 5116 },
        { key = "desengagement", id = 781 },
        { key = "fleche_de_dispersion", id = 19503 },
        { key = "fleche_noire", id = 3674 },
        { key = "aspect_de_la_vipere", id = 34074 },
        { key = "dissuasion", id = 19263 },
        { key = "piqure_de_scorpide", id = 3043 },
        { key = "aspect_de_la_meute", id = 13159 },
        { key = "effrayer_une_bete", id = 1513 },
    },
    Evoker = {
        { key = "eclair", id = 403 },
        { key = "chaine_d_eclairs", id = 421 },
        { key = "projectiles_des_arcanes", id = 5143 },
        { key = "explosion_des_arcanes", id = 1449 },
        { key = "bouclier_de_mana", id = 1463 },
        { key = "deflagration_des_arcanes", id = 30451 },
        { key = "pouvoir_des_arcanes", id = 12042 },
        { key = "presence_spirituelle", id = 12043 },
        { key = "intelligence_des_arcanes", id = 1459 },
        { key = "lenteur", id = 31589 },
        { key = "transfert", id = 1953 },
        { key = "delivrance_malediction", id = 475 },
    },
    Geomancer = {
        { key = "horion_de_terre", id = 8042 },
        { key = "arme_croque_roc", id = 8017 },
        { key = "epines", id = 467 },
        { key = "sarments", id = 26989 },
        { key = "totem_de_force_de_la_terre", id = 8075 },
        { key = "totem_de_magma", id = 8187 },
        { key = "totem_de_peau_de_pierre", id = 8071 },
        { key = "purification", id = 17550 },
        { key = "seisme", id = 61882 },
        { key = "horion_de_givre", id = 8056 },
        { key = "horion_de_flammes", id = 8050 },
        { key = "salve_de_guerison", id = 1064 },
    },
    Necromancer = {
        { key = "trait_de_l_ombre", id = 686 },
        { key = "mot_de_l_ombre_douleur", id = 589 },
        { key = "drain_d_ame", id = 1120 },
        { key = "drain_de_vie", id = 689 },
        { key = "malediction_d_agonie", id = 980 },
        { key = "armure_demoniaque", id = 706 },
        { key = "voile_mortel", id = 6789 },
        { key = "fouet_mental", id = 15407 },
        { key = "peste_devorante", id = 2944 },
        { key = "toucher_vampirique", id = 34914 },
        { key = "mot_de_l_ombre_mort", id = 32379 },
        { key = "pacte_noir", id = 18220 },
        { key = "malediction_de_faiblesse", id = 702 },
        { key = "peur", id = 5782 },
        { key = "malediction_des_elements", id = 1490 },
        { key = "malediction_funeste", id = 603 },
        { key = "hurlement_de_terreur", id = 5484 },
        { key = "controle_mental", id = 605 },
        { key = "furie_de_l_ombre", id = 30283 },
        { key = "lien_spirituel", id = 19028 },
        { key = "carapace_anti_magie", id = 48707 },
        { key = "bouclier_d_os", id = 49222 },
        { key = "froid_devorant", id = 49203 },
        { key = "poigne_de_la_mort", id = 49576 },
        { key = "changeliche", id = 49039 },
        { key = "chancre_impie", id = 49194 },
        { key = "sang_vampirique", id = 55233 },
        { key = "zone_anti_magie", id = 51052 },
        { key = "armee_des_morts", id = 42650 },
        { key = "invocation_d_une_gargouille", id = 49206 },
        { key = "frappe_du_fleau", id = 55090 },
        { key = "frappe_de_peste", id = 45462 },
        { key = "toucher_de_glace", id = 45477 },
        { key = "mort_et_decomposition", id = 43265 },
    },
    Pyromancer = {
        { key = "boule_de_feu", id = 133 },
        { key = "trait_de_feu", id = 2136 },
        { key = "brulure", id = 2948 },
        { key = "choc_de_flammes", id = 2120 },
        { key = "explosion_pyrotechnique", id = 11366 },
        { key = "bombe_vivante", id = 44457 },
        { key = "souffle_du_dragon", id = 31661 },
        { key = "combustion", id = 11129 },
        { key = "immolation", id = 348 },
        { key = "vague_explosive", id = 11113 },
        { key = "gardien_de_feu", id = 543 },
        { key = "armure_fournaise", id = 30482 },
    },
    RavageurChaos = {
        { key = "frappe_heroique", id = 78 },
        { key = "coup_de_tonnerre", id = 6343 },
        { key = "fracasser_armure", id = 7386 },
        { key = "vengeance", id = 6572 },
        { key = "execution", id = 5308 },
        { key = "cri_de_guerre", id = 2048 },
        { key = "tourbillon", id = 1680 },
        { key = "represailles", id = 20240 },
        { key = "charge", id = 100 },
        { key = "onde_de_choc", id = 46968 },
        { key = "provocation", id = 26281 },
        { key = "balayage", id = 31279 },
    },
    Venomancer = {
        { key = "evisceration", id = 2098 },
        { key = "garrot", id = 703 },
        { key = "coup_de_pied", id = 1766 },
        { key = "poison_mortel", id = 2818 },
        { key = "poison_instantane", id = 8679 },
        { key = "poison_douloureux", id = 13218 },
        { key = "poison_affaiblissant", id = 3408 },
        { key = "poison_de_distraction_mentale", id = 5761 },
        { key = "assommer", id = 6770 },
        { key = "attaque_pernicieuse", id = 1752 },
        { key = "evasion", id = 5277 },
        { key = "sprint", id = 2983 },
        { key = "disparition", id = 1856 },
        { key = "cecite", id = 2094 },
        { key = "rupture", id = 1943 },
        { key = "hemorragie", id = 16511 },
        { key = "demantelement", id = 51722 },
        { key = "cape_d_ombre", id = 31224 },
        { key = "premeditation", id = 14183 },
        { key = "danse_de_l_ombre", id = 51713 },
        { key = "eventail_de_couteaux", id = 51723 },
        { key = "frappe_fantome", id = 33925 },
    },
}

local CLASS_LABELS = {
    Cavalier = "Cavalier",
    Chronomancer = "Chronomancer",
    Dompteur = "Dompteur",
    Evoker = "Evocateur",
    Geomancer = "Geomancer",
    Necromancer = "Necromancer",
    Pyromancer = "Pyromancer",
    RavageurChaos = "Ravageur du Chaos",
    Venomancer = "Venomancer",
}

local CLASS_ORDER = { "Cavalier", "Dompteur", "Evoker", "Necromancer", "Venomancer", "Pyromancer", "Chronomancer", "Geomancer", "RavageurChaos" }
local COL_X_FRACTION = {
    Cavalier      = 0.0924,
    Dompteur      = 0.1871,
    Evoker        = 0.2864,
    Necromancer   = 0.4134,
    Venomancer    = 0.5058,
    Pyromancer    = 0.5935,
    Chronomancer  = 0.7286,
    Geomancer     = 0.8222,
    RavageurChaos = 0.9284,
}

local COL_X_OFFSET = {
    RavageurChaos = -10,
}

local CLASS_ID_TO_KEY = {
    [12] = "Cavalier",
    [15] = "Dompteur",
    [17] = "Evoker",
    [18] = "Necromancer",
    [19] = "Venomancer",
    [20] = "Pyromancer",
    [21] = "Chronomancer",
    [22] = "Geomancer",
    [23] = "RavageurChaos",
}

local CLASS_ICON_COORDS = {
    Cavalier      = { 0.625, 0.75, 0, 0.125 },
    Chronomancer  = { 0.125, 0.25, 0.25, 0.375 },
    Dompteur      = { 0.5, 0.625, 0, 0.125 },
    Evoker        = { 0, 0.125, 0.125, 0.25 },
    Geomancer     = { 0.125, 0.25, 0.25, 0.375 },
    Necromancer   = { 0.125, 0.25, 0.25, 0.375 },
    Pyromancer    = { 0.125, 0.25, 0.25, 0.375 },
    RavageurChaos = { 0, 0.125, 0.5, 0.625 },
    Venomancer    = { 0.125, 0.25, 0.25, 0.375 },
}

local FRAME_W, FRAME_H = 1200, 790
local CLASS_ICON_SIZE = 60
local ICON_SIZE = 44
local ICON_GAP = 4
local ICONS_PER_COL = 12
local ICON_PITCH = ICON_SIZE + ICON_GAP
local HEADER_H = 88     -- titre + compteur d'emplacements
local FOOTER_H = 34      -- bouton reinitialiser

local BG_TEXTURE         = "Interface\\legionfall\\legionfall"
local ATLAS_TEXTURE      = "Interface\\Journeys\\JourneysFrame2x"
local CLASS_ICON_TEXTURE = "Interface\\Glues\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
local RING_COORD    = { 0.335938, 0.393555, 0.101563, 0.159180 }

local ITEM_BORDER_TEXTURE = "Interface\\Collections\\Collections"
local ITEM_BORDER_COORD   = { 0.246094, 0.355469, 0.013672, 0.123047 }
local ARROW_NEXT     = { 0.002441, 0.022461, 0.002441, 0.037109 }

local ARROW_NEXT_DOWN = {
    ARROW_NEXT[1], ARROW_NEXT[4],   -- haut-gauche  = (L, B)
    ARROW_NEXT[2], ARROW_NEXT[4],   -- bas-gauche   = (R, B)
    ARROW_NEXT[1], ARROW_NEXT[3],   -- haut-droite  = (L, T)
    ARROW_NEXT[2], ARROW_NEXT[3],   -- bas-droite   = (R, T)
}
local PLATE_NORMAL   = { 0.026367, 0.334961, 0.102539, 0.204590 }
local BG_COORD = { 3 / 1024, 871 / 1024, 4 / 1024, 576 / 1024 }

-- ------------------------------------------------------------
--  Etat local
-- ------------------------------------------------------------
local myChoices = {}   -- ["classKey|abilityKey"] = true
local maxSlots  = 0
local usedSlots = 0

local function ChoiceId(classKey, abilityKey)
    return classKey .. "|" .. abilityKey
end

-- ------------------------------------------------------------
--  Frame principale
-- ------------------------------------------------------------
local MainFrame = nil
local SlotText = nil
local RowByClass = {}   -- [classKey] = { frame, icons={}, arrow, pageText, page }

local RefreshRow
local RefreshAllRows

local function CreateClassRow(classKey, centerX)
    local blockTop = -HEADER_H

    local row = CreateFrame("Frame", nil, MainFrame)
    row:SetSize(60, FRAME_H - HEADER_H - FOOTER_H)
    row:SetPoint("TOP", MainFrame, "TOPLEFT", centerX, blockTop)

    -- Icone de classe (remplace l'etiquette texte), centree en haut du bloc
    local classIcon = CreateFrame("Button", nil, row)
    classIcon:SetSize(CLASS_ICON_SIZE, CLASS_ICON_SIZE)
    classIcon:SetPoint("TOP", row, "TOP", 0, 0)

    local classIconTex = classIcon:CreateTexture(nil, "ARTWORK")
    classIconTex:SetAllPoints(classIcon)
    classIconTex:SetTexture(CLASS_ICON_TEXTURE)
    classIconTex:SetTexCoord(unpack(CLASS_ICON_COORDS[classKey] or { 0, 0.125, 0, 0.125 }))

    local classIconRing = classIcon:CreateTexture(nil, "OVERLAY")
    classIconRing:SetAllPoints(classIcon)
    classIconRing:SetTexture(ATLAS_TEXTURE)
    classIconRing:SetTexCoord(unpack(RING_COORD))

    classIcon:EnableMouse(true)
    classIcon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(CLASS_LABELS[classKey] or classKey)
        GameTooltip:Show()
    end)
    classIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Pile verticale d'icones de sort, sous l'icone de classe
    local icons = {}
    for i = 1, ICONS_PER_COL do
        local slot = CreateFrame("Button", nil, row)
        slot:SetSize(ICON_SIZE, ICON_SIZE)
        slot:SetPoint("TOP", classIcon, "BOTTOM", 0, -6 - (i - 1) * ICON_PITCH)

        local icon = slot:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("CENTER")
        icon:SetSize(ICON_SIZE - 4, ICON_SIZE - 4)
        slot.icon = icon

        local ring = slot:CreateTexture(nil, "OVERLAY")
        ring:SetAllPoints(slot)
        ring:SetTexture(ITEM_BORDER_TEXTURE)
        ring:SetTexCoord(unpack(ITEM_BORDER_COORD))
        slot.ring = ring

        slot:EnableMouse(true)
        slot:SetScript("OnEnter", function(self)
            if self.spellId then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

                GameTooltip:SetHyperlink("spell:" .. self.spellId)
                GameTooltip:Show()
                self.ring:SetVertexColor(1, 1, 0.55)
            end
        end)
        slot:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            if self.hasAbility then
                if self.chosen then
                    self.ring:SetVertexColor(0.55, 0.55, 0.55)
                else
                    self.ring:SetVertexColor(1, 1, 1)
                end
            end
        end)
        slot:SetScript("OnClick", function(self)
            if not self.hasAbility then return end
            if self.chosen then
                AIO.Handle("ChoiceSpellClassHandler", "RemoveAbility", self.classKey, self.abilityKey)
            else
                AIO.Handle("ChoiceSpellClassHandler", "ChooseAbility", self.classKey, self.abilityKey)
            end
        end)

        icons[i] = slot
    end

    local arrow = CreateFrame("Button", nil, row)
    arrow:SetSize(20, 20)
    arrow:SetPoint("TOP", icons[ICONS_PER_COL], "BOTTOM", 0, -6)

    local arrowTex = arrow:CreateTexture(nil, "ARTWORK")
    arrowTex:SetAllPoints(arrow)
    arrowTex:SetTexture(ATLAS_TEXTURE)
    arrowTex:SetTexCoord(unpack(ARROW_NEXT_DOWN))
    arrow.tex = arrowTex

    arrow:SetScript("OnEnter", function(self) self.tex:SetVertexColor(1, 1, 0.6) end)
    arrow:SetScript("OnLeave", function(self) self.tex:SetVertexColor(1, 1, 1) end)

    local pageText = row:CreateFontString(nil, "OVERLAY")
    pageText:SetFont("Fonts\\FRIZQT__.TTF", 9, "")
    pageText:SetPoint("TOP", arrow, "BOTTOM", 0, -2)
    pageText:SetTextColor(1, 1, 1)

    local rowData = {
        frame = row,
        icons = icons,
        arrow = arrow,
        pageText = pageText,
        page = 1,
        classKey = classKey,
    }

    arrow:SetScript("OnClick", function()
        local abilities = CLIENT_CATALOG[classKey] or {}
        local maxPage = math.max(1, math.ceil(#abilities / ICONS_PER_COL))
        if maxPage <= 1 then return end
        rowData.page = rowData.page + 1
        if rowData.page > maxPage then rowData.page = 1 end
        RefreshRow(rowData)
    end)

    RowByClass[classKey] = rowData
    return rowData
end

local function EnsureMainFrame()
    if MainFrame then return end

    MainFrame = CreateFrame("Frame", "ChoiceSpellClassFrame", UIParent)
    MainFrame:SetSize(FRAME_W, FRAME_H)
    MainFrame:SetPoint("CENTER")
    MainFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    MainFrame:SetFrameLevel(200)
    MainFrame:SetToplevel(true)
    MainFrame:SetMovable(true)
    MainFrame:EnableMouse(true)
    MainFrame:RegisterForDrag("LeftButton")
    MainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    MainFrame:SetScript("OnDragStop",  function(self) self:StopMovingOrSizing() end)

    local bg = MainFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(MainFrame)
    bg:SetTexture(BG_TEXTURE)
    bg:SetTexCoord(unpack(BG_COORD))
    MainFrame.bg = bg

    local title = MainFrame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\MORPHEUS.TTF", 20, "OUTLINE")
    title:SetPoint("TOP", MainFrame, "TOP", 0, -14)
    title:SetTextColor(255, 255, 255)
    title:SetText("")

    SlotText = MainFrame:CreateFontString(nil, "OVERLAY")
    SlotText:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    SlotText:SetPoint("TOP", title, "BOTTOM", -480, -20)
    SlotText:SetTextColor(255, 255, 255)
    SlotText:SetText("Niveaux : 0 / 0")

    local closeBtn = CreateFrame("Button", nil, MainFrame)
    closeBtn:SetSize(26, 26)
    closeBtn:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -30, -30)

    local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints(closeBtn)
    closeBg:SetTexture(ATLAS_TEXTURE)
    closeBg:SetTexCoord(unpack(RING_COORD))
    closeBg:SetVertexColor(0.55, 0.12, 0.08)
    closeBtn.bg = closeBg

    local closeLabel = closeBtn:CreateFontString(nil, "OVERLAY")
    closeLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    closeLabel:SetPoint("CENTER", 0, 0)
    closeLabel:SetText("X")
    closeLabel:SetTextColor(1, 0.92, 0.8)
    closeBtn.label = closeLabel

    closeBtn:SetScript("OnClick", function() MainFrame:Hide() end)
    closeBtn:SetScript("OnEnter", function(self)
        self.bg:SetVertexColor(0.85, 0.18, 0.12)
        self.label:SetTextColor(1, 1, 1)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self.bg:SetVertexColor(0.55, 0.12, 0.08)
        self.label:SetTextColor(1, 0.92, 0.8)
    end)

    tinsert(UISpecialFrames, "ChoiceSpellClassFrame")

    for _, classKey in ipairs(CLASS_ORDER) do
        local centerX = FRAME_W * (COL_X_FRACTION[classKey] or 0.5) + (COL_X_OFFSET[classKey] or 0)
        CreateClassRow(classKey, centerX)
    end

    local resetBtn = CreateFrame("Button", nil, MainFrame)
    resetBtn:SetSize(200, 26)
    resetBtn:SetPoint("BOTTOM", MainFrame, "BOTTOM", 400, 730)

    local resetBg = resetBtn:CreateTexture(nil, "BACKGROUND")
    resetBg:SetAllPoints(resetBtn)
    resetBg:SetTexture(ATLAS_TEXTURE)
    resetBg:SetTexCoord(unpack(PLATE_NORMAL))
    resetBtn.bg = resetBg

    local resetLabel = resetBtn:CreateFontString(nil, "OVERLAY")
    resetLabel:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    resetLabel:SetPoint("CENTER")
    resetLabel:SetText("Réinitialiser tous les sorts")
    resetLabel:SetTextColor(255, 255, 255)

    resetBtn:SetScript("OnEnter", function(self) self.bg:SetVertexColor(1, 0.7, 0.7) end)
    resetBtn:SetScript("OnLeave", function(self) self.bg:SetVertexColor(1, 1, 1) end)
    resetBtn:SetScript("OnClick", function()
        AIO.Handle("ChoiceSpellClassHandler", "ResetAll")
    end)

    MainFrame:Hide()
end

local function RefreshSlotText()
    if not SlotText then return end
    SlotText:SetText("Niveaux : " .. usedSlots .. " / " .. maxSlots)
    if usedSlots >= maxSlots then
        SlotText:SetTextColor(255, 255, 255)
    else
        SlotText:SetTextColor(255, 255, 255)
    end
end

RefreshRow = function(rowData)
    local abilities = CLIENT_CATALOG[rowData.classKey] or {}
    local total = #abilities
    local maxPage = math.max(1, math.ceil(total / ICONS_PER_COL))
    if rowData.page > maxPage then rowData.page = maxPage end

    local startIndex = (rowData.page - 1) * ICONS_PER_COL

    for i = 1, ICONS_PER_COL do
        local slot = rowData.icons[i]
        local ability = abilities[startIndex + i]

        if ability then
            slot:Show()
            slot.classKey = rowData.classKey
            slot.abilityKey = ability.key
            slot.spellId = ability.id
            slot.hasAbility = true

            local name, _, icon = GetSpellInfo(ability.id)

            local chosen = myChoices[ChoiceId(rowData.classKey, ability.key)] == true
            slot.chosen = chosen

            slot.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")

            if chosen then
                slot.icon:SetVertexColor(0.45, 0.45, 0.45)
                slot.ring:SetVertexColor(0.55, 0.55, 0.55)
            else
                slot.icon:SetVertexColor(1, 1, 1)
                slot.ring:SetVertexColor(1, 1, 1)
            end
        else
            slot.hasAbility = false
            slot.spellId = nil
            slot.chosen = false
            slot:Hide()
        end
    end

    if maxPage > 1 then
        rowData.pageText:SetText(rowData.page .. "/" .. maxPage)
        rowData.pageText:Show()
        rowData.arrow:Show()
    else
        rowData.pageText:Hide()
        rowData.arrow:Hide()
    end
end

RefreshAllRows = function()
    for _, classKey in ipairs(CLASS_ORDER) do
        local rowData = RowByClass[classKey]
        if rowData then
            RefreshRow(rowData)
        end
    end
end

function ChoiceSpellClassHandlers.SyncState(player, newMax, newUsed, ...)
    maxSlots  = tonumber(newMax) or 0
    usedSlots = tonumber(newUsed) or 0

    wipe(myChoices)
    local flat = { ... }
    for _, id in ipairs(flat) do
        myChoices[id] = true
    end

    RefreshSlotText()
    if MainFrame and MainFrame:IsShown() then
        RefreshAllRows()
    end
end

local function ToggleChoiceSpellClassFrame()
    EnsureMainFrame()
    if MainFrame:IsShown() then
        MainFrame:Hide()
        return
    end

    for _, classKey in ipairs(CLASS_ORDER) do
        local rowData = RowByClass[classKey]
        if rowData then rowData.page = 1 end
    end
    RefreshAllRows()
    MainFrame:Show()
    AIO.Handle("ChoiceSpellClassHandler", "RequestState")
end

SLASH_SORTSCHOIX1 = "/sortschoix"
SLASH_SORTSCHOIX2 = "/ssc"
SlashCmdList["SORTSCHOIX"] = ToggleChoiceSpellClassFrame

local function CreateCharacterFrameButton()
    if not CharacterFrame then return end

    local _, _, classId = UnitClass("player")
    local classKey = CLASS_ID_TO_KEY[classId]
    if not classKey then return end

    local btn = CreateFrame("Button", "ChoiceSpellClassCFButton", CharacterFrame)
    btn:SetSize(30, 30)
    btn:SetFrameStrata("HIGH")
    btn:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", -458, -30)

    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(btn)
    tex:SetTexture(CLASS_ICON_TEXTURE)
    tex:SetTexCoord(unpack(CLASS_ICON_COORDS[classKey] or { 0, 0.125, 0, 0.125 }))

    local ring = btn:CreateTexture(nil, "OVERLAY")
    ring:SetAllPoints(btn)
    ring:SetTexture(ATLAS_TEXTURE)
    ring:SetTexCoord(unpack(RING_COORD))

    btn:EnableMouse(true)
    btn:SetScript("OnClick", ToggleChoiceSpellClassFrame)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Codex des pouvoirs", 1, 1, 1)
        GameTooltip:AddLine("Combinez vos aptitudes de classe secondaire.", 1, 0.82, 0, true)
        GameTooltip:Show()
        ring:SetVertexColor(1, 1, 0.6)
    end)
    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        ring:SetVertexColor(1, 1, 1)
    end)

    btn:Hide()
    if PaperDollFrame then
        PaperDollFrame:HookScript("OnShow", function() btn:Show() end)
        PaperDollFrame:HookScript("OnHide", function() btn:Hide() end)
        if PaperDollFrame:IsShown() then btn:Show() end
    else
        btn:Show()
    end
end

local buttonCreated = false
local function TryCreateCharacterFrameButton()
    if buttonCreated then return end
    if not CharacterFrame then return end
    local _, _, classId = UnitClass("player")
    if not CLASS_ID_TO_KEY[classId] then return end -- pas encore pret / pas une classe secondaire
    CreateCharacterFrameButton()
    buttonCreated = true
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function()
    TryCreateCharacterFrameButton()
end)

if CharacterFrame then
    CharacterFrame:HookScript("OnShow", TryCreateCharacterFrameButton)
end
