local _, SMhelper = ...

local Layout = SMhelper.Config.Layout

-- Register the General settings page. The frame is created lazily when the
-- user first selects this page from the sidebar.
SMhelper.UI:RegisterPage("general", {
    title = "General",
    create = function(parent)
        local page = CreateFrame("Frame", nil, parent)
        local title = SMhelper.UI.API:CreateLabel(page, "General", {
            color = SMhelper.Config.colors.text,
            fontSize = Layout.GENERAL_PAGE_TITLE_FONT_SIZE,
        })
        title:SetPoint("TOPLEFT", Layout.PAGE_TITLE_X, Layout.PAGE_TITLE_Y)
        return page
    end,
})
