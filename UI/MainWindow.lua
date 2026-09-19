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

    frame:SetPoint("CENTER")
    frame:SetFrameStrata(Config.frameStrata)
    frame:SetFrameLevel(Config.frameLevel)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(Config.minWidth, Config.minHeight)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    API:CreateBorder(frame, Config.colors.border, 1)

    return frame
end

-- Attach close and drag behavior to the header component.
local function CreateWindowHeader(frame)
    local header = Header:Create(frame, function()
        UI:Hide()
    end)

    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    header:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
    end)

    return header
end

local function CreateWindowSidebar(frame, header)
    local sidebar = Sidebar:Create(frame)
    sidebar:SetPoint("TOPLEFT", header, "BOTTOMLEFT")
    sidebar:SetPoint("BOTTOMLEFT")
    return sidebar
end

local function CreateContentFrame(frame, sidebar)
    local content = Content:Create(frame)
    content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", Config.padding, 0)
    content:SetPoint("BOTTOMRIGHT", -Config.padding, Config.padding)
    return content
end

-- Create the bottom-right grip and connect mouse gestures to frame resizing.
local function CreateResizeHandle(frame)
    local resizeHandle = CreateFrame("Button", nil, frame)

    resizeHandle:SetSize(Layout.RESIZE_HANDLE_SIZE, Layout.RESIZE_HANDLE_SIZE)
    resizeHandle:SetPoint(
        "BOTTOMRIGHT",
        Layout.RESIZE_HANDLE_X,
        Layout.RESIZE_HANDLE_Y
    )
    resizeHandle:SetFrameLevel(
        frame:GetFrameLevel() + Layout.RESIZE_FRAME_LEVEL_OFFSET
    )
    resizeHandle:SetNormalTexture(Config.Paths.RESIZE_NORMAL)
    resizeHandle:SetHighlightTexture(Config.Paths.RESIZE_HIGHLIGHT)
    resizeHandle:SetPushedTexture(Config.Paths.RESIZE_PUSHED)

    resizeHandle:SetScript("OnMouseDown", function(_, mouseButton)
        if mouseButton == "LeftButton" then
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)

    resizeHandle:SetScript("OnMouseUp", function()
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

-- Register a page factory without constructing its frame immediately.
function UI:RegisterPage(pageId, pageSpecification)
    assert(
        type(pageId) == "string"
        and type(pageSpecification) == "table"
        and type(pageSpecification.create) == "function",
        "Invalid page registration"
    )

    if not registeredPages[pageId] then
        pageOrder[#pageOrder + 1] = pageId
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
