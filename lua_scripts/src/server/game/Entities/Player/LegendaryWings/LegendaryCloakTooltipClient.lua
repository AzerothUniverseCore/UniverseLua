local AIO = AIO or require("AIO");

if AIO.AddAddon() then
    return
end

local h_legendarywings = AIO.AddHandlers("h_legendarywings", {});

local IS_FRENCH = (GetLocale and GetLocale() == "frFR")

local HIDDEN_ITEMS = {
    [200015] = true,
    [200016] = true,
    [200017] = true,
    [200018] = true,
}

local EQUIP_PREFIX = (ITEM_SPELL_TRIGGER_ONEQUIP and ITEM_SPELL_TRIGGER_ONEQUIP:match("^(.-)%%s")) or "Equip: "

local CurrentHideState = false
local optionsCheckbox

--  Tooltip 
local function ProcessTooltip(tooltip)
    if not CurrentHideState or not tooltip or not tooltip.GetItem then
        return
    end

    local _, link = tooltip:GetItem()
    if not link then
        return
    end

    local itemID = tonumber(link:match("item:(%d+)"))
    if not itemID or not HIDDEN_ITEMS[itemID] then
        return
    end

    local name = tooltip:GetName()
    for i = 2, tooltip:NumLines() do
        local fs = _G[name .. "TextLeft" .. i]
        if fs then
            local text = fs:GetText()
            if text and text:find(EQUIP_PREFIX, 1, true) == 1 then
                fs:SetText("")
            end
        end
    end
    tooltip:Show()
end

GameTooltip:HookScript("OnTooltipSetItem", ProcessTooltip)
if ItemRefTooltip then
    ItemRefTooltip:HookScript("OnTooltipSetItem", ProcessTooltip)
end

--  Option Panel 
local panel = CreateFrame("Frame", "LegendaryCloakTooltipOptionsPanel", InterfaceOptionsFramePanelContainer)
panel.name = IS_FRENCH and "Ailes légendaires" or "Legendary Wings"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(IS_FRENCH and "Ailes légendaires [M+FULL]" or "Legendary Wings [M+FULL]")

local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetWidth(500)
subtitle:SetJustifyH("LEFT")
subtitle:SetText(IS_FRENCH
    and "Masque l'effet visuel des ailes légendaires."
    or "Hides the legendary wings' visual effect.")

optionsCheckbox = CreateFrame("CheckButton", "LegendaryCloakTooltipOptionsCheckbox", panel, "InterfaceOptionsCheckButtonTemplate")
optionsCheckbox:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -16)
_G[optionsCheckbox:GetName() .. "Text"]:SetText(IS_FRENCH
    and "Masquer l’effet du sort de la cape"
    or "Hide the effect of the cape's spell")

optionsCheckbox:SetScript("OnClick", function(self)
    local checked = self:GetChecked() and true or false
    AIO.Handle("h_legendarywings", "setState", checked and 1 or 0)
end)

panel.refresh = function()
    optionsCheckbox:SetChecked(CurrentHideState)
end

InterfaceOptions_AddCategory(panel)

function h_legendarywings.setState(player, hideValue)
    CurrentHideState = (hideValue == 1)
    if optionsCheckbox then
        optionsCheckbox:SetChecked(CurrentHideState)
    end
end

SLASH_LEGENDARYCLOAKTOOLTIP1 = "/hideailes"
SLASH_LEGENDARYCLOAKTOOLTIP2 = "/hidewings"
SlashCmdList["LEGENDARYCLOAKTOOLTIP"] = function()
    local newState = not CurrentHideState
    AIO.Handle("h_legendarywings", "setState", newState and 1 or 0)
    if IS_FRENCH then
        print("|cff4CFF00[Ailes légendaires]|r Effet du sort : " .. (newState and "|cffff0000masque|r" or "|cff00ff00affiche|r"))
    else
        print("|cff4CFF00[Legendary Wings]|r Spell effect: " .. (newState and "|cffff0000hidden|r" or "|cff00ff00shown|r"))
    end
end
