local AIO = AIO or require("AIO")

local WhoAllHandlers = AIO.AddHandlers("WhoAllHandler", {})

function WhoAllHandlers.Request(player)
    if not player then
        return
    end

    local ok, rows = pcall(function() return player:GetFullWhoList() end)
    if not ok or type(rows) ~= "table" then
        rows = {}
    end

    AIO.Handle(player, "WhoAllHandler", "SetResults", rows)
end
