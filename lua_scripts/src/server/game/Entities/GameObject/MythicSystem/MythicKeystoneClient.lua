-- ============================================================
--  MythicKeystoneClient.lua  –  Côté CLIENT (AIO)
--  TrinityCore 3.3.5 + Eluna + AIO
--
--  Corrections v2 :
--    • Activer > ferme la frame MK, affiche uniquement
--      l'overlay SystemTimer centré (chiffre + logo + sablier)
--    • Tooltip de l'item slotté (138019)
--    • Timer live rafraîchi toute les secondes côté client
--      (interpolation locale) + position corrigée
--    • Bosses ancré en bas de frame (au-dessus du bouton)
--    • Un seul overlay countdown (ST), pas de double
-- ============================================================

local AIO = AIO or require("AIO")
if AIO.AddAddon() then return end

-- ─────────────────────────────────────────────────────────────
-- TEXTURES MK
-- ─────────────────────────────────────────────────────────────
local TEX        = "Interface\\Challenges\\MythicKeystoneUI"
local TEX_CIRCLE = "Interface\\Challenges\\CircleDoreGrand"

-- ─────────────────────────────────────────────────────────────
-- TEXTURES SYSTEMTIMER (overlay countdown)
-- ─────────────────────────────────────────────────────────────
local ST_MEDIA = "Interface\\timer\\"
local ST_DIGITS = {
    [0]=ST_MEDIA.."number_zero",  [1]=ST_MEDIA.."number_one",
    [2]=ST_MEDIA.."number_two",   [3]=ST_MEDIA.."number_three",
    [4]=ST_MEDIA.."number_four",  [5]=ST_MEDIA.."number_five",
    [6]=ST_MEDIA.."number_six",   [7]=ST_MEDIA.."number_seven",
    [8]=ST_MEDIA.."number_eight", [9]=ST_MEDIA.."number_nine",
}

-- ─────────────────────────────────────────────────────────────
-- PALETTE
-- ─────────────────────────────────────────────────────────────
local C = {
    CYAN   = {0.00, 0.85, 0.95},
    GOLD   = {1.00, 0.82, 0.00},
    WHITE  = {1.00, 1.00, 1.00},
    GREEN  = {0.00, 1.00, 0.00},
    RED    = {1.00, 0.20, 0.20},
    ORANGE = {1.00, 0.55, 0.00},
    PURPLE = {0.70, 0.30, 1.00},
}

-- ─────────────────────────────────────────────────────────────
-- DIMENSIONS MK
-- ─────────────────────────────────────────────────────────────
local W, H        = 532, 532
local Y_LEVEL     = -28
local Y_SLOT      = -180
local Y_CIRCLE    = -213
local CIRCLE_SIZE = 128
local CIRCLE_OX   = -4
local Y_DUNGEON   = -375
local Y_TIMER_LBL = -400     -- "35 Minutes ×1.00"
local Y_LIVE      = -350     -- timer live (MM:SS)
local Y_ICONS     = -435
local Y_BOSSES    = -490     -- compteur bosses (juste au-dessus du bouton)
local CLOSE_OX    = -77
local CLOSE_OY    = -5

-- ─────────────────────────────────────────────────────────────
-- ÉTAT MK
-- ─────────────────────────────────────────────────────────────
local MK = {
    frame           = nil,
    data            = nil,
    ticker          = nil,
    mode            = "view",
    slottedItemID   = nil,
    KEYSTONE_ID     = 138019,
    selectedDungeon = nil,
    dungeonButtons  = {},
    -- timer live interpolé côté client
    liveRemaining   = 0,
    liveActive      = false,
    liveTicker      = nil,
}

-- ─────────────────────────────────────────────────────────────
-- ÉTAT SYSTEMTIMER (overlay : /timer autonome + countdown MK)
-- ─────────────────────────────────────────────────────────────
local ST = {
    frame        = nil,
    tex          = nil,
    texSword     = nil,
    active       = false,
    duration     = 9,
    elapsed      = 0,
    label        = "Timer",
    finished     = false,
    mkControlled = false,  -- true = fermeture silencieuse
}

-- ─────────────────────────────────────────────────────────────
-- POLYFILL C_Timer  (WotLK 3.3.5 n'a pas C_Timer natif)
-- ─────────────────────────────────────────────────────────────
if not C_Timer then
    local _tf = CreateFrame("Frame")
    _tf._cbs  = {}
    _tf:SetScript("OnUpdate", function(self, dt)
        for i = #self._cbs, 1, -1 do
            local cb = self._cbs[i]
            if cb.cancelled then
                table.remove(self._cbs, i)
            else
                cb.elapsed = cb.elapsed + dt
                if cb.elapsed >= cb.interval then
                    cb.elapsed = 0
                    cb.fn()
                    if cb.once then table.remove(self._cbs, i) end
                end
            end
        end
    end)
    C_Timer = {
        NewTicker = function(interval, fn)
            local cb = {interval=interval, elapsed=0, fn=fn, cancelled=false, once=false}
            table.insert(_tf._cbs, cb)
            return { Cancel = function() cb.cancelled = true end }
        end,
        After = function(delay, fn)
            local cb = {interval=delay, elapsed=0, fn=fn, cancelled=false, once=true}
            table.insert(_tf._cbs, cb)
        end,
    }
end

-- ─────────────────────────────────────────────────────────────
-- UTILITAIRES
-- ─────────────────────────────────────────────────────────────
local function FmtTime(s)
    s = math.max(0, math.floor(s))
    return string.format("%02d:%02d", math.floor(s/60), s%60)
end

-- ─────────────────────────────────────────────────────────────
-- SYSTEMTIMER – OVERLAY
-- ─────────────────────────────────────────────────────────────
local function ST_InitUI()
    if ST.frame then return end

    local f = CreateFrame("Frame", "SysTimerMainFrame", UIParent)
    f:SetWidth(320)
    f:SetHeight(160)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)

    local faction = UnitFactionGroup and UnitFactionGroup("player") or "Horde"
    local logoPath = (faction == "Alliance") and (ST_MEDIA.."alliance-logo")
                  or (ST_MEDIA.."horde-logo")

    local texLogo = f:CreateTexture(nil, "ARTWORK")
    texLogo:SetWidth(80); texLogo:SetHeight(80)
    texLogo:SetPoint("LEFT", f, "LEFT", 10, 0)
    texLogo:SetTexture(logoPath)

    local texHourglass = f:CreateTexture(nil, "ARTWORK")
    texHourglass:SetWidth(80); texHourglass:SetHeight(80)
    texHourglass:SetPoint("RIGHT", f, "RIGHT", -10, 0)
    texHourglass:SetTexture(ST_MEDIA.."challenges-logo")

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetWidth(140); tex:SetHeight(140)
    tex:SetPoint("CENTER", f, "CENTER", 0, 0)
    tex:SetTexture(ST_DIGITS[9])
    ST.tex = tex

    local texSword = f:CreateTexture(nil, "OVERLAY")
    texSword:SetWidth(140); texSword:SetHeight(140)
    texSword:SetPoint("CENTER", f, "CENTER", 0, 0)
    texSword:SetTexture(ST_MEDIA.."countdown_sword")
    texSword:Hide()
    ST.texSword = texSword

    f:Hide()
    ST.frame = f
end

-- Lance le décompte visuel SystemTimer.
-- mkControlled=true > fermeture silencieuse (sans épées) utilisé par MK.
local function ST_StartCountdown(duration, label, mkControlled)
    ST_InitUI()
    ST.active       = false
    ST.duration     = duration or 9
    ST.elapsed      = 0
    ST.label        = label or "Timer"
    ST.finished     = false
    ST.mkControlled = mkControlled or false

    if ST.tex then
        ST.tex:SetTexture(ST_DIGITS[ST.duration % 10] or ST_DIGITS[0])
        ST.tex:Show()
    end
    if ST.texSword then ST.texSword:Hide() end

    if ST.frame then
        ST.frame:ClearAllPoints()
        ST.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        ST.frame:Show()
    end

    -- Active au frame suivant pour éviter le dt=0 parasite
    local once = CreateFrame("Frame")
    once:SetScript("OnUpdate", function(self)
        ST.active = true
        self:SetScript("OnUpdate", nil)
    end)
end

local function ST_HideOverlay()
    ST.active   = false
    ST.finished = false
    if ST.frame then ST.frame:Hide() end
end

-- OnUpdate SystemTimer
local stUpdateF = CreateFrame("Frame")
stUpdateF:SetScript("OnUpdate", function(self, dt)
    if not ST.active then return end
    ST.elapsed = ST.elapsed + dt
    local remaining = ST.duration - math.floor(ST.elapsed)
    if remaining < 0 then remaining = 0 end

    if ST.tex then
        local d = remaining % 10
        ST.tex:SetTexture(ST_DIGITS[d] or ST_DIGITS[0])
    end

    if remaining <= 0 and not ST.finished then
        ST.finished = true
        ST.active   = false
        if not ST.mkControlled then
            -- Mode autonome : épées + son
            if ST.tex      then ST.tex:Hide()      end
            if ST.texSword then ST.texSword:Show() end
            PlaySound(569)
            RaidNotice_AddMessage(
                RaidWarningFrame,
                "|cffff4444" .. ST.label .. " : Terminé !|r",
                ChatTypeInfo["RAID_WARNING"]
            )
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cffff4444[SystemTimer]|r " .. ST.label .. " terminé !")
            local closeDelay = 0
            local closeF = CreateFrame("Frame")
            closeF:SetScript("OnUpdate", function(self2, dt2)
                closeDelay = closeDelay + dt2
                if closeDelay >= 3 then
                    if ST.texSword then ST.texSword:Hide() end
                    if ST.tex      then ST.tex:Show()      end
                    if ST.frame    then ST.frame:Hide()    end
                    self2:SetScript("OnUpdate", nil)
                end
            end)
        else
            ST_HideOverlay()
        end
    end
end)

-- ─────────────────────────────────────────────────────────────
-- TIMER LIVE – INTERPOLATION CLIENT
--   Toutes les secondes, décrémente MK.liveRemaining
--   et met à jour l'affichage sans attendre le serveur.
-- ─────────────────────────────────────────────────────────────
local function StopLiveTicker()
    if MK.liveTicker then
        MK.liveTicker:Cancel()
        MK.liveTicker = nil
    end
    MK.liveActive = false
end

local function UpdateLiveDisplay()
    local f = MK.frame
    if not f or not f:IsShown() then return end
    local remaining = MK.liveRemaining
    local depleted  = (remaining <= 0)

    -- Couleur selon temps restant
    local r, g, b
    if depleted then
        r, g, b = C.RED[1], C.RED[2], C.RED[3]
    elseif remaining <= 60 then
        r, g, b = C.RED[1], C.RED[2], C.RED[3]
    elseif remaining <= 300 then
        r, g, b = C.ORANGE[1], C.ORANGE[2], C.ORANGE[3]
    else
        r, g, b = C.GREEN[1], C.GREEN[2], C.GREEN[3]
    end

    local txt = depleted and "|cFFFF3333⚠ DÉPLÉTÉ|r" or FmtTime(remaining)
    f.txtLive:SetTextColor(r, g, b)
    f.txtLive:SetText(txt)

    if depleted then
        f.bgTex:SetVertexColor(1, 0.4, 0.4)
    else
        f.bgTex:SetVertexColor(1, 1, 1)
    end
end

local function StartLiveTicker(remaining)
    StopLiveTicker()
    MK.liveRemaining = math.max(0, remaining)
    MK.liveActive    = true
    UpdateLiveDisplay()
    MK.liveTicker = C_Timer.NewTicker(1, function()
        if not MK.liveActive then return end
        if MK.liveRemaining > 0 then
            MK.liveRemaining = MK.liveRemaining - 1
        end
        UpdateLiveDisplay()
        if MK.liveRemaining <= 0 then
            StopLiveTicker()
        end
    end)
end

-- ─────────────────────────────────────────────────────────────
-- PULSE
-- ─────────────────────────────────────────────────────────────
local _pulseAngle = 0

local function StartPulse()
    if MK.ticker then return end
    _pulseAngle = 0
    MK.ticker = C_Timer.NewTicker(0.05, function()
        local f = MK.frame
        if not f or not f:IsShown() then
            if MK.ticker then MK.ticker:Cancel(); MK.ticker = nil end
            return
        end
        _pulseAngle = (_pulseAngle + 3) % 360
        local p = 0.55 + 0.45 * math.abs(math.sin(math.rad(_pulseAngle)))
        f.bgTex:SetAlpha(0.85 + p * 0.15)
        if f.circleTex then f.circleTex:SetAlpha(0.90 + p * 0.10) end
    end)
end

local function StopPulse()
    if MK.ticker then MK.ticker:Cancel(); MK.ticker = nil end
end

-- ─────────────────────────────────────────────────────────────
-- AFFIXES
-- ─────────────────────────────────────────────────────────────
local function SetNodeColor(i, color, alpha)
    local slot = MK.frame and MK.frame.affixIcons[i]
    if not slot then return end
    slot.border:SetVertexColor(color[1], color[2], color[3])
    slot.border:SetAlpha(alpha or 0.9)
end

local function SetAffixSlot(i, active, iconPath, affixName, affixDesc)
    local slot = MK.frame and MK.frame.affixIcons[i]
    if not slot then return end
    if iconPath then slot.tex:SetTexture(iconPath) end
    slot.tex:SetAlpha(active and 1.0 or 0.25)
    slot.border:SetAlpha(active and 0.90 or 0.25)
    slot.border:SetVertexColor(
        active and C.PURPLE[1] or C.CYAN[1],
        active and C.PURPLE[2] or C.CYAN[2],
        active and C.PURPLE[3] or C.CYAN[3]
    )
    slot.affixName = active and affixName or nil
    slot.affixDesc = active and affixDesc or nil
end

local function ClearDungeonButtons()
    for _, btn in ipairs(MK.dungeonButtons) do
        btn:Hide()
        if btn.selTex    then btn.selTex:Hide()    end
        if btn.borderTex then btn.borderTex:Hide() end
    end
    MK.dungeonButtons  = {}
    MK.selectedDungeon = nil
end

-- ─────────────────────────────────────────────────────────────
-- CONSTRUCTION DE LA FRAME MK
-- ─────────────────────────────────────────────────────────────
local function BuildFrame()
    if MK.frame then return end

    local f = CreateFrame("Frame", "MKKeystoneFrame", UIParent)
    f:SetSize(W, H)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:Hide()

    -- Fond
    local bgTex = f:CreateTexture(nil, "BACKGROUND", nil, -1)
    bgTex:SetTexture(TEX)
    bgTex:SetAllPoints(f)
    bgTex:SetAlpha(1.0)
    f.bgTex = bgTex

    -- Bouton fermer
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetSize(26, 26)
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", CLOSE_OX, CLOSE_OY)
    closeBtn:SetScript("OnClick", function()
        f:Hide()
        StopPulse()
        StopLiveTicker()
    end)
    f.closeBtn = closeBtn

    -- ── SLOT DRAG & DROP ──────────────────────────────────────
    local slotFrame = CreateFrame("Button", "MKKeystoneSlot", f)
    slotFrame:SetSize(64, 64)
    slotFrame:SetPoint("TOP", f, "TOP", 0, Y_SLOT)
    slotFrame:SetFrameLevel(f:GetFrameLevel() + 1)
    slotFrame:EnableMouse(true)
    slotFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    slotFrame:RegisterForDrag("LeftButton")

    local slotBg = slotFrame:CreateTexture(nil, "BACKGROUND")
    slotBg:SetAllPoints(slotFrame)
    slotBg:SetAlpha(0)
    slotFrame.slotBg = slotBg

    local slotIcon = slotFrame:CreateTexture(nil, "ARTWORK")
    slotIcon:SetSize(48, 48)
    slotIcon:SetPoint("CENTER", slotFrame, "CENTER", CIRCLE_OX, 0)  -- aligné avec le cercle
    slotIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    slotIcon:Hide()
    slotFrame.slotIcon = slotIcon

    local slotGlow = slotFrame:CreateTexture(nil, "OVERLAY")
    slotGlow:SetSize(76, 76)
    slotGlow:SetPoint("CENTER")
    slotGlow:SetBlendMode("ADD")
    slotGlow:SetAlpha(0)
    slotFrame.slotGlow = slotGlow

    -- Hint invisible (conservé pour compatibilité Show/Hide dans le reste du code)
    local slotHint = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slotHint:SetPoint("TOP", slotFrame, "BOTTOM", 0, -4)
    slotHint:SetTextColor(C.CYAN[1], C.CYAN[2], C.CYAN[3])
    slotHint:SetText("")   -- texte vide : le tooltip remplace l'affichage
    f.slotHint = slotHint

    local function ClearSlot()
        MK.slottedItemID = nil
        slotFrame.slotIcon:Hide()
        slotFrame.slotGlow:SetAlpha(0)
        slotHint:Show()
    end

    local function TrySlotItem(itemID)
        itemID = tonumber(itemID)
        if not itemID then ClearCursor(); return end
        if itemID ~= MK.KEYSTONE_ID then
            print("|cFFFF4444[Mythic+]|r Ce n'est pas une Clé mythique.")
            ClearCursor(); return
        end
        local icon = GetItemIcon(itemID)
        if icon then
            slotFrame.slotIcon:SetTexture(icon)
            slotFrame.slotIcon:Show()
            slotFrame.slotGlow:SetAlpha(0.6)
            slotHint:Hide()
        end
        MK.slottedItemID = itemID
        ClearCursor()
    end

    -- Tooltip : hint si vide, tooltip item si keystone slotté
    slotFrame:SetScript("OnEnter", function(self)
        if MK.slottedItemID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. MK.slottedItemID .. ":0:0:0:0:0:0:0")
            GameTooltip:Show()
        else
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine("Déposez votre Clé mythique", C.CYAN[1], C.CYAN[2], C.CYAN[3])
            GameTooltip:Show()
        end
    end)
    slotFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    slotFrame:SetScript("OnReceiveDrag", function(self)
        local ctype, id = GetCursorInfo()
        if ctype == "item" then TrySlotItem(id) else ClearCursor() end
    end)
    slotFrame:SetScript("OnClick", function(self, btn)
        local ctype, id = GetCursorInfo()
        if btn == "LeftButton" then
            if ctype == "item" then
                TrySlotItem(id)
            elseif MK.slottedItemID then
                ClearSlot()
            end
        elseif btn == "RightButton" then
            if MK.slottedItemID then ClearSlot() end
        end
    end)

    f.slotFrame = slotFrame
    f.ClearSlot  = ClearSlot

    -- ── CERCLE DORÉ ───────────────────────────────────────────
    local circleFrame = CreateFrame("Frame", nil, f)
    circleFrame:SetSize(CIRCLE_SIZE, CIRCLE_SIZE)
    circleFrame:SetPoint("TOP", f, "TOP", CIRCLE_OX, Y_CIRCLE + CIRCLE_SIZE/2)
    -- circleFrame AU-DESSUS du slotFrame visuellement (icône sous le cercle)
    -- mais EnableMouse(false) pour ne pas bloquer le drag/drop
    local slotLevel = slotFrame:GetFrameLevel()
    circleFrame:SetFrameLevel(slotLevel + 2)
    circleFrame:EnableMouse(false)

    local circleTex = circleFrame:CreateTexture(nil, "ARTWORK")
    circleTex:SetTexture(TEX_CIRCLE)
    circleTex:SetAllPoints(circleFrame)
    circleTex:SetAlpha(1.0)
    f.circleFrame = circleFrame
    f.circleTex   = circleTex

    -- ── TEXTES ────────────────────────────────────────────────

    -- "Niveau X" (haut)
    local txtLevel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    txtLevel:SetPoint("TOP", f, "TOP", 0, Y_LEVEL)
    txtLevel:SetTextColor(C.GOLD[1], C.GOLD[2], C.GOLD[3])
    txtLevel:SetText("")
    f.txtLevel = txtLevel

    -- Nom du donjon
    local txtDungeon = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    txtDungeon:SetPoint("TOP", f, "TOP", 0, Y_DUNGEON)
    txtDungeon:SetTextColor(C.GOLD[1], C.GOLD[2], C.GOLD[3])
    txtDungeon:SetText("")
    f.txtDungeon = txtDungeon

    -- Temps limite (ex: "35 Minutes ×1.00")
    local txtTimerLbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    txtTimerLbl:SetPoint("TOP", f, "TOP", 0, Y_TIMER_LBL)
    txtTimerLbl:SetTextColor(C.WHITE[1], C.WHITE[2], C.WHITE[3])
    txtTimerLbl:SetText("")
    f.txtTimer = txtTimerLbl   -- conserve le nom txtTimer pour compatibilité

    -- Timer live (MM:SS, rafraîchi toute les secondes)
    local txtLive = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    txtLive:SetPoint("TOP", f, "TOP", 0, Y_LIVE)
    txtLive:SetTextColor(C.GREEN[1], C.GREEN[2], C.GREEN[3])
    txtLive:SetText("")
    f.txtLive = txtLive

    -- 5 ICÔNES D'AFFIXES
    local defaultAffixTex = {
        "Interface\\Icons\\ability_toughness",
        "Interface\\Icons\\achievement_boss_archaedas",
        "Interface\\Icons\\spell_nature_cyclone",
        "Interface\\Icons\\spell_fire_felflamering_red",
        "Interface\\Icons\\spell_animarevendreth_buff",
    }
    f.affixIcons = {}
    local ICON_SIZE    = 34
    local ICON_SPACING = 42
    for i = 1, 5 do
        local offsetX = (i-3) * ICON_SPACING
        local iconFrame = CreateFrame("Frame", nil, f)
        iconFrame:SetSize(ICON_SIZE+4, ICON_SIZE+4)
        iconFrame:SetPoint("TOP", f, "TOP", offsetX, Y_ICONS)
        iconFrame:EnableMouse(true)
        local border = iconFrame:CreateTexture(nil, "ARTWORK", nil, 1)
        border:SetAllPoints(iconFrame)
        border:SetBlendMode("ADD")
        border:SetAlpha(0.25)
        border:SetVertexColor(C.CYAN[1], C.CYAN[2], C.CYAN[3])
        local ico = iconFrame:CreateTexture(nil, "OVERLAY", nil, 2)
        ico:SetSize(ICON_SIZE, ICON_SIZE)
        ico:SetPoint("CENTER", iconFrame, "CENTER", 0, -2)
        ico:SetTexture(defaultAffixTex[i])
        ico:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        ico:SetAlpha(0.25)
        iconFrame:SetScript("OnEnter", function(self)
            local slot = MK.frame and MK.frame.affixIcons[i]
            if slot and slot.affixName then
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine(slot.affixName, C.PURPLE[1], C.PURPLE[2], C.PURPLE[3])
                if slot.affixDesc then
                    GameTooltip:AddLine(slot.affixDesc, 1, 1, 1, true)
                end
                GameTooltip:Show()
            end
        end)
        iconFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
        f.affixIcons[i] = { tex=ico, border=border, frame=iconFrame }
    end

    -- Compteur bosses – ancré en bas, au-dessus du bouton Activer
    local txtBosses = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    txtBosses:SetPoint("TOP", f, "TOP", 0, Y_BOSSES)
    txtBosses:SetTextColor(C.WHITE[1], C.WHITE[2], C.WHITE[3])
    txtBosses:SetText("")
    f.txtBosses = txtBosses

    -- LISTE DONJON (mode sélection)
    local listFrame = CreateFrame("Frame", nil, f)
    listFrame:SetSize(260, 160)
    listFrame:SetPoint("TOP", f, "TOP", 0, -50)
    listFrame:Hide()
    f.listFrame = listFrame

    -- BOUTON ACTIVER
    local btnActivate = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnActivate:SetSize(160, 28)
    btnActivate:SetPoint("BOTTOM", f, "BOTTOM", -90, 20)
    btnActivate:SetText("Activer")
    btnActivate:SetScript("OnClick", function()
        if MK.mode == "select" then
            if not MK.selectedDungeon then
                print("|cFFFF4444[Mythic+]|r Sélectionnez un donjon.")
                return
            end
            AIO.Handle("MKServer", "GiveKeystone", MK.selectedDungeon)
        else
            if not MK.slottedItemID then
                print("|cFFFF4444[Mythic+]|r Déposez votre Clé mythique dans le slot.")
                return
            end
            -- Envoie la demande au serveur ; la frame sera cachée
            -- par MKClientHandlers.StartCountdown quand le serveur confirme.
            AIO.Handle("MKServer", "ActivateRun", MK.slottedItemID)
        end
    end)
    f.btnActivate = btnActivate

    -- BOUTON CHANGER DE DONJON
    local btnChangeDungeon = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnChangeDungeon:SetSize(130, 28)
    btnChangeDungeon:SetPoint("BOTTOM", f, "BOTTOM", 80, 20)
    btnChangeDungeon:SetText("Changer donjon")
    btnChangeDungeon:SetScript("OnClick", function()
        AIO.Handle("MKServer", "ChangeDungeon")
    end)
    f.btnChangeDungeon = btnChangeDungeon

    MK.frame = f

    -- Fermeture avec la touche Échap (comme les frames natives WoW)
    tinsert(UISpecialFrames, "MKKeystoneFrame")
end

-- ─────────────────────────────────────────────────────────────
-- MODE VUE
-- ─────────────────────────────────────────────────────────────
local function ShowViewMode(data)
    BuildFrame()
    local f = MK.frame
    MK.data = data
    MK.mode = "view"

    f.txtLevel:SetText("Niveau |cFFFFD700" .. (data.level or "--") .. "|r")
    f.txtDungeon:SetText(data.dungeon or "--")
    local mins    = math.floor((data.timer or 0) / 60)
    local multStr = data.mult and string.format("  |cFFFF8800×%.2f|r", data.mult) or ""
    f.txtTimer:SetText(mins .. " Minutes" .. multStr)
    f.txtLive:SetText("")
    f.txtBosses:SetText("")

    local affixes = data.affixes or {}
    for i = 1, 5 do
        local aff = affixes[i]
        if aff then
            SetAffixSlot(i, true,
                aff.icon and ("Interface\\Icons\\" .. aff.icon),
                aff.name, aff.desc)
        else
            SetAffixSlot(i, false)
        end
    end

    f.listFrame:Hide()
    ClearDungeonButtons()
    f.circleFrame:Show()
    f.bgTex:SetVertexColor(1,1,1)

    if MK.liveActive then
        -- Run en cours : mode run (pas de slot ni boutons)
        f.btnActivate:Hide()
        f.btnChangeDungeon:Hide()
        f.slotFrame:Hide()
        f.slotHint:Hide()
    else
        -- Pas de run : mode normal avec slot et boutons
        f.btnActivate:ClearAllPoints()
        f.btnActivate:SetPoint("BOTTOM", f, "BOTTOM", -90, 20)
        f.btnActivate:SetText("Activer")
        f.btnActivate:Show()
        f.btnChangeDungeon:Show()
        f.slotFrame:Show()
        f.slotHint:Show()
    end

    f:Show()
    StartPulse()
end

-- ─────────────────────────────────────────────────────────────
-- MODE SÉLECTION
-- ─────────────────────────────────────────────────────────────
local function ShowSelectMode(data)
    BuildFrame()
    local f = MK.frame
    MK.data = nil
    MK.mode = "select"

    f.txtLevel:SetText("|cFF00CCFFChoisissez un donjon|r")
    f.txtDungeon:SetText("")
    f.txtTimer:SetText("")
    f.txtLive:SetText("")
    f.txtBosses:SetText("")
    for i = 1, 5 do SetAffixSlot(i, false) end

    f.slotFrame:Hide()
    f.slotHint:Hide()
    f.circleFrame:Hide()
    f.btnActivate:ClearAllPoints()
    f.btnActivate:SetPoint("BOTTOM", f, "BOTTOM", 0, 10)
    f.btnActivate:SetText("Confirmer")
    f.btnActivate:Show()
    f.btnChangeDungeon:Hide()
    f.bgTex:SetVertexColor(1,1,1)

    ClearDungeonButtons()
    f.listFrame:Show()

    local dungeons = data and data.dungeons or {}
    local sorted   = {}
    for id, info in pairs(dungeons) do
        table.insert(sorted, { id=id, info=info })
    end
    table.sort(sorted, function(a, b) return a.id < b.id end)

    for idx, entry in ipairs(sorted) do
        local btn = CreateFrame("Button", nil, f.listFrame, "UIPanelButtonTemplate")
        btn:SetSize(240, 24)
        btn:SetPoint("TOP", f.listFrame, "TOP", 0, -(idx-1)*28)
        local mins     = math.floor((entry.info.timer or 0) / 60)
        local pLevel   = entry.info.playerLevel or 0
        local levelStr = pLevel > 0 and ("  |cFFFFD700Niv." .. pLevel .. "|r") or "  |cFF888888Niv.1|r"
        btn:SetText(string.format("%s  [%d min]", entry.info.name, mins) .. levelStr)

        -- Texture de sélection – SetColorTexture n'existe pas en 3.3.5,
        -- on utilise une texture blanche teintée via SetVertexColor + SetAlpha.
        local selTex = btn:CreateTexture(nil, "OVERLAY")
        selTex:SetAllPoints(btn)
        selTex:SetVertexColor(1, 0.82, 0)
        selTex:SetAlpha(0.25)
        selTex:Hide()

        -- Bordure de sélection (frame colorée autour du bouton)
        local selBorder = CreateFrame("Frame", nil, btn)
        selBorder:SetPoint("TOPLEFT",     btn, "TOPLEFT",     -2,  2)
        selBorder:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT",  2, -2)
        selBorder:SetFrameLevel(btn:GetFrameLevel() + 1)
        local borderTex = selBorder:CreateTexture(nil, "OVERLAY")
        borderTex:SetAllPoints(selBorder)
        borderTex:SetVertexColor(1, 0.82, 0)
        borderTex:SetAlpha(0.9)
        borderTex:Hide()

        btn.selTex    = selTex
        btn.borderTex = borderTex

        local entryId = entry.id
        btn:SetScript("OnClick", function()
            MK.selectedDungeon = entryId
            -- Réinitialise tous les boutons
            for _, b in ipairs(MK.dungeonButtons) do
                if b.selTex    then b.selTex:Hide()    end
                if b.borderTex then b.borderTex:Hide() end
                b:GetFontString():SetTextColor(1, 1, 1)
            end
            -- Marque le bouton sélectionné
            selTex:Show()
            borderTex:Show()
            btn:GetFontString():SetTextColor(1, 0.82, 0)  -- texte doré
            f.txtDungeon:SetText("|cFFFFD700" .. entry.info.name .. "|r")
            f.txtTimer:SetText(mins .. " Minutes")
        end)
        table.insert(MK.dungeonButtons, btn)
    end

    f:Show()
    StartPulse()
end

-- ─────────────────────────────────────────────────────────────
-- HANDLERS SERVEUR > CLIENT  (MK)
-- ─────────────────────────────────────────────────────────────
local MKClientHandlers = AIO.AddHandlers("MKClient", {})

function MKClientHandlers.OpenUI(player, data)
    if data then ShowViewMode(data) end
end

function MKClientHandlers.OpenSelectDungeon(player, data)
    ShowSelectMode(data)
end

function MKClientHandlers.KeystoneGranted(player, data)
    if not data then return end
    ClearDungeonButtons()
    ShowViewMode(data)
    print("|cFF00CCFF[Mythic+]|r Clé mythique obtenu : |cFFFFD700" ..
          (data.dungeon or "?") .. "|r  Niveau " .. (data.level or 1))
end

function MKClientHandlers.KeystoneUpgraded(player, data)
    if not data then return end
    ShowViewMode(data)
    print("|cFF00CCFF[Mythic+]|r Clé mythique > Niveau |cFFFFD700" .. (data.level or "?") .. "|r")
end

function MKClientHandlers.UpdateTimer(player, data)
    if not data then return end
    -- Resynchronise le ticker client avec la valeur serveur
    StartLiveTicker(data.remaining or 0)
    if data.bossKilled and data.totalBoss then
        local f = MK.frame
        if f and f:IsShown() then
            f.txtBosses:SetText(string.format("Bosses : %d / %d", data.bossKilled, data.totalBoss))
        end
    end
end

-- ─────────────────────────────────────────────────────────────
-- COUNTDOWN MK
--   • Ferme la frame MK
--   • Affiche uniquement l'overlay SystemTimer centré
-- ─────────────────────────────────────────────────────────────
function MKClientHandlers.StartCountdown(player, seconds)
    seconds = tonumber(seconds) or 10

    -- Cache la frame MK et vide le slot maintenant que le serveur a confirmé
    if MK.frame then
        if MK.frame.ClearSlot then MK.frame.ClearSlot() end
        MK.frame:Hide()
        StopPulse()
    end

    -- Overlay SystemTimer centré (chiffre + logo faction + sablier)
    ST_StartCountdown(seconds, "Mythic+ commence dans…", true)

    print("|cFF00CCFF[Mythic+]|r Le run commence dans " .. seconds .. " secondes !")
end

-- Le timer réel démarre
function MKClientHandlers.RunActivated(player, data)
    -- Ferme l'overlay countdown
    ST_HideOverlay()

    -- Réouvre la frame MK en mode run
    BuildFrame()
    local f = MK.frame
    if not f then return end

    -- Réinitialise l'affichage pour le mode run
    f.btnActivate:Hide()
    f.btnChangeDungeon:Hide()
    f.slotFrame:Hide()
    f.slotHint:Hide()
    f.circleFrame:Show()
    f.bgTex:SetVertexColor(1, 1, 1)

    -- Démarre le ticker live avec le timer du donjon
    local timerSec = data and data.timer or 0
    StartLiveTicker(timerSec)

    f:Show()
    StartPulse()
    print("|cFF00FF00[Mythic+]|r C'est parti ! Timer démarré.")
end

function MKClientHandlers.RunDepleted(player)
    StopLiveTicker()
    MK.liveRemaining = 0
    if MK.frame then
        MK.frame.txtLive:SetTextColor(C.RED[1], C.RED[2], C.RED[3])
        MK.frame.txtLive:SetText("|cFFFF3333⚠ DÉPLÉTÉ|r")
        MK.frame.bgTex:SetVertexColor(1, 0.4, 0.4)
    end
    print("|cFFFF3333[Mythic+] Timer expiré – run déplété.|r")
end

function MKClientHandlers.BossKilled(player, killed, total)
    if MK.frame and MK.frame:IsShown() then
        MK.frame.txtBosses:SetText(string.format("Bosses : %d / %d", killed, total))
        for i = 1, math.min(killed, 5) do
            SetNodeColor(i, C.GREEN)
        end
    end
    print(string.format("|cFF00FF00[Mythic+] Boss tué ! (%d/%d)|r", killed, total))
end

function MKClientHandlers.RunComplete(player, data)
    StopPulse()
    StopLiveTicker()
    ST_HideOverlay()
    local msg
    if data and data.inTime then
        msg = string.format(
            "|cFFFFD700Run terminé dans le timer ! +%d niv (%d)|r",
            data.upgradeBonus or 0, data.newLevel or 0)
    else
        msg = "|cFFFF8800Run terminé (déplété). Clé mythique perdu.|r"
    end
    if MK.frame then MK.frame:Hide() end
    print("|cFF00CCFF[Mythic+]|r " .. msg)
    StaticPopupDialogs["MK_RUN_COMPLETE"] = {
        text    = msg,
        button1 = "OK",
        timeout = 0, whileDead=false, hideOnEscape=true,
        OnAccept = function()
            if data and data.inTime then AIO.Handle("MKServer", "OpenUI") end
        end,
    }
    StaticPopup_Show("MK_RUN_COMPLETE")
end

function MKClientHandlers.NoActiveRun(player)
    print("|cFFAAAAAA[Mythic+] Aucun run actif dans cette instance.|r")
end

function MKClientHandlers.NoKeystone(player)
    print("|cFFFF4444[Mythic+] Vous n'avez pas de Clé mythique actif.|r")
end

function MKClientHandlers.Error(player, msg)
    print("|cFFFF4444[Mythic+] Erreur :|r " .. tostring(msg))
end

-- ─────────────────────────────────────────────────────────────
-- HANDLERS SERVEUR > CLIENT  (SystemTimer autonome)
-- ─────────────────────────────────────────────────────────────
local TimerHandlers = AIO.AddHandlers("SystemTimer", {})

function TimerHandlers.TimerStarted(player, duration, label, serverTime)
    ST_StartCountdown(tonumber(duration) or 9, label or "Timer", false)
end

function TimerHandlers.TimerPaused(player, elapsedSec)
    ST.active  = false
    ST.elapsed = tonumber(elapsedSec) or ST.elapsed
end

function TimerHandlers.TimerResumed(player, newStartTime)
    ST.active = true
end

function TimerHandlers.TimerStopped()
    ST_HideOverlay()
end

function TimerHandlers.Error(player, errMsg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[SystemTimer Erreur]|r " .. tostring(errMsg))
end

function TimerHandlers.StateSync(player, duration, startTime, label, paused, pausedAt)
    local now     = time()
    local elapsed = paused and (pausedAt - startTime) or (now - startTime)
    local remain  = math.max(0, (tonumber(duration) or 0) - elapsed)
    if remain > 0 then
        ST_StartCountdown(math.floor(remain), label or "Timer", false)
        ST.elapsed = ST.duration - remain
        if paused then ST.active = false end
    end
end

function TimerHandlers.NoTimer()
    ST.active = false
end

-- ─────────────────────────────────────────────────────────────
-- SLASH COMMANDS
-- ─────────────────────────────────────────────────────────────

SLASH_SYSTEMTIMER1 = "/timer"
SlashCmdList["SYSTEMTIMER"] = function(msg)
    msg = strtrim(msg or "")
    if msg == "stop" then
        ST.active   = false
        ST.finished = false
        if ST.frame then ST.frame:Hide() end
        AIO.Handle("SystemTimer", "StopTimer")
    elseif msg == "pause" then
        AIO.Handle("SystemTimer", "TogglePause")
    else
        local dur, lbl = msg:match("^(%d+)%s*(.*)")
        if dur then
            lbl = (lbl and lbl ~= "") and lbl or "Timer"
            AIO.Handle("SystemTimer", "StartTimer", tonumber(dur), lbl)
        end
    end
end

-- /mk
SLASH_MK1 = "/mk"
SlashCmdList["MK"] = function()
    if MK.liveActive and MK.frame then
        -- Run en cours : rouvre directement en mode run
        MK.frame:Show()
        StartPulse()
    elseif MK.frame and MK.data then
        MK.frame:Show()
        StartPulse()
    else
        AIO.Handle("MKServer", "OpenUI")
    end
end

-- ─────────────────────────────────────────────────────────────
-- INITIALISATION
-- ─────────────────────────────────────────────────────────────
local function OnLogin()
    ST_InitUI()
    AIO.Handle("SystemTimer", "RequestState")
    --print("|cFF00CCFF[Mythic+]|r Commande : Tapez /mk pour ouvrir l'interface Mythic.")
end

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self, event)
    OnLogin()
    self:UnregisterAllEvents()
end)

if IsLoggedIn and IsLoggedIn() then
    OnLogin()
end