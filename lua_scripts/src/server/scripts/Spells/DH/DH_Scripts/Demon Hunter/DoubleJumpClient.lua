local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local MyHandlers = AIO.AddHandlers("Glide_Client", {})
local CLASS_DEMON_HUNTER = 13

GlideSpace = CreateFrame("Frame")
GlideSpace:EnableKeyboard(true)
GlideSpace:SetScript("OnUpdate",function(self,elapsed) self:OnUpdate(elapsed) end)
GlideSpace.timer = 0
GlideSpace.groundTimer = 0
GlideSpace.currentBinding = nil

function GetElapsed(elapsed)
    GlideSpace.timer = GlideSpace.timer + elapsed
    return GlideSpace.timer
end

-- Vérifier si le joueur est un Demon Hunter
local function IsDemonHunter()
    local _, classFileName = UnitClass("player")
    local classID = select(3, UnitClass("player"))
    return classFileName == "DEMONHUNTER" or classID == CLASS_DEMON_HUNTER
end

function GlideSpace:OnUpdate(elapsed)
    -- Ne fonctionne que pour les Demon Hunters
    if not IsDemonHunter() then
        return
    end

    if IsFalling() then
        GlideSpace.groundTimer = 0
        local canGlide = GetElapsed(elapsed) > 0.2 and true or false
        if canGlide and GlideSpace.currentBinding ~= "GLIDE" then
            SetBindingSpell("SPACE", "Glide")
            GlideSpace.currentBinding = "GLIDE"
        end
    else
        GlideSpace.timer = 0
        -- On exige 0.2s de sol stable avant de repasser le bind sur JUMP,
        -- car IsFalling() peut osciller brièvement (petites bosses, escaliers,
        -- collisions custom) et déclenchait un SetBinding à chaque oscillation.
        GlideSpace.groundTimer = GlideSpace.groundTimer + elapsed
        if GlideSpace.groundTimer > 0.2 and GlideSpace.currentBinding ~= "JUMP" then
            SetBinding("SPACE", "JUMP")
            GlideSpace.currentBinding = "JUMP"
        end
    end
end
