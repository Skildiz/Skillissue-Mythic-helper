local _, SMhelper = ...

-- Automatic combat logging module. It maps the current instance difficulty
-- to a user-configurable trigger and tracks whether this addon started logging,
-- preventing it from stopping a logging session owned by another addon.
SMhelper.Modules = SMhelper.Modules or {}
SMhelper.Modules.CombatLogging = SMhelper.Modules.CombatLogging or {}

local CombatLogging = SMhelper.Modules.CombatLogging
local Config = SMhelper.Config
local Constants = Config.CombatLogging
local Difficulty = Constants.DIFFICULTY
local TriggerKeys = Constants.TRIGGER_KEYS
local InstanceTypes = Constants.INSTANCE_TYPES

-- Ordered definitions used by both settings storage and the trigger dropdown.
CombatLogging.Triggers = Constants.TRIGGERS

-- Fallback values are read without eagerly writing every option to SavedVariables.
CombatLogging.Defaults = Constants.DEFAULTS

local settings = {}
local eventFrame
local loggingStartedByAddon = false
local pendingStopToken
local activeTriggerKey

local function IsTriggerEnabled(triggerKey)
    local configuredValue = settings[triggerKey]

    if configuredValue == nil then
        return CombatLogging.Defaults[triggerKey] == true
    end

    return configuredValue == true
end

-- Convert supported five-player difficulty IDs into configuration keys.
local function ResolvePartyTrigger(difficultyId)
    if difficultyId == Difficulty.MYTHIC_DUNGEON then
        return TriggerKeys.MYTHIC_DUNGEON
    end

    if difficultyId == Difficulty.MYTHIC_PLUS then
        return TriggerKeys.MYTHIC_PLUS
    end

    return nil
end

-- Convert supported raid difficulty IDs into configuration keys.
local function ResolveRaidTrigger(difficultyId)
    if difficultyId == Difficulty.MYTHIC_RAID then
        return TriggerKeys.MYTHIC_RAID
    end

    if difficultyId == Difficulty.HEROIC_RAID then
        return TriggerKeys.HEROIC_RAID
    end

    if difficultyId == Difficulty.NORMAL_RAID then
        return TriggerKeys.NORMAL_RAID
    end

    if difficultyId == Difficulty.RAID_FINDER
        or difficultyId == Difficulty.LEGACY_RAID_FINDER then
        return TriggerKeys.RAID_FINDER
    end

    return nil
end

-- Return the trigger key for the current instance, or nil when unsupported.
local function ResolveCurrentTrigger()
    local _, instanceType, difficultyId = GetInstanceInfo()

    if instanceType == InstanceTypes.PARTY then
        return ResolvePartyTrigger(difficultyId)
    end

    if instanceType == InstanceTypes.RAID then
        return ResolveRaidTrigger(difficultyId)
    end

    return nil
end

local function ShowLoggingEnabledMessage()
    DEFAULT_CHAT_FRAME:AddMessage(
        Constants.ENABLED_MESSAGE,
        unpack(Constants.MESSAGE_COLOR)
    )
end

local function CancelPendingStop()
    pendingStopToken = nil
end

-- Stop logging only when this module started the active logging session.
local function StopAddonLogging()
    if loggingStartedByAddon and LoggingCombat() then
        LoggingCombat(false)
    end

    loggingStartedByAddon = false
end

-- Use a token so canceled timers cannot stop a newer logging session.
local function ScheduleDelayedStop()
    if pendingStopToken then
        return
    end

    local stopToken = {}
    pendingStopToken = stopToken

    C_Timer.After(Constants.DELAYED_STOP_SECONDS, function()
        if pendingStopToken ~= stopToken then
            return
        end

        pendingStopToken = nil
        StopAddonLogging()
    end)
end

-- Start logging and notify once when entering a newly matched trigger.
local function StartLoggingForTrigger(triggerKey)
    CancelPendingStop()

    if not LoggingCombat() then
        LoggingCombat(true)
        loggingStartedByAddon = true
    end

    if activeTriggerKey ~= triggerKey then
        activeTriggerKey = triggerKey
        ShowLoggingEnabledMessage()
    end
end

-- Stop immediately or schedule the compatibility delay after leaving.
local function StopLoggingAfterLeavingInstance()
    activeTriggerKey = nil

    if not loggingStartedByAddon or not LoggingCombat() then
        CancelPendingStop()
        loggingStartedByAddon = false
        return
    end

    if IsTriggerEnabled(TriggerKeys.DELAYED_STOP) then
        ScheduleDelayedStop()
    else
        CancelPendingStop()
        StopAddonLogging()
    end
end

local function DisableAutomaticLogging()
    activeTriggerKey = nil
    CancelPendingStop()
    StopAddonLogging()
end

-- Create the invisible frame that funnels instance changes into one state check.
local function CreateEventFrame()
    local frame = CreateFrame(Config.UI.FrameTypes.FRAME)
    frame:SetScript(Config.UI.Scripts.EVENT, function()
        CombatLogging:RefreshLoggingState()
    end)
    return frame
end

local function RegisterInstanceEvents(frame)
    frame:RegisterEvent(Config.Events.PLAYER_ENTERING_WORLD)
    frame:RegisterEvent(Config.Events.ZONE_CHANGED_NEW_AREA)
    frame:RegisterEvent(Config.Events.CHALLENGE_MODE_START)
    frame:RegisterEvent(Config.Events.CHALLENGE_MODE_COMPLETED)
end

-- Reconcile logging with the master switch, current instance, and trigger settings.
function CombatLogging:RefreshLoggingState()
    if settings.enabled ~= true then
        DisableAutomaticLogging()
        return
    end

    local triggerKey = ResolveCurrentTrigger()

    if triggerKey and IsTriggerEnabled(triggerKey) then
        StartLoggingForTrigger(triggerKey)
        return
    end

    StopLoggingAfterLeavingInstance()
end

-- Restore settings, register instance events once, and evaluate current state.
function CombatLogging:Initialize(savedState)
    settings = type(savedState) == "table" and savedState or {}

    SMhelperDB = SMhelperDB or {}
    SMhelperDB.combatLogging = settings

    if not eventFrame then
        eventFrame = CreateEventFrame()
    end

    RegisterInstanceEvents(eventFrame)
    self:RefreshLoggingState()
end

function CombatLogging:GetConfig()
    return settings
end

function CombatLogging:IsEnabled()
    return settings.enabled == true
end

function CombatLogging:SetEnabled(value)
    settings.enabled = value and true or nil
    self:RefreshLoggingState()
end

function CombatLogging:GetTrigger(triggerKey)
    return IsTriggerEnabled(triggerKey)
end

function CombatLogging:SetTrigger(triggerKey, value)
    settings[triggerKey] = value and true or false
    self:RefreshLoggingState()
end

function CombatLogging:GetDelayStop()
    return IsTriggerEnabled(TriggerKeys.DELAYED_STOP)
end

function CombatLogging:SetDelayStop(value)
    settings.delaystop = value and true or false
    self:RefreshLoggingState()
end

-- Build the compact label displayed by the multi-select trigger dropdown.
function CombatLogging:GetTriggerSummary()
    local enabledTriggerNames = {}

    for _, trigger in ipairs(self.Triggers) do
        if IsTriggerEnabled(trigger.key) then
        enabledTriggerNames[
            #enabledTriggerNames + Config.Collections.NEXT_INDEX_OFFSET
        ] = trigger.text
        end
    end

    if #enabledTriggerNames == Config.Collections.EMPTY_COUNT then
        return Constants.EMPTY_SUMMARY
    end

    return table.concat(enabledTriggerNames, Constants.SUMMARY_SEPARATOR)
end
