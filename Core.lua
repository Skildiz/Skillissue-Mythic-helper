local addonName, SMhelper = ...

-- addon startup and commands
-- initialize modules after loading
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if event ~= "ADDON_LOADED" or loadedAddon ~= addonName then
        return
    end
    self:UnregisterEvent("ADDON_LOADED")
    SMhelperDB = SMhelperDB or {}
    local buffReminder = SMhelper.Modules
        and SMhelper.Modules.BuffReminder

    if buffReminder then
        buffReminder:Initialize(SMhelperDB.buffReminder)
    end
    local combatLogging = SMhelper.Modules
        and SMhelper.Modules.CombatLogging

    if combatLogging then
        combatLogging:Initialize(SMhelperDB.combatLogging)
    end
    local minimap = SMhelper.UI
        and SMhelper.UI.Minimap

    if minimap then
        minimap:SetOnClick(function()
            SMhelper.UI:Toggle()
        end)

        minimap:Create()
    end

    print(
        "|cff3399ffSkillissue M+ Helper successfully loaded! " ..
        "Type /smhelper or /smh to open the settings window.|r"
    )
end)

SLASH_SMHELPER1 = "/smhelper"
SLASH_SMHELPER2 = "/smh"

SlashCmdList.SMHELPER = function()
    if SMhelper.UI and SMhelper.UI.Toggle then
        SMhelper.UI:Toggle()
    else
        print("|cffff3333Skillissue M+ Helper: UI module is unavailable.|r")
    end
end