local addonName, addonTable = ...
local L = addonTable.L

local function OnSettingChanged(_, setting, value)
    local variable = setting:GetVariable()
    LootDialogLogDB[variable] = value
    if (variable == "isLocked" or variable == "bgAlpha") and addonTable.UpdateFrameStyle then
        addonTable.UpdateFrameStyle()
    end
    if (variable == "showNPC" or variable == "showTimestamp") and addonTable.RefreshLog then
        addonTable.RefreshLog()
    end
end

local function RegisterSettings()
    local category = Settings.RegisterVerticalLayoutCategory(L["ADDON_NAME"])

    -- 1. 아이템 등급 드롭다운
    local function GetQualityOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add(0, L["QUALITY_0"])
        container:Add(1, L["QUALITY_1"])
        container:Add(2, L["QUALITY_2"])
        container:Add(3, L["QUALITY_3"])
        container:Add(4, L["QUALITY_4"])
        container:Add(5, L["QUALITY_5"])
        return container:GetData()
    end

    local minQualitySetting = Settings.RegisterAddOnSetting(category, "minQuality", "minQuality", LootDialogLogDB, Settings.VarType.Number, L["OPT_MIN_QUALITY"], 0)
    Settings.CreateDropdown(category, minQualitySetting, GetQualityOptions, L["OPT_MIN_QUALITY_DESC"])
    Settings.SetOnValueChangedCallback("minQuality", OnSettingChanged)

    -- 2. 배경 투명도 슬라이더
    local alphaSetting = Settings.RegisterAddOnSetting(category, "bgAlpha", "bgAlpha", LootDialogLogDB, Settings.VarType.Number, L["OPT_BG_ALPHA"], 0.5)
    local sliderOptions = Settings.CreateSliderOptions(0, 1, 0.05)
    Settings.CreateSlider(category, alphaSetting, sliderOptions, L["OPT_BG_ALPHA_DESC"])
    Settings.SetOnValueChangedCallback("bgAlpha", OnSettingChanged)

    -- 3. 메시지 유지 시간 드롭다운
    local function GetExpirationOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add(0, L["EXP_UNLIMITED"])
        container:Add(60, L["EXP_1MIN"])
        container:Add(180, L["EXP_3MIN"])
        container:Add(300, L["EXP_5MIN"])
        container:Add(600, L["EXP_10MIN"])
        return container:GetData()
    end

    local expirationSetting = Settings.RegisterAddOnSetting(category, "expirationTime", "expirationTime", LootDialogLogDB, Settings.VarType.Number, L["OPT_EXPIRATION"], 0)
    Settings.CreateDropdown(category, expirationSetting, GetExpirationOptions, L["OPT_EXPIRATION_DESC"])
    Settings.SetOnValueChangedCallback("expirationTime", OnSettingChanged)

    -- 4. 체크박스들 등록 함수
    local function AddCheckbox(var, name, desc)
        local setting = Settings.RegisterAddOnSetting(category, var, var, LootDialogLogDB, Settings.VarType.Boolean, name, true)
        Settings.CreateCheckbox(category, setting, desc)
        Settings.SetOnValueChangedCallback(var, OnSettingChanged)
    end

    AddCheckbox("showTimestamp", L["OPT_TIMESTAMP"], L["OPT_TIMESTAMP_DESC"])
    AddCheckbox("showNPC", L["OPT_SHOW_NPC"], L["OPT_SHOW_NPC_DESC"])
    AddCheckbox("isLocked", L["OPT_LOCK"], L["OPT_LOCK_DESC"])
    AddCheckbox("hideInCombat", L["OPT_HIDE_IN_COMBAT"], L["OPT_HIDE_IN_COMBAT_DESC"])
    AddCheckbox("showInMythicPlus", L["OPT_SHOW_IN_MYTHIC"], L["OPT_SHOW_IN_MYTHIC_DESC"])
    AddCheckbox("showInRaid", L["OPT_SHOW_IN_RAID"], L["OPT_SHOW_IN_RAID_DESC"])

    Settings.RegisterAddOnCategory(category)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, name)
    if name == addonName then
        LootDialogLogDB = LootDialogLogDB or {
            minQuality = 0,
            hideInCombat = true,
            showInMythicPlus = true,
            showInRaid = true,
            showNPC = true,
            showTimestamp = false,
            framePosX = 200,
            framePosY = -200,
            frameWidth = 300,
            frameHeight = 150,
            isLocked = false,
            bgAlpha = 0.5,
            expirationTime = 0,
        }
        RegisterSettings()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
