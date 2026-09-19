local addonName, SMhelper = ...

-- Content host for lazily created settings pages. It owns page parenting,
-- visibility, and active-page tracking, while navigation remains in Sidebar.
SMhelper.UI.Content = SMhelper.UI.Content or {}
local Content = SMhelper.UI.Content
local host
local pages = {}
local activeId

-- Create the shared content frame once.
function Content:Create(parent)
    if host then return host end
    host = CreateFrame("Frame", nil, parent)
    return host
end

-- Attach and hide a newly constructed page until it is selected.
function Content:RegisterPage(id, frame)
    assert(host, "Content:Create(parent) must be called first")
    assert(type(id) == "string" and frame, "Content:RegisterPage(id, frame) requires both arguments")
    frame:SetParent(host)
    frame:SetAllPoints(host)
    frame:Hide()
    pages[id] = frame
end

-- Switch visibility from the active page to the requested page.
function Content:ShowPage(id)
    local page = pages[id]
    if not page then return false end
    if activeId and pages[activeId] then pages[activeId]:Hide() end
    page:Show()
    activeId = id
    return true
end

-- Report whether a lazy page factory has already produced its frame.
function Content:HasPage(id)
    return pages[id] ~= nil
end
