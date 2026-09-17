local _, SMhelper = ...

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

    paths = {
        borderTexture = "Interface\\Buttons\\WHITE8X8",
        backgroundTexture = "Interface\\DialogFrame\\UI-DialogBox-Background",
        highlightTexture = "Interface\\Buttons\\UI-Listbox-Highlight2",
    },

    -- Color codes used inside text
    colorCodes = {
        accent = "|cff3399ff",
        error = "|cffff3333",
        reset = "|r",
    },

    -- RGBA colors used by WoW API methods
    colors = {
        background = { 0.055, 0.065, 0.085, 0.78 },
        panel = { 0.085, 0.10, 0.13, 0.72 },
        panelHover = { 0.12, 0.15, 0.20, 0.88 },
        border = { 0.20, 0.24, 0.31, 1 },
        accent = { 0.20, 0.60, 1.00, 1 },
        text = { 0.92, 0.95, 1.00, 1 },
        mutedText = { 0.62, 0.68, 0.76, 1 },
    },
}