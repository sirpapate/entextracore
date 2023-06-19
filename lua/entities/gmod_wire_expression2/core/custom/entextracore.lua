local function isFriend(owner, player)
	if owner == player then
		return true
	end

    if CPPI then
		for _, friend in pairs(player:CPPIGetFriends()) do
			if friend == owner then
				return true
			end
		end

		return false
    else
        return E2Lib.isFriend(owner, player)
    end
end


local function isOwner(chip, entity, canTargetPlayers)
    if CPPI then
		if entity:IsPlayer() and canTargetPlayers then
			return isFriend(chip.player, entity)
		else
	        return entity:CPPICanTool(chip.player, "wire_expression2")
		end
    else
        return E2Lib.isOwner(chip, entity)
    end
end


E2Lib.RegisterExtension("entextracore", true)

--[[---------------------------------------------------------
	On Spawn
-----------------------------------------------------------]]

local registered_e2s_entspawn = {}
local lastentspawned = NULL

E2Lib.registerEvent("entitySpawn", {
	{ "Entity", "e" }
})

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
			
		E2Lib.triggerEvent("entitySpawn", {ent})

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

E2Lib.registerEvent("entityRemove", {
	{ "Entity", "e" }
})

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
			
	E2Lib.triggerEvent("entityRemove", {ent})

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
	if not IsValid(this) then return self:throw("Invalid entity", nil) end

	return this:GetCreationID()
end

__e2setcost(2)
e2function array entity:children()
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	
	return this:GetChildren()
end

--[[---------------------------------------------------------
	Tag system
-----------------------------------------------------------]]

__e2setcost(5)
e2function void entity:addTag(string tag)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this) then return self:throw("You do not own this entity", nil) end

	this.EntityMods = this.EntityMods or {}
	this.EntityMods.expession2_tag = this.EntityMods.expession2_tag or {}
	local tags = this.EntityMods.expession2_tag

	if not table.HasValue(tags, tag) then
		table.insert(tags, tag)
	end
end

__e2setcost(10)
e2function void array:addTag(string tag)
	for _, ent in pairs(this) do
		if not IsValid(ent) then return self:throw("Invalid entity", nil) end
		if not isOwner(self, ent) then return self:throw("You do not own this entity", nil) end
	end

	for _,ent in pairs(this) do
		ent.EntityMods = ent.EntityMods or {}
		ent.EntityMods.expession2_tag = ent.EntityMods.expession2_tag or {}
		local tags = ent.EntityMods.expession2_tag

		if not table.HasValue(tags, tag) then
			table.insert(tags, tag)
		end
	end
end

__e2setcost(5)
e2function void entity:removeTag(string tag)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this) then return self:throw("You do not own this entity", nil) end
	if not this.EntityMods or not this.EntityMods.expession2_tag then return end

	local tags = this.EntityMods.expession2_tag

	for i,t in pairs(tags) do
		if t == tag then
			tags[i] = nil
			break
		end
	end
end

__e2setcost(10)
e2function void array:removeTag(string tag)
	for _, ent in pairs(this) do
		if not IsValid(ent) then return self:throw("Invalid entity", nil) end
		if not isOwner(self, ent) then return self:throw("You do not own this entity", nil) end
	end

	for _,ent in pairs(this) do
		if not ent.EntityMods or not ent.EntityMods.expession2_tag then continue end
		
		local tags = ent.EntityMods.expession2_tag

		for i,t in pairs(tags) do
			if t == tag then
				tags[i] = nil
				break
			end
		end
	end
end

__e2setcost(5)
e2function array entity:getTags()
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not this.EntityMods or not this.EntityMods.expession2_tag then return {} end

	return this.EntityMods.expession2_tag
end

e2function number entity:hasTag(string tag)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not this.EntityMods or not this.EntityMods.expession2_tag then return 0 end
	
	local tags = this.EntityMods.expession2_tag

	return table.HasValue(tags, tag) and 1 or 0
end

__e2setcost(10)
e2function array array:haveTag(string tag)
	for _, ent in pairs(this) do
		if not IsValid(ent) then return self:throw("Invalid entity", nil) end
	end

	local filterredEntities = {}

	for _,ent in pairs(this) do
		if not ent.EntityMods or not ent.EntityMods.expession2_tag then continue end
		
		local tags = ent.EntityMods.expession2_tag

		if table.HasValue(tags, tag) then
			table.insert(filterredEntities, ent)
		end
	end

	return filterredEntities
end

__e2setcost(20)
e2function array getEntitiesByTag(string tag)
	local entities = {}

	for _,ent in pairs(ents.GetAll()) do
		if not IsValid(ent) then continue end
		if not ent.EntityMods or not ent.EntityMods.expession2_tag then continue end
		
		local tags = ent.EntityMods.expession2_tag

		if table.HasValue(tags, tag) then
			table.insert(entities, ent)
		end
	end

	return entities
end

--[[---------------------------------------------------------
	Key Value
-----------------------------------------------------------]]

__e2setcost(5)
e2function void entity:setKeyValue(string key, string value)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this) then return self:throw("You do not own this entity", nil) end
	
	this.EntityMods = this.EntityMods or {}
	this.EntityMods.expession2_keyvalues = this.EntityMods.expession2_keyvalues or {}
	local keyvalues = this.EntityMods.expession2_keyvalues

	keyvalues[key] = value
end

e2function void array:setKeyValue(string key, string value)
	for _, ent in pairs(this) do
		if not IsValid(ent) then return self:throw("Invalid entity", nil) end
		if not isOwner(self, ent) then return self:throw("You do not own this entity", nil) end
	end

	for _,ent in pairs(this) do
		ent.EntityMods = ent.EntityMods or {}
		ent.EntityMods.expession2_keyvalues = ent.EntityMods.expession2_keyvalues or {}
		local keyvalues = ent.EntityMods.expession2_keyvalues

		keyvalues[key] = value
    end
end

e2function void entity:removeKeyValue(string key)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this) then return self:throw("You do not own this entity", nil) end
	
	this.EntityMods = this.EntityMods or {}
	this.EntityMods.expession2_keyvalues = this.EntityMods.expession2_keyvalues or {}
	local keyvalues = this.EntityMods.expession2_keyvalues

	keyvalues[key] = nil
end

e2function void array:removeKeyValue(string key)
	for _, ent in pairs(this) do
		if not IsValid(ent) then return self:throw("Invalid entity", nil) end
		if not isOwner(self, ent) then return self:throw("You do not own this entity", nil) end
	end

	for _,ent in pairs(this) do
		ent.EntityMods = ent.EntityMods or {}
		ent.EntityMods.expession2_keyvalues = ent.EntityMods.expession2_keyvalues or {}
		local keyvalues = ent.EntityMods.expession2_keyvalues

		keyvalues[key] = nil
	end
end

e2function string entity:getKeyValue(string key)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this) then return self:throw("You do not own this entity", nil) end
	
	this.EntityMods = this.EntityMods or {}
	this.EntityMods.expession2_keyvalues = this.EntityMods.expession2_keyvalues or {}
	local keyvalues = this.EntityMods.expession2_keyvalues

	return keyvalues[key] or ""
end

local DEFAULT_TABLE = {n={},ntypes={},s={},stypes={},size=0}

e2function table entity:getKeyValues()
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this) then return self:throw("You do not own this entity", nil) end
	
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

__e2setcost(20)
e2function array getEntitiesByKeyValue(string key, string value)
	for _, ent in pairs(this) do
		if not IsValid(ent) then return self:throw("Invalid entity", nil) end
	end

	local entities = {}

	for _,ent in pairs(ents.GetAll()) do
		if not ent.EntityMods or not ent.EntityMods.expession2_keyvalues then continue end
		
		local keyvalues = ent.EntityMods.expession2_keyvalues

		if keyvalues[key] and keyvalues[key] == value then
			table.insert(entities, ent)
		end
	end

	return entities
end

__e2setcost(10)
e2function array array:haveKeyValue(string key, string value)
	for _, ent in pairs(this) do
		if not IsValid(ent) then return self:throw("Invalid entity", nil) end
	end

	local filterredEntities = {}

	for _,ent in pairs(this) do
		if not ent.EntityMods or not ent.EntityMods.expession2_keyvalues then continue end
	
		local keyvalues = this.EntityMods.expession2_keyvalues

		if keyvalues[key] and keyvalues[key] == value then
			table.insert(filterredEntities, ent)
		end
	end

	return filterredEntities
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

local function SetHalo(ent, color, blurX, blurY, add, ignore)
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

e2function void entity:setHalo(vector color, number blurX, number blurY, add, ignore)
	if not IsValid(this) then return self:throw("Invalid entity", this) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", this) end

    local color = Color(color[1], color[2], color[3])

    SetHalo(this, color, blurX, blurY, add~=0, ignore~=0)
end

e2function void entity:setHalo(vector color, number blurX, number blurY, add)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end

    local color = Color(color[1], color[2], color[3])

    SetHalo(this, color, blurX, blurY, add~=0, false)
end

e2function void entity:setHalo(vector color, number blurX, number blurY)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end

    local color = Color(color[1], color[2], color[3])

    SetHalo(this, color, blurX, blurY, true, false)
end

e2function void entity:setHalo(vector color)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end

    local color = Color(color[1], color[2], color[3])

    SetHalo(this, color, 5, 5, true, false)
end

e2function void entity:removeHalo()
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end
	
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
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end
	if #text == 0 then return end

    this.EntityMods = this.EntityMods or {}
    this.EntityMods.expession2_worldtip = text

	UpdateWorldTip(this)
end

e2function void entity:removeWorldTip()
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end
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
