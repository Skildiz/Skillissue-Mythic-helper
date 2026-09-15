local _, SMhelper = ...

-- utility helper settings page
-- register the page in the sidebar
SMhelper.UI:RegisterPage("utilityHelper", {
    title = "Utility helper",
    create = function(parent)
        local page = CreateFrame("Frame", nil, parent)
        local label = SMhelper.UI.API:CreateLabel(page, "Utility helper", {
            color = SMhelper.Config.colors.text,
            fontSize = 20,
        })
        label:SetPoint("TOPLEFT", 8, -8)
        return page
    end,
})
