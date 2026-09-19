local _, SMhelper = ...

-- Main settings-window coordinator. It composes independent UI components,
-- manages lazy page registration, and exposes the public show/hide API.
local UI = SMhelper.UI
local Config = SMhelper.Config
local Layout = Config.Layout
local API = UI.API
local Header = UI.Header
local Sidebar = UI.Sidebar
local Content = UI.Content
local UIConfig = Config.UI
local Anchors = UIConfig.AnchorPoints
local Scripts = UIConfig.Scripts
local ZERO_OFFSET = Layout.Anchor.ZERO_OFFSET

local mainFrame
local contentFrame
local registeredPages = {}
local pageOrder = {}

-- Create and configure the movable, resizable root frame.
local function CreateMainFrame()
    local frame = API:CreatePanel(UIParent, {
        width = Config.width,
        height = Config.height,
        color = Config.colors.background,
    })

    frame:SetPoint(Anchors.CENTER)
    frame:SetFrameStrata(Config.frameStrata)
    frame:SetFrameLevel(Config.frameLevel)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(Config.minWidth, Config.minHeight)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    API:CreateBorder(
        frame,
        Config.colors.border,
        Layout.Border.DEFAULT_THICKNESS
    )

    return frame
end

-- Attach close and drag behavior to the header component.
local function CreateWindowHeader(frame)
    local header = Header:Create(frame, function()
        UI:Hide()
    end)

    header:SetPoint(Anchors.TOP_LEFT)
    header:SetPoint(Anchors.TOP_RIGHT)
    header:EnableMouse(true)
    header:RegisterForDrag(UIConfig.MouseButtons.LEFT)
    header:SetScript(Scripts.DRAG_START, function()
        frame:StartMoving()
    end)
    header:SetScript(Scripts.DRAG_STOP, function()
        frame:StopMovingOrSizing()
    end)

    return header
end

local function CreateWindowSidebar(frame, header)
    local sidebar = Sidebar:Create(frame)
    sidebar:SetPoint(Anchors.TOP_LEFT, header, Anchors.BOTTOM_LEFT)
    sidebar:SetPoint(Anchors.BOTTOM_LEFT)
    return sidebar
end

local function CreateContentFrame(frame, sidebar)
    local content = Content:Create(frame)
    content:SetPoint(
        Anchors.TOP_LEFT,
        sidebar,
        Anchors.TOP_RIGHT,
        Config.padding,
        ZERO_OFFSET
    )
    content:SetPoint(
        Anchors.BOTTOM_RIGHT,
        -Config.padding,
        Config.padding
    )
    return content
end

-- Create the bottom-right grip and connect mouse gestures to frame resizing.
local function CreateResizeHandle(frame)
    local resizeHandle = CreateFrame(UIConfig.FrameTypes.BUTTON, nil, frame)

    resizeHandle:SetSize(Layout.ResizeHandle.SIZE, Layout.ResizeHandle.SIZE)
    resizeHandle:SetPoint(
        Anchors.BOTTOM_RIGHT,
        Layout.ResizeHandle.X,
        Layout.ResizeHandle.Y
    )
    resizeHandle:SetFrameLevel(
        frame:GetFrameLevel() + Layout.ResizeHandle.FRAME_LEVEL_OFFSET
    )
    resizeHandle:SetNormalTexture(Config.Paths.Interface.ChatFrame.RESIZE_HANDLE.NORMAL)
    resizeHandle:SetHighlightTexture(Config.Paths.Interface.ChatFrame.RESIZE_HANDLE.HIGHLIGHT)
    resizeHandle:SetPushedTexture(Config.Paths.Interface.ChatFrame.RESIZE_HANDLE.PUSHED)

    resizeHandle:SetScript(Scripts.MOUSE_DOWN, function(_, mouseButton)
        if mouseButton == UIConfig.MouseButtons.LEFT then
            frame:StartSizing(Anchors.BOTTOM_RIGHT)
        end
    end)

    resizeHandle:SetScript(Scripts.MOUSE_UP, function()
        frame:StopMovingOrSizing()
    end)

    return resizeHandle
end

-- Lazily construct a registered page, then synchronize content and sidebar state.
local function ShowRegisteredPage(pageId)
    local pageSpecification = registeredPages[pageId]

    if not pageSpecification then
        return false
    end

    if not Content:HasPage(pageId) then
        local pageFrame = pageSpecification.create(contentFrame)
        Content:RegisterPage(pageId, pageFrame)
    end

    Content:ShowPage(pageId)
    Sidebar:SetSelected(pageId)
    return true
end

-- Build sidebar buttons in the same order pages were registered.
local function CreateNavigationButtons()
    Sidebar:SetOnSelect(ShowRegisteredPage)

    for _, pageId in ipairs(pageOrder) do
        local pageSpecification = registeredPages[pageId]
        Sidebar:AddButton({
            id = pageId,
            text = pageSpecification.title or pageId,
        })
    end
end

local function ValidatePageRegistration(pageId, pageSpecification)
    assert(type(pageId) == "string", "Page ID must be a string")
    assert(type(pageSpecification) == "table", "Page specification must be a table")
    assert(
        type(pageSpecification.create) == "function",
        "Page specification must provide a create function"
    )
end

-- Register a page factory without constructing its frame immediately.
function UI:RegisterPage(pageId, pageSpecification)
    ValidatePageRegistration(pageId, pageSpecification)

    if not registeredPages[pageId] then
        pageOrder[
            #pageOrder + Config.Collections.NEXT_INDEX_OFFSET
        ] = pageId
    end

    registeredPages[pageId] = pageSpecification
end

-- Compose the complete settings window once and select the default page.
function UI:CreateMainWindow()
    if mainFrame then
        return mainFrame
    end

    mainFrame = CreateMainFrame()
    local header = CreateWindowHeader(mainFrame)
    local sidebar = CreateWindowSidebar(mainFrame, header)
    contentFrame = CreateContentFrame(mainFrame, sidebar)

    CreateResizeHandle(mainFrame)
    CreateNavigationButtons()

    mainFrame:Hide()
    ShowRegisteredPage(Config.defaultPage)
    return mainFrame
end

function UI:ShowPage(pageId)
    self:CreateMainWindow()
    return ShowRegisteredPage(pageId)
end

function UI:Show()
    self:CreateMainWindow():Show()
end

function UI:Hide()
    if mainFrame then
        mainFrame:Hide()
    end
end

function UI:Toggle()
    self:CreateMainWindow()
    mainFrame:SetShown(not mainFrame:IsShown())
end

function UI:IsShown()
    return mainFrame and mainFrame:IsShown() or false
end
