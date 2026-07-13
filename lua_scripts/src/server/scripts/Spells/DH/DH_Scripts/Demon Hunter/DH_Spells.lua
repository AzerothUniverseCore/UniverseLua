local AIO = AIO or require("AIO")
local MyHandlers = AIO.AddHandlers("DH_Spells", {})


local function contains(table, val)
   for i=1,#table do
      if table[i] == val then 
         return true
      end
   end
   return false
end

-- ID = {Spell_ID-1, Spell_ID-2, Delay, Repeats, Chance} --
local Demon_Hunter_Spells = {
[1] = {100018, 98990, 150, 1, 101}, --Metamorphosis
[2] = {98896, 0, 500, 1, 101}, --Unbound_Chaos
[3] = {100023, 110000, 2050, 1, 101}, --Damned_EyE
[4] = {98871, 0, 2051, 1, 0}, --Demonic
[5] = {98861, 0, 150, 1, 0}, --Fel_Wounds
[6] = {201122, 0, 0, 0, 0}, --Immolation_aura
[7] = {100019, 0, 0, 0, 0}, --Eye_Beam_Animation
[8] = {100011, 0, 0, 0, 0}, --Eye_Beam_Effect
}

function Metamorphosis(event, delay, repeats, player)
player:ResetSpellCooldown( Demon_Hunter_Spells[1][1], true )
player:ResetSpellCooldown( Demon_Hunter_Spells[1][2], true ) 
 end
 
function Unbound_Chaos(event, delay, repeats, player)
player:RemoveAura(Demon_Hunter_Spells[2][1])
 end
 
function Damned_EyE(event, delay, repeats, player)
if not player:HasItem(500003)then
player:CastSpell(player, Demon_Hunter_Spells[3][1], false)
end

if player:HasItem(500003)then
player:CastSpell(player, Demon_Hunter_Spells[3][2], false)
end

if not player:HasAura(98999)then
player:DeMorph()
 end
 end
 
function Demonic(event, delay, repeats, player)
if player:HasSpell(98870) and not player:HasAura(98999)then
player:CastSpell(player, Demon_Hunter_Spells[4][1], false)
end
 end
 
function Fel_Wounds(event, delay, repeats, player)
if player:HasSpell(98860)then
player:CastSpell(player, Demon_Hunter_Spells[5][1], false)
end
 end

function Immolation_aura(event, delay, repeats, player)
player:CastSpell(player, Demon_Hunter_Spells[6][1], false)
 end

function Eye_Beam_Animation(event, delay, repeats, player)
player:CastSpell(player, Demon_Hunter_Spells[7][1], false)
 end
 
function Eye_Beam_Effect(event, delay, repeats, player)
player:CastSpell(player, Demon_Hunter_Spells[8][1], false)
 end
 
--Spells % to cast--
local function Spells_Percent_Chance(event, player, spell)
local chance = math.random(1, 100)

if spell:GetEntry() == 346123 and player:HasAura(Demon_Hunter_Spells[2][1]) and chance <= Demon_Hunter_Spells[2][5] then
player:RegisterEvent(Unbound_Chaos, Demon_Hunter_Spells[2][3], Demon_Hunter_Spells[2][4])
end

if spell:GetEntry() == 98994 and chance <= Demon_Hunter_Spells[1][5] then
player:RegisterEvent(Metamorphosis, Demon_Hunter_Spells[1][3], Demon_Hunter_Spells[1][4])
end

if spell:GetEntry() == 98996 or spell:GetEntry() == 98829 and chance <= Demon_Hunter_Spells[5][5] then
player:RegisterEvent(Fel_Wounds, Demon_Hunter_Spells[5][3], Demon_Hunter_Spells[5][4])
end
end

local function EyeBeamSequence(event, player, spell)
if spell:GetEntry() == 100011  then
player:RegisterEvent(Damned_EyE, 2050, 1)
player:RegisterEvent(Demonic, 2051, 1)
end

if spell:GetEntry() == 100018 or spell:GetEntry() == 98869 then
player:SetDisplayId(32755)
player:RegisterEvent(Eye_Beam_Animation, 390, 1)
end

if spell:GetEntry() == 100019  then
player:RegisterEvent(Eye_Beam_Effect, 1, 1)
end
end

local CoreSpells = {
9077, 9078, 208, 196, 201, 674, 131347, 98898, 90500,
178740, 100012, 99991, 100014, 100015, 99994, 346123, 162243,
98990, 100013, 193840, 99996, 99993, 100018, 98986, 210153, 201427, 98989,
100009, 100010, 100006, 100007, 203819, 90501, 196055
}

local DemonHunter = {13}
local function Learn_Skills(event, player)
if contains(DemonHunter, player:GetClass())then
for k = 1, #CoreSpells do
player:LearnSpell(CoreSpells[k]) 
--Start Level--
player:SetLevel(70)
player:LearnSpell(142790)
player:ModifyMoney(50000)
		end
	end
end

RegisterPlayerEvent(30, Learn_Skills)
RegisterPlayerEvent(5, Spells_Percent_Chance)
RegisterPlayerEvent(5, EyeBeamSequence)