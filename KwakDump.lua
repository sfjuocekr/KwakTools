SLASH_KWAKDUMP1 = "/kwakdump"

local function DumpValue(name, value)
    if type(value) == "function" then
        print(name, "function", value)
    elseif type(value) == "table" then
        print(name, "table", value)
    else
        print(name, type(value), tostring(value))
    end
end


local function DumpFrame(frame, name)
    print("========================================")
    print("FRAME:", name)
    print("========================================")

    if not frame then
        print("Frame does not exist.")
        return
    end

    print("--- Direct members ---")

    for key, value in pairs(frame) do
        DumpValue("  " .. tostring(key), value)
    end

    print("--- Scripts ---")

    local scripts = {
        "OnLoad",
        "OnEvent",
        "OnShow",
        "OnHide",
        "OnUpdate",
        "OnSizeChanged",
        "OnAttributeChanged",
        "OnEnter",
        "OnLeave",
        "OnClick",
        "OnMouseDown",
        "OnMouseUp",
    }

    for _, scriptType in ipairs(scripts) do
        local handler = frame:GetScript(scriptType)

        if handler then
            print("  " .. scriptType, handler)
        end
    end

    print("--- Children ---")

    local children = { frame:GetChildren() }

    for i, child in ipairs(children) do
        print(
            "  " .. i,
            child:GetName() or "<unnamed>",
            child:GetObjectType()
        )
    end

    print("--- Regions ---")

    local regions = { frame:GetRegions() }

    for i, region in ipairs(regions) do
        print(
            "  " .. i,
            region:GetName() or "<unnamed>",
            region:GetObjectType()
        )
    end
end


SlashCmdList.KWAKDUMP = function(msg)
    msg = msg ~= "" and msg or "CompactPartyFrame"

    local frame = _G[msg]

    if not frame then
        print("Usage: /kwakdump FrameName")
        print("Example: /kwakdump CompactPartyFrame")
        return
    end

    DumpFrame(frame, msg)
end
