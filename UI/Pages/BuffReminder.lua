local _, SMhelper = ...

local Layout = SMhelper.Config.Layout

-- Register the Buff Reminder page. Its toggle delegates state management to
-- the feature module so the page remains a presentation-only component.
SMhelper.UI:RegisterPage("buffReminder", {
    title = "Buff Reminder",
    create = function(parent)
        local page = CreateFrame("Frame", nil, parent)
        local title = SMhelper.UI.API:CreateLabel(page, "Buff Reminder", {
            color = SMhelper.Config.colors.text,
            fontSize = Layout.PAGE_TITLE_FONT_SIZE,
        })
        title:SetPoint("TOPLEFT", Layout.PAGE_TITLE_X, Layout.PAGE_TITLE_Y)

        -- connect the toggle to the feature module
        local feature = SMhelper.Modules and SMhelper.Modules.BuffReminder
        if feature then
            local toggle = SMhelper.UI.Widgets:CreateToggle(page, "Enable buff reminders", feature:IsEnabled(), function(value)
                feature:SetEnabled(value)
            end)
            toggle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, Layout.PAGE_CONTROL_GAP)
        end
        return page
    end,
})
