[comment]: <> (## For more information, go to the [GitHub Page][GitHub Page])
[comment]: <> (To convert this file in Steam format, use this website: https://steamdown.vercel.app/)

# EntextaCore

In this core, you can now detect a entity when it spawns or when it gets removed. It adds some useful functions too. And best of all, it adds a system of tag. So basically It allows you to set tags on entities. With it, you can recognize a group of entities without wire and entities marker. There tags are persisting after a duplication.


## Workshop Installation

The DamageCore is available on the Steam Workshop! Go to the [EntextraCore Workshop Page][EntextraCore Workshop Page] and press `Subscribe`. For can go to the [Expression 2 Core Collection][Expression 2 Core Collection] for more extensions.

## Manual Installation

Clone this repository into your `steamapps\common\GarrysMod\garrysmod\addons` folder using this command if you are using git:

    git clone https://github.com/sirpapate/entextracore.git

## Documentation

### Events

| Declaration                         | Replacing                          | Description                            |
|-------------------------------------|------------------------------------|----------------------------------------|
| event entitySpawn(Entity:entity)  | runOnEntitySpawn, entitySpawnClk   | Triggered when an entity is spawned.   |
| event entityRemove(Entity:entity) | runOnEntityRemove, entityRemoveClk | Triggered when an entity is removed.   |

### Tick Functions

| Function                                                                              | Return | Description                                                                                                                                       |
|---------------------------------------------------------------------------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| runOnEntitySpawn(number activate)                                                   | void   | If set to 1, E2 will run when an entity is spawned.                                                                                               |
| entitySpawnClk()                                                                    | entity | Returns the entity that was spawned.                                                                                                              |
| runOnEntityRemove(number activate)                                                  | void   | If set to 1, E2 will run when an entity is removed.                                                                                               |
| entityRemoveClk()                                                                   | entity | Returns the entity that was removed.                                                                                                              |

### Info

| Function                                                                              | Return | Description                                                                                                                                       |
|---------------------------------------------------------------------------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| entity:creationID()                                                                 | number | Returns the entity's creation ID.                                                                                                                 |
| entity:children()                                                                   | array  | Returns entity's creation ID. Unlike E:id(), it will always increase and old values won't be reused.                                              |

### Tags

Allowing E2s to tag entities. The tags can be used to identify the entity in other E2s.

| Function                                                                              | Return | Description                                                                                                                                       |
|---------------------------------------------------------------------------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| entity:addTag(Tag:string)                                                           | void   | Adds a tag to the entity. The tag can be used to identify the entity in other E2s.                                                                |
| array:addTag(Tag:string)                                                            | void   | Adds a tag to all entities in the array. The tag can be used to identify the entity in other E2s.                                                 |
| entity:removeTag(Tag:string)                                                        | void   | Removes a tag from the entity.                                                                                                                    |
| array:removeTag(Tag:string)                                                         | void   | Removes a tag from all entities in the array.                                                                                                     |
| entity:getTags()                                                                    | array  | Gets all tags of the entity.                                                                                                                      |
| entity:hasTag(Tag:string)                                                           | number | Returns 1 if the entity has the tag, 0 otherwise.                                                                                                 |
| array:haveTag(Tag:string)                                                           | array  | Returns an array of 1s and 0s. 1 if the entity has the tag, 0 otherwise.                                                                          |
| getEntitiesByTag(Tag:string)                                                        | array  | Returns an array of entities with the tag.                                                                                                        |

### Key-Value

Allowing E2s to store data on entities. The data is stored in a key-value pair. The key is a string and the value can only be a string.
The key-value pair can be used to store data on the entity and can be retrieved by other E2s.

| Function                                                                              | Return | Description                                                                                                                                       |
|---------------------------------------------------------------------------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| entity:setKeyValue(Key:string, Value:string)                                        | void   | Sets a key-value pair on the entity. The key-value pair can be used to store data on the entity and can be retrieved by other E2s.                |
| array:setKeyValue(Key:string, Value:string)                                         | void   | Sets a key-value pair on all entities in the array. The key-value pair can be used to store data on the entity and can be retrieved by other E2s. |
| entity:removeKeyValue(Key:string)                                                   | void   | Removes a key-value pair from the entity.                                                                                                         |
| array:removeKeyValue(Key:string)                                                    | void   | Removes a key-value pair from all entities in the array.                                                                                          |
| entity:getKeyValue(Key:string)                                                      | string | Gets the value of a key-value pair on the entity.                                                                                                 |
| entity:getKeyValues()                                                               | table  | Gets all key-value pairs on the entity.                                                                                                           |
| getEntitiesByKeyValue(Key:string, Value:string)                                     | array  | Gets all entities with the specified key-value pair.                                                                                              |
| array:haveKeyValue(Key:string, Value:string)                                        | array  | Returns an array of 1s and 0s. 1 if the entity has the key-value pair, 0 otherwise.                                                               |

### Halo

* "Color:vector" - The desired color of the halo. See Color.
* "BlurX:number" = "2" - The strength of the halo's blur on the x axis.
* "BlurY:number" = "2" - The strength of the halo's blur on the y axis.
* "Passes:number" = "1" - The number of times the halo should be drawn per frame. Increasing this may hinder player FPS.
* "Additive:number" = "1" - Sets the render mode of the halo to additive. (0 or 1)
* "IgnoreZ:number" = "0" - Renders the halo through anything when set to 1. (0 or 1)

| Function                                                                               | Return | Description                                                                                                                                       |
|----------------------------------------------------------------------------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| entity:setHalo(Color:vector, BlurX:number, BlurY:number, Add:number, IgnoreZ:number) | void   | Applies a halo glow effect to the entity.                                                                                                         |
| entity:setHalo(Color:vector, BlurX:number, BlurY:number, Add:number)                 | void   | Applies a halo glow effect to the entity.                                                                                                         |
| entity:setHalo(Color:vector, BlurX:number, BlurY:number)                             | void   | Applies a halo glow effect to the entity.                                                                                                         |
| entity:setHalo(Color:vector)                                                         | void   | Applies a halo glow effect to the entity.                                                                                                         |
| entity:removeHalo()                                                                  | void   | Removes the halo from the entity.                                                                                                                 |

### World Tip

| Function                                                                               | Return | Description                                                                                                                                       |
|----------------------------------------------------------------------------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| entity:setWorldTip(string text)                                                      | void   | Sets a world tip on the entity.                                                                                                                   |
| entity:removeWorldTip()                                                              | void   | Removes the world tip from the entity.                                                                                                            |



[EntextraCore Workshop Page]: <https://steamcommunity.com/sharedfiles/filedetails/?id=714598720>
[Expression 2 Core Collection]: <https://steamcommunity.com/workshop/filedetails/?id=726399057>
[GitHub Page]: <https://github.com/sirpapate/entextracore>