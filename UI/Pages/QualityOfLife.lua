local _, SMhelper = ...

-- Quality of Life settings page. Construction is split by feature so combat
-- logging and repair controls can evolve independently.
local API = SMhelper.UI.API
local Widgets = SMhelper.UI.Widgets
local Config = SMhelper.Config
local Layout = Config.Layout

local function CreatePageTitle(page)
    local title = API:CreateLabel(page, "Quality of Life", {
        color = Config.colors.text,
        fontSize = Layout.PAGE_TITLE_FONT_SIZE,
    })

    title:SetPoint("TOPLEFT", Layout.PAGE_TITLE_X, Layout.PAGE_TITLE_Y)
    return title
end

-- Create the anchored region that contains all vertically stacked controls.
local function CreatePageBody(page, title)
    local body = CreateFrame("Frame", nil, page)

    body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, Layout.PAGE_BODY_TOP_OFFSET)
    body:SetPoint("TOPRIGHT", page, "TOPRIGHT", Layout.PAGE_BODY_RIGHT_MARGIN, 0)
    body:SetPoint("BOTTOM", page, "BOTTOM")

    return body
end

-- Bind the trigger dropdown directly to the combat logging module API.
local function CreateTriggerDropdown(region, combatLogging)
    local triggerLabel = API:CreateLabel(region, "Auto-Log Triggers", {
        color = Config.colors.text,
    })
    triggerLabel:SetPoint("LEFT", region, "LEFT", 0, 0)

    local dropdown = Widgets:CreateCheckboxDropdown(region, {
        width = Layout.DROPDOWN_WIDTH,
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
    dropdown:SetPoint("RIGHT", region, "RIGHT", Layout.ROW_TOGGLE_RIGHT_MARGIN, 0)

    return triggerLabel, dropdown
end

-- Build combat logging controls and return the next available vertical position.
local function CreateCombatLoggingControls(body, combatLogging, y_pos)
    local _, headerHeight = Widgets:CreateSectionHeader(
        body,
        "AUTO COMBAT LOGGING",
        y_pos
    )
    y_pos = y_pos - headerHeight

    local primaryRow = Widgets:CreateTwoColumnRow(body, y_pos)
    y_pos = y_pos - Layout.ROW_HEIGHT

    local compatibilityRow = Widgets:CreateTwoColumnRow(body, y_pos)
    y_pos = y_pos - Layout.ROW_HEIGHT

    local triggerLabel, triggerDropdown = CreateTriggerDropdown(
        primaryRow.Right,
        combatLogging
    )

    Widgets:CreateRowToggle(
        compatibilityRow.Left,
        "Warcraft Recorder Compatibility",
        combatLogging:GetDelayStop(),
        function(value)
            combatLogging:SetDelayStop(value)
        end,
        string.format(
            "Delays stopping combat logging by %d seconds after leaving an instance. Recommended for Warcraft Recorder compatibility.",
            Config.CombatLogging.DELAYED_STOP_SECONDS
        )
    )

    -- Disable dependent controls when the master switch is off.
    local function RefreshDependentControls()
        local isEnabled = combatLogging:IsEnabled()
        triggerDropdown:SetEnabled(isEnabled)
        triggerLabel:SetAlpha(isEnabled and 1 or 0.3)
        compatibilityRow:SetShown(isEnabled)
    end

    Widgets:CreateRowToggle(
        primaryRow.Left,
        "Enable Auto Logging",
        combatLogging:IsEnabled(),
        function(value)
            combatLogging:SetEnabled(value)
            RefreshDependentControls()
        end,
        "Automatically starts and stops combat logging when entering or leaving a loggable instance."
    )

    triggerDropdown:Refresh()
    RefreshDependentControls()
    return y_pos
end

-- Build the general quality-of-life controls below combat logging.
local function CreateAutoRepairControls(body, autoRepair, y_pos)
    y_pos = y_pos - Config.padding

    local _, headerHeight = Widgets:CreateSectionHeader(body, "GENERAL", y_pos)
    y_pos = y_pos - headerHeight

    local repairRow = Widgets:CreateTwoColumnRow(body, y_pos)

    Widgets:CreateRowToggle(
        repairRow.Left,
        "Enable Auto Repair",
        autoRepair:IsEnabled(),
        function(value)
            autoRepair:SetEnabled(value)
        end,
        "Automatically repairs damaged equipment when opening a repair merchant. Guild repair funds are used when available."
    )
end

-- Lazily create the complete page using whichever feature modules are available.
local function CreateQualityOfLifePage(parent)
    local page = CreateFrame("Frame", nil, parent)
    local title = CreatePageTitle(page)
    local combatLogging = SMhelper.Modules and SMhelper.Modules.CombatLogging
    local autoRepair = SMhelper.Modules and SMhelper.Modules.AutoRepair

    if not combatLogging then
        return page
    end

    local body = CreatePageBody(page, title)
    local y_pos = 0
    y_pos = CreateCombatLoggingControls(body, combatLogging, y_pos)

    if autoRepair then
        CreateAutoRepairControls(body, autoRepair, y_pos)
    end

    return page
end

SMhelper.UI:RegisterPage("qualityOfLife", {
    title = "Quality of Life",
    create = CreateQualityOfLifePage,
})
