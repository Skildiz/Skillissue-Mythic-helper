local _, SMhelper = ...

-- main window composition and public UI methods
local UI, Config = SMhelper.UI, SMhelper.Config
local API, Header, Sidebar, Content = UI.API, UI.Header, UI.Sidebar, UI.Content
local frame, contentFrame
local pages, order = {}, {}

-- register a lazy page factory
function UI:RegisterPage(id, spec)
    assert(type(id) == "string" and type(spec) == "table" and type(spec.create) == "function", "Invalid page")
    if not pages[id] then order[#order + 1] = id end
    pages[id] = spec
end

-- create a page on first use, then show it
local function selectPage(id)
    local spec = pages[id]
    if not spec then return false end
    if not Content:HasPage(id) then Content:RegisterPage(id, spec.create(contentFrame)) end
    Content:ShowPage(id)
    Sidebar:SetSelected(id)
    return true
end

-- build the complete window once
function UI:Create()
    if frame then return frame end

    frame = API:CreatePanel(UIParent, {
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

    local header = Header:Create(frame, function() UI:Hide() end)
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() frame:StartMoving() end)
    header:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    local sidebar = Sidebar:Create(frame)
    sidebar:SetPoint("TOPLEFT", header, "BOTTOMLEFT")
    sidebar:SetPoint("BOTTOMLEFT")

    contentFrame = Content:Create(frame)
    contentFrame:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", Config.padding, 0)
    contentFrame:SetPoint("BOTTOMRIGHT", -Config.padding, Config.padding)

    -- bottom-right resize handle
    local resize = CreateFrame("Button", nil, frame)
    resize:SetSize(20, 20)
    resize:SetPoint("BOTTOMRIGHT", -2, 2)
    resize:SetFrameLevel(frame:GetFrameLevel() + 10)
    resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resize:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then frame:StartSizing("BOTTOMRIGHT") end
    end)
    resize:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)

    Sidebar:SetOnSelect(selectPage)
    for _, id in ipairs(order) do
        Sidebar:AddButton({ id = id, text = pages[id].title or id })
    end

    frame:Hide()
    selectPage(Config.defaultPage)
    return frame
end

-- open a page by its id
function UI:ShowPage(id)
    self:Create()
    return selectPage(id)
end

-- public window controls
function UI:Show() self:Create():Show() end
function UI:Hide() if frame then frame:Hide() end end
function UI:Toggle() self:Create(); frame:SetShown(not frame:IsShown()) end
function UI:IsShown() return frame and frame:IsShown() or false end
