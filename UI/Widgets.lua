local _, SMhelper = ...

-- Reusable higher-level controls built on UI/API.lua. Complex widgets are split
-- into construction, behavior, and refresh helpers to keep public factories small.
local API = SMhelper.UI.API
local Config = SMhelper.Config
local Layout = Config.Layout

SMhelper.UI.Widgets = SMhelper.UI.Widgets or {}
local Widgets = SMhelper.UI.Widgets

-- Keep toggle color and knob position synchronized with its boolean value.
local function RefreshToggleAppearance(button, knob, isEnabled)
    if isEnabled then
        button.Background:SetColorTexture(unpack(Config.colors.accent))
        knob:SetColorTexture(unpack(Config.colors.white))
        knob:ClearAllPoints()
        knob:SetPoint("RIGHT", -Layout.TOGGLE_KNOB_OFFSET, 0)
        return
    end

    button.Background:SetColorTexture(unpack(Config.colors.panel))
    knob:SetColorTexture(unpack(Config.colors.toggleDisabled))
    knob:ClearAllPoints()
    knob:SetPoint("LEFT", Layout.TOGGLE_KNOB_OFFSET, 0)
end

-- Add value accessors and user-interaction behavior to a toggle panel.
local function AddToggleMethods(button, knob, initialValue, callback)
    local currentValue = initialValue == true

    function button:SetValue(newValue, silent)
        currentValue = newValue == true
        RefreshToggleAppearance(button, knob, currentValue)

        if not silent and callback then
            callback(currentValue)
        end
    end

    function button:GetValue()
        return currentValue
    end

    button:SetScript("OnMouseUp", function()
        button:SetValue(not currentValue)
    end)

    RefreshToggleAppearance(button, knob, currentValue)
end

local function CreateDropdownButton(parent, options)
    local dropdown = API:CreateButton(parent, {
        width = options.width,
        height = Layout.DROPDOWN_HEIGHT,
        color = Config.colors.panel,
        hoverColor = Config.colors.panelHover,
        textColor = Config.colors.text,
        justifyH = "LEFT",
    })

    API:CreateBorder(dropdown, Config.colors.border, 1)
    return dropdown
end

local function CreateDropdownArrow(dropdown)
    local arrow = dropdown:CreateTexture(nil, "OVERLAY")

    arrow:SetSize(Layout.DROPDOWN_ARROW_SIZE, Layout.DROPDOWN_ARROW_SIZE)
    arrow:SetPoint("RIGHT", Layout.DROPDOWN_ARROW_RIGHT, 0)
    arrow:SetTexture(Config.Paths.DROPDOWN_ARROW)

    dropdown.Label:ClearAllPoints()
    dropdown.Label:SetPoint("LEFT", Layout.BUTTON_TEXT_INSET, 0)
    dropdown.Label:SetPoint("RIGHT", arrow, "LEFT", -Layout.DROPDOWN_MENU_PADDING, 0)
    dropdown.Label:SetJustifyH("LEFT")
    dropdown.Label:SetWordWrap(false)
end

local function CreateDropdownMenu(dropdown, width, itemCount)
    local menu = API:CreatePanel(dropdown, {
        width = width,
        color = Config.colors.panelHover,
    })

    menu:SetFrameLevel(dropdown:GetFrameLevel() + Layout.RESIZE_FRAME_LEVEL_OFFSET)
    menu:SetPoint("TOPRIGHT", dropdown, "BOTTOMRIGHT", 0, Layout.DROPDOWN_MENU_OFFSET_Y)
    menu:SetHeight(
        Layout.DROPDOWN_MENU_VERTICAL_PADDING
        + itemCount * Layout.DROPDOWN_ROW_HEIGHT
    )
    API:CreateBorder(menu, Config.colors.border, 1)
    menu:Hide()

    return menu
end

-- Build one checkbox row and return a function that refreshes its check mark.
local function CreateDropdownEntry(menu, dropdown, options, item, index)
    local padding = Layout.DROPDOWN_MENU_PADDING
    local rowHeight = Layout.DROPDOWN_ROW_HEIGHT
    local topOffset = -padding - (index - 1) * rowHeight

    local entry = API:CreateButton(menu, {
        height = rowHeight,
        color = Config.colors.transparent,
        hoverColor = Config.colors.panelHover,
        textColor = Config.colors.text,
        text = item.text,
        justifyH = "LEFT",
        textInset = Layout.DROPDOWN_ENTRY_TEXT_INSET,
    })

    entry:SetPoint("TOPLEFT", padding, topOffset)
    entry:SetPoint("TOPRIGHT", -padding, topOffset)

    local emptyBox = entry:CreateTexture(nil, "ARTWORK")
    emptyBox:SetSize(Layout.DROPDOWN_CHECKBOX_SIZE, Layout.DROPDOWN_CHECKBOX_SIZE)
    emptyBox:SetPoint("LEFT", Layout.DROPDOWN_CHECKBOX_LEFT, 0)
    emptyBox:SetTexture(Config.Paths.CHECKBOX_EMPTY)

    local checkMark = entry:CreateTexture(nil, "OVERLAY")
    checkMark:SetSize(Layout.DROPDOWN_CHECKBOX_SIZE, Layout.DROPDOWN_CHECKBOX_SIZE)
    checkMark:SetPoint("LEFT", Layout.DROPDOWN_CHECKBOX_LEFT, 0)
    checkMark:SetTexture(Config.Paths.CHECKBOX_CHECKED)

    local function RefreshCheckMark()
        checkMark:SetShown(options.getValue(item.key) == true)
    end

    entry:SetScript("OnClick", function()
        local newValue = options.getValue(item.key) ~= true
        options.setValue(item.key, newValue)
        RefreshCheckMark()
        dropdown:Refresh()
    end)

    RefreshCheckMark()
    return RefreshCheckMark
end

-- Attach the dropdown public API and synchronize summary and checkbox state.
local function AddDropdownMethods(dropdown, menu, options, refreshEntries)
    dropdown.isEnabled = true

    function dropdown:Refresh()
        local summary = options.getSummary and options.getSummary() or ""
        self.Label:SetText(summary)

        for _, refreshEntry in ipairs(refreshEntries) do
            refreshEntry()
        end
    end

    function dropdown:SetEnabled(enabled)
        self.isEnabled = enabled == true
        self:SetAlpha(self.isEnabled and 1 or 0.3)
        self:EnableMouse(self.isEnabled)

        if not self.isEnabled then
            menu:Hide()
        end
    end

    dropdown:SetScript("OnClick", function()
        if dropdown.isEnabled then
            menu:SetShown(not menu:IsShown())
        end
    end)
end

function Widgets:CreateButton(parent, text, onClick, options)
    options = options or {}
    options.text = text
    options.onClick = onClick
    options.color = options.color or Config.colors.panel
    options.hoverColor = options.hoverColor or Config.colors.panelHover
    options.textColor = options.textColor or Config.colors.text

    return API:CreateButton(parent, options)
end

-- Create a labeled switch with normalized boolean state.
function Widgets:CreateToggle(parent, text, initialValue, callback)
    local button = API:CreatePanel(parent, {
        width = Layout.TOGGLE_WIDTH,
        height = Layout.TOGGLE_HEIGHT,
        color = Config.colors.panel,
    })
    button:EnableMouse(true)

    local knob = button:CreateTexture(nil, "ARTWORK")
    knob:SetSize(Layout.TOGGLE_KNOB_SIZE, Layout.TOGGLE_KNOB_SIZE)
    button.Knob = knob

    local label = API:CreateLabel(parent, text, { color = Config.colors.text })
    label:SetPoint("LEFT", button, "RIGHT", Layout.TOGGLE_LABEL_GAP, 0)
    button.Label = label

    AddToggleMethods(button, knob, initialValue, callback)
    return button
end

-- Create an uppercase heading with a divider and report consumed vertical space.
function Widgets:CreateSectionHeader(parent, text, y_pos)
    local frame = CreateFrame("Frame", nil, parent)
    local verticalPosition = y_pos or 0

    frame:SetHeight(Layout.SECTION_HEADER_HEIGHT)
    frame:SetPoint("TOPLEFT", 0, verticalPosition)
    frame:SetPoint("TOPRIGHT", 0, verticalPosition)

    local label = API:CreateLabel(frame, string.upper(text or ""), {
        color = Config.colors.mutedText,
        fontSize = Layout.SECTION_HEADER_FONT_SIZE,
    })
    label:SetPoint("LEFT", 0, 0)

    local divider = frame:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(Layout.SECTION_DIVIDER_HEIGHT)
    divider:SetColorTexture(unpack(Config.colors.border))
    divider:SetPoint("LEFT", label, "RIGHT", Layout.SECTION_DIVIDER_GAP, 0)
    divider:SetPoint("RIGHT", 0, 0)

    frame.Label = label
    return frame, Layout.SECTION_HEADER_SPACE
end

-- Create equal left/right regions separated by the configured column gap.
function Widgets:CreateTwoColumnRow(parent, y_pos, height)
    local rowHeight = height or Layout.ROW_HEIGHT
    local verticalPosition = y_pos or 0
    local row = CreateFrame("Frame", nil, parent)

    row:SetHeight(rowHeight)
    row:SetPoint("TOPLEFT", 0, verticalPosition)
    row:SetPoint("TOPRIGHT", 0, verticalPosition)

    local leftRegion = CreateFrame("Frame", nil, row)
    leftRegion:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    leftRegion:SetPoint("BOTTOMRIGHT", row, "BOTTOM", -Layout.ROW_COLUMN_GAP, 0)

    local rightRegion = CreateFrame("Frame", nil, row)
    rightRegion:SetPoint("TOPLEFT", row, "TOP", Layout.ROW_COLUMN_GAP, 0)
    rightRegion:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)

    row.Left = leftRegion
    row.Right = rightRegion

    return row, rowHeight
end

-- Place a toggle across a row region and optionally attach explanatory tooltip text.
function Widgets:CreateRowToggle(region, text, initialValue, callback, tooltip)
    local toggle = self:CreateToggle(region, text, initialValue, callback)

    toggle:ClearAllPoints()
    toggle:SetPoint("RIGHT", region, "RIGHT", Layout.ROW_TOGGLE_RIGHT_MARGIN, 0)

    toggle.Label:ClearAllPoints()
    toggle.Label:SetPoint("LEFT", region, "LEFT", 0, 0)
    toggle.Label:SetPoint("RIGHT", toggle, "LEFT", -Layout.TOGGLE_LABEL_GAP, 0)
    toggle.Label:SetJustifyH("LEFT")

    if tooltip then
        toggle:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(text, 1, 1, 1)
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        toggle:HookScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    return toggle
end

-- Create a multi-select dropdown whose values are owned by callback functions.
function Widgets:CreateCheckboxDropdown(parent, options)
    options = options or {}
    options.items = options.items or {}
    options.width = options.width or Layout.DROPDOWN_WIDTH

    local dropdown = CreateDropdownButton(parent, options)
    CreateDropdownArrow(dropdown)

    local menu = CreateDropdownMenu(dropdown, options.width, #options.items)
    local refreshEntries = {}

    for index, item in ipairs(options.items) do
        refreshEntries[index] = CreateDropdownEntry(
            menu,
            dropdown,
            options,
            item,
            index
        )
    end

    AddDropdownMethods(dropdown, menu, options, refreshEntries)
    return dropdown
end
