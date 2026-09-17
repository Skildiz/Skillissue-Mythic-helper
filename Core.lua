local addonName, SMhelper = ...

-- Addon startup and slash commands
local Config = SMhelper.Config
local Colors = Config.colorCodes

local eventFrame = CreateFrame("Frame")

-- Module initialization
-- Buff BuffReminder module
local function InitializeBuffReminder()
    local module =
        SMhelper.Modules
        and SMhelper.Modules.BuffReminder

    if not module then
        return
    end

    module:Initialize(SMhelperDB.buffReminder)
end

-- Combat logging module
local function InitializeCombatLogging()
    local module =
        SMhelper.Modules
        and SMhelper.Modules.CombatLogging

    if not module then
        return
    end

    module:Initialize(SMhelperDB.combatLogging)
end

-- Auto Repair module
local function InitializeAutoRepair()
    local module =
        SMhelper.Modules
        and SMhelper.Modules.AutoRepair

    if not module then
        return
    end

    module:Initialize(SMhelperDB.autoRepair)
end

-- Minimap button initialization
-- TODO: Fix minimap button (work in progress)
local function InitializeMinimap()
    local module =
        SMhelper.UI
        and SMhelper.UI.Minimap

    if not module then
        return
    end

    module:SetOnClick(function()
        SMhelper.UI:Toggle()
    end)

    module:Create()
end


local function InitializeModules()
    InitializeBuffReminder()
    InitializeCombatLogging()
    InitializeAutoRepair()
    InitializeMinimap()
end


-- Addon events
eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if event ~= "ADDON_LOADED" or loadedAddon ~= addonName then
        return
    end

    self:UnregisterEvent("ADDON_LOADED")

    -- Initialize saved variables
    SMhelperDB = SMhelperDB or {}

    -- Initialize every addon module
    InitializeModules()

    print(
        Colors.accent
        .. Config.title
        .. " successfully loaded! "
        .. "Type /smhelper or /smh to open the settings window."
        .. Colors.reset
    )
end)


-- Slash commands
SLASH_SMHELPER1 = "/smhelper"
SLASH_SMHELPER2 = "/smh"

SlashCmdList.SMHELPER = function()
    if SMhelper.UI and SMhelper.UI.Toggle then
        SMhelper.UI:Toggle()
        return
    end

    print(
        Colors.error
        .. Config.title
        .. ": UI module is unavailable."
        .. Colors.reset
    )
end