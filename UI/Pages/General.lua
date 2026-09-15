local _, SMhelper = ...

-- general settings page
-- register the page in the sidebar
SMhelper.UI:RegisterPage("general", {
    title = "General",
    create = function(parent)
        local page = CreateFrame("Frame", nil, parent)
        local title = SMhelper.UI.API:CreateLabel(page, "General", {
            color = SMhelper.Config.colors.text,
            fontSize = 24,
        })
        title:SetPoint("TOPLEFT", 8, -8)
        return page
    end,
})
