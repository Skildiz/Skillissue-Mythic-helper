local _, SMhelper = ...

-- Main-window header. It builds the title and close control; drag behavior is
-- attached by MainWindow because that component owns the movable frame.
local API = SMhelper.UI.API
local Config = SMhelper.Config
local Layout = Config.Layout
local Anchors = Config.UI.AnchorPoints
local ZERO_OFFSET = Layout.Anchor.ZERO_OFFSET

SMhelper.UI.Header = SMhelper.UI.Header or {}
local Header = SMhelper.UI.Header
local headerFrame

-- Create the title while reserving space for the close button.
local function CreateHeaderTitle(parent)
    local title = API:CreateLabel(parent, Config.title, {
        color = Config.colors.text,
        fontSize = Layout.Header.Title.FONT_SIZE,
    })

    title:SetPoint(Anchors.LEFT, Config.padding, ZERO_OFFSET)
    title:SetPoint(
        Anchors.RIGHT,
        Layout.Header.Title.RIGHT_MARGIN,
        ZERO_OFFSET
    )
    return title
end

-- Create a transparent close control with a hover background.
local function CreateCloseButton(parent, onClose)
    local closeButton = API:CreateButton(parent, {
        text = Config.UI.Header.CloseButton.TEXT,
        width = Layout.Header.CloseButton.SIZE,
        height = Layout.Header.CloseButton.SIZE,
        color = Config.colors.transparent,
        hoverColor = Config.colors.panelHover,
        onClick = onClose,
    })

    closeButton:SetPoint(
        Anchors.TOP_RIGHT,
        Layout.Header.CloseButton.X,
        Layout.Header.CloseButton.Y
    )
    return closeButton
end

-- Build the header once and reuse it for the lifetime of the addon.
function Header:Create(parent, onClose)
    if headerFrame then
        return headerFrame
    end

    headerFrame = API:CreatePanel(parent, {
        height = Config.headerHeight,
        color = Config.colors.panel,
    })
    headerFrame:SetFrameLevel(
        parent:GetFrameLevel() + Layout.Frame.LEVEL_INCREMENT
    )

    CreateHeaderTitle(headerFrame)
    CreateCloseButton(headerFrame, onClose)
    API:CreateBorder(
        headerFrame,
        Config.colors.border,
        Layout.Border.DEFAULT_THICKNESS
    )

    return headerFrame
end
