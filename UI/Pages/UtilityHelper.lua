local _, SMhelper = ...

local Config = SMhelper.Config
local Layout = Config.Layout
local PageConfig = Config.Pages.UtilityHelper
local Anchors = Config.UI.AnchorPoints

-- Register the Utility Helper placeholder page. Additional utility controls can
-- be added to this lazy factory without changing window composition code.
SMhelper.UI:RegisterPage(PageConfig.NAME, {
    title = PageConfig.TITLE,
    create = function(parent)
        local page = CreateFrame(
            Config.UI.FrameTypes.FRAME,
            PageConfig.Frame.NAME,
            parent
        )
        local label = SMhelper.UI.API:CreateLabel(page, PageConfig.TITLE, {
            name = PageConfig.Frame.Label.NAME,
            color = Config.colors.text,
            fontSize = Layout.Page.Title.FONT_SIZE,
        })
        label:SetPoint(
            Anchors.TOP_LEFT,
            Layout.Page.Title.X,
            Layout.Page.Title.Y
        )
        return page
    end,
})
