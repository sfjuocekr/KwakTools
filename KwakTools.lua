local KwakTools = LibStub("AceAddon-3.0"):NewAddon(
    "KwakTools",
    "AceConsole-3.0",
    "AceEvent-3.0"
)


local defaults = {
    profile = {
        spiritTapEmote = false,
        manaLowEmote = false,
        levelUpScreenshot = false,
        killStreakSound = false,
    },
}


local playerUID = UnitGUID("player")

local UNREAL_SOUND_PATH = "Interface/AddOns/KwakTools/Sounds/Unreal/%s"

-- Ordered from lowest to highest kill streak, matching the WoW announcer thresholds.
local STREAK_SOUNDS = {
    { kills = 5,  sound = "killingspree.ogg" },
    { kills = 10, sound = "dominating.ogg" },
    { kills = 15, sound = "rampage.ogg" },
    { kills = 20, sound = "unstoppable.ogg" },
    { kills = 25, sound = "godlike.ogg" },
    { kills = 30, sound = "massacre.ogg" },
}

-- Fine-tier combos (2nd, 3rd, ...) announced on a short, separate window.
local STREAK_COMBO_SOUNDS = {
    { kills = 2, sound = "doublekill.ogg" },
    { kills = 3, sound = "multikill.ogg" },
    { kills = 4, sound = "megakill.ogg" },
    { kills = 5, sound = "ultrakill.ogg" },
    { kills = 6, sound = "monsterkill.ogg" },
}


local function GetStreakTier(_count)
    local tier

    for _, entry in ipairs(STREAK_SOUNDS) do
        if _count >= entry.kills then
            tier = entry
        else
            break
        end
    end

    return tier
end


local function GetStreakComboTier(_count)
    local tier

    for _, entry in ipairs(STREAK_COMBO_SOUNDS) do
        if _count >= entry.kills then
            tier = entry
        else
            break
        end
    end

    return tier
end


function KwakTools:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(
        "KwakToolsDB",
        defaults,
        true
    )

    self:InitializeUI()
    self:InitializeAuras()
    --self:InitializePartyFrame()

    self:Print("OnInitialize")

    self:RegisterEvent("PARTY_KILL", "OnPartyKill")
    self:RegisterEvent("PLAYER_DEAD", "OnPartyKill")

--    hooksecurefunc("JumpOrAscendStart", function() print("Jump key pressed") end)
end


function KwakTools:PrintArgs(...)
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        self:Print(i .. ": " .. tostring(value))
    end
end


local STREAK_RESET_SECONDS = 120
local STREAK_COMBO_SECONDS = 30

local killStreak = 0
local killStreakTimer = nil
local killStreakLastSound = nil

local killCombo = 0
local killComboTimer = nil
local killComboLastSound = nil

-- Queue of kill-streak sounds awaiting playback, so they play one after
-- another instead of firing on top of each other (Unreal Tournament style).
local killSoundQueue = {}
local killSoundTicker = nil
local killSoundHandle = nil
local KILL_SOUND_CHECK_SECONDS = 0.1


function KwakTools:OnPartyKill(event, attackerGUID, targetGUID)
    --self:Print("OnPartyKill")

    if event == "PLAYER_DEAD" then
        self:ClearKillStreak()
        return
    end

    if issecretvalue(attackerGUID) or issecretvalue(targetGUID) then
        return
    end

    if attackerGUID ~= playerUID then
        return
    end

    local unitType = strsplit("-", targetGUID)

    if not unitType or unitType:lower() ~= "creature" then
        return
    end

    killStreak = (killStreak or 0) + 1
    killCombo = (killCombo or 0) + 1

    if self.db.profile.killStreakSound then
        local tier = GetStreakTier(killStreak)

        if tier and tier.sound ~= killStreakLastSound then
            killStreakLastSound = tier.sound
            self:EnqueueKillSound(tier.sound)
        end

        local combo = GetStreakComboTier(killCombo)

        if combo and combo.sound ~= killComboLastSound then
            killComboLastSound = combo.sound
            self:EnqueueKillSound(combo.sound)
        end
    end

    if killStreakTimer then
        killStreakTimer:Cancel()
    end

    killStreakTimer = C_Timer.NewTimer(
        STREAK_RESET_SECONDS,
        self.ClearKillStreak
    )

    if killComboTimer then
        killComboTimer:Cancel()
    end

    killComboTimer = C_Timer.NewTimer(
        STREAK_COMBO_SECONDS,
        self.ClearKillCombo
    )
end


function KwakTools:EnqueueKillSound(_sound)
    if not _sound then
        return
    end

    table.insert(killSoundQueue, _sound)

    if not killSoundTicker then
        killSoundTicker = C_Timer.NewTicker(
            KILL_SOUND_CHECK_SECONDS,
            self.TickKillSoundQueue
        )
    end
end


function KwakTools:TickKillSoundQueue()
    if #killSoundQueue == 0 then
        killSoundHandle = nil
        if killSoundTicker then
            killSoundTicker:Cancel()
            killSoundTicker = nil
        end
        return
    end

    -- Only one sound plays at a time: if the previous sound is still
    -- playing, leave the queue untouched and try again next tick.
    local handle = killSoundHandle
    if handle and C_Sound.IsPlaying(handle) then
        return
    end

    local sound = table.remove(killSoundQueue, 1)
    local path = format(UNREAL_SOUND_PATH, sound)

    killSoundHandle = PlaySoundFile(path)
end


function KwakTools:ClearKillSoundQueue()
    while #killSoundQueue > 0 do
        table.remove(killSoundQueue)
    end
end


function KwakTools:ClearKillStreak()
    killStreak = 0
    killStreakTimer = nil
    killStreakLastSound = nil
end


function KwakTools:ClearKillCombo()
    killCombo = 0
    killComboTimer = nil
    killComboLastSound = nil
end


function KwakTools:OnEnable()
    self:Print("OnEnable")
end


function KwakTools:OnDisable()
    self:Print("OnDisable")
end


function KwakTools:OnKwak(_input)
    if _input == "" then
        Settings.OpenToCategory(self.optionsFrame.name)
        return
    end

    self:Print(_input)
end


function KwakTools:OnWhisperTarget(_input)
    if _input == "" then
        return
    end

    --local _firstName, _lastName = UnitName("target")

    --if _input == "" or not _firstName then
    --    return
    --end

    --local _targetName = _firstName

    --if _lastName then
    --    _targetName = _firstName .. " " .. _lastName
    --end

    C_ChatInfo.SendChatMessage(
        _input,
        "WHISPER",
        nil,
        self:GetFullName("target")
    )
end


function KwakTools:OnFFA(_input)
    C_PartyInfo.SetLootMethod(Enum.LootMethod.Freeforall)
end


function KwakTools:OnGL(_input)
    C_PartyInfo.SetLootMethod(Enum.LootMethod.Group)
end


function KwakTools:OnLeader(_input)
    if not UnitExists("target") or not UnitIsPlayer("target") then
        KwakTools:Print("You need to target a player.")
        return
    end

    if not UnitInParty("target") then
        KwakTools:Print("Your target is not in your group.")
        return
    end

    if not UnitIsGroupLeader("player") then
        KwakTools:Print("You must be the group leader.")
        return
    end

    --local _firstName, _lastName = UnitName("target")
    --local _targetName = _firstName

    --if _lastName then
    --    _targetName = _firstName .. " " .. _lastName
    --end

    C_PartyInfo.PromoteToLeader(self:GetFullName("target"))
end


function KwakTools:InitializePartyFrame()
    self:KeepPartyFrameVisible()

    --[[hooksecurefunc(CompactPartyFrame, "Hide", function()
        if not IsInGroup() then
            CompactPartyFrame:Show()
        end
    end)]]

    --self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnGroupRosterUpdate")
    --self:RegisterEvent("PLAYER_LEVEL_UP", "OnLevelUp")
end


function KwakTools:IsRestricted()
    local inInstance, instanceType = IsInInstance()
    local isPvP = inInstance and instanceType == "pvp"

    return IsEncounterInProgress() or isPvP
end


function KwakTools:OnGroupRosterUpdate()
    if not self:IsRestricted() then
        self:KeepPartyFrameVisible()
    else
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    end
end


function KwakTools:PLAYER_REGEN_ENABLED()
    if not self:IsRestricted() then
        self:KeepPartyFrameVisible()
    end
end


function KwakTools:OnLevelUp()
    self:Print("DING!")

    --C_Timer.After(1, function()
        Screenshot()
    --end)
end


function KwakTools:KeepPartyFrameVisible()
    if not IsInGroup() then
        CompactPartyFrame:Show()
    end
end


function KwakTools:GetFullName(_target)
    local _firstName, _lastName = UnitName(_target)
    local _targetName = _firstName

    if _lastName then
        _targetName = _firstName .. " " .. _lastName
    end

    return _targetName
end


KwakTools:RegisterChatCommand("kwak", "OnKwak")
KwakTools:RegisterChatCommand("wt", "OnWhisperTarget")
KwakTools:RegisterChatCommand("ffa", "OnFFA")
KwakTools:RegisterChatCommand("gl", "OnGL")
KwakTools:RegisterChatCommand("leader", "OnLeader")
