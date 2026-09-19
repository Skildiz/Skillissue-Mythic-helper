local _, SMhelper = ...

-- Reusable higher-level controls built on UI/API.lua. Complex widgets are split
-- into construction, behavior, and refresh helpers to keep public factories small.
local API = SMhelper.UI.API
local Config = SMhelper.Config
local Layout = Config.Layout
local UIConfig = Config.UI
local Anchors = UIConfig.AnchorPoints
local Layers = UIConfig.DrawLayers
local Scripts = UIConfig.Scripts
local ZERO_OFFSET = Layout.Anchor.ZERO_OFFSET

SMhelper.UI.Widgets = SMhelper.UI.Widgets or {}
local Widgets = SMhelper.UI.Widgets

-- Keep toggle color and knob position synchronized with its boolean value.
local function RefreshToggleAppearance(button, knob, isEnabled)
    if isEnabled then
        button.Background:SetColorTexture(unpack(Config.colors.accent))
        knob:SetColorTexture(unpack(Config.colors.toggleKnobEnabled))
        knob:ClearAllPoints()
        knob:SetPoint(Anchors.RIGHT, -Layout.Toggle.KNOB_OFFSET, ZERO_OFFSET)
        return
    end

    button.Background:SetColorTexture(unpack(Config.colors.panel))
    knob:SetColorTexture(unpack(Config.colors.toggleDisabled))
    knob:ClearAllPoints()
    knob:SetPoint(Anchors.LEFT, Layout.Toggle.KNOB_OFFSET, ZERO_OFFSET)
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

    button:SetScript(Scripts.MOUSE_UP, function()
        button:SetValue(not currentValue)
    end)

    RefreshToggleAppearance(button, knob, currentValue)
end

local function CreateDropdownButton(parent, options)
    local dropdown = API:CreateButton(parent, {
        width = options.width,
        height = Layout.Dropdown.HEIGHT,
        color = Config.colors.panel,
        hoverColor = Config.colors.panelHover,
        textColor = Config.colors.text,
        justifyH = UIConfig.HorizontalAlignment.LEFT,
    })

    API:CreateBorder(
        dropdown,
        Config.colors.border,
        Layout.Border.DEFAULT_THICKNESS
    )
    return dropdown
end

local function CreateDropdownArrow(dropdown)
    local arrow = dropdown:CreateTexture(nil, Layers.OVERLAY)

    arrow:SetSize(Layout.Dropdown.ARROW_SIZE, Layout.Dropdown.ARROW_SIZE)
    arrow:SetPoint(Anchors.RIGHT, Layout.Dropdown.ARROW_RIGHT, ZERO_OFFSET)
    arrow:SetTexture(Config.Paths.Interface.Buttons.DROPDOWN_ARROW)

    dropdown.Label:ClearAllPoints()
    dropdown.Label:SetPoint(
        Anchors.LEFT,
        Layout.Button.TEXT_INSET,
        ZERO_OFFSET
    )
    dropdown.Label:SetPoint(
        Anchors.RIGHT,
        arrow,
        Anchors.LEFT,
        -Layout.Dropdown.MENU_PADDING,
        ZERO_OFFSET
    )
    dropdown.Label:SetJustifyH(UIConfig.HorizontalAlignment.LEFT)
    dropdown.Label:SetWordWrap(false)
end

local function CreateDropdownMenu(dropdown, width, itemCount)
    local menu = API:CreatePanel(dropdown, {
        width = width,
        color = Config.colors.panelHover,
    })

    menu:SetFrameLevel(dropdown:GetFrameLevel() + Layout.ResizeHandle.FRAME_LEVEL_OFFSET)
    menu:SetPoint(
        Anchors.TOP_RIGHT,
        dropdown,
        Anchors.BOTTOM_RIGHT,
        ZERO_OFFSET,
        Layout.Dropdown.MENU_OFFSET_Y
    )
    menu:SetHeight(
        Layout.Dropdown.MENU_VERTICAL_PADDING
        + itemCount * Layout.Dropdown.ROW_HEIGHT
    )
    API:CreateBorder(
        menu,
        Config.colors.border,
        Layout.Border.DEFAULT_THICKNESS
    )
    menu:Hide()

    return menu
end

-- Build one checkbox row and return a function that refreshes its check mark.
local function CreateDropdownEntry(menu, dropdown, options, item, index)
    local padding = Layout.Dropdown.MENU_PADDING
    local rowHeight = Layout.Dropdown.ROW_HEIGHT
    local topOffset = -padding
        - (index - Config.Collections.FIRST_INDEX) * rowHeight

    local entry = API:CreateButton(menu, {
        height = rowHeight,
        color = Config.colors.transparent,
        hoverColor = Config.colors.panelHover,
        textColor = Config.colors.text,
        text = item.text,
        justifyH = UIConfig.HorizontalAlignment.LEFT,
        textInset = Layout.Dropdown.ENTRY_TEXT_INSET,
    })

    entry:SetPoint(Anchors.TOP_LEFT, padding, topOffset)
    entry:SetPoint(Anchors.TOP_RIGHT, -padding, topOffset)

    local emptyBox = entry:CreateTexture(nil, Layers.ARTWORK)
    emptyBox:SetSize(Layout.Dropdown.CHECKBOX_SIZE, Layout.Dropdown.CHECKBOX_SIZE)
    emptyBox:SetPoint(
        Anchors.LEFT,
        Layout.Dropdown.CHECKBOX_LEFT,
        ZERO_OFFSET
    )
    emptyBox:SetTexture(Config.Paths.Interface.Buttons.CHECKBOX.EMPTY)

    local checkMark = entry:CreateTexture(nil, Layers.OVERLAY)
    checkMark:SetSize(Layout.Dropdown.CHECKBOX_SIZE, Layout.Dropdown.CHECKBOX_SIZE)
    checkMark:SetPoint(
        Anchors.LEFT,
        Layout.Dropdown.CHECKBOX_LEFT,
        ZERO_OFFSET
    )
    checkMark:SetTexture(Config.Paths.Interface.Buttons.CHECKBOX.CHECKED)

    local function RefreshCheckMark()
        checkMark:SetShown(options.getValue(item.key) == true)
    end

    entry:SetScript(Scripts.CLICK, function()
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
        self:SetAlpha(
            self.isEnabled and Config.Opacity.ENABLED or Config.Opacity.DISABLED
        )
        self:EnableMouse(self.isEnabled)

        if not self.isEnabled then
            menu:Hide()
        end
    end

    dropdown:SetScript(Scripts.CLICK, function()
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
        width = Layout.Toggle.WIDTH,
        height = Layout.Toggle.HEIGHT,
        color = Config.colors.panel,
    })
    button:EnableMouse(true)

    local knob = button:CreateTexture(nil, Layers.ARTWORK)
    knob:SetSize(Layout.Toggle.KNOB_SIZE, Layout.Toggle.KNOB_SIZE)
    button.Knob = knob

    local label = API:CreateLabel(parent, text, { color = Config.colors.text })
    label:SetPoint(
        Anchors.LEFT,
        button,
        Anchors.RIGHT,
        Layout.Toggle.LABEL_GAP,
        ZERO_OFFSET
    )
    button.Label = label

    AddToggleMethods(button, knob, initialValue, callback)
    return button
end

-- Create an uppercase heading with a divider and report consumed vertical space.
function Widgets:CreateSectionHeader(parent, text, y_pos)
    local frame = CreateFrame(UIConfig.FrameTypes.FRAME, nil, parent)
    local verticalPosition = y_pos or ZERO_OFFSET

    frame:SetHeight(Layout.SectionHeader.HEIGHT)
    frame:SetPoint(Anchors.TOP_LEFT, ZERO_OFFSET, verticalPosition)
    frame:SetPoint(Anchors.TOP_RIGHT, ZERO_OFFSET, verticalPosition)

    local label = API:CreateLabel(frame, string.upper(text or ""), {
        color = Config.colors.mutedText,
        fontSize = Layout.SectionHeader.FONT_SIZE,
    })
    label:SetPoint(Anchors.LEFT, ZERO_OFFSET, ZERO_OFFSET)

    local divider = frame:CreateTexture(nil, Layers.ARTWORK)
    divider:SetHeight(Layout.SectionHeader.DIVIDER_HEIGHT)
    divider:SetColorTexture(unpack(Config.colors.border))
    divider:SetPoint(
        Anchors.LEFT,
        label,
        Anchors.RIGHT,
        Layout.SectionHeader.DIVIDER_GAP,
        ZERO_OFFSET
    )
    divider:SetPoint(Anchors.RIGHT, ZERO_OFFSET, ZERO_OFFSET)

    frame.Label = label
    return frame, Layout.SectionHeader.SPACE
end

-- Create equal left/right regions separated by the configured column gap.
function Widgets:CreateTwoColumnRow(parent, y_pos, height)
    local rowHeight = height or Layout.Row.HEIGHT
    local verticalPosition = y_pos or ZERO_OFFSET
    local row = CreateFrame(UIConfig.FrameTypes.FRAME, nil, parent)

    row:SetHeight(rowHeight)
    row:SetPoint(Anchors.TOP_LEFT, ZERO_OFFSET, verticalPosition)
    row:SetPoint(Anchors.TOP_RIGHT, ZERO_OFFSET, verticalPosition)

    local leftRegion = CreateFrame(UIConfig.FrameTypes.FRAME, nil, row)
    leftRegion:SetPoint(
        Anchors.TOP_LEFT,
        row,
        Anchors.TOP_LEFT,
        ZERO_OFFSET,
        ZERO_OFFSET
    )
    leftRegion:SetPoint(
        Anchors.BOTTOM_RIGHT,
        row,
        Anchors.BOTTOM,
        -Layout.Row.COLUMN_GAP,
        ZERO_OFFSET
    )

    local rightRegion = CreateFrame(UIConfig.FrameTypes.FRAME, nil, row)
    rightRegion:SetPoint(
        Anchors.TOP_LEFT,
        row,
        Anchors.TOP,
        Layout.Row.COLUMN_GAP,
        ZERO_OFFSET
    )
    rightRegion:SetPoint(
        Anchors.BOTTOM_RIGHT,
        row,
        Anchors.BOTTOM_RIGHT,
        ZERO_OFFSET,
        ZERO_OFFSET
    )

    row.Left = leftRegion
    row.Right = rightRegion

    return row, rowHeight
end

-- Place a toggle across a row region and optionally attach explanatory tooltip text.
function Widgets:CreateRowToggle(region, text, initialValue, callback, tooltip)
    local toggle = self:CreateToggle(region, text, initialValue, callback)

    toggle:ClearAllPoints()
    toggle:SetPoint(
        Anchors.RIGHT,
        region,
        Anchors.RIGHT,
        Layout.Row.TOGGLE_RIGHT_MARGIN,
        ZERO_OFFSET
    )

    toggle.Label:ClearAllPoints()
    toggle.Label:SetPoint(
        Anchors.LEFT,
        region,
        Anchors.LEFT,
        ZERO_OFFSET,
        ZERO_OFFSET
    )
    toggle.Label:SetPoint(
        Anchors.RIGHT,
        toggle,
        Anchors.LEFT,
        -Layout.Toggle.LABEL_GAP,
        ZERO_OFFSET
    )
    toggle.Label:SetJustifyH(UIConfig.HorizontalAlignment.LEFT)

    if tooltip then
        toggle:HookScript(Scripts.ENTER, function(self)
            local tooltipColor = Config.colors.tooltipTitle
            GameTooltip:SetOwner(self, Config.UI.Tooltip.ANCHOR)
            GameTooltip:SetText(text, unpack(tooltipColor))
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        toggle:HookScript(Scripts.LEAVE, function()
            GameTooltip:Hide()
        end)
    end

    return toggle
end

-- Create a multi-select dropdown whose values are owned by callback functions.
function Widgets:CreateCheckboxDropdown(parent, options)
    options = options or {}
    options.items = options.items or {}
    options.width = options.width or Layout.Dropdown.WIDTH

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
