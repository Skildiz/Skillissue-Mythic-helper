local addonName, SMhelper = ...

-- page container and page switching
SMhelper.UI.Content = SMhelper.UI.Content or {}
local Content = SMhelper.UI.Content
local host
local pages = {}
local activeId

-- create the shared page area
function Content:Create(parent)
    if host then return host end
    host = CreateFrame("Frame", nil, parent)
    return host
end

-- attach a page to the content area
function Content:RegisterPage(id, frame)
    assert(host, "Content:Create(parent) must be called first")
    assert(type(id) == "string" and frame, "Content:RegisterPage(id, frame) requires both arguments")
    frame:SetParent(host)
    frame:SetAllPoints(host)
    frame:Hide()
    pages[id] = frame
end

-- hide the old page and show the selected page
function Content:ShowPage(id)
    local page = pages[id]
    if not page then return false end
    if activeId and pages[activeId] then pages[activeId]:Hide() end
    page:Show()
    activeId = id
    return true
end

-- check whether a page was already created
function Content:HasPage(id)
    return pages[id] ~= nil
end
