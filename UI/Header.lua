local _, SMhelper = ...

-- Main-window header. It builds the title and close control; drag behavior is
-- attached by MainWindow because that component owns the movable frame.
local API = SMhelper.UI.API
local Config = SMhelper.Config
local Layout = Config.Layout

SMhelper.UI.Header = SMhelper.UI.Header or {}
local Header = SMhelper.UI.Header
local headerFrame

-- Create the title while reserving space for the close button.
local function CreateHeaderTitle(parent)
    local title = API:CreateLabel(parent, Config.title, {
        color = Config.colors.text,
        fontSize = Layout.HEADER_TITLE_FONT_SIZE,
    })

    title:SetPoint("LEFT", Config.padding, 0)
    title:SetPoint("RIGHT", Layout.HEADER_TITLE_RIGHT_MARGIN, 0)
    return title
end

-- Create a transparent close control with a hover background.
local function CreateCloseButton(parent, onClose)
    local closeButton = API:CreateButton(parent, {
        text = "X",
        width = Layout.HEADER_CLOSE_SIZE,
        height = Layout.HEADER_CLOSE_SIZE,
        color = Config.colors.transparent,
        hoverColor = Config.colors.panelHover,
        onClick = onClose,
    })

    closeButton:SetPoint(
        "TOPRIGHT",
        Layout.HEADER_CLOSE_X,
        Layout.HEADER_CLOSE_Y
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
    headerFrame:SetFrameLevel(parent:GetFrameLevel() + 1)

    CreateHeaderTitle(headerFrame)
    CreateCloseButton(headerFrame, onClose)
    API:CreateBorder(headerFrame, Config.colors.border, 1)

    return headerFrame
end
