if not lib then return end

local Logger = require 'modules.logger.server'

-- Átadás event
RegisterNetEvent('ox_inventory:giveItem', function(target, item, count)
    local source = source
    if not target or not item or not count then return end
    
    Logger.logGive(source, target, item, count)
end)

-- Kraftolás event
RegisterNetEvent('ox_inventory:craftedItem', function(benchId, recipe, item, count)
    local source = source
    if not benchId or not recipe or not item then return end
    
    Logger.logCrafting(source, benchId, recipe, item, count or 1)
end)

-- Bizonyítékraktár event
RegisterNetEvent('ox_inventory:evidenceAction', function(action, item, count, evidenceId)
    local source = source
    if not action or not item then return end
    
    Logger.logEvidence(source, action, item, count or 1, evidenceId)
end)

-- Bolt vásárlás event
RegisterNetEvent('ox_inventory:shopPurchase', function(shopType, item, count, price, currency)
    local source = source
    if not shopType or not item or not count then return end
    
    Logger.logShop(source, shopType, item, count, price or 0, currency or 'money')
end)

-- Jármű tároló event
RegisterNetEvent('ox_inventory:vehicleStorage', function(action, vehicleType, plate, item, count)
    local source = source
    if not action or not vehicleType or not item then return end
    
    Logger.logVehicle(source, action, vehicleType, plate, item, count or 1)
end)

-- Stash event
RegisterNetEvent('ox_inventory:stashAction', function(action, stashName, stashLabel, item, count)
    local source = source
    if not action or not stashName or not item then return end
    
    Logger.logStash(source, action, stashName, stashLabel, item, count or 1)
end)

-- Item használat event
RegisterNetEvent('ox_inventory:itemUsed', function(item, slot)
    local source = source
    if not item then return end
    
    Logger.logItemUse(source, item, slot)
end)

print('^2[OX_INVENTORY_LOGGER] Discord webhook events sikeresen regisztrálva!^0')