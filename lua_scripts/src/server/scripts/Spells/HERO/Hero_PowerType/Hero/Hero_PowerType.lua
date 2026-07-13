local AIO = AIO or require("AIO")

local customPowerTypes = {}                    
  
--Hero--
customPowerTypes["Volonté"] =                    
{
    classesString = {
        frFR = "Héros", -- Français
        enUS = "Hero"       -- Anglais
    },
	classesID = {16},
    defaultMax = 500000,
    id = 204,
    powerString = "Volonté",
    color = { r = 255, g = 255, b = 255 },
    consumingSpells = {381700, 381701},
    passiveUpdate = {                                                                   
                        interval = 500,                                                 
                        UpdateFunc = function(event, delay, repeats, player)        
                            local regen = 0
                            if (player:IsInCombat()) then
                                regen = 0
							else
								regen = 0
                            end
                            local prevPower = player:GetPower(4)
                            local newPower = prevPower + (regen * (delay / 5000))
                            local maxPower = player:GetMaxPower(4)
                            
                            if (newPower < 0) then
                                newPower = 0
                            elseif ( newPower > maxPower ) then
                                newPower = maxPower
                            end
                            
                            player:SetPower(newPower, 4)
                        end
                    };
}

if AIO.AddAddon() then
    local function OnLogin(event, player)
        local playerclass = player:GetClass()
        
        for powerToken, powerTable in pairs(customPowerTypes) do
            for _, class in pairs(powerTable.classesID) do
                if (playerclass == class) then
                    player:SetMaxPower(4, powerTable.defaultMax)
                    player:SetMaxPower(0, 0)
                    
                    if (powerTable.passiveUpdate ~= nil) then
                        player:RegisterEvent(powerTable.passiveUpdate.UpdateFunc, powerTable.passiveUpdate.interval, 0)
                    end
                end
            end
        end
        
    end
    
    local function OnLevelChange(event, player, oldLevel)
        local playerclass = player:GetClass()
        for _, powerTable in pairs(customPowerTypes) do
            for _, class in pairs(powerTable.classesID) do
                if (playerclass == class) then
                    if (powerTable.defaultMax ~= nil) then
                        player:SetMaxPower(4, powerTable.defaultMax)
                    end
                end
            end
        end
    end
    
    RegisterPlayerEvent( 3, OnLogin )
    RegisterPlayerEvent( 13, OnLevelChange )
    return
end
 
 
HAPPINESS_COST = "%d Happiness";
local myclass = UnitClass("player")
 
for customToken, powerTable in pairs(customPowerTypes) do
    _G[customToken] = powerTable.powerString
    PowerBarColor[customToken] = powerTable.color
    PowerBarColor[powerTable.id] = PowerBarColor[customToken]
end
 
 
-- Hook official Blizzard UI function GetSpellInfo(spellId or spellName or spellLink), to fix custom powerType return, if applicable
local origGetSpellInfo = GetSpellInfo;
GetSpellInfo = function(...)
    local spellID = ...;
    local ok, name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = pcall(origGetSpellInfo, ...)
    if not ok then
        return nil
    end
    
    -- if a spellName was passed as argument, jump through some hoops to get the spellID
    if (type(spellID) == "string") then
        local spellLink = GetSpellLink(spellID)
        if (spellLink ~= nil) then
            spellID = tonumber(strmatch(spellLink, "^\124c%x+\124Hspell:(%d+)\124h%[.*%]"))
        end
    end
    
    if (spellID ~= nil) then
        for _, powerTable in pairs(customPowerTypes) do
            local earlyReturn = false
            for _, id in pairs(powerTable.consumingSpells) do
                if (id == spellID) then
                    powerType = powerTable.id
                    break
                end
            end
            if earlyReturn then break end
        end
    end
    
    return name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange; 
end
 
-- Hook official Blizzard UI function UnitPower(unit, powerType), to add custom value return, if applicable
local origUnitPower = UnitPower;
UnitPower = function(...)
    local unit, powerType = ...;
    
    if (UnitIsPlayer(unit)) then
        for customToken, powerTable in pairs(customPowerTypes) do
            if (powerTable.id == powerType) then
                return origUnitPower(unit, 4)
            end
        end
    end
    
    return origUnitPower(...); 
end
 
-- Hook official Blizzard UI function UnitPowerMax(unit, powerType), to add custom value return, if applicable
local origUnitPowerMax = UnitPowerMax;
UnitPowerMax = function(...)
    local unit, powerType = ...;
    
    if (UnitIsPlayer(unit)) then
        for customToken, powerTable in pairs(customPowerTypes) do
            if (powerTable.id == powerType) then
                return origUnitPowerMax(unit, 4)
            end
        end
    end
    
    return origUnitPowerMax(...); 
end
 
-- Hook official Blizzard UI function UnitPowerType(unit), to add custom powerType and powerToken return, if applicable
local origUnitPowerType = UnitPowerType;
UnitPowerType = function(...)
    local unit = ...;
    
    local unitClass = UnitClass(unit)
    for customToken, powerTable in pairs(customPowerTypes) do
        for _, class in pairs(powerTable.classesString) do
            if (unitClass == class) then
                local powerType, _, altR, altG, altB = origUnitPowerType(unit)
                powerType = powerTable.id
                return powerType, customToken, altR, altG, altB
            end
        end
    end
    
    return origUnitPowerType(...); 
end
 
-- Overwrite official Blizzard UI function UnitFrameManaBar_UpdateType(manaBar)
function UnitFrameManaBar_UpdateType(manaBar)
    if ( not manaBar ) then
        return;
    end
    local unitFrame = manaBar:GetParent();
    local powerType, powerToken, altR, altG, altB = UnitPowerType(manaBar.unit);
    local prefix = _G[powerToken];
    local info = PowerBarColor[powerToken];
    if ( info ) then
        if ( not manaBar.lockColor ) then
            manaBar:SetStatusBarColor(info.r, info.g, info.b);
        end
    else
        if ( not altR) then
            info = PowerBarColor[powerType] or PowerBarColor["MANA"];
        else
            if ( not manaBar.lockColor ) then
                manaBar:SetStatusBarColor(altR, altG, altB);
            end
        end
    end
    
    if (customPowerTypes[powerToken] ~= nil) then
        powerType = 4;
    end
    manaBar.powerType = powerType;
    
    if ( not unitFrame.noTextPrefix ) then
        SetTextStatusBarTextPrefix(manaBar, prefix);
    end
    TextStatusBar_UpdateTextString(manaBar);
 
    if ( manaBar.unit ~= "pet" or powerToken == "HAPPINESS" ) then
        if ( unitFrame:GetName() == "PlayerFrame" ) then
            manaBar.tooltipTitle = prefix;
            manaBar.tooltipText = _G["NEWBIE_TOOLTIP_MANABAR_"..powerType];
        else
            manaBar.tooltipTitle = nil;
            manaBar.tooltipText = nil;
        end
    end
end
 
local function CustomPrimaryResourceTooltip_OnShow(self, ...)
    local _, _, spellID = GameTooltip:GetSpell()
    if (spellID == nil) then
        return
    end
    
    local numLines = GameTooltip:NumLines();
    local i = 1;
    
    for currentLine=1, numLines do
        local line = {};
        local left = _G["GameTooltipTextLeft"..currentLine];
        if ( left ) then
            line.w = true;
            line.leftR, line.leftG, line.leftB = left:GetTextColor();
            local t = left:GetText();
            
            local happinessCost = strmatch(t, "(%d+) Happiness")
            if (happinessCost ~= nil) then
                local _, powerToken = UnitPowerType("player")
                left:SetText(happinessCost.." ".._G[powerToken])
            end
            
            line.left = t;
        end
        i = i + 1;
    end
    
    GameTooltip:Show();
end
 
 
for powerToken, powerTable in pairs(customPowerTypes) do
    for _, class in pairs(powerTable.classesString) do
        if (myclass == class) then
            UnitFrameManaBar_UpdateType(PlayerFrameManaBar)
            AlternatePowerBar_UpdatePowerType(PlayerFrameAlternateManaBar)
        end
    end
end
 
GameTooltip:HookScript( "OnShow", CustomPrimaryResourceTooltip_OnShow )
