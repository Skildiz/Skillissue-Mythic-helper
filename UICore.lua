local addonName, sframe = ...

local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("ADDON_LOADED")

eventHandler:SetScript("OnEvent", function(frame, _, loadedAddonName)
    if loadedAddonName ~= addonName then return end

    local Style = sframe.Style

    -- Chat message after logging in

    print("|cffff7f00Skillissue M+ helper successfully loaded! Type /smhelper or /sh to open the settings window.|r")

    -- Main settings frame
    local f = Style:CreatePanel(UIParent, 500, 350, "SkillissueSettingsFrame")
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:Hide()

    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local header = Style:CreateHeader(f, "Skillissue M+ Helper", 30)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, header)
    closeBtn:SetSize(18, 18)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -6, 0)
    closeBtn:EnableMouse(true)
    closeBtn:SetFrameLevel(header:GetFrameLevel() + 5)
    
    closeBtn.text = closeBtn:CreateFontString(nil, "OVERLAY")
    Style:ApplyFont(closeBtn.text, 10, "OUTLINE")
    closeBtn.text:SetText("X")
    closeBtn.text:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
    closeBtn.text:SetTextColor(0.7, 0.7, 0.7)

    closeBtn:SetScript("OnClick", function() 
        f:Hide() 
    end)
    closeBtn:SetScript("OnEnter", function(button) 
        button.text:SetTextColor(1, 0.2, 0.2) 
    end)
    closeBtn:SetScript("OnLeave", function(button) 
        button.text:SetTextColor(0.7, 0.7, 0.7) 
    end)

    -- Sound effects on show/hide
    f:SetScript("OnShow", function() PlaySound(808) end)
    f:SetScript("OnHide", function() PlaySound(808) end)

    -- Slash command to toggle the settings frame
    SLASH_SKILLHELPER1 = "/smhelper"
    SLASH_SKILLHELPER2 = "/sh"
    SlashCmdList["SKILLHELPER"] = function()
        if f:IsShown() then
            f:Hide()
        else
            f:Show()
        end
    end

    frame:UnregisterEvent("ADDON_LOADED")
end)