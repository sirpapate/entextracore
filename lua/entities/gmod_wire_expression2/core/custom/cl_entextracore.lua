
local entshalo = {}

net.Receive("wire_expression2_entextracore_halo_update", function()
    local ent = net.ReadEntity()
    local halo = util.JSONToTable(net.ReadString())

    if IsValid(ent) then
        entshalo[ent] = halo
    end
end)

net.Receive("wire_expression2_entextracore_halo_sync", function()
    local count = net.ReadInt(32)

    entshalo = {}

    for i = 1, count do
        local ent = net.ReadEntity()
        local halo = util.JSONToTable(net.ReadString())

        if IsValid(ent) then
            entshalo[ent] = halo
        end
    end
end)

net.Receive("wire_expression2_entextracore_halo_remove", function()
    local ent = net.ReadEntity()

    if IsValid(ent) then
        entshalo[ent] = nil
    end
end)

hook.Add("PreDrawHalos", "wire_expression2_entextracore_halo_draw", function()
    for ent, h in pairs(entshalo) do
        if IsValid(ent) then
            halo.Add({ent}, h.Color, h.BlurX, h.BlurY, 5, h.Additive, h.IgnoreZ)
        else
            entshalo[ent] = nil
        end
    end
end)

local entsworldtip = {}

net.Receive("wire_expression2_entextracore_worldtip_update", function()
    local ent = net.ReadEntity()
    local text = net.ReadString()

    if IsValid(ent) then
        if text ~= "" then
            entsworldtip[ent] = text
        else
            entsworldtip[ent] = nil
        end
    end
end)

net.Receive("wire_expression2_entextracore_worldtip_sync", function()
    local count = net.ReadInt(32)

    entsworldtip = {}

    for i = 1, count do
        local ent = net.ReadEntity()
        local halo = util.JSONToTable(net.ReadString())

        if IsValid(ent) then
            entsworldtip[ent] = halo
        end
    end
end)

hook.Add("Think", "wire_expression2_entextracore_worldtip_draw", function()
    local tr = LocalPlayer():GetEyeTrace()
    local ent = tr.Entity

    if IsValid(ent) and entsworldtip[ent] then
        if tr.StartPos:Distance(tr.HitPos) <= 256 then
            AddWorldTip(ent:EntIndex(), entsworldtip[ent], 0.5, ent:GetPos(), ent)

    		halo.Add({ent}, Color(255, 255, 255, 255), 1, 1, 1, true, true)
        end
    end
end)
