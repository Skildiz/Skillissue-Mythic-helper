local addonName, sframe = ...

local eventHandler = CreateFrame("Frame")

eventHandler:RegisterEvent("ADDON_LOADED")

eventHandler:SetScript("OnEvent", function(frame, _, loadedAddonName)

    if loadedAddonName ~= addonName then return end

    local Style = sframe.Style

    -- Chat notification on addon load
    print("|cffff7f00Skillissue M+ helper successfully loaded! Type /smhelper or /sh to open the settings window.|r")

    -- Main settings frame
    local panelWidth, panelHeight = 1250, 850
    local f = Style:CreatePanel(UIParent, panelWidth, panelHeight, "SkillissueSettingsFrame")

    local availableWidth = UIParent:GetWidth() - 40
    local availableHeight = UIParent:GetHeight() - 40
    local scale = math.min(1, availableWidth / panelWidth, availableHeight / panelHeight)

    f:SetScale(scale)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetFrameStrata("HIGH")
    f:SetFrameLevel(100)
    f:SetToplevel(true)
    f:Hide()

    -- Enable frame dragging
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")

    f:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    -- Header creation
    local header = Style:CreateHeader(f, "Skillissue M+ Helper", 30)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, header)

    closeBtn:SetSize(18, 18)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -6, 0)
    closeBtn:EnableMouse(true)
    closeBtn:SetFrameLevel(header:GetFrameLevel() + 5)

    closeBtn.text = closeBtn:CreateFontString(nil, "OVERLAY")
    Style:ApplyFont(closeBtn.text, 10, "OUTLINE")

    closeBtn.text:SetText("X")
    closeBtn.text:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
    closeBtn.text:SetTextColor(0.7, 0.7, 0.7)

    closeBtn:SetScript("OnClick", function()
        f:Hide()
    end)

    closeBtn:SetScript("OnEnter", function(button)
        button.text:SetTextColor(1, 0.2, 0.2)
    end)

    closeBtn:SetScript("OnLeave", function(button)
        button.text:SetTextColor(0.7, 0.7, 0.7)
    end)

    -- Sidebar container for tab navigation
    local sidebar = CreateFrame("Frame", nil, f)

    sidebar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 8, -8)
    sidebar:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 8, 8)
    sidebar:SetWidth(200)

    -- Main content container for tab views
    local contentArea = CreateFrame("Frame", nil, f)

    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    contentArea:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)

    -- Navigation categories list
    local tabData = {
        { id = "general",  name = "General" },
        { id = "utility",  name = "Utility helper" },
        { id = "targeted", name = "Targeted spells" },
        { id = "buffs",    name = "Buff reminder" },
    }

    local tabs = {}
    local activeTabId = nil

    -- Tab switching logic
    local function SelectTab(tabId)

        activeTabId = tabId

        for id, tab in pairs(tabs) do

            if id == tabId then

                tab.button:SetBackdropColor(unpack(Style.Colors.accent))
                tab.button.Text:SetTextColor(1, 1, 1)
                tab.content:Show()

            else

                tab.button:SetBackdropColor(unpack(Style.Colors.buttonBg))
                tab.button.Text:SetTextColor(unpack(Style.Colors.text))
                tab.content:Hide()

            end
        end
    end

    -- Construct sidebar buttons and corresponding content pages
    for index, info in ipairs(tabData) do

        -- Sidebar navigation button
        local btn = Style:CreateButton(sidebar, info.name, 190, 55)

        btn:SetPoint(
            "TOPLEFT",
            sidebar,
            "TOPLEFT",
            0,
            -(index - 1) * 63
        )

        Style:ApplyFont(btn.Text, 16, "")

        -- Content frame for current tab
        local content = CreateFrame("Frame", nil, contentArea)

        content:SetAllPoints(contentArea)
        content:Hide()

        -- Content page title
        local title = content:CreateFontString(nil, "OVERLAY")

        Style:ApplyFont(title, 20, "OUTLINE")

        title:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -10)
        title:SetText(info.name)
        title:SetTextColor(unpack(Style.Colors.orange))

        -- Store tab reference
        tabs[info.id] = {
            button = btn,
            content = content
        }

        -- Button interaction scripts
        btn:SetScript("OnClick", function()
            SelectTab(info.id)
        end)

        btn:SetScript("OnEnter", function(button)

            if activeTabId ~= info.id then

                button:SetBackdropColor(unpack(Style.Colors.buttonHover))
                button.Text:SetTextColor(unpack(Style.Colors.orange))

            end
        end)

        btn:SetScript("OnLeave", function(button)

            if activeTabId ~= info.id then

                button:SetBackdropColor(unpack(Style.Colors.buttonBg))
                button.Text:SetTextColor(unpack(Style.Colors.text))

            end
        end)
    end

    -- Select default tab on load
    SelectTab("general")

    -- Expose tab contents for external UI construction
    -- Usage example: f.TabContent["buffs"].content
    f.TabContent = tabs

    -- Sound effects on show/hide
    f:SetScript("OnShow", function()
        PlaySound(808)
    end)

    f:SetScript("OnHide", function()
        PlaySound(808)
    end)

    -- Slash commands to toggle the settings frame
    SLASH_SKILLHELPER1 = "/smhelper"
    SLASH_SKILLHELPER2 = "/sh"

    SlashCmdList["SKILLHELPER"] = function()

        if f:IsShown() then
            f:Hide()
        else
            f:Show()
        end

    end

    frame:UnregisterEvent("ADDON_LOADED")

end)