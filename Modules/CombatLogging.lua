local _, SMhelper = ...

-- Automatic combat logging feature.
-- Starts and stops combat logging when entering or leaving
-- a selected loggable instance.

SMhelper.Modules = SMhelper.Modules or {}
SMhelper.Modules.CombatLogging = SMhelper.Modules.CombatLogging or {}

local CombatLogging = SMhelper.Modules.CombatLogging

-- Ordered trigger list rendered by the Auto-Log Triggers dropdown.
CombatLogging.Triggers = {
    { key = "mythicDungeon", text = "Mythic Dungeon" },
    { key = "mythicplus",    text = "Mythic+ Dungeon" },
    { key = "mythicRaid",    text = "Mythic Raid" },
    { key = "heroicRaid",    text = "Heroic Raid" },
    { key = "normalRaid",    text = "Normal Raid" },
    { key = "lfrRaid",       text = "Raid Finder" },
}

-- Fallback values used when a setting has never been changed by the user.
CombatLogging.Defaults = {
    mythicDungeon = true,
    mythicplus = true,
    mythicRaid = true,
    heroicRaid = true,
    normalRaid = false,
    lfrRaid = false,
    delaystop = false,
}

local config = {}
local eventFrame
local loggingStartedByUs = false
local pendingStop
local activeTriggerKey

local LOGGING_ENABLED_MESSAGE =
    "Log recording is enabled. Combat logs will be automatically started and stopped when entering or leaving selected instances."

-- Read a trigger value, falling back to its default.
local function triggerValue(key)
    local value = config[key]

    if value == nil then
        return CombatLogging.Defaults[key] == true
    end

    return value == true
end

-- Map the current instance to a trigger key.
-- Returns nil when the current instance is not supported.
local function resolveTriggerKey()
    local _, instanceType, difficultyID = GetInstanceInfo()

    if instanceType == "party" then
        if difficultyID == 23 then
            return "mythicDungeon"
        end

        if difficultyID == 8 then
            return "mythicplus"
        end
    elseif instanceType == "raid" then
        if difficultyID == 16 then
            return "mythicRaid"
        end

        if difficultyID == 15 then
            return "heroicRaid"
        end

        if difficultyID == 14 then
            return "normalRaid"
        end

        if difficultyID == 17 or difficultyID == 7 then
            return "lfrRaid"
        end
    end

    return nil
end

-- Print the combat logging notification in blue.
local function showLoggingEnabledMessage()
    DEFAULT_CHAT_FRAME:AddMessage(
        LOGGING_ENABLED_MESSAGE,
        0.25,
        0.65,
        1
    )
end

-- Forget any scheduled delayed stop.
local function cancelPendingStop()
    pendingStop = nil
end

-- Turn combat logging off only if this module turned it on.
local function stopLogging()
    if loggingStartedByUs and LoggingCombat() then
        LoggingCombat(false)
    end

    loggingStartedByUs = false
end

-- Stop combat logging after a 30-second delay.
-- This provides compatibility with Warcraft Recorder.
local function scheduleStop()
    -- Do not restart the timer if a delayed stop is already scheduled.
    if pendingStop then
        return
    end

    local token = {}
    pendingStop = token

    C_Timer.After(30, function()
        if pendingStop ~= token then
            return
        end

        pendingStop = nil
        stopLogging()
    end)
end

-- Evaluate the current instance and start or stop logging accordingly.
function CombatLogging:Recheck()
    -- Master switch is disabled.
    if config.enabled ~= true then
        activeTriggerKey = nil
        cancelPendingStop()
        stopLogging()
        return
    end

    local key = resolveTriggerKey()
    local shouldLog = key and triggerValue(key)

    if shouldLog then
        cancelPendingStop()

        -- Start logging if it is not already active.
        if not LoggingCombat() then
            LoggingCombat(true)
            loggingStartedByUs = true
        end

        -- Show the message only once when entering a selected instance.
        if activeTriggerKey ~= key then
            activeTriggerKey = key
            showLoggingEnabledMessage()
        end

        return
    end

    -- The character is no longer inside a selected instance.
    activeTriggerKey = nil

    -- Stop only the logging session started by this module.
    if loggingStartedByUs and LoggingCombat() then
        if triggerValue("delaystop") then
            scheduleStop()
        else
            cancelPendingStop()
            stopLogging()
        end
    else
        cancelPendingStop()
        loggingStartedByUs = false
    end
end

-- Load saved options and begin listening for instance changes.
function CombatLogging:Initialize(savedState)
    if type(savedState) == "table" then
        config = savedState
    else
        config = {}
    end

    SMhelperDB = SMhelperDB or {}
    SMhelperDB.combatLogging = config

    if not eventFrame then
        eventFrame = CreateFrame("Frame")

        eventFrame:SetScript("OnEvent", function()
            CombatLogging:Recheck()
        end)
    end

    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    eventFrame:RegisterEvent("CHALLENGE_MODE_START")
    eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")

    self:Recheck()
end

-- Return the live configuration table shared with SMhelperDB.
function CombatLogging:GetConfig()
    return config
end

-- Master switch helpers.
function CombatLogging:IsEnabled()
    return config.enabled == true
end

function CombatLogging:SetEnabled(value)
    config.enabled = value and true or nil
    self:Recheck()
end

-- Per-trigger helpers.
function CombatLogging:GetTrigger(key)
    return triggerValue(key)
end

function CombatLogging:SetTrigger(key, value)
    config[key] = value and true or false
    self:Recheck()
end

-- Warcraft Recorder compatibility helpers.
function CombatLogging:GetDelayStop()
    return triggerValue("delaystop")
end

function CombatLogging:SetDelayStop(value)
    config.delaystop = value and true or false
    self:Recheck()
end

-- Return a comma-separated list of enabled triggers for the dropdown label.
function CombatLogging:GetTriggerSummary()
    local parts = {}

    for _, item in ipairs(self.Triggers) do
        if triggerValue(item.key) then
            parts[#parts + 1] = item.text
        end
    end

    if #parts == 0 then
        return "None"
    end

    return table.concat(parts, ", ")
end