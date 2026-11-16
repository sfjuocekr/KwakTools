local KwakTools = KwakTools

local options = {
    type = "group",
    name = "KwakTools",
    args = {
        emotesConfig = {
            type = "group",
            name = "Emotional damage:",
            inline = true,
            order = 1,
            args = {
                spiritTap = {
                    type = "toggle",
                    name = "Spirit Tap",
                    desc = "Do a /charge whenever Spirit Tap is gained.",
                    order = 1,

                    get = function()
                        return KwakTools:IsSpiritTapEmoteEnabled()
                    end,

                    set = function(_, value)
                        KwakTools:SetSpiritTapEmoteEnabled(value)
                    end,
                },
                manaLow = {
                    type = "toggle",
                    name = "Mana",
                    desc = "Do a /oom whenever mana is low.",
                    order = 1,

                    get = function()
                        return KwakTools:IsManaLowEmoteEnabled()
                    end,

                    set = function(_, value)
                        KwakTools:SetManaLowEmoteEnabled(value)
                    end,
                },
                levelUp = {
                    type = "toggle",
                    name = "Level Up Screenshot",
                    desc = "Make a screenshot whenever you level up.",
                    order = 1,

                    get = function()
                        return KwakTools:IsLevelUpScreenshotEnabled()
                    end,

                    set = function(_, value)
                        KwakTools:SetLevelUpScreenshotEnabled(value)
                    end,
                },
            },
        },
    },
}


function KwakTools:SetSpiritTapEmoteEnabled(_value)
    self.db.profile.spiritTapEmote = _value

    --if not _value then
    --    self.spiritTapActive = false
    --end
end


function KwakTools:IsSpiritTapEmoteEnabled()
    return self.db.profile.spiritTapEmote
end


function KwakTools:SetManaLowEmoteEnabled(_value)
    self.db.profile.manaLowEmote = _value
end


function KwakTools:IsManaLowEmoteEnabled()
    return self.db.profile.manaLowEmote
end


function KwakTools:SetLevelUpScreenshotEnabled(_value)
    self.db.profile.levelUpScreenshot = _value
end


function KwakTools:IsLevelUpScreenshotEnabled()
    return self.db.profile.levelUpScreenshot
end


function KwakTools:InitializeUI()
    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")

    AceConfig:RegisterOptionsTable(
        "KwakTools",
        options
    )

    self.optionsFrame = AceConfigDialog:AddToBlizOptions(
        "KwakTools",
        "KwakTools"
    )
end
