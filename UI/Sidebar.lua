local _, SMhelper = ...

-- Sidebar navigation component. It owns button ordering and selected-state
-- rendering while delegating page changes through an injected callback.
local Widgets = SMhelper.UI.Widgets
local Config = SMhelper.Config
local Layout = Config.Layout
local Anchors = Config.UI.AnchorPoints

SMhelper.UI.Sidebar = SMhelper.UI.Sidebar or {}
local Sidebar = SMhelper.UI.Sidebar

local sidebarFrame
local onPageSelected
local navigationButtons = {}

-- Calculate vertical placement from padding, index, and the configured row step.
local function GetButtonYPosition(buttonIndex)
    return -Config.padding
        - (
            (buttonIndex - Config.Collections.FIRST_INDEX)
            * Layout.Sidebar.Button.STEP
        )
end

function Sidebar:Create(parent)
    if not sidebarFrame then
        sidebarFrame = SMhelper.UI.API:CreatePanel(parent, {
            width = Config.sidebarWidth,
            color = Config.colors.panel,
        })
    end

    return sidebarFrame
end

function Sidebar:SetOnSelect(callback)
    onPageSelected = callback
end

-- Add one navigation button and preserve its page ID for selection updates.
function Sidebar:AddButton(options)
    local button = Widgets:CreateButton(
        sidebarFrame,
        options.text or options.id,
        function()
            if onPageSelected then
                onPageSelected(options.id)
            end
        end,
        {
            height = Layout.Sidebar.Button.HEIGHT,
            justifyH = Config.UI.HorizontalAlignment.LEFT,
            selectedColor = Config.colors.accent,
            glowColor = Config.colors.sidebarButtonGlow,
        }
    )

    local y_pos = GetButtonYPosition(
        #navigationButtons + Config.Collections.NEXT_INDEX_OFFSET
    )
    button:SetPoint(Anchors.TOP_LEFT, Config.padding, y_pos)
    button:SetPoint(Anchors.TOP_RIGHT, -Config.padding, y_pos)

    navigationButtons[
        #navigationButtons + Config.Collections.NEXT_INDEX_OFFSET
    ] = {
        id = options.id,
        button = button,
    }

    return button
end

-- Highlight only the button associated with the active page.
function Sidebar:SetSelected(selectedPageId)
    for _, item in ipairs(navigationButtons) do
        item.button:SetSelected(item.id == selectedPageId)
    end
end
