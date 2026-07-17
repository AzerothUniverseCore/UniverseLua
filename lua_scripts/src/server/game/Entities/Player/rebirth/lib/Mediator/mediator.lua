--[[
    mediator.lua

    A lightweight mediator pattern implementation with:
    - Singleton pattern for global access
    - Named parameters for improved readability
    - Multiple return values with default fallbacks
    - Recursion guard to prevent stack overflow on re-entrant events
    - Safe unpack using explicit length to handle userdata in defaults tables

    @module Mediator
    @author iThorgrim
    @license AGL v3
    @version 2.1

    Fix v2.0: replaced global `unpack` with `table.unpack` for Lua 5.2+ compatibility
    (Eluna TrinityCore 3.3.5a runs on Lua 5.2 where unpack global no longer exists)

    Fix v2.1:
    - Added per-event recursion guard (_executing table).
      If a Mediator.On("X") call triggers a callback that calls Mediator.On("X") again,
      the re-entrant call is skipped and defaults are returned instead of stack overflowing.
    - Replaced `#defaults` length operator with explicit counting via rawlen-safe loop.
      The `#` operator is unreliable on tables containing userdata values (Eluna objects
      like Player, Creature, etc.) because their __len metamethod may not be defined.
      This caused `table.unpack(defaults)` to unpack 0 values even when defaults had entries,
      leading to nil reassignments of player/paragon/apply in hook callbacks.
    - Error in callback now prints a warning instead of calling error(), which could
      itself cause a stack overflow if caught by a parent pcall that retries.
]]

local Object = Object or require("classic")

---@class Mediator
---@field private events table<string, table> Registered callbacks by event name
---@field private _executing table<string, boolean> Recursion guard per event
local Mediator = Object:extend()

-- Singleton instance
local Instance = nil

---
--- Initializes a new Mediator instance.
---
--- @return Mediator
---
function Mediator:new()
    self.events    = {}
    self._executing = {}
end

---
--- Gets the singleton instance of the Mediator.
--- Creates the instance on first call.
---
--- @return Mediator The singleton instance
---
function Mediator.GetInstance()
    if not Instance then
        Instance = Mediator()
    end
    return Instance
end

---
--- Registers a callback function for a specific event.
---
--- @param eventName string The event name
--- @param callback function The callback function to execute
--- @return void
---
function Mediator:Register(eventName, callback)
    if not self.events[eventName] then
        self.events[eventName] = {}
    end
    table.insert(self.events[eventName], callback)
end

-- ============================================================================
-- SAFE UNPACK HELPER
-- ============================================================================

---
--- Safely counts the number of entries in a table even when it contains
--- userdata values (Eluna objects). The # operator is unreliable in this
--- case because userdata may define __len metamethods that return unexpected
--- values or because the table has userdata holes that confuse the length heuristic.
---
--- This function counts entries by iterating from index 1 until the first nil.
---
--- @param t table The table to count
--- @return number The number of consecutive non-nil entries starting at index 1
---
local function safeLen(t)
    if type(t) ~= "table" then
        return 0
    end
    local n = 0
    while t[n + 1] ~= nil do
        n = n + 1
    end
    return n
end

---
--- Safely unpacks a table using safeLen instead of the # operator.
---
--- @param t table The table to unpack
--- @return ... The unpacked values
---
local function safeUnpack(t)
    local n = safeLen(t)
    if n == 0 then
        return nil
    end
    return table.unpack(t, 1, n)
end

-- ============================================================================
-- CORE
-- ============================================================================

---
--- Triggers an event and collects return values from registered callbacks.
---
--- If the same event is triggered re-entrantly (i.e. a callback for event X
--- calls Mediator.On("X") again), the inner call is skipped and defaults are
--- returned immediately to prevent a stack overflow.
---
--- @param eventName string The event name to trigger
--- @param params table Named parameters with optional: arguments, defaults
--- @return ... Merged return values
---
function Mediator:On(eventName, params)
    params = params or {}

    local args     = params.arguments or {}
    local defaults = params.defaults  or {}

    -- Recursion guard: if this event is already being executed, return defaults
    if self._executing[eventName] then
        return safeUnpack(defaults)
    end

    -- No callbacks registered — return defaults immediately
    if not self.events[eventName] then
        return safeUnpack(defaults)
    end

    -- Mark event as executing to block re-entrant calls
    self._executing[eventName] = true

    local allReturns = {}
    local argCount   = safeLen(args)

    -- Execute all callbacks
    for _, callback in ipairs(self.events[eventName]) do
        local results = { pcall(callback, table.unpack(args, 1, argCount)) }
        local success = table.remove(results, 1)

        if success then
            table.insert(allReturns, results)
        else
            -- Print warning instead of calling error() to avoid triggering a
            -- parent pcall that might retry and cause another stack overflow
            -- print("[Mediator] Error in callback for '" .. eventName .. "': " .. tostring(results[1]))
        end
    end

    -- Unmark event as executing
    self._executing[eventName] = false

    -- Return merged results or defaults
    if #allReturns > 0 then
        return self:_MergeReturns(allReturns, defaults)
    end

    return safeUnpack(defaults)
end

---
--- Merges return values from multiple callbacks.
--- For each position, uses the first non-nil value found.
--- Falls back to defaults for positions with no non-nil callback return.
---
--- @param allReturns table Array of return value arrays
--- @param defaults table Array of default values
--- @return ... Merged return values
--- @private
---
function Mediator:_MergeReturns(allReturns, defaults)
    local defaultCount = safeLen(defaults)
    local maxCount     = defaultCount

    -- Find maximum return count across all callbacks
    for _, returns in ipairs(allReturns) do
        local n = safeLen(returns)
        if n > maxCount then
            maxCount = n
        end
    end

    if maxCount == 0 then
        return nil
    end

    local merged = {}

    for i = 1, maxCount do
        local value = nil

        -- First non-nil value from any callback wins
        for _, returns in ipairs(allReturns) do
            if returns[i] ~= nil then
                value = returns[i]
                break
            end
        end

        -- Fallback to default
        if value == nil and i <= defaultCount and defaults[i] ~= nil then
            value = defaults[i]
        end

        merged[i] = value
    end

    return table.unpack(merged, 1, maxCount)
end

---
--- Unpacks default values safely.
---
--- @param defaults table Array of default values
--- @return ... Unpacked values or nil
--- @private
---
function Mediator:_UnpackDefaults(defaults)
    return safeUnpack(defaults)
end

---
--- Clears callbacks for a specific event or all events.
---
--- @param eventName string|nil Event name to clear, or nil to clear all
--- @return void
---
function Mediator:Clear(eventName)
    if eventName then
        self.events[eventName]     = nil
        self._executing[eventName] = nil
    else
        self.events     = {}
        self._executing = {}
    end
end

---
--- Gets the count of registered callbacks for an event.
---
--- @param eventName string|nil Event name, or nil for total count
--- @return number Callback count
---
function Mediator:GetCallbackCount(eventName)
    if eventName then
        return self.events[eventName] and #self.events[eventName] or 0
    else
        local total = 0
        for _, callbacks in pairs(self.events) do
            total = total + #callbacks
        end
        return total
    end
end

-- =============================================================================
-- GLOBAL API
-- =============================================================================

local mediatorInstance = Mediator.GetInstance()

---
--- Global Mediator API for convenient access.
---
_G.Mediator = {
    ---
    --- Triggers an event with named parameters.
    ---
    --- @param eventName string The event name
    --- @param params table Named parameters with optional: arguments, defaults
    --- @return ... Return values
    ---
    On = function(eventName, params)
        return mediatorInstance:On(eventName, params)
    end,

    ---
    --- Registers a callback.
    ---
    --- @param eventName string The event name
    --- @param callback function The callback function
    --- @return void
    ---
    Register = function(eventName, callback)
        return mediatorInstance:Register(eventName, callback)
    end,

    ---
    --- Clears callbacks for an event.
    ---
    --- @param eventName string|nil Event to clear, or nil for all
    --- @return void
    ---
    Clear = function(eventName)
        return mediatorInstance:Clear(eventName)
    end,

    ---
    --- Gets callback count for an event.
    ---
    --- @param eventName string|nil Event name, or nil for total
    --- @return number Callback count
    ---
    GetCallbackCount = function(eventName)
        return mediatorInstance:GetCallbackCount(eventName)
    end
}

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

---
--- Registers a mediator callback.
---
--- @param eventName string The event name
--- @param callback function|nil The callback function (optional)
--- @return function|void Registration function or void
---
function RegisterMediatorEvent(eventName, callback)
    if type(callback) == "function" then
        mediatorInstance:Register(eventName, callback)
    else
        return function(cb)
            mediatorInstance:Register(eventName, cb)
        end
    end
end

return Mediator
