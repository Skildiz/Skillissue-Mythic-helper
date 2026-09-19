local _, SMhelper = ...

-- Quality of Life settings page. Construction is split by feature so combat
-- logging and repair controls can evolve independently.
local API = SMhelper.UI.API
local Widgets = SMhelper.UI.Widgets
local Config = SMhelper.Config
local Layout = Config.Layout
local PageConfig = Config.Pages.QualityOfLife
local Anchors = Config.UI.AnchorPoints
local ZERO_OFFSET = Layout.Anchor.ZERO_OFFSET

local function CreatePageTitle(page)
    local title = API:CreateLabel(page, PageConfig.TITLE, {
        color = Config.colors.text,
        fontSize = Layout.Page.Title.FONT_SIZE,
    })

    title:SetPoint(
        Anchors.TOP_LEFT,
        Layout.Page.Title.X,
        Layout.Page.Title.Y
    )
    return title
end

-- Create the anchored region that contains all vertically stacked controls.
local function CreatePageBody(page, title)
    local body = CreateFrame(
        Config.UI.FrameTypes.FRAME,
        PageConfig.Frame.Body.NAME,
        page
    )

    body:SetPoint(
        Anchors.TOP_LEFT,
        title,
        Anchors.BOTTOM_LEFT,
        Layout.Page.Body.LEFT_X,
        Layout.Page.Body.TOP_OFFSET
    )
    body:SetPoint(
        Anchors.TOP_RIGHT,
        page,
        Anchors.TOP_RIGHT,
        Layout.Page.Body.RIGHT_MARGIN,
        Layout.Page.Body.RIGHT_Y
    )
    body:SetPoint(Anchors.BOTTOM, page, Anchors.BOTTOM)

    return body
end

-- Bind the trigger dropdown directly to the combat logging module API.
local function CreateTriggerDropdown(region, combatLogging)
    local triggerLabel = API:CreateLabel(region, PageConfig.Controls.TRIGGERS, {
        color = Config.colors.text,
    })
    triggerLabel:SetPoint(
        Anchors.LEFT,
        region,
        Anchors.LEFT,
        ZERO_OFFSET,
        ZERO_OFFSET
    )

    local dropdown = Widgets:CreateCheckboxDropdown(region, {
        width = Layout.Dropdown.WIDTH,
        items = combatLogging.Triggers,
        getValue = function(triggerKey)
            return combatLogging:GetTrigger(triggerKey)
        end,
        setValue = function(triggerKey, value)
            combatLogging:SetTrigger(triggerKey, value)
        end,
        getSummary = function()
            return combatLogging:GetTriggerSummary()
        end,
    })
    dropdown:SetPoint(
        Anchors.RIGHT,
        region,
        Anchors.RIGHT,
        Layout.Row.TOGGLE_RIGHT_MARGIN,
        ZERO_OFFSET
    )

    return triggerLabel, dropdown
end

-- Build combat logging controls and return the next available vertical position.
local function CreateCombatLoggingControls(body, combatLogging, y_pos)
    local _, headerHeight = Widgets:CreateSectionHeader(
        body,
        PageConfig.Sections.COMBAT_LOGGING,
        y_pos
    )
    y_pos = y_pos - headerHeight

    local primaryRow = Widgets:CreateTwoColumnRow(body, y_pos)
    y_pos = y_pos - Layout.Row.HEIGHT

    local compatibilityRow = Widgets:CreateTwoColumnRow(body, y_pos)
    y_pos = y_pos - Layout.Row.HEIGHT

    local triggerLabel, triggerDropdown = CreateTriggerDropdown(
        primaryRow.Right,
        combatLogging
    )

    Widgets:CreateRowToggle(
        compatibilityRow.Left,
        PageConfig.Controls.RECORDER_COMPATIBILITY,
        combatLogging:GetDelayStop(),
        function(value)
            combatLogging:SetDelayStop(value)
        end,
        string.format(
            PageConfig.Tooltips.RECORDER_COMPATIBILITY,
            Config.CombatLogging.DELAYED_STOP_SECONDS
        )
    )

    -- Disable dependent controls when the master switch is off.
    local function RefreshDependentControls()
        local isEnabled = combatLogging:IsEnabled()
        triggerDropdown:SetEnabled(isEnabled)
        triggerLabel:SetAlpha(
            isEnabled and Config.Opacity.ENABLED or Config.Opacity.DISABLED
        )
        compatibilityRow:SetShown(isEnabled)
    end

    Widgets:CreateRowToggle(
        primaryRow.Left,
        PageConfig.Controls.ENABLE_AUTO_LOGGING,
        combatLogging:IsEnabled(),
        function(value)
            combatLogging:SetEnabled(value)
            RefreshDependentControls()
        end,
        PageConfig.Tooltips.AUTO_LOGGING
    )

    triggerDropdown:Refresh()
    RefreshDependentControls()
    return y_pos
end

-- Build the general quality-of-life controls below combat logging.
local function CreateAutoRepairControls(body, autoRepair, y_pos)
    y_pos = y_pos - Config.padding

    local _, headerHeight = Widgets:CreateSectionHeader(
        body,
        PageConfig.Sections.GENERAL,
        y_pos
    )
    y_pos = y_pos - headerHeight

    local repairRow = Widgets:CreateTwoColumnRow(body, y_pos)

    Widgets:CreateRowToggle(
        repairRow.Left,
        PageConfig.Controls.ENABLE_AUTO_REPAIR,
        autoRepair:IsEnabled(),
        function(value)
            autoRepair:SetEnabled(value)
        end,
        PageConfig.Tooltips.AUTO_REPAIR
    )
end

-- Lazily create the complete page using whichever feature modules are available.
local function CreateQualityOfLifePage(parent)
    local page = CreateFrame(
        Config.UI.FrameTypes.FRAME,
        PageConfig.Frame.NAME,
        parent
    )
    local title = CreatePageTitle(page)
    local combatLogging = SMhelper.Modules and SMhelper.Modules.CombatLogging
    local autoRepair = SMhelper.Modules and SMhelper.Modules.AutoRepair

    if not combatLogging then
        return page
    end

    local body = CreatePageBody(page, title)
    local y_pos = ZERO_OFFSET
    y_pos = CreateCombatLoggingControls(body, combatLogging, y_pos)

    if autoRepair then
        CreateAutoRepairControls(body, autoRepair, y_pos)
    end

    return page
end

SMhelper.UI:RegisterPage(PageConfig.NAME, {
    title = PageConfig.TITLE,
    create = CreateQualityOfLifePage,
})
