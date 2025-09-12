if not lib then return end

local Logger = require 'modules.logger.server'
local Inventory = require 'modules.inventory.server'

-- Hook regisztrálása az item átadásokhoz
exports.ox_inventory:registerHook('giveItem', function(payload)
    if payload.source and payload.target and payload.item and payload.count then
        Logger.logGive(payload.source, payload.target, payload.item, payload.count)
    end
end, {
    print = false
})

-- Hook regisztrálása a kraftolásokhoz
exports.ox_inventory:registerHook('craftItem', function(payload)
    if payload.source and payload.recipe and payload.benchId then
        local item = {
            name = payload.recipe.name,
            metadata = payload.recipe.metadata or {}
        }
        local count = payload.recipe.count or 1
        Logger.logCrafting(payload.source, payload.benchId, payload.recipe, item, count)
    end
end, {
    print = false
})

-- Hook regisztrálása a bolt vásárlásokhoz
exports.ox_inventory:registerHook('buyItem', function(payload)
    if payload.source and payload.shopType and payload.itemName and payload.count then
        local item = {
            name = payload.itemName,
            metadata = payload.metadata or {}
        }
        Logger.logShop(payload.source, payload.shopType, item, payload.count, payload.totalPrice, payload.currency)
    end
end, {
    print = false
})

-- Hook regisztrálása az inventory mozgatásokhoz
exports.ox_inventory:registerHook('swapItems', function(payload)
    if not payload.source or not payload.fromInventory or not payload.toInventory then return end
    
    local fromInv = Inventory(payload.fromInventory)
    local toInv = Inventory(payload.toInventory)
    
    if not fromInv or not toInv then return end
    
    -- Csak akkor logoljuk, ha nem player -> player mozgatás (kivéve átadás)
    if fromInv.type == 'player' and toInv.type == 'player' then return end
    
    local item = payload.fromSlot or payload.item
    local count = payload.count or 1
    
    if not item then return end
    
    -- Meghatározzuk a log típusát
    if toInv.type == 'trunk' or toInv.type == 'glovebox' or fromInv.type == 'trunk' or fromInv.type == 'glovebox' then
        local vehicleType = toInv.type == 'trunk' and 'trunk' or toInv.type == 'glovebox' and 'glovebox' or 
                           fromInv.type == 'trunk' and 'trunk' or 'glovebox'
        local action = fromInv.type == 'player' and 'add' or 'remove'
        local plate = toInv.id and toInv.id:match('trunk(.+)') or toInv.id and toInv.id:match('glove(.+)') or
                     fromInv.id and fromInv.id:match('trunk(.+)') or fromInv.id and fromInv.id:match('glove(.+)')
        
        Logger.logVehicle(payload.source, action, vehicleType, plate, item, count)
    elseif toInv.type == 'policeevidence' or fromInv.type == 'policeevidence' then
        local action = fromInv.type == 'player' and 'add' or 'remove'
        local evidenceId = toInv.id and toInv.id:match('evidence%-(.+)') or fromInv.id and fromInv.id:match('evidence%-(.+)')
        
        Logger.logEvidence(payload.source, action, item, count, evidenceId)
    elseif toInv.type == 'stash' or fromInv.type == 'stash' then
        local action = fromInv.type == 'player' and 'add' or 'remove'
        local stashName = toInv.type == 'stash' and toInv.id or fromInv.id
        local stashLabel = toInv.type == 'stash' and toInv.label or fromInv.label
        
        Logger.logStash(payload.source, action, stashName, stashLabel, item, count)
    else
        -- Általános inventory mozgatás log
        Logger.logInventoryMove(payload.source, fromInv, toInv, item, count, 'move')
    end
end, {
    print = false
})

-- Hook regisztrálása az item használatokhoz (opcionális)
exports.ox_inventory:registerHook('usingItem', function(payload)
    if payload.source and payload.item then
        Logger.logItemUse(payload.source, payload.item, payload.item.slot)
    end
end, {
    print = false
})

print('^2[OX_INVENTORY_LOGGER] Discord webhook hooks sikeresen regisztrálva!^0')