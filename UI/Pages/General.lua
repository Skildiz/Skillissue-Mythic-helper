local _, SMhelper = ...

local Config = SMhelper.Config
local Layout = Config.Layout
local PageConfig = Config.Pages.General
local Anchors = Config.UI.AnchorPoints

-- Register the General settings page. The frame is created lazily when the
-- user first selects this page from the sidebar.
SMhelper.UI:RegisterPage(PageConfig.NAME, {
    title = PageConfig.TITLE,
    create = function(parent)
        local page = CreateFrame(
            Config.UI.FrameTypes.FRAME,
            PageConfig.Frame.NAME,
            parent
        )
        local title = SMhelper.UI.API:CreateLabel(page, PageConfig.TITLE, {
            color = Config.colors.text,
            fontSize = Layout.Page.Title.GENERAL_FONT_SIZE,
        })
        title:SetPoint(
            Anchors.TOP_LEFT,
            Layout.Page.Title.X,
            Layout.Page.Title.Y
        )
        return page
    end,
})
