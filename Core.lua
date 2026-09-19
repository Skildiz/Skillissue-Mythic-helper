local addonName, SMhelper = ...

-- Addon entry point. Waits for this addon to finish loading, restores saved
-- settings, initializes each independent module, and registers slash commands.
local Config = SMhelper.Config
local Colors = Config.colorCodes
local ADDON_LOADED_EVENT = Config.Events.ADDON_LOADED

-- Both aliases open or close the same settings window.
SLASH_SMHELPER1 = Config.SlashCommands.PRIMARY
SLASH_SMHELPER2 = Config.SlashCommands.SECONDARY

local eventFrame = CreateFrame(Config.UI.FrameTypes.FRAME)

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
eventFrame:RegisterEvent(ADDON_LOADED_EVENT)

eventFrame:SetScript(Config.UI.Scripts.EVENT, function(self, event, loadedAddon)
    if event ~= ADDON_LOADED_EVENT or loadedAddon ~= addonName then
        return
    end

    self:UnregisterEvent(ADDON_LOADED_EVENT)

    -- Create the account-wide SavedVariables root before modules access it.
    SMhelperDB = SMhelperDB or {}

    -- Modules receive their own saved-state tables and manage their defaults.
    InitializeModules()

    print(
        Colors.accent
        .. Config.title
        .. Config.Messages.LOADED
        .. Config.Messages.COMMAND_PREFIX
        .. SLASH_SMHELPER1
        .. Config.Messages.COMMAND_SEPARATOR
        .. SLASH_SMHELPER2
        .. Config.Messages.COMMAND_SUFFIX
        .. Colors.reset
    )
end)
SlashCmdList.SMHELPER = function()
    if SMhelper.UI and SMhelper.UI.Toggle then
        SMhelper.UI:Toggle()
        return
    end

    print(
        Colors.error
        .. Config.title
        .. Config.Messages.UI_UNAVAILABLE
        .. Colors.reset
    )
end