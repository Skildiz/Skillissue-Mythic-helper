local _, SMhelper = ...

-- Automatically repairs all damaged equipment when a repair merchant opens.
SMhelper.Modules = SMhelper.Modules or {}
SMhelper.Modules.AutoRepair = SMhelper.Modules.AutoRepair or {}

local AutoRepair = SMhelper.Modules.AutoRepair

local config = {}
local eventFrame

-- Repair all damaged equipment when a repair merchant opens.
local function RepairAtMerchant()
    if config.enabled ~= true then
        return
    end

    if not CanMerchantRepair() then
        return
    end

    local repairCost, canRepair = GetRepairAllCost()

    if not canRepair or not repairCost or repairCost <= 0 then
        return
    end

    -- Use guild repair funds when they are available.
    local useGuildBank = IsInGuild()
        and CanGuildBankRepair
        and CanGuildBankRepair()

    if useGuildBank then
        RepairAllItems(true)
        return
    end

    -- Use personal gold only when the full repair is affordable.
    if GetMoney() >= repairCost then
        RepairAllItems(false)
    end
end

-- Register or unregister the merchant event.
local function ApplyEventState()
    if not eventFrame then
        eventFrame = CreateFrame("Frame")

        eventFrame:SetScript("OnEvent", function(_, event)
            if event == "MERCHANT_SHOW" then
                RepairAtMerchant()
            end
        end)
    end

    if config.enabled == true then
        eventFrame:RegisterEvent("MERCHANT_SHOW")
    else
        eventFrame:UnregisterEvent("MERCHANT_SHOW")
    end
end

-- Load the saved Auto Repair option.
function AutoRepair:Initialize(savedState)
    if type(savedState) == "table" then
        config = savedState
    else
        config = {}
    end

    -- Auto Repair is disabled by default.
    if config.enabled == nil then
        config.enabled = false
    end

    SMhelperDB = SMhelperDB or {}
    SMhelperDB.autoRepair = config

    ApplyEventState()
end

-- Return the current Auto Repair state.
function AutoRepair:IsEnabled()
    return config.enabled == true
end

-- Enable or disable Auto Repair and save the new state.
function AutoRepair:SetEnabled(value)
    config.enabled = value and true or false

    SMhelperDB = SMhelperDB or {}
    SMhelperDB.autoRepair = config

    ApplyEventState()
end