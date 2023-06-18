E2Helper.Descriptions["runOnEntitySpawn"] = "If set to 1, E2 will run when an entity is spawned."
E2Helper.Descriptions["entitySpawnClk"] = "Returns the entity that was spawned."
E2Helper.Descriptions["runOnEntityRemove"] = "If set to 1, E2 will run when an entity is removed."
E2Helper.Descriptions["entityRemoveClk"] = "Returns the entity that was removed."

E2Helper.Descriptions["creationID"] = "Returns the entity's creation ID."
E2Helper.Descriptions["children"] = "Returns entity's creation ID. Unlike E:id(), it will always increase and old values won't be reused."

E2Helper.Descriptions["addTag"] = "Adds a tag to the entity or all entities in the array. The tag can be used to identify the entity in other E2s."
E2Helper.Descriptions["removeTag"] = "Removes a tag from the entity or all entities in the array."
E2Helper.Descriptions["getTags"] = "Gets all tags of the entity."
E2Helper.Descriptions["hasTag"] = "Returns 1 if the entity has the tag, 0 otherwise."
E2Helper.Descriptions["haveTag"] = "Returns an array of 1s and 0s. 1 if the entity has the tag, 0 otherwise."
E2Helper.Descriptions["getEntitiesByTag"] = "Returns an array of entities with the tag."

E2Helper.Descriptions["setKeyValue"] = "Sets a key-value pair on the entity or all entities in the array. The key-value pair can be used to store data on the entity and can be retrieved by other E2s."
E2Helper.Descriptions["removeKeyValue"] = "Removes a key-value pair from the entity or all entities in the array."
E2Helper.Descriptions["getKeyValue"] = "Gets the value of a key-value pair on the entity."
E2Helper.Descriptions["getKeyValues"] = "Gets all key-value pairs on the entity."
E2Helper.Descriptions["getEntitiesByKeyValue"] = "Gets all entities with the specified key-value pair."
E2Helper.Descriptions["haveKeyValue"] = "Returns an array of 1s and 0s. 1 if the entity has the key-value pair, 0 otherwise."

E2Helper.Descriptions["setHalo"] = "Applies a halo glow effect to the entity. (Color, BlurX, BlurY, Add, IgnoreZ)"
E2Helper.Descriptions["removeHalo"] = "Removes the halo from the entity."

E2Helper.Descriptions["setWorldTip"] = "Sets a world tip on the entity."
E2Helper.Descriptions["removeWorldTip"] = "Removes the world tip from the entity."

-- Halo

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

-- World Tip

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
