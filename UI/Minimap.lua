local addonName, SMhelper = ...

-- minimap button for toggling the menu
SMhelper.UI.Minimap = SMhelper.UI.Minimap or {}
local MinimapButton = SMhelper.UI.Minimap
local button
local onClick

-- set the button action
function MinimapButton:SetOnClick(callback)
    onClick = callback
end

-- create the minimap button once
function MinimapButton:Create()
    if button or not Minimap then return button end
    button = CreateFrame("Button", nil, Minimap)
    button:SetSize(32, 32)
    button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 2, -2)
    button:SetNormalTexture("Interface\Icons\INV_Misc_Gear_01")
    button:SetHighlightTexture("Interface\Minimap\UI-Minimap-ZoomButton-Highlight")
    button:SetScript("OnClick", function()
        if onClick then onClick() end
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(SMhelper.Config.addonName)
        GameTooltip:AddLine("Click to toggle", 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return button
end
