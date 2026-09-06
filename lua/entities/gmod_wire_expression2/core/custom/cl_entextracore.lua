E2Helper.Descriptions["runOnEntitySpawn"] = "If set to 1, E2 will run when an entity is spawned. Deprecated: use the entityCreated event instead"
E2Helper.Descriptions["entitySpawnClk"] = "Returns the entity that was spawned. Deprecated: use the entityCreated event instead"
E2Helper.Descriptions["runOnEntityRemove"] = "If set to 1, E2 will run when an entity is removed. Deprecated: use the entityRemoved event instead"
E2Helper.Descriptions["entityRemoveClk"] = "Returns the entity that was removed. Deprecated: use the entityRemoved event instead"

E2Helper.Descriptions["creationID"] = "Returns the entity's creation ID. Unlike E:id(), it will always increase and old values won't be reused."
E2Helper.Descriptions["children"] = "Returns the entity's children."

E2Helper.Descriptions["addTag"] = "Adds a tag to the entity or all entities in the array. The tag can be used to identify the entity in other E2s."
E2Helper.Descriptions["removeTag"] = "Removes a tag from the entity or all entities in the array."
E2Helper.Descriptions["getTags"] = "Gets all tags of the entity."
E2Helper.Descriptions["hasTag"] = "Returns 1 if the entity has the tag, 0 otherwise."
E2Helper.Descriptions["haveTag"] = "Returns an array of entities that have the tag."
E2Helper.Descriptions["getEntitiesByTag"] = "Returns an array of entities with the tag."

E2Helper.Descriptions["setKeyValue"] = "Sets a key-value pair on the entity or all entities in the array. The key-value pair can be used to store data on the entity and can be retrieved by other E2s."
E2Helper.Descriptions["removeKeyValue"] = "Removes a key-value pair from the entity or all entities in the array."
E2Helper.Descriptions["getKeyValue"] = "Gets the value of a key-value pair on the entity."
E2Helper.Descriptions["getKeyValues"] = "Gets all key-value pairs on the entity."
E2Helper.Descriptions["getEntitiesByKeyValue"] = "Gets all entities with the specified key-value pair."
E2Helper.Descriptions["haveKeyValue"] = "Returns an array of entities that have the specified key-value pair."

E2Helper.Descriptions["setHalo"] = "Applies a halo glow effect to the entity. (Color, BlurX, BlurY, Add, IgnoreZ)"
E2Helper.Descriptions["removeHalo"] = "Removes the halo from the entity."

E2Helper.Descriptions["setWorldTip"] = "Sets a world tip on the entity."
E2Helper.Descriptions["removeWorldTip"] = "Removes the world tip from the entity."

-- Halo

local ents_halo = {}
local world_tip_halo_ent = NULL

local function readHalo()
	return {
		Color = net.ReadColor(),
		BlurX = net.ReadFloat(),
		BlurY = net.ReadFloat(),
		Additive = net.ReadBool(),
		IgnoreZ = net.ReadBool()
	}
end

net.Receive("wire_expression2_entextracore_halo_update", function()
	local ent = net.ReadEntity()
	local haloData = readHalo()

	if IsValid(ent) then
		ents_halo[ent] = haloData
	end
end)

net.Receive("wire_expression2_entextracore_halo_sync", function()
	local count = net.ReadUInt(16)

	ents_halo = {}

	for _ = 1, count do
		local ent = net.ReadEntity()
		local haloData = readHalo()

		if IsValid(ent) then
			ents_halo[ent] = haloData
		end
	end
end)

net.Receive("wire_expression2_entextracore_halo_remove", function()
	local ent = net.ReadEntity()

	if IsValid(ent) then
		ents_halo[ent] = nil
	end
end)

-- World Tip

local ents_world_tip = {}

net.Receive("wire_expression2_entextracore_worldtip_update", function()
	local ent = net.ReadEntity()
	local text = net.ReadString()

	if IsValid(ent) then
		if text ~= "" then
			ents_world_tip[ent] = text
		else
			ents_world_tip[ent] = nil
		end
	end
end)

net.Receive("wire_expression2_entextracore_worldtip_sync", function()
	local count = net.ReadUInt(16)

	ents_world_tip = {}

	for _ = 1, count do
        local ent = net.ReadEntity()
        local text = net.ReadString()

        if IsValid(ent) then
            if text ~= "" then
                entsworldtip[ent] = text
            else
                entsworldtip[ent] = nil
            end
        end
    end
end)

hook.Add("InitPostEntity", "wire_expression2_entextracore_sync", function()
	net.Start("wire_expression2_entextracore_sync_request")
	net.SendToServer()
end)

hook.Add("Think", "wire_expression2_entextracore_worldtip_draw", function()
	world_tip_halo_ent = NULL

	local lp = LocalPlayer()
	if not IsValid(lp) then return end

	local tr = lp:GetEyeTrace()
	local ent = tr.Entity

	if IsValid(ent) and ents_world_tip[ent] then
		if tr.StartPos:Distance(tr.HitPos) <= 256 then
			if ent:IsPlayer() then
				AddWorldTip(ent:EntIndex(), ents_world_tip[ent], 0.5, ent:EyePos())
			else
				AddWorldTip(ent:EntIndex(), ents_world_tip[ent], 0.5, ent:GetPos())
			end

			world_tip_halo_ent = ent
		end
	end
end)

hook.Add("PreDrawHalos", "wire_expression2_entextracore_halo_draw", function()
	for ent, h in pairs(ents_halo) do
		if IsValid(ent) then
			halo.Add({ent}, h.Color, h.BlurX, h.BlurY, 1, h.Additive, h.IgnoreZ)
		else
			ents_halo[ent] = nil
		end
	end

	if IsValid(world_tip_halo_ent) then
		halo.Add({world_tip_halo_ent}, Color(255, 255, 255, 255), 1, 1, 1, true, true)
	end
end)
