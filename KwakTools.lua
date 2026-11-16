KwakTools = LibStub("AceAddon-3.0"):NewAddon(
    "KwakTools",
    "AceConsole-3.0",
    "AceEvent-3.0"
)


local defaults = {
    profile = {
        spiritTapEmote = false,
        manaLowEmote = false,
        levelUpScreenshot = false,
    },
}


local killsMade = 0
local killTimer = nil
local playerUID = UnitGUID("player")


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
    --self:RegisterEvent("PLAYER_TARGET_DIED", "OnPlayerTargetDied")

--    hooksecurefunc("JumpOrAscendStart", function() print("Jump key pressed") end)
end


function KwakTools:PrintArgs(...)
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        self:Print(i .. ": " .. tostring(value))
    end
end


function KwakTools:OnPartyKill(event, attackerGUID, targetGUID)
    --self:Print("OnPartyKill")

    if issecretvalue(attackerGUID) or issecretvalue(targetGUID) then
        return
    end

    if attackerGUID ~= playerUID then
        return
    end

    local unitType = strsplit("-", targetGUID)

    if not (killTimer and unitType:lower() == "player") then
        return
    end

    killsMade = killsMade + 1

    self:Print(killsMade)

    killTimer:Cancel()
    killTimer = C_Timer.NewTimer(60, self.KillTimeOut)
end

function KwakTools:OnPlayerTargetDied(...)
    self:Print("OnPlayerTargetDied")

    self:PrintArgs(...)
end

function KwakTools:KillTimeOut()
    self:Print("KillTimeOut")

    killsMade = 0
    killTimer = nil
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
