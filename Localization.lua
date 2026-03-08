local addonName, addonTable = ...
local L = setmetatable({}, { __index = function(t, k)
    local v = tostring(k)
    t[k] = v
    return v
end })
addonTable.L = L

-- Default strings (enUS)
L["ADDON_NAME"] = "LootDialogLog"
L["TAB_ALL"] = "All"
L["TAB_NPC"] = "NPC"
L["TAB_ITEM"] = "Items"
L["TAB_CLEAR"] = "Clear"

L["OPT_MIN_QUALITY"] = "Min Item Quality"
L["OPT_MIN_QUALITY_DESC"] = "Select the minimum item quality to be displayed in the log."
L["OPT_BG_ALPHA"] = "Background Transparency"
L["OPT_BG_ALPHA_DESC"] = "Adjust the opacity of the frame background. (0.0 ~ 1.0)"
L["OPT_EXPIRATION"] = "Log Retention Time"
L["OPT_EXPIRATION_DESC"] = "Set how long log messages stay on the screen."
L["OPT_TIMESTAMP"] = "Show Timestamp"
L["OPT_TIMESTAMP_DESC"] = "Display time in [HH:MM] format at the beginning of messages."
L["OPT_SHOW_NPC"] = "Show NPC Dialogues"
L["OPT_SHOW_NPC_DESC"] = "Display monster's say, yell, and whisper in the log."
L["OPT_LOCK"] = "Lock Position & Size"
L["OPT_LOCK_DESC"] = "Prevents moving or resizing the window. (/ldl lock)"
L["OPT_HIDE_IN_COMBAT"] = "Hide in Combat"
L["OPT_HIDE_IN_COMBAT_DESC"] = "Automatically hide the window when entering combat."
L["OPT_SHOW_IN_MYTHIC"] = "Show in Mythic+"
L["OPT_SHOW_IN_MYTHIC_DESC"] = "Display the log inside Mythic+ dungeons."
L["OPT_SHOW_IN_RAID"] = "Show in Raid"
L["OPT_SHOW_IN_RAID_DESC"] = "Display the log inside raid instances."

L["EXP_UNLIMITED"] = "Unlimited"
L["EXP_1MIN"] = "1 Min"
L["EXP_3MIN"] = "3 Mins"
L["EXP_5MIN"] = "5 Mins"
L["EXP_10MIN"] = "10 Mins"

L["QUALITY_0"] = "|cff9d9d9dPoor|r"
L["QUALITY_1"] = "|cffffffffCommon|r"
L["QUALITY_2"] = "|cff1eff00Uncommon|r"
L["QUALITY_3"] = "|cff0070ddRare|r"
L["QUALITY_4"] = "|cffa335eeEpic|r"
L["QUALITY_5"] = "|cffff8000Legendary|r"

-- Korean (koKR)
if GetLocale() == "koKR" then
    L["TAB_ALL"] = "전체"
    L["TAB_NPC"] = "NPC"
    L["TAB_ITEM"] = "아이템"
    L["TAB_CLEAR"] = "삭제"

    L["OPT_MIN_QUALITY"] = "최소 아이템 등급"
    L["OPT_MIN_QUALITY_DESC"] = "표시할 아이템의 최소 등급을 선택합니다."
    L["OPT_BG_ALPHA"] = "배경 투명도"
    L["OPT_BG_ALPHA_DESC"] = "창 배경의 불투명도를 조절합니다. (0.0 ~ 1.0)"
    L["OPT_EXPIRATION"] = "메시지 유지 시간"
    L["OPT_EXPIRATION_DESC"] = "로그 메시지가 화면에 유지되는 시간을 설정합니다."
    L["OPT_TIMESTAMP"] = "타임스탬프 표시"
    L["OPT_TIMESTAMP_DESC"] = "메시지 맨 앞에 [HH:MM] 형식의 시간을 표시합니다."
    L["OPT_SHOW_NPC"] = "NPC 대화 표시"
    L["OPT_SHOW_NPC_DESC"] = "몬스터의 일반 대화, 외치기, 귓속말을 로그에 표시합니다."
    L["OPT_LOCK"] = "창 위치 및 크기 잠금"
    L["OPT_LOCK_DESC"] = "창의 이동과 크기 조절을 방지합니다. (/ldl lock)"
    L["OPT_HIDE_IN_COMBAT"] = "전투 중 숨기기"
    L["OPT_HIDE_IN_COMBAT_DESC"] = "전투 시작 시 자동으로 창을 숨깁니다."
    L["OPT_SHOW_IN_MYTHIC"] = "신화+ 던전에서 표시"
    L["OPT_SHOW_IN_MYTHIC_DESC"] = "신화+ 던전 안에서 로그를 표시합니다."
    L["OPT_SHOW_IN_RAID"] = "공격대 던전에서 표시"
    L["OPT_SHOW_IN_RAID_DESC"] = "공격대 던전 안에서 로그를 표시합니다."

    L["EXP_UNLIMITED"] = "무제한"
    L["EXP_1MIN"] = "1분"
    L["EXP_3MIN"] = "3분"
    L["EXP_5MIN"] = "5분"
    L["EXP_10MIN"] = "10분"

    L["QUALITY_0"] = "|cff9d9d9d하급 (Poor)|r"
    L["QUALITY_1"] = "|cffffffff일반 (Common)|r"
    L["QUALITY_2"] = "|cff1eff00고급 (Uncommon)|r"
    L["QUALITY_3"] = "|cff0070dd희귀 (Rare)|r"
    L["QUALITY_4"] = "|cffa335ee영웅 (Epic)|r"
    L["QUALITY_5"] = "|cffff8000전설 (Legendary)|r"
end
