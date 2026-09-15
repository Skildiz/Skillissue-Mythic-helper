local _, SMhelper = ...

-- window header with title and close button
local API, Config = SMhelper.UI.API, SMhelper.Config
SMhelper.UI.Header = SMhelper.UI.Header or {}
local Header = SMhelper.UI.Header
local frame

-- create the header once
function Header:Create(parent, onClose)
    if frame then return frame end

    frame = API:CreatePanel(parent, { height = Config.headerHeight, color = Config.colors.panel })
    frame:SetFrameLevel(parent:GetFrameLevel() + 1)

    local title = API:CreateLabel(frame, Config.title, { color = Config.colors.text, fontSize = 18 })
    title:SetPoint("LEFT", Config.padding, 0)
    title:SetPoint("RIGHT", -48, 0)

    -- simple close button
    local close = API:CreateButton(frame, {
        text = "X",
        width = 32,
        height = 32,
        color = { 0, 0, 0, 0 },
        hoverColor = Config.colors.panelHover,
        onClick = onClose,
    })
    close:SetPoint("TOPRIGHT", -8, -9)

    API:CreateBorder(frame, Config.colors.border, 1)
    return frame
end
