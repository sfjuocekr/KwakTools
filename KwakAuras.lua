local KwakTools = KwakTools

local SPIRIT_TAP_COOLDOWN_ID = 199997
local SPIRIT_TAP_CHECK_INTERVAL = 0.1


function KwakTools:InitializeAuras()
    self.spiritTapActive = false
    self.spiritTapFrame = nil
    
    C_Timer.NewTicker(
        SPIRIT_TAP_CHECK_INTERVAL,
        function()
            KwakTools:UpdateSpiritTap()
        end
    )
end


function KwakTools:FindSpiritTapFrame()
    if not BuffIconCooldownViewer then
        return nil
    end

    for _, frame in ipairs({BuffIconCooldownViewer:GetChildren()}) do
        if frame
            and frame.GetCooldownID
            and frame:GetCooldownID() == SPIRIT_TAP_COOLDOWN_ID
        then
            self.spiritTapFrame = frame
            return frame
        end
    end

    self.spiritTapFrame = nil
    
    return nil
end


function KwakTools:UpdateSpiritTap()
    local frame = self.spiritTapFrame

    if not frame
        or not frame.GetCooldownID
        or frame:GetCooldownID() ~= SPIRIT_TAP_COOLDOWN_ID
    then
        frame = KwakTools:FindSpiritTapFrame()
    end

    if not frame then
        return
    end

    --self:Print("Spirit Tap state:", tostring(frame:IsActive()))
    KwakTools:HandleSpiritTap(frame:IsActive())
end


function KwakTools:HandleSpiritTap(_active)
    if self:IsRestricted() then
        return
    end

    if _active == self.spiritTapActive then
        return
    end

    self.spiritTapActive = _active

    if not _active then
        return
    end

    --self:Print("SPIRIT TAP ACTIVE")

    if self.db.profile.spiritTapEmote then
        local emotes = { "cheer", "train", "charge", "attacktarget", "openfire" }
        DoEmote(emotes[math.random(#emotes)], "none")
    end
end
