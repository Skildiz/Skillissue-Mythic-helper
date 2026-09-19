local _, SMhelper = ...

-- Minimap shortcut for the settings window. The click behavior is injected by
-- Core so this component does not depend on the window implementation.
local Config = SMhelper.Config
local Layout = Config.Layout
local MinimapConfig = Config.UI.Minimap
local UIConfig = Config.UI
local Anchors = UIConfig.AnchorPoints

SMhelper.UI.Minimap = SMhelper.UI.Minimap or {}
local MinimapButton = SMhelper.UI.Minimap

local minimapButtonFrame
local clickHandler

-- Apply asset paths from Config rather than embedding texture paths here.
local function ConfigureButtonTextures(button)
    button:SetNormalTexture(Config.Paths.Interface.Icons.MINIMAP)
    button:SetHighlightTexture(Config.Paths.Interface.Minimap.HIGHLIGHT)
end

-- Attach click and tooltip behavior to the button.
local function ConfigureButtonScripts(button)
    local tooltip = MinimapConfig.Tooltip
    local tooltipColor = tooltip.TEXT_COLOR
    local scripts = {
        [UIConfig.Scripts.CLICK] = function()
            if clickHandler then
                clickHandler()
            end
        end,
        [UIConfig.Scripts.ENTER] = function(self)
            GameTooltip:SetOwner(self, tooltip.ANCHOR)
            GameTooltip:SetText(Config.addonName)
            GameTooltip:AddLine(tooltip.TEXT, unpack(tooltipColor))
            GameTooltip:Show()
        end,
        [UIConfig.Scripts.LEAVE] = function()
            GameTooltip:Hide()
        end,
    }

    for scriptName, handler in pairs(scripts) do
        button:SetScript(scriptName, handler)
    end
end

function MinimapButton:SetOnClick(callback)
    clickHandler = callback
end

-- Create the minimap button once at its configured initial position.
function MinimapButton:Create()
    if minimapButtonFrame or not Minimap then
        return minimapButtonFrame
    end

    minimapButtonFrame = CreateFrame(UIConfig.FrameTypes.BUTTON, nil, Minimap)
    minimapButtonFrame:SetSize(
        Layout.Minimap.Button.SIZE,
        Layout.Minimap.Button.SIZE
    )
    minimapButtonFrame:SetPoint(
        Anchors.TOP_LEFT,
        Minimap,
        Anchors.TOP_LEFT,
        Layout.Minimap.Button.X,
        Layout.Minimap.Button.Y
    )

    ConfigureButtonTextures(minimapButtonFrame)
    ConfigureButtonScripts(minimapButtonFrame)
    return minimapButtonFrame
end
