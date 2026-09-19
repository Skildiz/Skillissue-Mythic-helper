local addonName, SMhelper = ...

-- Addon entry point. Waits for this addon to finish loading, restores saved
-- settings, initializes each independent module, and registers slash commands.
local Config = SMhelper.Config
local Colors = Config.colorCodes

local eventFrame = CreateFrame("Frame")

-- Initialize the buff reminder with its persisted settings.
local function InitializeBuffReminder()
    local module =
        SMhelper.Modules
        and SMhelper.Modules.BuffReminder

    if not module then
        return
    end

    module:Initialize(SMhelperDB.buffReminder)
end

-- Initialize automatic combat logging with its persisted settings.
local function InitializeCombatLogging()
    local module =
        SMhelper.Modules
        and SMhelper.Modules.CombatLogging

    if not module then
        return
    end

    module:Initialize(SMhelperDB.combatLogging)
end

-- Initialize automatic repair with its persisted settings.
local function InitializeAutoRepair()
    local module =
        SMhelper.Modules
        and SMhelper.Modules.AutoRepair

    if not module then
        return
    end

    module:Initialize(SMhelperDB.autoRepair)
end

-- Create the minimap entry point and connect it to the main window toggle.
-- TODO: Replace the fixed minimap position with draggable positioning.
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


-- Keep startup order explicit so module dependencies remain easy to review.
local function InitializeModules()
    InitializeBuffReminder()
    InitializeCombatLogging()
    InitializeAutoRepair()
    InitializeMinimap()
end


-- ADDON_LOADED is filtered by addon name because every addon fires this event.
eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if event ~= "ADDON_LOADED" or loadedAddon ~= addonName then
        return
    end

    self:UnregisterEvent("ADDON_LOADED")

-- Create the account-wide SavedVariables root before modules access it.
    SMhelperDB = SMhelperDB or {}

-- Modules receive their own saved-state tables and manage their defaults.
    InitializeModules()

    print(
        Colors.accent
        .. Config.title
        .. " successfully loaded! "
        .. "Type /smhelper or /smh to open the settings window."
        .. Colors.reset
    )
end)


-- Both aliases open or close the same settings window.
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