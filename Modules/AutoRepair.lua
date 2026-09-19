local _, SMhelper = ...

-- Automatic repair module. It listens only while enabled, prefers guild
-- repair funds when available, and never spends personal gold unless the
-- character can afford the complete repair.
SMhelper.Modules = SMhelper.Modules or {}
SMhelper.Modules.AutoRepair = SMhelper.Modules.AutoRepair or {}

local AutoRepair = SMhelper.Modules.AutoRepair
local Config = SMhelper.Config
local MERCHANT_SHOW_EVENT = Config.Events.MERCHANT_SHOW
local settings = {}
local eventFrame

local function CanAffordRepair(repairCost)
    return GetMoney() >= repairCost
end

local function CanUseGuildRepair()
    return IsInGuild()
        and CanGuildBankRepair
        and CanGuildBankRepair()
end

-- Return a positive full-repair cost, or nil when nothing can be repaired.
local function GetValidRepairCost()
    local repairCost, canRepair = GetRepairAllCost()

    if not canRepair
        or not repairCost
        or repairCost <= Config.AutoRepair.MIN_REPAIR_COST then
        return nil
    end

    return repairCost
end

-- Perform one repair attempt when a repair-capable merchant window opens.
local function RepairDamagedEquipment()
    if settings.enabled ~= true or not CanMerchantRepair() then
        return
    end

    local repairCost = GetValidRepairCost()

    if not repairCost then
        return
    end

    if CanUseGuildRepair() then
        RepairAllItems(true)
    elseif CanAffordRepair(repairCost) then
        RepairAllItems(false)
    end
end

local function HandleMerchantEvent(_, eventName)
    if eventName == MERCHANT_SHOW_EVENT then
        RepairDamagedEquipment()
    end
end

-- Lazily create the invisible frame used only for merchant events.
local function GetOrCreateEventFrame()
    if eventFrame then
        return eventFrame
    end

    eventFrame = CreateFrame(Config.UI.FrameTypes.FRAME)
    eventFrame:SetScript(Config.UI.Scripts.EVENT, HandleMerchantEvent)
    return eventFrame
end

-- Avoid unnecessary event callbacks by listening only while enabled.
local function RefreshMerchantEventRegistration()
    local frame = GetOrCreateEventFrame()

    if settings.enabled == true then
        frame:RegisterEvent(MERCHANT_SHOW_EVENT)
    else
        frame:UnregisterEvent(MERCHANT_SHOW_EVENT)
    end
end

-- Store the live settings table directly in SavedVariables.
local function SaveSettings()
    SMhelperDB = SMhelperDB or {}
    SMhelperDB.autoRepair = settings
end

-- Restore persisted state, apply defaults, and synchronize event registration.
function AutoRepair:Initialize(savedState)
    settings = type(savedState) == "table" and savedState or {}

    if settings.enabled == nil then
        settings.enabled = false
    end

    SaveSettings()
    RefreshMerchantEventRegistration()
end

function AutoRepair:IsEnabled()
    return settings.enabled == true
end

-- Persist the new state and immediately update event registration.
function AutoRepair:SetEnabled(value)
    settings.enabled = value == true
    SaveSettings()
    RefreshMerchantEventRegistration()
end
