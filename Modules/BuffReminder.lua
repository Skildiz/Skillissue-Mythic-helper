local addonName, SMhelper = ...

-- saved state for the buff reminder feature
SMhelper.Modules = SMhelper.Modules or {}
SMhelper.Modules.BuffReminder = SMhelper.Modules.BuffReminder or {}
local BuffReminder = SMhelper.Modules.BuffReminder
local enabled = true

-- load the saved option
function BuffReminder:Initialize(savedState)
    if type(savedState) == "table" and savedState.enabled ~= nil then
        enabled = not not savedState.enabled
    end
end

-- return the current option
function BuffReminder:IsEnabled()
    return enabled
end

-- update and save the option
function BuffReminder:SetEnabled(value)
    enabled = not not value
    SMhelperDB = SMhelperDB or {}
    SMhelperDB.buffReminder = SMhelperDB.buffReminder or {}
    SMhelperDB.buffReminder.enabled = enabled
end
