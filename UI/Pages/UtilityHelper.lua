local _, SMhelper = ...

local Layout = SMhelper.Config.Layout

-- Register the Utility Helper placeholder page. Additional utility controls can
-- be added to this lazy factory without changing window composition code.
SMhelper.UI:RegisterPage("utilityHelper", {
    title = "Utility helper",
    create = function(parent)
        local page = CreateFrame("Frame", nil, parent)
        local label = SMhelper.UI.API:CreateLabel(page, "Utility helper", {
            color = SMhelper.Config.colors.text,
            fontSize = Layout.PAGE_TITLE_FONT_SIZE,
        })
        label:SetPoint("TOPLEFT", Layout.PAGE_TITLE_X, Layout.PAGE_TITLE_Y)
        return page
    end,
})
