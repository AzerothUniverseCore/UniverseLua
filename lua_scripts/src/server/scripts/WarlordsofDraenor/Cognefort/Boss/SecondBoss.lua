local NPC_MARGTHAR_ID = 5100124

local SPELL_FIRE_SHIELD = 42945
local SPELL_ELEMENTAL_TOTEM = 2894
local SPELL_RAIN_OF_FIRE = 49518
local SPELL_FLAME_TONGUE_WEAPON = 61657
local SPELL_FIRE_BREATH = 132165

function MiniBoss_OnSpawn(event, creature)
    creature:RegisterEvent(MiniBoss_CastFireShield, 1000, 0)
    creature:RegisterEvent(MiniBoss_CastElementalTotem, 10000, 0)
    creature:RegisterEvent(MiniBoss_CastRainOfFire, 15000, 0)
    creature:RegisterEvent(MiniBoss_CastElementalTotem, 18000, 0)
    creature:RegisterEvent(MiniBoss_CastFlameTongueWeapon, 25000, 0)
    creature:RegisterEvent(MiniBoss_CastElementalTotem, 28000, 0)
    creature:RegisterEvent(MiniBoss_CastFireBreath, 35000, 0)
    creature:RegisterEvent(MiniBoss_CastElementalTotem, 38000, 0)
end

function MiniBoss_CastFireShield(event, delay, pCall, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_FIRE_SHIELD)
    end
end

function MiniBoss_CastElementalTotem(event, delay, pCall, creature)
    creature:CastSpell(creature, SPELL_ELEMENTAL_TOTEM)
end

function MiniBoss_CastRainOfFire(event, delay, pCall, creature)
    creature:CastSpell(creature, SPELL_RAIN_OF_FIRE)
end

function MiniBoss_CastFlameTongueWeapon(event, delay, pCall, creature)
    creature:CastSpell(creature, SPELL_FLAME_TONGUE_WEAPON)
end

function MiniBoss_CastFireBreath(event, delay, pCall, creature)
    creature:CastSpell(creature, SPELL_FIRE_BREATH)
end

function MargtharAI_Register()
    RegisterCreatureEvent(NPC_MARGTHAR_ID, 1, MargtharAI_OnEnterCombat)
end

function MargtharAI_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Vous n'échapperez pas à ma vengeance !", 0)
    -- Vous pouvez ajouter ici du code spécifique pour le déclenchement du combat
    -- Par exemple : déclencher des emotes, appliquer des effets spéciaux, etc.
end

RegisterCreatureEvent(NPC_MARGTHAR_ID, 5, MiniBoss_OnSpawn)
MargtharAI_Register()
