local _, SMhelper = ...

-- quality of life settings page
-- register the page in the sidebar
SMhelper.UI:RegisterPage("qualityOfLife", {
    title = "Quality of Life",
    create = function(parent)
        local API = SMhelper.UI.API
        local W = SMhelper.UI.Widgets
        local Config = SMhelper.Config
        local module = SMhelper.Modules and SMhelper.Modules.CombatLogging
        local repairModule = SMhelper.Modules and SMhelper.Modules.AutoRepair

        local page = CreateFrame("Frame", nil, parent)
        local title = API:CreateLabel(page, "Quality of Life", {
            color = Config.colors.text,
            fontSize = 20,
        })
        title:SetPoint("TOPLEFT", 8, -8)

        if not module then return page end

        -- content area, inset from the title with a right margin
        local body = CreateFrame("Frame", nil, page)
        body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -18)
        body:SetPoint("TOPRIGHT", page, "TOPRIGHT", -24, 0)
        body:SetPoint("BOTTOM", page, "BOTTOM")

        local y = 0
        local _, headerH = W:SectionHeader(body, "AUTO COMBAT LOGGING", y)
        y = y - headerH

        -- row 1: Enable Auto Logging (left) + Auto-Log Triggers (right)
        local row1 = W:Row(body, y)
        y = y - 44

        -- row 2: Warcraft Recorder Compatibility (left), hidden while off
        local row2 = W:Row(body, y)
        y = y - 44

        -- Auto-Log Triggers: label plus a multi-select checkbox dropdown
        local trigLabel = API:CreateLabel(row1.Right, "Auto-Log Triggers", {
            color = Config.colors.text,
        })
        trigLabel:SetPoint("LEFT", row1.Right, "LEFT", 0, 0)

        local triggers = W:CreateCheckboxDropdown(row1.Right, {
            width = 210,
            items = module.Triggers,
            getValue = function(key) return module:GetTrigger(key) end,
            setValue = function(key, value) module:SetTrigger(key, value) end,
            getSummary = function() return module:GetTriggerSummary() end,
        })
        triggers:SetPoint("RIGHT", row1.Right, "RIGHT", -20, 0)

        -- Warcraft Recorder Compatibility toggle
        W:RowToggle(
            row2.Left,
            "Warcraft Recorder Compatibility",
            module:GetDelayStop(),
            function(value) module:SetDelayStop(value) end,
            "Delays stopping combat logging by 30 seconds after leaving an instance. Recommended for Warcraft Recorder compatibility."
        )

        -- gray the triggers while off; hide the Warcraft Recorder row entirely
        local function applyDependentState()
            local on = module:IsEnabled()
            triggers:SetEnabled(on)
            trigLabel:SetAlpha(on and 1 or 0.3)
            row2:SetShown(on)
        end

        -- Enable Auto Logging master toggle
        W:RowToggle(
            row1.Left,
            "Enable Auto Logging",
            module:IsEnabled(),
            function(value)
                module:SetEnabled(value)
                applyDependentState()
            end,
            "Automatically starts and stops combat logging when entering or leaving a loggable instance."
        )

        triggers:Refresh()
        applyDependentState()

        -- auto repair settings
        if repairModule then
            y = y - 8

            local _, repairHeaderH = W:SectionHeader(body, "GENERAL", y)
            y = y - repairHeaderH

            -- row 3: Enable Auto Repair
            local row3 = W:Row(body, y)

            -- Enable Auto Repair toggle
            W:RowToggle(
                row3.Left,
                "Enable Auto Repair",
                repairModule:IsEnabled(),
                function(value)
                    repairModule:SetEnabled(value)
                end,
                "Automatically repairs damaged equipment when opening a repair merchant. Guild repair funds are used when available."
            )
            W:RowToggle(
                row3.Right,
                "Auto-fill delete confirmation",
                repairModule:IsEnabled(),
                function(value)
                    repairModule:SetEnabled(value)
                end,
                "Automatically types 'DELETE' when trying to delete a valuable item."
            )
        end
        return page
    end,
})