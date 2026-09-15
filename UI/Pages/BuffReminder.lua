local _, SMhelper = ...

-- buff reminder settings page
-- register the page in the sidebar
SMhelper.UI:RegisterPage("buffReminder", {
    title = "Buff Reminder",
    create = function(parent)
        local page = CreateFrame("Frame", nil, parent)
        local title = SMhelper.UI.API:CreateLabel(page, "Buff Reminder", {
            color = SMhelper.Config.colors.text,
            fontSize = 20,
        })
        title:SetPoint("TOPLEFT", 8, -8)

        -- connect the toggle to the feature module
        local feature = SMhelper.Modules and SMhelper.Modules.BuffReminder
        if feature then
            local toggle = SMhelper.UI.Widgets:CreateToggle(page, "Enable buff reminders", feature:IsEnabled(), function(value)
                feature:SetEnabled(value)
            end)
            toggle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)
        end
        return page
    end,
})
