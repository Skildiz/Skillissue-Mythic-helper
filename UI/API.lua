local _, SMhelper = ...

-- Low-level UI factory helpers. These functions centralize frame construction
-- and visual behavior so higher-level components do not repeat texture, font,
-- color, hover, and selection setup.
SMhelper.UI = SMhelper.UI or {}
SMhelper.UI.API = SMhelper.UI.API or {}

local API = SMhelper.UI.API
local Config = SMhelper.Config
local Layout = Config.Layout
local UIConfig = Config.UI
local Anchors = UIConfig.AnchorPoints
local Layers = UIConfig.DrawLayers
local Scripts = UIConfig.Scripts
local ZERO_OFFSET = Layout.Anchor.ZERO_OFFSET
local ColorComponents = Config.ColorComponents

-- Convert an RGBA table into the four values expected by WoW UI methods.
local function GetColorComponents(value, fallback)
    local selectedColor = value or fallback or Config.colors.defaultTexture
    return
        selectedColor[ColorComponents.RED],
        selectedColor[ColorComponents.GREEN],
        selectedColor[ColorComponents.BLUE],
        selectedColor[ColorComponents.ALPHA] or Config.Opacity.OPAQUE
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
    local glow = button:CreateTexture(
        nil,
        Layers.BACKGROUND,
        nil,
        Layout.Texture.Button.GLOW_SUB_LEVEL
    )
    local offset = Layout.Button.GLOW_OFFSET

    glow:SetPoint(Anchors.TOP_LEFT, -offset, offset)
    glow:SetPoint(Anchors.BOTTOM_RIGHT, offset, -offset)
    glow:SetColorTexture(GetColorComponents(options.glowColor, Config.colors.selectedGlow))
    glow:SetBlendMode(UIConfig.BlendModes.ADDITIVE)
    glow:Hide()

    button.Glow = glow
    return glow
end

local function CreateButtonBackground(button)
    local background = button:CreateTexture(
        nil,
        Layers.BACKGROUND,
        nil,
        Layout.Texture.Button.BACKGROUND_SUB_LEVEL
    )
    background:SetAllPoints()
    button.NormalTexture = background
    return background
end

local function CreateButtonLabel(button, options)
    local textInset = options.textInset or Layout.Button.TEXT_INSET
    local label = API:CreateLabel(button, options.text, {
        color = options.textColor,
        justifyH = options.justifyH or UIConfig.HorizontalAlignment.CENTER,
    })

    label:SetPoint(Anchors.LEFT, textInset, ZERO_OFFSET)
    label:SetPoint(Anchors.RIGHT, -textInset, ZERO_OFFSET)
    button.Label = label
    return label
end

-- Create a frame with a full-size solid-color background texture.
function API:CreatePanel(parent, options)
    options = options or {}

    local frame = CreateFrame(
        options.frameType or UIConfig.FrameTypes.FRAME,
        nil,
        parent,
        options.template
    )
    ApplyOptionalFrameSize(frame, options)

    frame.Background = frame:CreateTexture(nil, Layers.BACKGROUND)
    frame.Background:SetAllPoints()
    frame.Background:SetColorTexture(GetColorComponents(options.color, Config.colors.defaultPanel))

    return frame
end

-- Add a BackdropTemplate border that follows all edges of its parent.
function API:CreateBorder(parent, borderColor, thickness)
    local border = CreateFrame(
        UIConfig.FrameTypes.FRAME,
        nil,
        parent,
        UIConfig.Templates.BACKDROP
    )

    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = Config.Paths.Interface.Buttons.BORDER,
        edgeSize = thickness or Layout.Border.DEFAULT_THICKNESS,
    })
    border:SetBackdropBorderColor(GetColorComponents(borderColor, Config.colors.defaultBorder))

    return border
end

-- Create a consistently styled font string with optional size and alignment.
function API:CreateLabel(parent, text, options)
    options = options or {}

    local label = parent:CreateFontString(
        options.name,
        options.layer or Layers.OVERLAY,
        options.template or UIConfig.Templates.FONT
    )

    label:SetText(text or "")
    label:SetTextColor(GetColorComponents(options.color))
    label:SetJustifyH(options.justifyH or UIConfig.HorizontalAlignment.LEFT)
    label:SetJustifyV(options.justifyV or UIConfig.VerticalAlignment.MIDDLE)

    if options.fontSize then
        local font, _, flags = label:GetFont()
        label:SetFont(font, options.fontSize, flags)
    end

    return label
end

-- Create a reusable button with normal, hover, and selected visual states.
function API:CreateButton(parent, options)
    options = options or {}

    local button = CreateFrame(UIConfig.FrameTypes.BUTTON, nil, parent)
    button:SetSize(
        options.width or Layout.Button.WIDTH,
        options.height or Layout.Button.HEIGHT
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

    button:SetScript(Scripts.ENTER, function()
        isHovered = true
        RefreshAppearance()
    end)

    button:SetScript(Scripts.LEAVE, function()
        isHovered = false
        RefreshAppearance()
    end)

    if options.onClick then
        button:SetScript(Scripts.CLICK, options.onClick)
    end

    RefreshAppearance()
    return button
end
