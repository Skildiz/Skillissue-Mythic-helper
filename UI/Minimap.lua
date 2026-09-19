local _, SMhelper = ...

-- Minimap shortcut for the settings window. The click behavior is injected by
-- Core so this component does not depend on the window implementation.
local Config = SMhelper.Config
local Layout = Config.Layout

SMhelper.UI.Minimap = SMhelper.UI.Minimap or {}
local MinimapButton = SMhelper.UI.Minimap

local minimapButtonFrame
local clickHandler

-- Apply asset paths from Config rather than embedding texture paths here.
local function ConfigureButtonTextures(button)
    button:SetNormalTexture(Config.Paths.MINIMAP_ICON)
    button:SetHighlightTexture(Config.Paths.MINIMAP_HIGHLIGHT)
end

-- Attach click and tooltip behavior to the button.
local function ConfigureButtonScripts(button)
    button:SetScript("OnClick", function()
        if clickHandler then
            clickHandler()
        end
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(Config.addonName)
        GameTooltip:AddLine("Click to toggle", 1, 1, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function MinimapButton:SetOnClick(callback)
    clickHandler = callback
end

-- Create the minimap button once at its configured initial position.
function MinimapButton:Create()
    if minimapButtonFrame or not Minimap then
        return minimapButtonFrame
    end

    minimapButtonFrame = CreateFrame("Button", nil, Minimap)
    minimapButtonFrame:SetSize(
        Layout.MINIMAP_BUTTON_SIZE,
        Layout.MINIMAP_BUTTON_SIZE
    )
    minimapButtonFrame:SetPoint(
        "TOPLEFT",
        Minimap,
        "TOPLEFT",
        Layout.MINIMAP_BUTTON_X,
        Layout.MINIMAP_BUTTON_Y
    )

    ConfigureButtonTextures(minimapButtonFrame)
    ConfigureButtonScripts(minimapButtonFrame)
    return minimapButtonFrame
end
