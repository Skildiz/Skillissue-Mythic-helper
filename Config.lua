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

    Events = {
        ADDON_LOADED = "ADDON_LOADED",
        MERCHANT_SHOW = "MERCHANT_SHOW",
        PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD",
        ZONE_CHANGED_NEW_AREA = "ZONE_CHANGED_NEW_AREA",
        CHALLENGE_MODE_START = "CHALLENGE_MODE_START",
        CHALLENGE_MODE_COMPLETED = "CHALLENGE_MODE_COMPLETED",
    },

    SlashCommands = {
        PRIMARY = "/smhelper",
        SECONDARY = "/smh",
    },

    Opacity = {
        OPAQUE = 1,
        ENABLED = 1,
        DISABLED = 0.3,
    },

    Collections = {
        FIRST_INDEX = 1,
        NEXT_INDEX_OFFSET = 1,
        EMPTY_COUNT = 0,
    },

    ColorComponents = {
        RED = 1,
        GREEN = 2,
        BLUE = 3,
        ALPHA = 4,
    },

    -- Blizzard texture paths grouped by their Interface directory hierarchy.
    Paths = {
        Interface = {
            Buttons = {
                BORDER = "Interface\\Buttons\\WHITE8X8",
                DROPDOWN_ARROW = "Interface\\Buttons\\Arrow-Down-Up",
                CHECKBOX = {
                    EMPTY = "Interface\\Buttons\\UI-CheckBox-Up",
                    CHECKED = "Interface\\Buttons\\UI-CheckBox-Check",
                },
            },
            ChatFrame = {
                RESIZE_HANDLE = {
                    NORMAL = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up",
                    HIGHLIGHT = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight",
                    PUSHED = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down",
                },
            },
            Icons = {
                MINIMAP = "Interface\\Icons\\INV_Misc_Gear_01",
            },
            Minimap = {
                HIGHLIGHT = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight",
            },
        },
    },

    -- Pixel measurements grouped by the component that consumes them.
    Layout = {
        Anchor = {
            ZERO_OFFSET = 0,
        },
        Border = {
            DEFAULT_THICKNESS = 1,
        },
        Frame = {
            LEVEL_INCREMENT = 1,
        },
        Texture = {
            Button = {
                GLOW_SUB_LEVEL = -8,
                BACKGROUND_SUB_LEVEL = -7,
            },
        },
        Page = {
            Title = {
                X = 8,
                Y = -8,
                FONT_SIZE = 20,
                GENERAL_FONT_SIZE = 24,
            },
            Body = {
                LEFT_X = 0,
                TOP_OFFSET = -18,
                RIGHT_MARGIN = -24,
                RIGHT_Y = 0,
            },
            CONTROL_GAP = -20,
        },
        Header = {
            Title = {
                FONT_SIZE = 18,
                RIGHT_MARGIN = -48,
            },
            CloseButton = {
                SIZE = 32,
                X = -8,
                Y = -9,
            },
        },
        Sidebar = {
            Button = {
                HEIGHT = 38,
                STEP = 44,
            },
        },
        ResizeHandle = {
            SIZE = 20,
            X = -2,
            Y = 2,
            FRAME_LEVEL_OFFSET = 10,
        },
        Minimap = {
            Button = {
                SIZE = 32,
                X = 2,
                Y = -2,
            },
        },
        Button = {
            WIDTH = 120,
            HEIGHT = 32,
            TEXT_INSET = 10,
            GLOW_OFFSET = 4,
        },
        Toggle = {
            WIDTH = 44,
            HEIGHT = 22,
            KNOB_SIZE = 18,
            KNOB_OFFSET = 2,
            LABEL_GAP = 10,
        },
        SectionHeader = {
            HEIGHT = 24,
            SPACE = 32,
            FONT_SIZE = 12,
            DIVIDER_HEIGHT = 1,
            DIVIDER_GAP = 12,
        },
        Row = {
            HEIGHT = 44,
            COLUMN_GAP = 12,
            TOGGLE_RIGHT_MARGIN = -20,
        },
        Dropdown = {
            WIDTH = 210,
            HEIGHT = 24,
            ROW_HEIGHT = 24,
            MENU_PADDING = 4,
            MENU_VERTICAL_PADDING = 8,
            MENU_OFFSET_Y = -2,
            ARROW_SIZE = 16,
            ARROW_RIGHT = -6,
            CHECKBOX_SIZE = 18,
            CHECKBOX_LEFT = 4,
            ENTRY_TEXT_INSET = 28,
        },
    },

    UI = {
        FrameTypes = {
            FRAME = "Frame",
            BUTTON = "Button",
        },
        DrawLayers = {
            BACKGROUND = "BACKGROUND",
            ARTWORK = "ARTWORK",
            OVERLAY = "OVERLAY",
        },
        AnchorPoints = {
            CENTER = "CENTER",
            TOP = "TOP",
            BOTTOM = "BOTTOM",
            LEFT = "LEFT",
            RIGHT = "RIGHT",
            TOP_LEFT = "TOPLEFT",
            TOP_RIGHT = "TOPRIGHT",
            BOTTOM_LEFT = "BOTTOMLEFT",
            BOTTOM_RIGHT = "BOTTOMRIGHT",
        },
        Scripts = {
            EVENT = "OnEvent",
            CLICK = "OnClick",
            ENTER = "OnEnter",
            LEAVE = "OnLeave",
            MOUSE_DOWN = "OnMouseDown",
            MOUSE_UP = "OnMouseUp",
            DRAG_START = "OnDragStart",
            DRAG_STOP = "OnDragStop",
        },
        BlendModes = {
            ADDITIVE = "ADD",
        },
        HorizontalAlignment = {
            LEFT = "LEFT",
            CENTER = "CENTER",
        },
        VerticalAlignment = {
            MIDDLE = "MIDDLE",
        },
        Templates = {
            BACKDROP = "BackdropTemplate",
            FONT = "GameFontNormal",
        },
        MouseButtons = {
            LEFT = "LeftButton",
        },
        Tooltip = {
            ANCHOR = "ANCHOR_RIGHT",
        },
        Header = {
            CloseButton = {
                TEXT = "X",
            },
        },
        Minimap = {
            Tooltip = {
                ANCHOR = "ANCHOR_LEFT",
                TEXT = "Click to toggle",
                TEXT_COLOR = { 1, 1, 1 },
            },
        },
    },

    Pages = {
        General = {
            NAME = "general",
            TITLE = "General",
            Frame = {
                NAME = nil,
            },
        },
        BuffReminder = {
            NAME = "buffReminder",
            TITLE = "Buff Reminder",
            TOGGLE_TEXT = "Enable buff reminders",
            Frame = {
                NAME = nil,
            },
        },
        UtilityHelper = {
            NAME = "utilityHelper",
            TITLE = "Utility helper",
            Frame = {
                NAME = nil,
                Label = {
                    NAME = nil,
                },
            },
        },
        QualityOfLife = {
            NAME = "qualityOfLife",
            TITLE = "Quality of Life",
            Frame = {
                NAME = nil,
                Body = {
                    NAME = nil,
                },
            },
            Sections = {
                COMBAT_LOGGING = "AUTO COMBAT LOGGING",
                GENERAL = "GENERAL",
            },
            Controls = {
                TRIGGERS = "Auto-Log Triggers",
                RECORDER_COMPATIBILITY = "Warcraft Recorder Compatibility",
                ENABLE_AUTO_LOGGING = "Enable Auto Logging",
                ENABLE_AUTO_REPAIR = "Enable Auto Repair",
            },
            Tooltips = {
                RECORDER_COMPATIBILITY = "Delays stopping combat logging by %d "
                    .. "seconds after leaving an instance. Recommended for "
                    .. "Warcraft Recorder compatibility.",
                AUTO_LOGGING = "Automatically starts and stops combat logging "
                    .. "when entering or leaving a loggable instance.",
                AUTO_REPAIR = "Automatically repairs damaged equipment when "
                    .. "opening a repair merchant. Guild repair funds are used "
                    .. "when available.",
            },
        },
    },

    Messages = {
        LOADED = " successfully loaded! ",
        COMMAND_PREFIX = "Type ",
        COMMAND_SEPARATOR = " or ",
        COMMAND_SUFFIX = " to open the settings window.",
        UI_UNAVAILABLE = ": UI module is unavailable.",
    },

    -- Constants used to identify supported instance difficulties and stop timing.
    CombatLogging = {
        DELAYED_STOP_SECONDS = 30,
        MESSAGE_COLOR = { 0.25, 0.65, 1 },
        ENABLED_MESSAGE = "Log recording is enabled. Combat logs will be "
            .. "automatically started and stopped when entering or leaving "
            .. "selected instances.",
        EMPTY_SUMMARY = "None",
        SUMMARY_SEPARATOR = ", ",
        INSTANCE_TYPES = {
            PARTY = "party",
            RAID = "raid",
        },
        TRIGGER_KEYS = {
            MYTHIC_DUNGEON = "mythicDungeon",
            MYTHIC_PLUS = "mythicplus",
            MYTHIC_RAID = "mythicRaid",
            HEROIC_RAID = "heroicRaid",
            NORMAL_RAID = "normalRaid",
            RAID_FINDER = "lfrRaid",
            DELAYED_STOP = "delaystop",
        },
        TRIGGERS = {
            { key = "mythicDungeon", text = "Mythic Dungeon" },
            { key = "mythicplus", text = "Mythic+ Dungeon" },
            { key = "mythicRaid", text = "Mythic Raid" },
            { key = "heroicRaid", text = "Heroic Raid" },
            { key = "normalRaid", text = "Normal Raid" },
            { key = "lfrRaid", text = "Raid Finder" },
        },
        DEFAULTS = {
            mythicDungeon = true,
            mythicplus = true,
            mythicRaid = true,
            heroicRaid = true,
            normalRaid = false,
            lfrRaid = false,
            delaystop = false,
        },
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

    AutoRepair = {
        MIN_REPAIR_COST = 0,
    },

    -- Inline WoW color escape sequences for chat messages.
    colorCodes = {
        accent = "|cff3399ff",
        error = "|cffff3333",
        reset = "|r",
    },

    -- RGBA colors are named after the UI role that consumes them.
    colors = {
        background = { 0.055, 0.065, 0.085, 0.78 },
        panel = { 0.085, 0.10, 0.13, 0.72 },
        panelHover = { 0.12, 0.15, 0.20, 0.88 },
        border = { 0.20, 0.24, 0.31, 1 },
        accent = { 0.20, 0.60, 1.00, 1 },
        text = { 0.92, 0.95, 1.00, 1 },
        mutedText = { 0.62, 0.68, 0.76, 1 },
        tooltipTitle = { 1, 1, 1 },
        transparent = { 0, 0, 0, 0 },
        defaultTexture = { 1, 1, 1, 1 },
        toggleKnobEnabled = { 1, 1, 1, 1 },
        toggleDisabled = { 0.65, 0.68, 0.72, 1 },
        defaultPanel = { 0.08, 0.08, 0.08, 1 },
        defaultButton = { 0.12, 0.12, 0.12, 1 },
        defaultBorder = { 0.3, 0.3, 0.3, 1 },
        selectedGlow = { 0.20, 0.58, 1.00, 0.55 },
        sidebarButtonGlow = { 0.20, 0.60, 1.00, 0.60 },
    },
}
