local _, SMhelper = ...

-- low-level UI helpers
SMhelper.UI = SMhelper.UI or {}
SMhelper.UI.API = SMhelper.UI.API or {}
local API = SMhelper.UI.API

-- unpack a color table
local function color(value, fallback)
    value = value or fallback or { 1, 1, 1, 1 }
    return value[1], value[2], value[3], value[4] or 1
end

-- create a colored frame
function API:CreatePanel(parent, options)
    options = options or {}
    local frame = CreateFrame(options.frameType or "Frame", nil, parent, options.template)
    if options.width then frame:SetWidth(options.width) end
    if options.height then frame:SetHeight(options.height) end

    frame.Background = frame:CreateTexture(nil, "BACKGROUND")
    frame.Background:SetAllPoints()
    frame.Background:SetColorTexture(color(options.color, { 0.08, 0.08, 0.08, 1 }))
    return frame
end

-- add a simple frame border
function API:CreateBorder(parent, borderColor, thickness)
    local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = thickness or 1 })
    border:SetBackdropBorderColor(color(borderColor, { 0.3, 0.3, 0.3, 1 }))
    return border
end

-- create a text label
function API:CreateLabel(parent, text, options)
    options = options or {}
    local label = parent:CreateFontString(nil, options.layer or "OVERLAY", options.template or "GameFontNormal")
    label:SetText(text or "")
    label:SetTextColor(color(options.color))
    label:SetJustifyH(options.justifyH or "LEFT")
    label:SetJustifyV(options.justifyV or "MIDDLE")
    if options.fontSize then
        local font, _, flags = label:GetFont()
        label:SetFont(font, options.fontSize, flags)
    end
    return label
end

-- create a button with hover and active states
function API:CreateButton(parent, options)
    options = options or {}
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(options.width or 120, options.height or 32)

    local glow = button:CreateTexture(nil, "BACKGROUND", nil, -8)
    glow:SetPoint("TOPLEFT", -4, 4)
    glow:SetPoint("BOTTOMRIGHT", 4, -4)
    glow:SetColorTexture(color(options.glowColor, { 0.20, 0.58, 1.00, 0.55 }))
    glow:SetBlendMode("ADD")
    glow:Hide()
    button.Glow = glow

    local background = button:CreateTexture(nil, "BACKGROUND", nil, -7)
    background:SetAllPoints()
    button.NormalTexture = background

    local label = self:CreateLabel(button, options.text, {
        color = options.textColor,
        justifyH = options.justifyH or "CENTER",
    })
    label:SetPoint("LEFT", options.textInset or 10, 0)
    label:SetPoint("RIGHT", -(options.textInset or 10), 0)
    button.Label = label

    local hovered, selected = false, false
    -- refresh the button appearance
    local function render()
        local fill = selected and options.selectedColor
            or (hovered and options.hoverColor)
            or options.color
            or { 0.12, 0.12, 0.12, 1 }
        background:SetColorTexture(color(fill))
        glow:SetShown(selected)
    end

    -- mark the button as active
    function button:SetSelected(value)
        selected = not not value
        render()
    end

    button:SetScript("OnEnter", function() hovered = true; render() end)
    button:SetScript("OnLeave", function() hovered = false; render() end)
    if options.onClick then button:SetScript("OnClick", options.onClick) end
    render()
    return button
end
