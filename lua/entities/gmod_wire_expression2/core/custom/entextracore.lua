local cv_max_tag_length = CreateConVar("wire_expression2_entextracore_max_tag_length", "64", FCVAR_ARCHIVE, "Maximum length of an E2 entity tag.", 1, 1024)
local cv_max_tags = CreateConVar("wire_expression2_entextracore_max_tags", "32", FCVAR_ARCHIVE, "Maximum number of tags per entity.", 1, 1024)
local cv_max_key_length = CreateConVar("wire_expression2_entextracore_max_key_length", "64", FCVAR_ARCHIVE, "Maximum length of an E2 entity key-value key.", 1, 1024)
local cv_max_value_length = CreateConVar("wire_expression2_entextracore_max_value_length", "256", FCVAR_ARCHIVE, "Maximum length of an E2 entity key-value value.", 1, 4096)
local cv_max_keys = CreateConVar("wire_expression2_entextracore_max_keys", "32", FCVAR_ARCHIVE, "Maximum number of key-values per entity.", 1, 1024)
local cv_max_worldtip_length = CreateConVar("wire_expression2_entextracore_max_worldtip_length", "256", FCVAR_ARCHIVE, "Maximum length of an E2 world tip.", 1, 2048)
local cv_max_halo_blur = CreateConVar("wire_expression2_entextracore_max_halo_blur", "16", FCVAR_ARCHIVE, "Maximum halo blur for E2 setHalo.", 0, 64)

local function isFriend(owner, player)
	if owner == player then
		return true
	end

	if CPPI then
		local friends = player.CPPIGetFriends and player:CPPIGetFriends()
		if not istable(friends) then return false end

		for _, friend in pairs(friends) do
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

local function getEntityMod(ent, key)
	if not IsValid(ent) or not ent.EntityMods then return nil end
	return ent.EntityMods[key]
end

local function setEntityMod(ent, key, data)
	ent.EntityMods = ent.EntityMods or {}
	ent.EntityMods[key] = data

	if duplicator and duplicator.StoreEntityModifier and istable(data) then
		duplicator.StoreEntityModifier(ent, key, data)
	end
end

local function copyDenseArray(tbl)
	local copy = {}
	if not tbl then return copy end

	for _, v in pairs(tbl) do
		table.insert(copy, v)
	end

	return copy
end

local function removeValueFromList(tags, tag)
	local dense = {}
	for _, t in pairs(tags) do
		if t ~= tag then
			table.insert(dense, t)
		end
	end
	return dense
end


E2Lib.RegisterExtension("entextracore", true)

--[[---------------------------------------------------------
	On Spawn
-----------------------------------------------------------]]

local registered_e2s_ent_spawn = {}
local last_ent_spawned = NULL

E2Lib.registerEvent("entitySpawn", {
	{ "Entity", "e" }
}, nil, nil, "Deprecated: use the entityCreated event instead")

registerCallback("destruct", function(self)
	registered_e2s_ent_spawn[self.entity] = nil
end)

hook.Add("OnEntityCreated", "wire_expression2_entextracore_on_entity_created", function(ent)
	timer.Simple(0, function()
		if not IsValid(ent) then return end

		last_ent_spawned = ent

		for entity, _ in pairs(registered_e2s_ent_spawn) do
			if entity:IsValid() then
				entity:Execute()
			else
				registered_e2s_ent_spawn[entity] = nil
			end
		end

		E2Lib.triggerEvent("entitySpawn", {ent})

		last_ent_spawned = NULL
	end)
end)

__e2setcost(1)
[deprecated = "Use the entityCreated event instead"]
e2function void runOnEntitySpawn(activate)
	if activate ~= 0 then
		registered_e2s_ent_spawn[self.entity] = true
	else
		registered_e2s_ent_spawn[self.entity] = nil
	end
end

__e2setcost(2)
[deprecated = "Use the entityCreated event instead"]
e2function entity entitySpawnClk()
	return last_ent_spawned
end

--[[---------------------------------------------------------
	On Remove
-----------------------------------------------------------]]

local registered_e2s_ent_remove = {}
local last_ent_removed = NULL

E2Lib.registerEvent("entityRemove", {
	{ "Entity", "e" }
}, nil, nil, "Deprecated: use the entityRemoved event instead")

registerCallback("destruct", function(self)
	registered_e2s_ent_remove[self.entity] = nil
end)

hook.Add("EntityRemoved", "wire_expression2_entextracore_on_entity_removed", function(ent)
	last_ent_removed = ent

	for entity, _ in pairs(registered_e2s_ent_remove) do
		if entity:IsValid() then
			entity:Execute()
		else
			registered_e2s_ent_remove[entity] = nil
		end
	end

	E2Lib.triggerEvent("entityRemove", {ent})

	last_ent_removed = NULL
end)

__e2setcost(1)
[deprecated = "Use the entityRemoved event instead"]
e2function void runOnEntityRemove(activate)
	if activate ~= 0 then
		registered_e2s_ent_remove[self.entity] = true
	else
		registered_e2s_ent_remove[self.entity] = nil
	end
end

__e2setcost(2)
[deprecated = "Use the entityRemoved event instead"]
e2function entity entityRemoveClk()
	return last_ent_removed
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

local function addTagToEntity(ent, tag)
	local tags = getEntityMod(ent, "expession2_tag") or {}
	if table.HasValue(tags, tag) then return true end
	if #tags >= cv_max_tags:GetInt() then return false end

	table.insert(tags, tag)
	setEntityMod(ent, "expession2_tag", tags)
	return true
end

__e2setcost(5)
e2function void entity:addTag(string tag)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this) then return self:throw("You do not own this entity", nil) end
	if #tag > cv_max_tag_length:GetInt() then return self:throw("Tag is too long", nil) end

	if not addTagToEntity(this, tag) then
		return self:throw("Entity has too many tags", nil)
	end
end

__e2setcost(10)
e2function void array:addTag(string tag)
	if #tag > cv_max_tag_length:GetInt() then return self:throw("Tag is too long", nil) end

	for _, ent in pairs(this) do
		if not IsValid(ent) then return self:throw("Invalid entity", nil) end
		if not isOwner(self, ent) then return self:throw("You do not own this entity", nil) end
	end

	for _, ent in pairs(this) do
		if not addTagToEntity(ent, tag) then
			return self:throw("Entity has too many tags", nil)
		end
	end
end

__e2setcost(5)
e2function void entity:removeTag(string tag)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this) then return self:throw("You do not own this entity", nil) end

	local tags = getEntityMod(this, "expession2_tag")
	if not tags then return end

	setEntityMod(this, "expession2_tag", removeValueFromList(tags, tag))
end

__e2setcost(10)
e2function void array:removeTag(string tag)
	for _, ent in pairs(this) do
		if not IsValid(ent) then return self:throw("Invalid entity", nil) end
		if not isOwner(self, ent) then return self:throw("You do not own this entity", nil) end
	end

	for _, ent in pairs(this) do
		local tags = getEntityMod(ent, "expession2_tag")
		if not tags then continue end

		setEntityMod(ent, "expession2_tag", removeValueFromList(tags, tag))
	end
end

__e2setcost(5)
e2function array entity:getTags()
	if not IsValid(this) then return self:throw("Invalid entity", nil) end

	return copyDenseArray(getEntityMod(this, "expession2_tag"))
end

e2function number entity:hasTag(string tag)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end

	local tags = getEntityMod(this, "expession2_tag")
	if not tags then return 0 end

	return table.HasValue(tags, tag) and 1 or 0
end

__e2setcost(10)
e2function array array:haveTag(string tag)
	local filteredEntities = {}

	for _, ent in pairs(this) do
		if not IsValid(ent) then continue end

		local tags = getEntityMod(ent, "expession2_tag")
		if not tags then continue end

		if table.HasValue(tags, tag) then
			table.insert(filteredEntities, ent)
		end
	end

	return filteredEntities
end

__e2setcost(20)
e2function array getEntitiesByTag(string tag)
	local entities = {}

	for _, ent in ipairs(ents.GetAll()) do
		if not IsValid(ent) then continue end

		local tags = getEntityMod(ent, "expession2_tag")
		if not tags then continue end

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
	if #key > cv_max_key_length:GetInt() then return self:throw("Key is too long", nil) end
	if #value > cv_max_value_length:GetInt() then return self:throw("Value is too long", nil) end

	local keyValues = getEntityMod(this, "expession2_keyvalues") or {}
	if keyValues[key] == nil then
		local count = 0
		for _ in pairs(keyValues) do
			count = count + 1
		end
		if count >= cv_max_keys:GetInt() then return self:throw("Entity has too many key-values", nil) end
	end

	keyValues[key] = value
	setEntityMod(this, "expession2_keyvalues", keyValues)
end

__e2setcost(10)
e2function void array:setKeyValue(string key, string value)
	if #key > cv_max_key_length:GetInt() then return self:throw("Key is too long", nil) end
	if #value > cv_max_value_length:GetInt() then return self:throw("Value is too long", nil) end

	for _, ent in pairs(this) do
		if not IsValid(ent) then return self:throw("Invalid entity", nil) end
		if not isOwner(self, ent) then return self:throw("You do not own this entity", nil) end
	end

	for _, ent in pairs(this) do
		local keyValues = getEntityMod(ent, "expession2_keyvalues") or {}
		if keyValues[key] == nil then
			local count = 0
			for _ in pairs(keyValues) do
				count = count + 1
			end
			if count >= cv_max_keys:GetInt() then return self:throw("Entity has too many key-values", nil) end
		end

		keyValues[key] = value
		setEntityMod(ent, "expession2_keyvalues", keyValues)
	end
end

__e2setcost(5)
e2function void entity:removeKeyValue(string key)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this) then return self:throw("You do not own this entity", nil) end

	local keyValues = getEntityMod(this, "expession2_keyvalues")
	if not keyValues then return end

	keyValues[key] = nil
	setEntityMod(this, "expession2_keyvalues", keyValues)
end

__e2setcost(10)
e2function void array:removeKeyValue(string key)
	for _, ent in pairs(this) do
		if not IsValid(ent) then return self:throw("Invalid entity", nil) end
		if not isOwner(self, ent) then return self:throw("You do not own this entity", nil) end
	end

	for _, ent in pairs(this) do
		local keyValues = getEntityMod(ent, "expession2_keyvalues")
		if not keyValues then continue end

		keyValues[key] = nil
		setEntityMod(ent, "expession2_keyvalues", keyValues)
	end
end

__e2setcost(5)
e2function string entity:getKeyValue(string key)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this) then return self:throw("You do not own this entity", nil) end

	local keyValues = getEntityMod(this, "expession2_keyvalues")
	if not keyValues then return "" end

	return keyValues[key] or ""
end

local DEFAULT_TABLE = {n={},ntypes={},s={},stypes={},size=0}

__e2setcost(8)
e2function table entity:getKeyValues()
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this) then return self:throw("You do not own this entity", nil) end

	local keyValues = getEntityMod(this, "expession2_keyvalues")
	if not keyValues then return table.Copy(DEFAULT_TABLE) end

	local ret = table.Copy(DEFAULT_TABLE)
	local size = 0
	for k, v in pairs(keyValues) do
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
	local entities = {}

	for _, ent in ipairs(ents.GetAll()) do
		if not IsValid(ent) then continue end

		local keyValues = getEntityMod(ent, "expession2_keyvalues")
		if not keyValues then continue end

		if keyValues[key] and keyValues[key] == value then
			table.insert(entities, ent)
		end
	end

	return entities
end

__e2setcost(10)
e2function array array:haveKeyValue(string key, string value)
	local filteredEntities = {}

	for _, ent in pairs(this) do
		if not IsValid(ent) then continue end

		local keyValues = getEntityMod(ent, "expession2_keyvalues")
		if not keyValues then continue end

		if keyValues[key] and keyValues[key] == value then
			table.insert(filteredEntities, ent)
		end
	end

	return filteredEntities
end

--[[---------------------------------------------------------
    Halo
-----------------------------------------------------------]]

util.AddNetworkString("wire_expression2_entextracore_halo_sync")
util.AddNetworkString("wire_expression2_entextracore_halo_update")
util.AddNetworkString("wire_expression2_entextracore_halo_remove")
util.AddNetworkString("wire_expression2_entextracore_sync_request")
util.AddNetworkString("wire_expression2_entextracore_worldtip_sync")
util.AddNetworkString("wire_expression2_entextracore_worldtip_update")

local function haloColor(data)
	if not data then return Color(255, 255, 255) end
	if IsColor(data.Color) then return data.Color end
	if istable(data.Color) then
		return Color(data.Color.r or data.Color[1] or 255, data.Color.g or data.Color[2] or 255, data.Color.b or data.Color[3] or 255, data.Color.a or data.Color[4] or 255)
	end
	if data.r then return Color(data.r, data.g, data.b, data.a or 255) end
	return Color(255, 255, 255)
end

local function writeHalo(ent, data)
	net.WriteEntity(ent)
	net.WriteColor(haloColor(data))
	net.WriteFloat(data.BlurX or 5)
	net.WriteFloat(data.BlurY or 5)
	net.WriteBool(data.Additive and true or false)
	net.WriteBool(data.IgnoreZ and true or false)
end

local function UpdateHalo(ent)
	local data = getEntityMod(ent, "expession2_halo")
	if not data then return end

	net.Start("wire_expression2_entextracore_halo_update")
		writeHalo(ent, data)
	net.Broadcast()
end

local function SetHalo(ent, color, blurX, blurY, add, ignore)
	local data = {
		Color = {r = color.r, g = color.g, b = color.b, a = color.a or 255},
		BlurX = math.Clamp(blurX, 0, cv_max_halo_blur:GetInt()),
		BlurY = math.Clamp(blurY, 0, cv_max_halo_blur:GetInt()),
		Additive = add and true or false,
		IgnoreZ = ignore and true or false
	}

	setEntityMod(ent, "expession2_halo", data)
	UpdateHalo(ent)
end

local function SyncHalos(ply)
	local list = {}

	for _, ent in ipairs(ents.GetAll()) do
		if IsValid(ent) and getEntityMod(ent, "expession2_halo") then
			list[#list + 1] = ent
		end
	end

	net.Start("wire_expression2_entextracore_halo_sync")
		net.WriteUInt(#list, 16)

		for _, ent in ipairs(list) do
			writeHalo(ent, getEntityMod(ent, "expession2_halo"))
		end
	net.Send(ply)
end

local function getWorldTipText(ent)
	local mod = getEntityMod(ent, "expession2_worldtip")
	return isstring(mod) and mod or ""
end

local function UpdateWorldTip(ent)
	net.Start("wire_expression2_entextracore_worldtip_update")
		net.WriteEntity(ent)
		net.WriteString(getWorldTipText(ent))
	net.Broadcast()
end

local function SyncWorldTips(ply)
	local list = {}

	for _, ent in ipairs(ents.GetAll()) do
		if IsValid(ent) and getWorldTipText(ent) ~= "" then
			list[#list + 1] = ent
		end
	end

	net.Start("wire_expression2_entextracore_worldtip_sync")
		net.WriteUInt(#list, 16)

		for _, ent in ipairs(list) do
			net.WriteEntity(ent)
			net.WriteString(getWorldTipText(ent))
		end
	net.Send(ply)
end

local last_sync_request = {}

net.Receive("wire_expression2_entextracore_sync_request", function(_, ply)
	if not IsValid(ply) then return end

	local now = CurTime()
	if last_sync_request[ply] and now - last_sync_request[ply] < 5 then return end
	last_sync_request[ply] = now

	SyncHalos(ply)
	SyncWorldTips(ply)
end)

hook.Add("PlayerDisconnected", "wire_expression2_entextracore_sync_request", function(ply)
	last_sync_request[ply] = nil
end)

hook.Add("PlayerInitialSpawn", "wire_expression2_entextracore_halo_sync", function(ply)
	timer.Simple(1, function()
		if not IsValid(ply) then return end
		SyncHalos(ply)
		SyncWorldTips(ply)
	end)
end)

hook.Add("OnEntityCreated", "wire_expression2_entextracore_halo_update", function(ent)
	timer.Simple(0, function()
		if not IsValid(ent) then return end

		if getEntityMod(ent, "expession2_halo") then
			UpdateHalo(ent)
		end
	end)
end)

local function applyHalo(ent, color, blurX, blurY, add, ignore)
	SetHalo(ent, Color(color[1], color[2], color[3]), blurX, blurY, add, ignore)
end

__e2setcost(10)
e2function void entity:setHalo(vector color, number blurX, number blurY, add, ignore)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end

	applyHalo(this, color, blurX, blurY, add ~= 0, ignore ~= 0)
end

e2function void entity:setHalo(vector color, number blurX, number blurY, add)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end

	applyHalo(this, color, blurX, blurY, add ~= 0, false)
end

e2function void entity:setHalo(vector color, number blurX, number blurY)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end

	applyHalo(this, color, blurX, blurY, true, false)
end

e2function void entity:setHalo(vector color)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end

	applyHalo(this, color, 5, 5, true, false)
end

e2function void entity:removeHalo()
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end
	if not getEntityMod(this, "expession2_halo") then return end

	if this.EntityMods then
		this.EntityMods.expession2_halo = nil
	end
	if duplicator and duplicator.ClearEntityModifier then
		duplicator.ClearEntityModifier(this, "expession2_halo")
	end

	net.Start("wire_expression2_entextracore_halo_remove")
		net.WriteEntity(this)
	net.Broadcast()
end

--[[---------------------------------------------------------
    WorldTip
-----------------------------------------------------------]]

__e2setcost(10)
e2function void entity:setWorldTip(string text)
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end
	if #text == 0 then return end
	local maxLen = cv_max_worldtip_length:GetInt()
	if #text > maxLen then
		text = string.sub(text, 1, maxLen)
	end

	setEntityMod(this, "expession2_worldtip", text)
	UpdateWorldTip(this)
end

e2function void entity:removeWorldTip()
	if not IsValid(this) then return self:throw("Invalid entity", nil) end
	if not isOwner(self, this, true) then return self:throw("You do not own this entity", nil) end
	if getWorldTipText(this) == "" then return end

	if this.EntityMods then
		this.EntityMods.expession2_worldtip = nil
	end
	if duplicator and duplicator.ClearEntityModifier then
		duplicator.ClearEntityModifier(this, "expession2_worldtip")
	end

	UpdateWorldTip(this)
end

hook.Add("OnEntityCreated", "wire_expression2_entextracore_worldtip_update", function(ent)
	timer.Simple(0, function()
		if not IsValid(ent) then return end

		if getWorldTipText(ent) ~= "" then
			UpdateWorldTip(ent)
		end
	end)
end)

--[[---------------------------------------------------------
    Duplicator
-----------------------------------------------------------]]

local function registerMod(name, fn)
	if not duplicator or not duplicator.RegisterEntityModifier then return end
	duplicator.RegisterEntityModifier(name, fn)
end

registerMod("expession2_tag", function(_, ent, data)
	setEntityMod(ent, "expession2_tag", data)
end)

registerMod("expession2_keyvalues", function(_, ent, data)
	setEntityMod(ent, "expession2_keyvalues", data)
end)

registerMod("expession2_halo", function(_, ent, data)
	setEntityMod(ent, "expession2_halo", data)
	if IsValid(ent) then UpdateHalo(ent) end
end)

registerMod("expession2_worldtip", function(_, ent, data)
	if istable(data) then data = data.text or "" end
	setEntityMod(ent, "expession2_worldtip", data)
	if IsValid(ent) then UpdateWorldTip(ent) end
end)
