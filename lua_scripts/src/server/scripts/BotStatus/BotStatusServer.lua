local REALM_ID = GetRealmID()
local PUSH_INTERVAL_MS = 15000 -- aligned with UniverseBot's own CHECK_INTERVAL_SECONDS default (15s)

AuthDBExecute([[
    CREATE TABLE IF NOT EXISTS bot_status (
        realm_id INT UNSIGNED NOT NULL PRIMARY KEY,
        npcbots_count INT UNSIGNED NOT NULL DEFAULT 0,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB
]])

local function PushBotCount()
    local ok, count = pcall(GetNpcBotsCount)
    if not ok or type(count) ~= "number" then
        count = 0
    end

    AuthDBExecute(string.format(
        "INSERT INTO bot_status (realm_id, npcbots_count) VALUES (%d, %d) " ..
        "ON DUPLICATE KEY UPDATE npcbots_count = VALUES(npcbots_count)",
        REALM_ID, count
    ))
end

PushBotCount() -- push immediat au demarrage / .reload eluna, sans attendre le premier intervalle
CreateLuaEvent(PushBotCount, PUSH_INTERVAL_MS, 0) -- puis toutes les PUSH_INTERVAL_MS ms, indefiniment (0 = infini)
