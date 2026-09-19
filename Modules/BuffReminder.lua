local addonName, SMhelper = ...

-- Buff reminder state module. UI controls use this small public API instead
-- of reading or writing SavedVariables directly.
SMhelper.Modules = SMhelper.Modules or {}
SMhelper.Modules.BuffReminder = SMhelper.Modules.BuffReminder or {}
local BuffReminder = SMhelper.Modules.BuffReminder
local enabled = true

-- Restore the saved option while preserving the enabled-by-default behavior.
function BuffReminder:Initialize(savedState)
    if type(savedState) == "table" and savedState.enabled ~= nil then
        enabled = not not savedState.enabled
    end
end

-- Return the normalized in-memory enabled state.
function BuffReminder:IsEnabled()
    return enabled
end

-- Normalize, update, and persist the enabled state.
function BuffReminder:SetEnabled(value)
    enabled = not not value
    SMhelperDB = SMhelperDB or {}
    SMhelperDB.buffReminder = SMhelperDB.buffReminder or {}
    SMhelperDB.buffReminder.enabled = enabled
end
