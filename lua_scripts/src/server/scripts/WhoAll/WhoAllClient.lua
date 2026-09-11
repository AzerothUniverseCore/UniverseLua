local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local WhoAllHandlers = AIO.AddHandlers("WhoAllHandler", {})

-- ============================================================================
-- Locale
-- ============================================================================

local UI_LOCALE = (GetLocale and GetLocale() == "enUS") and "enUS" or "frFR"
local Locales = {
    frFR = {
        TITLE = "Qui (vue étendue)",
        SEARCH_PLACEHOLDER = "Rechercher (nom ou zone)",
        COL_NAME = "Nom",
        COL_LEVEL = "Niv.",
        COL_CLASS = "Classe",
        COL_ZONE = "Zone",
        REFRESH = "Actualiser",
        OPEN_BUTTON = "Vue étendue",
        COUNT_ALL = "%d résultat(s)",
        COUNT_FILTERED = "%d résultat(s) sur %d",
        LOADING = "Chargement...",
        NONE = "Aucun résultat.",
    },
    enUS = {
        TITLE = "Who (Extended view)",
        SEARCH_PLACEHOLDER = "Search (name or zone)",
        COL_NAME = "Name",
        COL_LEVEL = "Lvl",
        COL_CLASS = "Class",
        COL_ZONE = "Zone",
        REFRESH = "Refresh",
        OPEN_BUTTON = "Extended view",
        COUNT_ALL = "%d result(s)",
        COUNT_FILTERED = "%d result(s) out of %d",
        LOADING = "Loading...",
        NONE = "No results.",
    },
}
local L = Locales[UI_LOCALE] or Locales.frFR

-- ============================================================================
-- Data
-- ============================================================================

local CLASS_TOKENS = {
    [1] = "WARRIOR", [2] = "PALADIN", [3] = "HUNTER", [4] = "ROGUE", [5] = "PRIEST",
    [6] = "DEATHKNIGHT", [7] = "SHAMAN", [8] = "MAGE", [9] = "WARLOCK", [11] = "DRUID",
}

local allResults = {}      -- raw rows as received from the server
local shownResults = {}    -- filtered + sorted view actually displayed
local searchText = ""
local sortKey = "name"
local sortAsc = true
local hasReceivedData = false

local function ClassInfo(classId)
    local token = CLASS_TOKENS[classId]
    if not token then
        return "?", 0.6, 0.6, 0.6
    end
    local displayName = (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[token]) or token
    local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[token]
    if color then
        return displayName, color.r, color.g, color.b
    end
    return displayName, 1, 1, 1
end

local function MatchesSearch(row, needle)
    if needle == "" then
        return true
    end
    local name = strlower(row.name or "")
    local zone = strlower(row.zoneName or "")
    return strfind(name, needle, 1, true) ~= nil or strfind(zone, needle, 1, true) ~= nil
end

local function CompareRows(a, b)
    local va, vb
    if sortKey == "level" then
        va, vb = a.level or 0, b.level or 0
    elseif sortKey == "class" then
        local classNameA = ClassInfo(a.class)
        local classNameB = ClassInfo(b.class)
        va, vb = classNameA, classNameB
    elseif sortKey == "zone" then
        va, vb = a.zoneName or "", b.zoneName or ""
    else
        va, vb = a.name or "", b.name or ""
    end
    if va == vb then
        return (a.name or "") < (b.name or "")
    end
    if sortAsc then
        return va < vb
    end
    return va > vb
end

local function RebuildShownResults()
    wipe(shownResults)
    local needle = strlower(searchText or "")
    for _, row in ipairs(allResults) do
        if MatchesSearch(row, needle) then
            tinsert(shownResults, row)
        end
    end
    sort(shownResults, CompareRows)
end

local botDropDown = CreateFrame("Frame", "WhoAllBotDropDown", UIParent, "UIDropDownMenuTemplate")
local botDropDownTargetName

local function BotDropDown_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    info.text = TARGET
    info.notCheckable = true
    info.func = function()
        if botDropDownTargetName then
            TargetUnit(botDropDownTargetName, 1)
        end
    end
    UIDropDownMenu_AddButton(info, level)

    info = UIDropDownMenu_CreateInfo()
    info.text = CANCEL
    info.notCheckable = true
    UIDropDownMenu_AddButton(info, level)
end
UIDropDownMenu_Initialize(botDropDown, BotDropDown_Initialize, "MENU")

local function ShowRowDropdown(rowData)
    if not rowData or not rowData.name or rowData.name == "" then
        return
    end
    if rowData.isPlayer then
        FriendsFrame_ShowDropdown(rowData.name, 1)
    else
        botDropDownTargetName = rowData.name
        ToggleDropDownMenu(1, nil, botDropDown, "cursor")
    end
end

-- ============================================================================
-- Frame
-- ============================================================================

local FRAME_W, FRAME_H = 1024, 512
local ROW_HEIGHT = 18
local NUM_ROWS = 15

local CONTENT_LEFT = 470
local CONTENT_RIGHT = 820
local CONTENT_W = CONTENT_RIGHT - CONTENT_LEFT   -- 350

local COL_NAME_X, COL_NAME_W = 0, 150
local COL_LEVEL_X, COL_LEVEL_W = 156, 34
local COL_CLASS_X, COL_CLASS_W = 196, 78
local COL_ZONE_X, COL_ZONE_W = 280, 70

local frame, rows, scrollFrame, searchBox, searchHint, countText

local function UpdateSearchHint()
    if not searchBox then
        return
    end
    if searchBox:GetText() == "" and not searchBox:HasFocus() then
        searchHint:Show()
    else
        searchHint:Hide()
    end
end

local function UpdateList()
    FauxScrollFrame_Update(scrollFrame, #shownResults, NUM_ROWS, ROW_HEIGHT)
    local offset = FauxScrollFrame_GetOffset(scrollFrame)

    for i = 1, NUM_ROWS do
        local row = rows[i]
        local dataIndex = offset + i
        local data = shownResults[dataIndex]

        if data then
            row.data = data
            row.name:SetText(data.name or "")
            row.level:SetText(tostring(data.level or ""))
            local className, r, g, b = ClassInfo(data.class)
            row.class:SetText(className)
            row.class:SetTextColor(r, g, b)
            row.zone:SetText(data.zoneName or "")
            if dataIndex % 2 == 0 then
                row.bg:Show()
            else
                row.bg:Hide()
            end
            row:Show()
        else
            row.data = nil
            row:Hide()
        end
    end

    if not hasReceivedData then
        countText:SetText(L.LOADING)
    elseif #shownResults == 0 then
        countText:SetText(L.NONE)
    elseif #shownResults == #allResults then
        countText:SetText(format(L.COUNT_ALL, #allResults))
    else
        countText:SetText(format(L.COUNT_FILTERED, #shownResults, #allResults))
    end
end

local function SetSort(key)
    if sortKey == key then
        sortAsc = not sortAsc
    else
        sortKey = key
        sortAsc = true
    end
    RebuildShownResults()
    UpdateList()
end

local function CreateHeaderButton(parent, text, x, w, key)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetPoint("TOPLEFT", x, 0)
    btn:SetSize(w, 16)

    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("LEFT", 2, 0)
    fs:SetText(text)
    fs:SetWordWrap(false)
    btn.text = fs

    btn:SetScript("OnClick", function() SetSort(key) end)
    btn:SetScript("OnEnter", function(self) self.text:SetTextColor(1, 0.82, 0) end)
    btn:SetScript("OnLeave", function(self) self.text:SetTextColor(1, 1, 1) end)

    return btn
end

local function CreateRow(parent, index)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(CONTENT_W, ROW_HEIGHT)
    row:SetPoint("TOPLEFT", 0, -((index - 1) * ROW_HEIGHT))
    row:RegisterForClicks("RightButtonUp")
    row:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            ShowRowDropdown(self.data)
        end
    end)

    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(row)
    bg:SetTexture(1, 1, 1, 0.10)
    row.bg = bg

    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    name:SetPoint("LEFT", COL_NAME_X, 0)
    name:SetWidth(COL_NAME_W - 6)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    row.name = name

    local level = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    level:SetPoint("LEFT", COL_LEVEL_X, 0)
    level:SetWidth(COL_LEVEL_W)
    level:SetJustifyH("CENTER")
    level:SetWordWrap(false)
    row.level = level

    local class = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    class:SetPoint("LEFT", COL_CLASS_X, 0)
    class:SetWidth(COL_CLASS_W - 6)
    class:SetJustifyH("LEFT")
    class:SetWordWrap(false)
    row.class = class

    local zone = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    zone:SetPoint("LEFT", COL_ZONE_X, 0)
    zone:SetWidth(COL_ZONE_W - 4)
    zone:SetJustifyH("LEFT")
    zone:SetWordWrap(false)
    row.zone = zone

    return row
end

local function CreateWhoAllFrame()
    frame = CreateFrame("Frame", "WhoAllFrame", UIParent)
    frame:SetSize(FRAME_W, FRAME_H)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetToplevel(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnMouseDown", function(self) self:Raise() end)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetTexture("Interface\\WhoAll\\textures\\WhoAll_UI.blp")
    frame.bg = bg

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOPLEFT", CONTENT_LEFT + CONTENT_W / 2, -46)
    title:SetText(L.TITLE)

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPLEFT", CONTENT_RIGHT + 45, -45)
    closeButton:SetScript("OnClick", function() frame:Hide() end)

    -- Search box (placeholder rendered INSIDE the box, standard convention, hidden while typing/focused)
    searchBox = CreateFrame("EditBox", "WhoAllSearchBox", frame, "InputBoxTemplate")
    searchBox:SetSize(CONTENT_W - 16, 20)
    searchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_LEFT + 8, -73)
    searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnTextChanged", function(self)
        searchText = self:GetText() or ""
        RebuildShownResults()
        UpdateList()
        UpdateSearchHint()
    end)
    searchBox:SetScript("OnEditFocusGained", UpdateSearchHint)
    searchBox:SetScript("OnEditFocusLost", UpdateSearchHint)
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    searchHint = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    searchHint:SetPoint("LEFT", 6, 0)
    searchHint:SetText(L.SEARCH_PLACEHOLDER)
    searchHint:SetWordWrap(false)

    -- Column headers
    local header = CreateFrame("Frame", nil, frame)
    header:SetSize(CONTENT_W, 16)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_LEFT, -118)
    CreateHeaderButton(header, L.COL_NAME, COL_NAME_X, COL_NAME_W, "name")
    CreateHeaderButton(header, L.COL_LEVEL, COL_LEVEL_X, COL_LEVEL_W, "level")
    CreateHeaderButton(header, L.COL_CLASS, COL_CLASS_X, COL_CLASS_W, "class")
    CreateHeaderButton(header, L.COL_ZONE, COL_ZONE_X, COL_ZONE_W, "zone")

    local headerLine = frame:CreateTexture(nil, "ARTWORK")
    headerLine:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -3)
    headerLine:SetSize(CONTENT_W, 1)
    headerLine:SetTexture(1, 0.82, 0, 0.6)

    -- Scroll list
    local listFrame = CreateFrame("Frame", nil, frame)
    listFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_LEFT, -143)
    listFrame:SetSize(CONTENT_W, NUM_ROWS * ROW_HEIGHT)

    scrollFrame = CreateFrame("ScrollFrame", "WhoAllScrollFrame", listFrame, "FauxScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, 0)
    scrollFrame:SetSize(CONTENT_W, NUM_ROWS * ROW_HEIGHT)
    scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, UpdateList)
    end)

    rows = {}
    for i = 1, NUM_ROWS do
        rows[i] = CreateRow(listFrame, i)
    end

    -- Footer (reste dans la zone sombre, au-dessus du bord bas brule/transparent de l'illustration)
    local footerLine = frame:CreateTexture(nil, "ARTWORK")
    footerLine:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_LEFT, -446)
    footerLine:SetSize(CONTENT_W, 1)
    footerLine:SetTexture(1, 1, 1, 0.15)

    countText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    countText:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_LEFT + 2, -466)
    countText:SetText(L.LOADING)
    countText:SetWordWrap(false)

    local refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refreshButton:SetSize(96, 22)
    refreshButton:SetPoint("TOPRIGHT", frame, "TOPLEFT", CONTENT_RIGHT, -450)
    refreshButton:SetText(L.REFRESH)
    refreshButton:SetScript("OnClick", function()
        AIO.Handle("WhoAllHandler", "Request")
    end)

    frame:Hide()
    tinsert(UISpecialFrames, "WhoAllFrame")

    UpdateSearchHint()
end

-- ============================================================================
-- AIO handlers
-- ============================================================================

function WhoAllHandlers.SetResults(player, data)
    allResults = type(data) == "table" and data or {}
    hasReceivedData = true
    RebuildShownResults()
    if frame then
        UpdateList()
    end
end

local function OpenWhoAll()
    if not frame then
        CreateWhoAllFrame()
    end

    hasReceivedData = false
    UpdateList()
    frame:Show()
    frame:Raise()
    AIO.Handle("WhoAllHandler", "Request")
end

local openButton = CreateFrame("Button", "WhoAllOpenButton", WhoFrame, "UIPanelButtonTemplate")
openButton:SetSize(120, 22)
openButton:SetPoint("TOP", WhoFrameGroupInviteButton, "BOTTOM", -90, 390)
openButton:SetText(L.OPEN_BUTTON)
openButton:SetScript("OnClick", OpenWhoAll)
