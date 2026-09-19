local _, SMhelper = ...

local Config = SMhelper.Config
local Layout = Config.Layout
local PageConfig = Config.Pages.BuffReminder
local Anchors = Config.UI.AnchorPoints
local ZERO_OFFSET = Layout.Anchor.ZERO_OFFSET

-- Register the Buff Reminder page. Its toggle delegates state management to
-- the feature module so the page remains a presentation-only component.
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
            fontSize = Layout.Page.Title.FONT_SIZE,
        })
        title:SetPoint(
            Anchors.TOP_LEFT,
            Layout.Page.Title.X,
            Layout.Page.Title.Y
        )

        -- connect the toggle to the feature module
        local feature = SMhelper.Modules and SMhelper.Modules.BuffReminder
        if feature then
            local toggle = SMhelper.UI.Widgets:CreateToggle(
                page,
                PageConfig.TOGGLE_TEXT,
                feature:IsEnabled(),
                function(value)
                    feature:SetEnabled(value)
                end
            )
            toggle:SetPoint(
                Anchors.TOP_LEFT,
                title,
                Anchors.BOTTOM_LEFT,
                ZERO_OFFSET,
                Layout.Page.CONTROL_GAP
            )
        end
        return page
    end,
})
