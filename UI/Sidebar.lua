local _, SMhelper = ...

-- sidebar navigation buttons
local Widgets, Config = SMhelper.UI.Widgets, SMhelper.Config
SMhelper.UI.Sidebar = SMhelper.UI.Sidebar or {}
local Sidebar = SMhelper.UI.Sidebar
local frame, onSelect
local buttons = {}

-- create the sidebar panel
function Sidebar:Create(parent)
    if not frame then
        frame = SMhelper.UI.API:CreatePanel(parent, { width = Config.sidebarWidth, color = Config.colors.panel })
    end
    return frame
end

-- set the page selection callback
function Sidebar:SetOnSelect(callback)
    onSelect = callback
end

-- add one navigation button
function Sidebar:AddButton(options)
    local button = Widgets:CreateButton(frame, options.text or options.id, function()
        if onSelect then onSelect(options.id) end
    end, {
        height = 38,
        justifyH = "LEFT",
        selectedColor = Config.colors.accent,
        glowColor = { Config.colors.accent[1], Config.colors.accent[2], Config.colors.accent[3], 0.6 },
    })
    local y = -Config.padding - (#buttons * 44)
    button:SetPoint("TOPLEFT", Config.padding, y)
    button:SetPoint("TOPRIGHT", -Config.padding, y)
    buttons[#buttons + 1] = { id = options.id, button = button }
    return button
end

-- highlight the active button
function Sidebar:SetSelected(id)
    for _, item in ipairs(buttons) do
        item.button:SetSelected(item.id == id)
    end
end
