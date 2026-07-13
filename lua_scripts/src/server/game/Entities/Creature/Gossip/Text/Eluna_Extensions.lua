--[[
  math.round function
]]--
function math.round(nbr, nbr1)
  return math.floor(nbr*(10^nbr1))/(10^nbr1);
end

--[[
  Auto Calculate 32 Unique PhaseMask (2, 4, 8, 16, 32..)
]]--
function phaseCalc(nbr)
  return math.round(math.pow(2,nbr),1);
end

--[[
  function player:GossipSetText()
]]--
local SMSG_NPC_TEXT_UPDATE = 384
local MAX_GOSSIP_TEXT_OPTIONS = 8
 
function Player:GossipSetText(text, textID)
    local data = CreatePacket(SMSG_NPC_TEXT_UPDATE, 100);
    data:WriteULong(textID or 0x7FFFFFFF)
    for i = 1, MAX_GOSSIP_TEXT_OPTIONS do
        data:WriteFloat(0) -- Probability
        data:WriteString(text) -- Text
        data:WriteString(text) -- Text
        data:WriteULong(0) -- language
        data:WriteULong(0) -- emote
        data:WriteULong(0) -- emote
        data:WriteULong(0) -- emote
        data:WriteULong(0) -- emote
        data:WriteULong(0) -- emote
        data:WriteULong(0) -- emote
    end
    self:SendPacket(data)
end
-- player:GossipSetText("Testing "..math.random()) -- Will show as top text within the gossip menu
-- player:GossipSendMenu(0x7FFFFFFF, creature) -- Use 0x7FFFFFFF as the ManuId instead of the normal database based MenuId's