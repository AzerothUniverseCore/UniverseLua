local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local ROW_COUNT = 12
local NetherilFrame = nil

local BACKGROUND_TEXTURE = "Interface\\NetherilUI\\NetherilUI"

local function NotifyServerState(isOpen)
    AIO.Handle("NetherilUI", "SetUIState", isOpen)
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
    frame:SetScript("OnHide", function() NotifyServerState(false) end)
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
    local yOffset = -115
    for i = 1, ROW_COUNT do
        local row = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 58, yOffset)
        row:SetPoint("RIGHT", frame, "RIGHT", -58, 0)
        row:SetJustifyH("LEFT")
        frame.rows[i] = row
        yOffset = yOffset - 21
    end

    frame.summary = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.summary:SetPoint("BOTTOM", frame, "BOTTOM", 0, 47)

    frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.status:SetPoint("BOTTOM", frame, "BOTTOM", 0, 40)

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
        local entry = data.rows and data.rows[i]
        if fs and entry then
            local color = entry.done and "|cff00ff00" or "|cff00ccff"
            fs:SetText(string.format("%s  %s%d/%d|r", entry.label, color, entry.counter, entry.quantity))
        elseif fs then
            fs:SetText("")
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
