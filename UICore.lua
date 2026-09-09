print("|cffff7f00Skillissue M+ helper successfully loaded! Type /mhelper or /sh to open the settings window.")

-- Addon settings window
local f = CreateFrame("Frame", "f", UIParent, "BasicFrameTemplateWithInset")
f:SetSize(500, 350)
f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
f.TitleBg:SetHeight(30)
f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
f.title:SetPoint("TOPLEFT", f.TitleBg, "TOPLEFT", 5, -3)
f.title:SetText("Skillissue M+ Helper")
f:Hide()

-- Make the frame draggable
f:EnableMouse(true)
f:SetMovable(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)
f:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

f:SetScript("OnShow", function()
        PlaySound(808)
end)

f:SetScript("OnHide", function()
        PlaySound(808)
end)

-- Chat command to toggle the settings window

SLASH_SKILLHELPER1 = "/smhelper"
SLASH_SKILLHELPER2 = "/sh"
SlashCmdList["SKILLHELPER"] = function()
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end
