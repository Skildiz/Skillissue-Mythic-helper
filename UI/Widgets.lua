local addonName, SMhelper = ...

-- reusable controls for addon pages
local API = SMhelper.UI.API
local Config = SMhelper.Config
SMhelper.UI.Widgets = SMhelper.UI.Widgets or {}
local Widgets = SMhelper.UI.Widgets

-- create a styled action button
function Widgets:CreateButton(parent, text, onClick, options)
    options = options or {}
    options.text = text
    options.onClick = onClick
    options.color = options.color or Config.colors.panel
    options.hoverColor = options.hoverColor or Config.colors.panelHover
    options.textColor = options.textColor or Config.colors.text
    return API:CreateButton(parent, options)
end

-- create a custom toggle switch
function Widgets:CreateToggle(parent, text, initialValue, callback)
    local value = not not initialValue
    local button = API:CreatePanel(parent, { width = 44, height = 22, color = Config.colors.panel })
    button:EnableMouse(true)

    local knob = button:CreateTexture(nil, "ARTWORK")
    knob:SetSize(18, 18)
    button.Knob = knob

    local label = API:CreateLabel(parent, text, { color = Config.colors.text })
    label:SetPoint("LEFT", button, "RIGHT", 10, 0)
    button.Label = label

    -- move and recolor the toggle knob
    local function render()
        if value then
            button.Background:SetColorTexture(unpack(Config.colors.accent))
            knob:SetColorTexture(1, 1, 1, 1)
            knob:ClearAllPoints()
            knob:SetPoint("RIGHT", -2, 0)
        else
            button.Background:SetColorTexture(unpack(Config.colors.panel))
            knob:SetColorTexture(0.65, 0.68, 0.72, 1)
            knob:ClearAllPoints()
            knob:SetPoint("LEFT", 2, 0)
        end
    end

    -- update the toggle value
    function button:SetValue(newValue, silent)
        value = not not newValue
        render()
        if not silent and callback then callback(value) end
    end

    -- return the current toggle value
    function button:GetValue()
        return value
    end

    button:SetScript("OnMouseUp", function()
        button:SetValue(not value)
    end)
    render()
    return button
end

-- create an uppercase section header with a trailing divider line
-- returns the frame and the vertical space it consumes
function Widgets:SectionHeader(parent, text, y)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(24)
    frame:SetPoint("TOPLEFT", 0, y or 0)
    frame:SetPoint("TOPRIGHT", 0, y or 0)

    local label = API:CreateLabel(frame, string.upper(text or ""), {
        color = Config.colors.mutedText,
        fontSize = 12,
    })
    label:SetPoint("LEFT", 0, 0)

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetColorTexture(unpack(Config.colors.border))
    line:SetPoint("LEFT", label, "RIGHT", 12, 0)
    line:SetPoint("RIGHT", 0, 0)

    frame.Label = label
    return frame, 32
end

-- create a two-column row; returns the row (with .Left and .Right regions)
-- and the vertical space it consumes
function Widgets:Row(parent, y, height)
    height = height or 44
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(height)
    row:SetPoint("TOPLEFT", 0, y or 0)
    row:SetPoint("TOPRIGHT", 0, y or 0)

    local left = CreateFrame("Frame", nil, row)
    left:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMRIGHT", row, "BOTTOM", -12, 0)

    local right = CreateFrame("Frame", nil, row)
    right:SetPoint("TOPLEFT", row, "TOP", 12, 0)
    right:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)

    row.Left, row.Right = left, right
    return row, height
end

-- toggle laid out as a row: label on the left, switch pinned to the right
function Widgets:RowToggle(region, text, initial, callback, tooltip)
    local toggle = self:CreateToggle(region, text, initial, callback)
    toggle:ClearAllPoints()
    toggle:SetPoint("RIGHT", region, "RIGHT", -20, 0)

    toggle.Label:ClearAllPoints()
    toggle.Label:SetPoint("LEFT", region, "LEFT", 0, 0)
    toggle.Label:SetPoint("RIGHT", toggle, "LEFT", -10, 0)
    toggle.Label:SetJustifyH("LEFT")

    if tooltip then
        toggle:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(text, 1, 1, 1)
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        toggle:HookScript("OnLeave", function() GameTooltip:Hide() end)
    end
    return toggle
end

-- multi-select dropdown: a field showing a summary that opens a checkbox menu
-- options: items = { { key=, text= }, ... }, getValue(key), setValue(key, bool),
-- getSummary() -> string, width
function Widgets:CreateCheckboxDropdown(parent, options)
    options = options or {}
    local width = options.width or 210
    local rowHeight = 24

    local dropdown = API:CreateButton(parent, {
        width = width,
        height = 24,
        color = Config.colors.panel,
        hoverColor = Config.colors.panelHover,
        textColor = Config.colors.text,
        justifyH = "LEFT",
    })
    API:CreateBorder(dropdown, Config.colors.border, 1)

    local arrow = dropdown:CreateTexture(nil, "OVERLAY")
    arrow:SetSize(16, 16)
    arrow:SetPoint("RIGHT", -6, 0)
    arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")

    dropdown.Label:ClearAllPoints()
    dropdown.Label:SetPoint("LEFT", 10, 0)
    dropdown.Label:SetPoint("RIGHT", arrow, "LEFT", -4, 0)
    dropdown.Label:SetJustifyH("LEFT")
    dropdown.Label:SetWordWrap(false)

    -- the popup menu, drawn above sibling controls and hidden with the window
    local menu = API:CreatePanel(dropdown, { width = width, color = Config.colors.panelHover })
    menu:SetFrameLevel(dropdown:GetFrameLevel() + 10)
    menu:SetPoint("TOPRIGHT", dropdown, "BOTTOMRIGHT", 0, -2)
    menu:SetHeight(8 + #options.items * rowHeight)
    API:CreateBorder(menu, Config.colors.border, 1)
    menu:Hide()

    local rows = {}
    for index, item in ipairs(options.items) do
        local entry = API:CreateButton(menu, {
            height = rowHeight,
            color = { 0, 0, 0, 0 },
            hoverColor = Config.colors.panelHover,
            textColor = Config.colors.text,
            text = item.text,
            justifyH = "LEFT",
            textInset = 28,
        })
        local top = -4 - (index - 1) * rowHeight
        entry:SetPoint("TOPLEFT", 4, top)
        entry:SetPoint("TOPRIGHT", -4, top)

        local box = entry:CreateTexture(nil, "ARTWORK")
        box:SetSize(18, 18)
        box:SetPoint("LEFT", 4, 0)
        box:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")

        local check = entry:CreateTexture(nil, "OVERLAY")
        check:SetSize(18, 18)
        check:SetPoint("LEFT", 4, 0)
        check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")

        local function renderCheck()
            check:SetShown(options.getValue(item.key) == true)
        end

        entry:SetScript("OnClick", function()
            options.setValue(item.key, not (options.getValue(item.key) == true))
            renderCheck()
            dropdown:Refresh()
        end)

        renderCheck()
        rows[index] = renderCheck
    end

    dropdown.enabled = true

    -- update the summary text and every checkbox state
    function dropdown:Refresh()
        self.Label:SetText(options.getSummary and options.getSummary() or "")
        for _, renderCheck in ipairs(rows) do renderCheck() end
    end

    -- gray out and block the field while disabled
    function dropdown:SetEnabled(enabled)
        self.enabled = enabled and true or false
        self:SetAlpha(self.enabled and 1 or 0.3)
        self:EnableMouse(self.enabled)
        if not self.enabled and menu:IsShown() then menu:Hide() end
    end

    dropdown:SetScript("OnClick", function()
        if not dropdown.enabled then return end
        menu:SetShown(not menu:IsShown())
    end)

    return dropdown
end
