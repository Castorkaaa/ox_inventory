if not lib then return end

local Logger = require 'server.logger'

-- Várunk, hogy az ox_inventory betöltődjön
CreateThread(function()
    while GetResourceState('ox_inventory') ~= 'started' do
        Wait(1000)
    end
    
    Wait(2000) -- Extra várakozás a teljes inicializálásra
    
    -- Hook regisztrálása az item átadásokhoz
    local success1 = pcall(function()
        exports.ox_inventory:registerHook('giveItem', function(payload)
            if payload.source and payload.target and payload.item and payload.count then
                Logger.logGive(payload.source, payload.target, payload.item, payload.count)
            end
        end, {
            print = Config.Settings.debug
        })
    end)
    
    -- Hook regisztrálása a kraftolásokhoz
    local success2 = pcall(function()
        exports.ox_inventory:registerHook('craftItem', function(payload)
            if payload.source and payload.recipe and payload.benchId then
                local item = {
                    name = payload.recipe.name,
                    label = payload.recipe.label,
                    metadata = payload.recipe.metadata or {}
                }
                local count = payload.recipe.count or 1
                Logger.logCrafting(payload.source, payload.benchId, payload.recipe, item, count)
            end
        end, {
            print = Config.Settings.debug
        })
    end)
    
    -- Hook regisztrálása a bolt vásárlásokhoz
    local success3 = pcall(function()
        exports.ox_inventory:registerHook('buyItem', function(payload)
            if payload.source and payload.shopType and payload.itemName and payload.count then
                local item = {
                    name = payload.itemName,
                    label = payload.itemName,
                    metadata = payload.metadata or {}
                }
                Logger.logShop(payload.source, payload.shopType, item, payload.count, payload.totalPrice, payload.currency)
            end
        end, {
            print = Config.Settings.debug
        })
    end)
    
    -- Hook regisztrálása az inventory mozgatásokhoz
    local success4 = pcall(function()
        exports.ox_inventory:registerHook('swapItems', function(payload)
            if not payload.source or not payload.fromInventory or not payload.toInventory then return end
            
            -- Lekérjük az inventory adatokat
            local fromInv = {
                type = payload.fromType or 'unknown',
                id = payload.fromInventory,
                label = payload.fromInventory
            }
            
            local toInv = {
                type = payload.toType or 'unknown', 
                id = payload.toInventory,
                label = payload.toInventory
            }
            
            -- Csak akkor logoljuk, ha nem player -> player mozgatás (kivéve átadás)
            if fromInv.type == 'player' and toInv.type == 'player' then return end
            
            local item = payload.fromSlot or payload.item
            local count = payload.count or 1
            
            if not item then return end
            
            -- Meghatározzuk a log típusát és hívjuk a megfelelő függvényt
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
            print = Config.Settings.debug
        })
    end)
    
    -- Hook regisztrálása az item használatokhoz (opcionális)
    if Config.Settings.logItemUse then
        local success5 = pcall(function()
            exports.ox_inventory:registerHook('usingItem', function(payload)
                if payload.source and payload.item then
                    Logger.logItemUse(payload.source, payload.item, payload.item.slot)
                end
            end, {
                print = Config.Settings.debug
            })
        end)
        
        if success5 then
            print('^2[OX_INVENTORY_LOGGER] Item használat hook regisztrálva!^0')
        else
            print('^1[OX_INVENTORY_LOGGER] Item használat hook regisztrálása sikertelen!^0')
        end
    end
    
    -- Eredmények kiírása
    local successCount = 0
    if success1 then successCount = successCount + 1 end
    if success2 then successCount = successCount + 1 end
    if success3 then successCount = successCount + 1 end
    if success4 then successCount = successCount + 1 end
    
    print(string.format('^2[OX_INVENTORY_LOGGER] %d/4 hook sikeresen regisztrálva!^0', successCount))
    
    if successCount < 4 then
        print('^1[OX_INVENTORY_LOGGER] Néhány hook regisztrálása sikertelen! Ellenőrizd az ox_inventory verziót.^0')
    end
end)

-- Stash webhookok újratöltése parancs
RegisterCommand('reloadstashwebhooks', function(source)
    if source ~= 0 then return end -- Csak console-ról
    
    Logger.loadStashWebhooks()
    print('^2[OX_INVENTORY_LOGGER] Stash webhookok újratöltve!^0')
end, true)

-- Debug parancs
RegisterCommand('testlogger', function(source, args)
    if source ~= 0 then return end -- Csak console-ról
    
    local testType = args[1] or 'give'
    
    if testType == 'give' then
        Logger.logGive(1, 2, {name = 'water', label = 'Víz', weight = 100, metadata = {test = true}}, 5)
    elseif testType == 'shop' then
        Logger.logShop(1, 'General', {name = 'burger', label = 'Hamburger', weight = 200}, 2, 50, 'money')
    elseif testType == 'stash' then
        Logger.logStash(1, 'add', 'teststash', 'Test Stash', {name = 'lockpick', label = 'Lockpick', weight = 50}, 1)
    end
    
    print('^2[OX_INVENTORY_LOGGER] Test webhook elküldve: ' .. testType .. '^0')
end, true)