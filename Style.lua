local addonName, sframe = ...

sframe.Style = {}
local Style = sframe.Style

Style.Textures = {
    Flat = "Interface\\Buttons\\WHITE8x8",
}

Style.Fonts = {
    -- Путь к Expressway внутри папки аддона Media/Fonts/
    Main = "Interface\\AddOns\\" .. addonName .. "\\Media\\fonts\\Expressway.ttf",
    Fallback = "Fonts\\FRIZQT__.TTF",
}

Style.Colors = {
    bg          = {0.05, 0.05, 0.05, 0.88},
    border      = {0.00, 0.00, 0.00, 1.00},
    header      = {0.12, 0.12, 0.14, 0.95},
    accent      = {1.00, 0.50, 0.00, 1.00},
    orange      = {1.00, 0.50, 0.00, 1.00},
    text        = {0.95, 0.95, 0.95, 1.00},
    textMuted   = {0.60, 0.60, 0.60, 1.00},
    buttonBg    = {0.15, 0.15, 0.18, 1.00},
    buttonHover = {0.25, 0.25, 0.30, 1.00},
}

function Style:ApplyFont(fontString, size, flags)
    flags = flags or "OUTLINE"
    local success = fontString:SetFont(Style.Fonts.Main, size, flags)
    
    if not success then
        fontString:SetFont(Style.Fonts.Fallback, size, flags)
    end
end

function Style:CreatePanel(parent, width, height, name)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:SetSize(width, height)

    frame:SetBackdrop({
        bgFile   = Style.Textures.Flat,
        edgeFile = Style.Textures.Flat,
        tile     = false, tileSize = 0, edgeSize = 1,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 }
    })

    frame:SetBackdropColor(unpack(Style.Colors.bg))
    frame:SetBackdropBorderColor(unpack(Style.Colors.border))

    return frame
end

function Style:CreateHeader(parent, titleText, height)
    height = height or 24
    local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -1, -1)
    header:SetHeight(height)

    header:SetBackdrop({
        bgFile = Style.Textures.Flat,
        edgeFile = nil,
    })
    header:SetBackdropColor(unpack(Style.Colors.header))
    
    local title = header:CreateFontString(nil, "OVERLAY")
    Style:ApplyFont(title, 11, "OUTLINE")
    title:SetPoint("LEFT", header, "LEFT", 8, 0)
    title:SetText(titleText or "")
    title:SetTextColor(unpack(Style.Colors.orange))
    
    local line = parent:CreateTexture(nil, "BORDER")
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, 0)
    line:SetColorTexture(unpack(Style.Colors.border))
    
    return header
end

function Style:CreateButton(parent, text, width, height)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width or 80, height or 22)
    
    btn:SetBackdrop({
        bgFile   = Style.Textures.Flat,
        edgeFile = Style.Textures.Flat,
        edgeSize = 1,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    
    btn:SetBackdropColor(unpack(Style.Colors.buttonBg))
    btn:SetBackdropBorderColor(unpack(Style.Colors.border))
    
    local label = btn:CreateFontString(nil, "OVERLAY")
    Style:ApplyFont(label, 10, "OUTLINE")
    label:SetPoint("CENTER", btn, "CENTER", 0, 0)
    label:SetText(text or "")
    label:SetTextColor(unpack(Style.Colors.text))
    btn.Text = label
    
    btn:SetScript("OnEnter", function(button)
        button:SetBackdropColor(unpack(Style.Colors.buttonHover))
        button.Text:SetTextColor(unpack(Style.Colors.orange))
    end)
    
    btn:SetScript("OnLeave", function(button)
        button:SetBackdropColor(unpack(Style.Colors.buttonBg))
        button.Text:SetTextColor(unpack(Style.Colors.text))
    end)
    
    return btn
end