local _, SMhelper = ...

-- Low-level UI factory helpers. These functions centralize frame construction
-- and visual behavior so higher-level components do not repeat texture, font,
-- color, hover, and selection setup.
SMhelper.UI = SMhelper.UI or {}
SMhelper.UI.API = SMhelper.UI.API or {}

local API = SMhelper.UI.API
local Config = SMhelper.Config
local Layout = Config.Layout

-- Convert an RGBA table into the four values expected by WoW UI methods.
local function GetColorComponents(value, fallback)
    local selectedColor = value or fallback or Config.colors.white
    return selectedColor[1], selectedColor[2], selectedColor[3], selectedColor[4] or 1
end

-- Apply only dimensions supplied by the caller, allowing anchors to size frames.
local function ApplyOptionalFrameSize(frame, options)
    if options.width then
        frame:SetWidth(options.width)
    end

    if options.height then
        frame:SetHeight(options.height)
    end
end

-- Create the additive glow shown while a button is selected.
local function CreateButtonGlow(button, options)
    local glow = button:CreateTexture(nil, "BACKGROUND", nil, -8)
    local offset = Layout.BUTTON_GLOW_OFFSET

    glow:SetPoint("TOPLEFT", -offset, offset)
    glow:SetPoint("BOTTOMRIGHT", offset, -offset)
    glow:SetColorTexture(GetColorComponents(options.glowColor, Config.colors.selectedGlow))
    glow:SetBlendMode("ADD")
    glow:Hide()

    button.Glow = glow
    return glow
end

local function CreateButtonBackground(button)
    local background = button:CreateTexture(nil, "BACKGROUND", nil, -7)
    background:SetAllPoints()
    button.NormalTexture = background
    return background
end

local function CreateButtonLabel(button, options)
    local textInset = options.textInset or Layout.BUTTON_TEXT_INSET
    local label = API:CreateLabel(button, options.text, {
        color = options.textColor,
        justifyH = options.justifyH or "CENTER",
    })

    label:SetPoint("LEFT", textInset, 0)
    label:SetPoint("RIGHT", -textInset, 0)
    button.Label = label
    return label
end

-- Create a frame with a full-size solid-color background texture.
function API:CreatePanel(parent, options)
    options = options or {}

    local frame = CreateFrame(options.frameType or "Frame", nil, parent, options.template)
    ApplyOptionalFrameSize(frame, options)

    frame.Background = frame:CreateTexture(nil, "BACKGROUND")
    frame.Background:SetAllPoints()
    frame.Background:SetColorTexture(GetColorComponents(options.color, Config.colors.defaultPanel))

    return frame
end

-- Add a BackdropTemplate border that follows all edges of its parent.
function API:CreateBorder(parent, borderColor, thickness)
    local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")

    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = Config.Paths.BORDER_TEXTURE,
        edgeSize = thickness or 1,
    })
    border:SetBackdropBorderColor(GetColorComponents(borderColor, Config.colors.defaultBorder))

    return border
end

-- Create a consistently styled font string with optional size and alignment.
function API:CreateLabel(parent, text, options)
    options = options or {}

    local label = parent:CreateFontString(
        nil,
        options.layer or "OVERLAY",
        options.template or "GameFontNormal"
    )

    label:SetText(text or "")
    label:SetTextColor(GetColorComponents(options.color))
    label:SetJustifyH(options.justifyH or "LEFT")
    label:SetJustifyV(options.justifyV or "MIDDLE")

    if options.fontSize then
        local font, _, flags = label:GetFont()
        label:SetFont(font, options.fontSize, flags)
    end

    return label
end

-- Create a reusable button with normal, hover, and selected visual states.
function API:CreateButton(parent, options)
    options = options or {}

    local button = CreateFrame("Button", nil, parent)
    button:SetSize(
        options.width or Layout.BUTTON_WIDTH,
        options.height or Layout.BUTTON_HEIGHT
    )

    local glow = CreateButtonGlow(button, options)
    local background = CreateButtonBackground(button)
    CreateButtonLabel(button, options)

    local isHovered = false
    local isSelected = false

    local function RefreshAppearance()
        local fillColor = options.color or Config.colors.defaultButton

        if isSelected and options.selectedColor then
            fillColor = options.selectedColor
        elseif isHovered and options.hoverColor then
            fillColor = options.hoverColor
        end

        background:SetColorTexture(GetColorComponents(fillColor))
        glow:SetShown(isSelected)
    end

    function button:SetSelected(value)
        isSelected = value == true
        RefreshAppearance()
    end

    button:SetScript("OnEnter", function()
        isHovered = true
        RefreshAppearance()
    end)

    button:SetScript("OnLeave", function()
        isHovered = false
        RefreshAppearance()
    end)

    if options.onClick then
        button:SetScript("OnClick", options.onClick)
    end

    RefreshAppearance()
    return button
end
