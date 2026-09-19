local _, SMhelper = ...

-- Central configuration for shared addon metadata, visual styles, asset paths,
-- layout measurements, and feature-specific constants. Keep reusable magic values
-- here so UI and module files describe behavior rather than implementation details.
SMhelper.Config = {
    width = 1250,
    height = 850,
    minWidth = 900,
    minHeight = 600,
    sidebarWidth = 220,
    headerHeight = 50,
    padding = 12,

    defaultPage = "general",
    addonName = "SMHelper",
    title = "Skillissue M+ helper",
    frameStrata = "DIALOG",
    frameLevel = 100,

    -- Blizzard texture paths used by multiple UI components.
    Paths = {
        BORDER_TEXTURE = "Interface\\Buttons\\WHITE8X8",
        DROPDOWN_ARROW = "Interface\\Buttons\\Arrow-Down-Up",
        CHECKBOX_EMPTY = "Interface\\Buttons\\UI-CheckBox-Up",
        CHECKBOX_CHECKED = "Interface\\Buttons\\UI-CheckBox-Check",
        RESIZE_NORMAL = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up",
        RESIZE_HIGHLIGHT = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight",
        RESIZE_PUSHED = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down",
        MINIMAP_ICON = "Interface\\Icons\\INV_Misc_Gear_01",
        MINIMAP_HIGHLIGHT = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight",
    },

    -- Pixel measurements shared across the window, widgets, and settings pages.
    Layout = {
        PAGE_TITLE_X = 8,
        PAGE_TITLE_Y = -8,
        PAGE_BODY_TOP_OFFSET = -18,
        PAGE_BODY_RIGHT_MARGIN = -24,
        PAGE_CONTROL_GAP = -20,
        PAGE_TITLE_FONT_SIZE = 20,
        GENERAL_PAGE_TITLE_FONT_SIZE = 24,
        HEADER_TITLE_FONT_SIZE = 18,
        SECTION_HEADER_FONT_SIZE = 12,

        HEADER_TITLE_RIGHT_MARGIN = -48,
        HEADER_CLOSE_SIZE = 32,
        HEADER_CLOSE_X = -8,
        HEADER_CLOSE_Y = -9,

        SIDEBAR_BUTTON_HEIGHT = 38,
        SIDEBAR_BUTTON_STEP = 44,

        RESIZE_HANDLE_SIZE = 20,
        RESIZE_HANDLE_X = -2,
        RESIZE_HANDLE_Y = 2,
        RESIZE_FRAME_LEVEL_OFFSET = 10,

        MINIMAP_BUTTON_SIZE = 32,
        MINIMAP_BUTTON_X = 2,
        MINIMAP_BUTTON_Y = -2,

        BUTTON_WIDTH = 120,
        BUTTON_HEIGHT = 32,
        BUTTON_TEXT_INSET = 10,
        BUTTON_GLOW_OFFSET = 4,

        TOGGLE_WIDTH = 44,
        TOGGLE_HEIGHT = 22,
        TOGGLE_KNOB_SIZE = 18,
        TOGGLE_KNOB_OFFSET = 2,
        TOGGLE_LABEL_GAP = 10,

        SECTION_HEADER_HEIGHT = 24,
        SECTION_HEADER_SPACE = 32,
        SECTION_DIVIDER_HEIGHT = 1,
        SECTION_DIVIDER_GAP = 12,
        ROW_HEIGHT = 44,
        ROW_COLUMN_GAP = 12,
        ROW_TOGGLE_RIGHT_MARGIN = -20,

        DROPDOWN_WIDTH = 210,
        DROPDOWN_HEIGHT = 24,
        DROPDOWN_ROW_HEIGHT = 24,
        DROPDOWN_MENU_PADDING = 4,
        DROPDOWN_MENU_VERTICAL_PADDING = 8,
        DROPDOWN_MENU_OFFSET_Y = -2,
        DROPDOWN_ARROW_SIZE = 16,
        DROPDOWN_ARROW_RIGHT = -6,
        DROPDOWN_CHECKBOX_SIZE = 18,
        DROPDOWN_CHECKBOX_LEFT = 4,
        DROPDOWN_ENTRY_TEXT_INSET = 28,
    },

    -- Constants used to identify supported instance difficulties and stop timing.
    CombatLogging = {
        DELAYED_STOP_SECONDS = 30,
        MESSAGE_COLOR = { 0.25, 0.65, 1 },
        DIFFICULTY = {
            MYTHIC_DUNGEON = 23,
            MYTHIC_PLUS = 8,
            MYTHIC_RAID = 16,
            HEROIC_RAID = 15,
            NORMAL_RAID = 14,
            RAID_FINDER = 17,
            LEGACY_RAID_FINDER = 7,
        },
    },

    -- Inline WoW color escape sequences for chat messages.
    colorCodes = {
        accent = "|cff3399ff",
        error = "|cffff3333",
        reset = "|r",
    },

    -- RGBA color palette used by frame and texture APIs.
    colors = {
        background = { 0.055, 0.065, 0.085, 0.78 },
        panel = { 0.085, 0.10, 0.13, 0.72 },
        panelHover = { 0.12, 0.15, 0.20, 0.88 },
        border = { 0.20, 0.24, 0.31, 1 },
        accent = { 0.20, 0.60, 1.00, 1 },
        text = { 0.92, 0.95, 1.00, 1 },
        mutedText = { 0.62, 0.68, 0.76, 1 },
        transparent = { 0, 0, 0, 0 },
        white = { 1, 1, 1, 1 },
        toggleDisabled = { 0.65, 0.68, 0.72, 1 },
        defaultPanel = { 0.08, 0.08, 0.08, 1 },
        defaultButton = { 0.12, 0.12, 0.12, 1 },
        defaultBorder = { 0.3, 0.3, 0.3, 1 },
        selectedGlow = { 0.20, 0.58, 1.00, 0.55 },
    },
}
