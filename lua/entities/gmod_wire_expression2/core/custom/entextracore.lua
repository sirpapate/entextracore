
E2Lib.RegisterExtension("entextracore", true)

--[[---------------------------------------------------------
	On Spawn
-----------------------------------------------------------]]

local registered_e2s_entspawn = {}
local lastentspawned = NULL

registerCallback("destruct", function(self)
	registered_e2s_entspawn[self.entity] = nil
end)

hook.Add("OnEntityCreated", "wire_expression2_entextracore_onentitycreated", function(ent)
    timer.Simple(0, function()
    	lastentspawned = ent

    	for entity,_ in pairs(registered_e2s_entspawn) do
    		if entity:IsValid() then
    			entity:Execute()
    		end
    	end

    	lastentspawned = NULL
    end)
end)

__e2setcost(1)
e2function void runOnEntitySpawn(activate)
	if activate ~= 0 then
		registered_e2s_entspawn[self.entity] = true
	else
		registered_e2s_entspawn[self.entity] = nil
	end
end

__e2setcost(2)
e2function entity entitySpawnClk()
	return lastentspawned
end

--[[---------------------------------------------------------
	On Remove
-----------------------------------------------------------]]

local registered_e2s_entremove = {}
local lastentremoved = NULL

registerCallback("destruct", function(self)
	registered_e2s_entremove[self.entity] = nil
end)

hook.Add("EntityRemoved", "wire_expression2_entextracore_entityremoved", function(ent)
	lastentremoved = ent

	for entity,_ in pairs(registered_e2s_entremove) do
		if entity:IsValid() then
			entity:Execute()
		end
	end

	lastentremoved = NULL
end)

__e2setcost(1)
e2function void runOnEntityRemove(activate)
	if activate ~= 0 then
		registered_e2s_entremove[self.entity] = true
	else
		registered_e2s_entremove[self.entity] = nil
	end
end

__e2setcost(2)
e2function entity entityRemoveClk()
	return lastentremoved
end

--[[---------------------------------------------------------
	Misc
-----------------------------------------------------------]]

__e2setcost(1)
e2function number entity:creationID()
	if IsValid(this) then
		return this:GetCreationID()
	end
end

__e2setcost(2)
e2function array entity:children()
	if IsValid(this) then
		return this:GetChildren()
	end
end

--[[---------------------------------------------------------
	Tag system
-----------------------------------------------------------]]

__e2setcost(5)
e2function void entity:addTag(string tag)
	if IsValid(this) and E2Lib.isOwner(self, this) then
		this.EntityMods = this.EntityMods or {}
		this.EntityMods.expession2_tag = this.EntityMods.expession2_tag or {}
		local tags = this.EntityMods.expession2_tag

		if not table.HasValue(tags, tag) then
			table.insert(tags, tag)
		end
	end
end

__e2setcost(10)
e2function void array:addTag(string tag)
	for _,ent in pairs(this) do
		if IsValid(ent) and E2Lib.isOwner(self, ent) then
			ent.EntityMods = ent.EntityMods or {}
			ent.EntityMods.expession2_tag = ent.EntityMods.expession2_tag or {}
			local tags = ent.EntityMods.expession2_tag

			if not table.HasValue(tags, tag) then
				table.insert(tags, tag)
			end
		end
	end
end

__e2setcost(5)
e2function void entity:removeTag(string tag)
	if IsValid(this) and this.EntityMods and this.EntityMods.expession2_tag then
		if E2Lib.isOwner(self, this) then
			local tags = this.EntityMods.expession2_tag

			for i,t in pairs(tags) do
				if t == tag then
					tags[i] = nil
					break
				end
			end
		end
	end
end

__e2setcost(10)
e2function void array:removeTag(string tag)
	for _,ent in pairs(this) do
		if IsValid(ent) and ent.EntityMods and ent.EntityMods.expession2_tag then
			if E2Lib.isOwner(self, ent) then
				local tags = ent.EntityMods.expession2_tag

				for i,t in pairs(tags) do
					if t == tag then
						tags[i] = nil
						break
					end
				end
			end
		end
	end
end

__e2setcost(5)
e2function array entity:getTags()
	if IsValid(this) and this.EntityMods and this.EntityMods.expession2_tag then
		return this.EntityMods.expession2_tag
	end

	return {}
end

e2function number entity:hasTag(string tag)
	if IsValid(this) and this.EntityMods and this.EntityMods.expession2_tag then
		local tags = this.EntityMods.expession2_tag

		if table.HasValue(tags, tag) then
			return 1
		end
	end

	return 0
end

__e2setcost(10)
e2function array array:haveTag(string tag)
	local goodents = {}

	for _,ent in pairs(this) do
		if IsValid(ent) and ent.EntityMods and ent.EntityMods.expession2_tag then
			local tags = ent.EntityMods.expession2_tag

			if table.HasValue(tags, tag) then
				table.insert(goodents, ent)
			end
		end
	end

	return goodents
end
__e2setcost(20)
e2function array getEntitiesByTag(string tag)
	local entities = {}

	for _,ent in pairs(ents.GetAll()) do
		if IsValid(ent) and ent.EntityMods and ent.EntityMods.expession2_tag then
			local tags = ent.EntityMods.expession2_tag

			if table.HasValue(tags, tag) then
				table.insert(entities, ent)
			end
		end
	end

	return entities
end

--[[---------------------------------------------------------
	Key Value
-----------------------------------------------------------]]

__e2setcost(5)
e2function void entity:setKeyValue(string key, string value)
	if IsValid(this) and E2Lib.isOwner(self, this) then
		this.EntityMods = this.EntityMods or {}
		this.EntityMods.expession2_keyvalues = this.EntityMods.expession2_keyvalues or {}
		local keyvalues = this.EntityMods.expession2_keyvalues

        keyvalues[key] = value
	end
end

e2function void array:setKeyValue(string key, string value)
	for _,ent in pairs(this) do
    	if IsValid(ent) and E2Lib.isOwner(self, ent) then
    		ent.EntityMods = ent.EntityMods or {}
    		ent.EntityMods.expession2_keyvalues = ent.EntityMods.expession2_keyvalues or {}
    		local keyvalues = ent.EntityMods.expession2_keyvalues

            keyvalues[key] = value
    	end
    end
end

e2function void entity:removeKeyValue(string key)
	if IsValid(this) and E2Lib.isOwner(self, this) then
		this.EntityMods = this.EntityMods or {}
		this.EntityMods.expession2_keyvalues = this.EntityMods.expession2_keyvalues or {}
		local keyvalues = this.EntityMods.expession2_keyvalues

        keyvalues[key] = nil
	end
end

e2function void array:removeKeyValue(string key)
	for _,ent in pairs(this) do
    	if IsValid(ent) and E2Lib.isOwner(self, ent) then
    		ent.EntityMods = ent.EntityMods or {}
    		ent.EntityMods.expession2_keyvalues = ent.EntityMods.expession2_keyvalues or {}
    		local keyvalues = ent.EntityMods.expession2_keyvalues

            keyvalues[key] = nil
    	end
    end
end

e2function string entity:getKeyValue(string key)
    if IsValid(this) and E2Lib.isOwner(self, this) then
        this.EntityMods = this.EntityMods or {}
        this.EntityMods.expession2_keyvalues = this.EntityMods.expession2_keyvalues or {}
        local keyvalues = this.EntityMods.expession2_keyvalues

        print(keyvalues[key])
        return keyvalues[key] or ""
    end

    return ""
end

local DEFAULT_TABLE = {n={},ntypes={},s={},stypes={},size=0}

e2function table entity:getKeyValues()
    if IsValid(this) and E2Lib.isOwner(self, this) then
        this.EntityMods = this.EntityMods or {}
        this.EntityMods.expession2_keyvalues = this.EntityMods.expession2_keyvalues or {}

		local ret = table.Copy(DEFAULT_TABLE)
		local size = 0
		for k,v in pairs(this.EntityMods.expession2_keyvalues) do
			if isstring(v) then
				ret.s[k] = v
				ret.stypes[k] = "s"
				size = size + 1
			end
		end

		ret.size = size
		return ret
    end
end

__e2setcost(20)
e2function array getEntitiesByKeyValue(string key, string value)
	local entities = {}

	for _,ent in pairs(ents.GetAll()) do
		if IsValid(ent) and ent.EntityMods and ent.EntityMods.expession2_keyvalues then
			local keyvalues = ent.EntityMods.expession2_keyvalues

			if keyvalues[key] and keyvalues[key] == value then
				table.insert(entities, ent)
			end
		end
	end

	return entities
end

__e2setcost(10)
e2function array array:haveKeyValue(string key, string value)
	local goodents = {}

	for _,ent in pairs(this) do
		if IsValid(ent) and ent.EntityMods and ent.EntityMods.expession2_tag then
			local keyvalues = this.EntityMods.expession2_keyvalues

			if keyvalues[key] and keyvalues[key] == value then
				table.insert(goodents, ent)
			end
		end
	end

	return goodents
end

--[[---------------------------------------------------------
    Halo
-----------------------------------------------------------]]

util.AddNetworkString("wire_expression2_entextracore_halo_sync")
util.AddNetworkString("wire_expression2_entextracore_halo_update")
util.AddNetworkString("wire_expression2_entextracore_halo_remove")

local function UpdateHalo(ent)
	net.Start("wire_expression2_entextracore_halo_update")
		net.WriteEntity(ent)
		net.WriteString(util.TableToJSON(ent.EntityMods.expession2_halo))
	net.Broadcast()
end

local function SetHalo(ent, color, blurX, blurY, add, ingore)
    ent.EntityMods = ent.EntityMods or {}
    ent.EntityMods.expession2_halo = {
        Color = color,
        BlurX = blurX,
        BlurY = blurY,
        Additive = add,
        IgnoreZ = ignore
    }

	UpdateHalo(ent)
end

hook.Add("PlayerInitialSpawn", "wire_expression2_entextracore_halo_sync", function(ply)
    local info = {}

    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and ent.EntityMods and ent.EntityMods.expession2_halo then
            info[ent] = ent.EntityMods.expession2_halo
        end
    end

    net.Start("wire_expression2_entextracore_halo_sync")
        net.WriteInt(#info, 32)

        for ent, halo in pairs(info) do
            net.WriteEntity(ent)
            net.WriteString(util.TableToJSON(halo))
        end
    net.Send(ply)
end)

hook.Add("OnEntityCreated", "wire_expression2_entextracore_halo_update", function(ent)
    timer.Simple(0, function()
        if ent.EntityMods and ent.EntityMods.expession2_halo then
            UpdateHalo(ent)
        end
    end)
end)

e2function void entity:setHalo(vector c, number blurX, number blurY, add, ingore)
    if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end
    local color = Color(c[1], c[2], c[3])

    SetHalo(this, color, blurX, blurY, add~=0, ingore~=0)
end

e2function void entity:setHalo(vector c, number blurX, number blurY, add)
    if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end
    local color = Color(c[1], c[2], c[3])

    SetHalo(this, color, blurX, blurY, add~=0, false)
end

e2function void entity:setHalo(vector c, number blurX, number blurY)
    if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end
    local color = Color(c[1], c[2], c[3])

    SetHalo(this, color, blurX, blurY, true, false)
end

e2function void entity:setHalo(vector c)
    if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end
    local color = Color(c[1], c[2], c[3])

    SetHalo(this, color, 5, 5, true, false)
end

e2function void entity:removeHalo()
    if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end
    if not this.EntityMods or not this.EntityMods.expession2_halo then return end

    this.EntityMods.expession2_halo = nil

    net.Start("wire_expression2_entextracore_remove")
        net.WriteEntity(this)
    net.Broadcast()
end

--[[---------------------------------------------------------
    WorldTip
-----------------------------------------------------------]]

util.AddNetworkString("wire_expression2_entextracore_worldtip_sync")
util.AddNetworkString("wire_expression2_entextracore_worldtip_update")

local function UpdateWorldTip(ent)
	net.Start("wire_expression2_entextracore_worldtip_update")
		net.WriteEntity(ent)
		net.WriteString(ent.EntityMods.expession2_worldtip or "")
	net.Broadcast()
end

e2function void entity:setWorldTip(string text)
    if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end
	if #text == 0 then return end

    this.EntityMods = this.EntityMods or {}
    this.EntityMods.expession2_worldtip = text

	UpdateWorldTip(this)
end

e2function void entity:removeWorldTip()
    if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end
	if not this.EntityMods or not this.EntityMods.expession2_worldtip then return end

    this.EntityMods = this.EntityMods or {}
    this.EntityMods.expession2_worldtip = nil

	UpdateWorldTip(this)
end

hook.Add("PlayerInitialSpawn", "wire_expression2_entextracore_worldtip_sync", function(ply)
    local info = {}

    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and ent.EntityMods and ent.EntityMods.expession2_worldtip then
            info[ent] = ent.EntityMods.expession2_worldtip
        end
    end

    net.Start("wire_expression2_entextracore_worldtip_sync")
        net.WriteInt(#info, 32)

        for ent, text in pairs(info) do
            net.WriteEntity(ent)
            net.WriteString(text)
        end
    net.Send(ply)
end)

hook.Add("OnEntityCreated", "wire_expression2_entextracore_worldtip_update", function(ent)
    timer.Simple(0, function()
        if ent.EntityMods and ent.EntityMods.expession2_worldtip then
            UpdateWorldTip(ent)
        end
    end)
end)
