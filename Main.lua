local addonName, addonTable = ...
local L = addonTable

-- 기본 설정값
local defaultDB = {
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
    expirationTime = 0, -- 0: 무제한, 60: 1분, 300: 5분, 600: 10분
}

local frame = CreateFrame("ScrollingMessageFrame", "LootDialogLogFrame", UIParent, "BackdropTemplate")
frame:SetSize(defaultDB.frameWidth, defaultDB.frameHeight)
frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", defaultDB.framePosX, defaultDB.framePosY)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetResizable(true)
frame:SetResizeBounds(150, 80, 800, 600)
frame:SetInsertMode("TOP")
frame:SetFading(false)
frame:SetMaxLines(100)
frame:SetFontObject(ChatFontNormal)
frame:SetJustifyH("LEFT")

-- 필터 상태 (all, npc, item)
L.FilterMode = "all"

-- 버튼 업데이트 함수
local function UpdateFilterButtons()
    -- 모든 버튼 초기화
    local buttons = {
        all = L.btnAll,
        npc = L.btnNPC,
        item = L.btnItem
    }
    
    for id, btn in pairs(buttons) do
        if btn then
            if id == L.FilterMode then
                btn:LockHighlight() -- 버튼 강조 고정
                btn:GetFontString():SetTextColor(1, 0.82, 0) -- 노란색 텍스트
            else
                btn:UnlockHighlight() -- 강조 해제
                btn:GetFontString():SetTextColor(1, 1, 1) -- 흰색 텍스트
            end
        end
    end
end

-- 버튼 생성 유틸리티
local function CreateFilterButton(text, point, relativeFrame, x, y, onClick)
    local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btn:SetSize(45, 18)
    btn:SetText(text)
    btn:SetPoint(point, relativeFrame, point, x, y)
    btn:GetFontString():SetFont(ChatFontNormal:GetFont(), 10)
    btn:SetScript("OnClick", function(self)
        onClick(self)
        UpdateFilterButtons()
    end)
    return btn
end

-- 버튼 바 배경
local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
header:SetSize(frame:GetWidth(), 22)
header:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 0)
header:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
})
header:SetBackdropColor(0, 0, 0, 0.8)
header:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

-- 버튼들 추가
L.btnAll = CreateFilterButton(L["TAB_ALL"], "LEFT", header, 2, 0, function() L.FilterMode = "all"; L.RefreshLog() end)
L.btnNPC = CreateFilterButton(L["TAB_NPC"], "LEFT", L.btnAll, 47, 0, function() L.FilterMode = "npc"; L.RefreshLog() end)
L.btnItem = CreateFilterButton(L["TAB_ITEM"], "LEFT", L.btnNPC, 47, 0, function() L.FilterMode = "item"; L.RefreshLog() end)
local btnClear = CreateFilterButton(L["TAB_CLEAR"], "RIGHT", header, -2, 0, function() L.LogEntries = {}; L.RefreshLog() end)

-- 초기 상태 적용
UpdateFilterButtons()

-- 마우스 휠 스크롤 추가
frame:EnableMouseWheel(true)
frame:SetScript("OnMouseWheel", function(self, delta)
    if delta > 0 then
        if IsShiftKeyDown() then self:ScrollToTop() else self:ScrollUp() end
    else
        if IsShiftKeyDown() then self:ScrollToBottom() else self:ScrollDown() end
    end
end)

-- 로그 항목 저장 테이블
L.LogEntries = {}

local function RefreshLog()
    frame:Clear()
    -- 아래에서 위로(오래된 것부터) 추가해야 InsertMode("TOP")에 의해 최신이 위로 감
    for i = #L.LogEntries, 1, -1 do
        local entry = L.LogEntries[i]
        local show = false
        
        if L.FilterMode == "all" then
            show = true
        elseif L.FilterMode == "npc" and entry.isNPC then
            show = true
        elseif L.FilterMode == "item" and not entry.isNPC then
            show = true
        end
        
        if show then
            frame:AddMessage(entry.text)
        end
    end
end
L.RefreshLog = RefreshLog

local function AddLogMessage(msg, isNPC)
    -- 옵션에서 꺼져있으면 기록조차 하지 않음
    if isNPC and not LootDialogLogDB.showNPC then return end
    
    table.insert(L.LogEntries, 1, { text = msg, timestamp = time(), isNPC = isNPC })
    if #L.LogEntries > 100 then
        table.remove(L.LogEntries)
    end
    
    -- 현재 필터 모드에 맞는 경우에만 화면에 즉시 출력
    L.RefreshLog()
end

-- 주기적으로 오래된 메시지 삭제
C_Timer.NewTicker(10, function()
    if not LootDialogLogDB or LootDialogLogDB.expirationTime == 0 then return end
    
    local currentTime = time()
    local changed = false
    for i = #L.LogEntries, 1, -1 do
        if currentTime - L.LogEntries[i].timestamp > LootDialogLogDB.expirationTime then
            table.remove(L.LogEntries, i)
            changed = true
        end
    end
    
    if changed then
        RefreshLog()
    end
end)

-- 하이퍼링크 상호작용
frame:SetHyperlinksEnabled(true)
frame:SetScript("OnHyperlinkEnter", function(self, _, link)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:SetHyperlink(link)
    GameTooltip:Show()
end)
frame:SetScript("OnHyperlinkLeave", function(self) GameTooltip:Hide() end)
frame:SetScript("OnHyperlinkClick", function(self, _, link, button) SetItemRef(link, link, button) end)

-- 유틸리티: 타임스탬프
local function GetTimestamp()
    if LootDialogLogDB and LootDialogLogDB.showTimestamp then
        return string.format("|cff888888[%s]|r ", date("%H:%M"))
    end
    return ""
end

-- 유틸리티: 직업 색상 코드 가져오기 (전체 메시지용)
local function GetClassColor(guid, name)
    local englishClass
    
    -- 1. 본인 확인 (가장 빈번하므로 최우선 처리)
    if guid == UnitGUID("player") or name == UnitName("player") then
        _, englishClass = UnitClass("player")
    -- 2. GUID를 통한 정보 확인
    elseif guid and guid ~= "" then
        _, englishClass = GetPlayerInfoByGUID(guid)
    -- 3. 이름 기반 확인 (근처 유닛)
    elseif name and name ~= "" then
        _, englishClass = UnitClass(name)
    end
    
    if englishClass then
        local classColor = C_ClassColor.GetClassColor(englishClass)
        if classColor then
            return classColor:GenerateHexColorMarkup() -- "ffxxxxxx" 형식 반환
        end
    end
    
    return "ffffff00" -- 기본 루팅 노란색 (실패 시)
end

-- 크기 조절 핸들
local resizeButton = CreateFrame("Button", nil, frame)
resizeButton:SetSize(16, 16)
resizeButton:SetPoint("BOTTOMRIGHT")
resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

resizeButton:SetScript("OnMouseDown", function(self) if not LootDialogLogDB.isLocked then frame:StartSizing("BOTTOMRIGHT") end end)
resizeButton:SetScript("OnMouseUp", function()
    frame:StopMovingOrSizing()
    LootDialogLogDB.frameWidth = frame:GetWidth()
    LootDialogLogDB.frameHeight = frame:GetHeight()
end)

-- 스타일 업데이트
local function UpdateFrameStyle()
    if not LootDialogLogDB then return end
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tile = true, tileSize = 16,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetBackdropColor(0, 0, 0, LootDialogLogDB.bgAlpha or 0.5)
    if LootDialogLogDB.isLocked then resizeButton:Hide() else resizeButton:Show() end
end
L.UpdateFrameStyle = UpdateFrameStyle

-- 드래그 및 슬래시
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) if not LootDialogLogDB.isLocked then self:StartMoving() end end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local _, _, _, xOfs, yOfs = self:GetPoint()
    LootDialogLogDB.framePosX = xOfs
    LootDialogLogDB.framePosY = yOfs
end)

SLASH_LOOTDIALOGLOG1 = "/ldl"
SlashCmdList["LOOTDIALOGLOG"] = function(msg)
    if msg == "lock" then
        LootDialogLogDB.isLocked = not LootDialogLogDB.isLocked
        UpdateFrameStyle()
    else
        Settings.OpenToCategory("LootDialogLog")
    end
end

-- 이벤트
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
frame:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

local function UpdateVisibility()
    if not LootDialogLogDB then return end
    local difficultyID = C_Instance and C_Instance.GetDifficultyID and C_Instance.GetDifficultyID()
    local _, instanceType = GetInstanceInfo()
    local isMythicPlus = (difficultyID == 23)
    local isRaid = (instanceType == "raid")
    
    if (isMythicPlus and not LootDialogLogDB.showInMythicPlus) or (isRaid and not LootDialogLogDB.showInRaid) then
        frame:Hide()
        return
    end
    if LootDialogLogDB.hideInCombat and InCombatLockdown() then frame:Hide() else frame:Show() end
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            LootDialogLogDB = LootDialogLogDB or {}
            for k, v in pairs(defaultDB) do if LootDialogLogDB[k] == nil then LootDialogLogDB[k] = v end end
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LootDialogLogDB.framePosX, LootDialogLogDB.framePosY)
            self:SetSize(LootDialogLogDB.frameWidth, LootDialogLogDB.frameHeight)
            UpdateFrameStyle()
            UpdateVisibility()
        end
    elseif event == "CHAT_MSG_LOOT" then
        local message, sender, _, _, _, _, _, _, _, _, _, guid = ...
        local itemLink = string.match(message, "|Hitem:.-|h.-|h")
        if itemLink then
            local quality = C_Item.GetItemQualityByID(itemLink)
            if quality and quality >= (LootDialogLogDB.minQuality or 0) then
                -- GenerateHexColorMarkup()이 이미 |c를 포함하므로 추가하지 않음
                local colorCode = GetClassColor(guid, sender)
                local finalMsg = string.format("%s%s|r", colorCode, message)
                AddLogMessage(GetTimestamp() .. finalMsg)
            end
        end
    elseif event:find("CHAT_MSG_MONSTER") then
        local message, sender, language = ...
        local color = "|cffffff9f"
        if event == "CHAT_MSG_MONSTER_YELL" then color = "|cffff4040"
        elseif event == "CHAT_MSG_MONSTER_WHISPER" then color = "|cffffb5eb"
        end
        
        -- 언어 정보 추가 (공통어가 아니거나 비어있지 않은 경우)
        local langTag = (language and language ~= "" and language ~= "Universal") and ("["..language.."] ") or ""
        AddLogMessage(string.format("%s%s[%s]: %s%s|r", GetTimestamp(), color, sender or "NPC", langTag, message), true)
    elseif event == "PLAYER_REGEN_DISABLED"
 or event == "PLAYER_REGEN_ENABLED" or event == "ZONE_CHANGED_NEW_AREA" then
        UpdateVisibility()
    end
end)
