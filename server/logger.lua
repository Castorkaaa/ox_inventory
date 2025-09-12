if not lib then return end

local Logger = {}

-- Játékos információk lekérése
local function getPlayerInfo(source)
    local player = exports.ox_inventory:GetPlayerFromId and exports.ox_inventory:GetPlayerFromId(source)
    
    if not player then
        -- Fallback más frameworkökre
        if GetResourceState('es_extended') == 'started' then
            player = exports.es_extended:getSharedObject().GetPlayerFromId(source)
        elseif GetResourceState('qbx_core') == 'started' then
            player = exports.qbx_core:GetPlayer(source)
        elseif GetResourceState('ox_core') == 'started' then
            player = exports.ox_core:GetPlayer(source)
        end
    end
    
    if not player then 
        return GetPlayerName(source) or 'Ismeretlen játékos', 'N/A' 
    end
    
    local name = player.name or player.getName and player.getName() or GetPlayerName(source)
    local identifier = player.identifier or player.citizenid or player.charid or 'N/A'
    
    return name, tostring(identifier)
end

-- Item információk formázása
local function formatItemInfo(item, count)
    local itemName = 'Ismeretlen Item'
    local metadata = 'Nincs'
    local weight = 0
    
    if type(item) == 'table' then
        itemName = item.label or item.name or 'Ismeretlen Item'
        count = count or item.count or 1
        weight = item.weight or 0
        
        if item.metadata and next(item.metadata) then
            metadata = json.encode(item.metadata, {indent = false})
        end
    else
        itemName = tostring(item)
        count = count or 1
    end
    
    return {
        name = itemName,
        count = count,
        metadata = metadata,
        weight = weight
    }
end

-- Discord webhook küldése
local function sendWebhook(webhookUrl, embed)
    if not webhookUrl or webhookUrl == '' then 
        if Config.Settings.debug then
            print('^3[OX_INVENTORY_LOGGER] Webhook URL nincs beállítva^0')
        end
        return 
    end
    
    local data = {
        username = 'OX Inventory Logger',
        embeds = { embed }
    }
    
    PerformHttpRequest(webhookUrl, function(statusCode, response, headers)
        if statusCode ~= 200 and statusCode ~= 204 then
            print('^1[OX_INVENTORY_LOGGER] Webhook hiba: ' .. statusCode .. '^0')
            if Config.Settings.debug then
                print('^1Response: ' .. tostring(response) .. '^0')
            end
        elseif Config.Settings.debug then
            print('^2[OX_INVENTORY_LOGGER] Webhook sikeresen elküldve: ' .. statusCode .. '^0')
        end
    end, 'POST', json.encode(data), {
        ['Content-Type'] = 'application/json'
    })
end

-- Átadás log
function Logger.logGive(source, target, item, count)
    if not Config.Webhooks.give or Config.Webhooks.give == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local targetName, targetId = getPlayerInfo(target)
    local itemInfo = formatItemInfo(item, count)
    
    local embed = {
        title = '📤 Item Átadás',
        color = Config.Colors.give,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        fields = {
            {
                name = '👤 Átadó',
                value = string.format('**%s**\nID: %s\nIdentifier: %s', playerName, source, playerId),
                inline = true
            },
            {
                name = '👥 Átvevő',
                value = string.format('**%s**\nID: %s\nIdentifier: %s', targetName, target, targetId),
                inline = true
            },
            {
                name = '📦 Item',
                value = string.format('**%s**\nMennyiség: %s\nSúly: %sg\nMetadata: %s', 
                    itemInfo.name, itemInfo.count, itemInfo.weight, itemInfo.metadata),
                inline = false
            }
        },
        footer = {
            text = 'OX Inventory Logger',
            icon_url = 'https://i.imgur.com/4M34hi2.png'
        }
    }
    
    sendWebhook(Config.Webhooks.give, embed)
end

-- Kraftolás log
function Logger.logCrafting(source, benchId, recipe, item, count)
    if not Config.Webhooks.crafting or Config.Webhooks.crafting == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    
    local ingredientsText = ''
    if recipe and recipe.ingredients then
        for ingredient, amount in pairs(recipe.ingredients) do
            ingredientsText = ingredientsText .. string.format('• %s: %s\n', ingredient, amount)
        end
    end
    
    local embed = {
        title = '🔨 Kraftolás',
        color = Config.Colors.crafting,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        fields = {
            {
                name = '👤 Játékos',
                value = string.format('**%s**\nID: %s\nIdentifier: %s', playerName, source, playerId),
                inline = true
            },
            {
                name = '🏭 Munkaszék',
                value = string.format('**%s**', tostring(benchId)),
                inline = true
            },
            {
                name = '📦 Elkészített Item',
                value = string.format('**%s**\nMennyiség: %s\nSúly: %sg', 
                    itemInfo.name, itemInfo.count, itemInfo.weight),
                inline = false
            },
            {
                name = '🧪 Felhasznált Alapanyagok',
                value = ingredientsText ~= '' and ingredientsText or 'Nincs adat',
                inline = false
            }
        },
        footer = {
            text = 'OX Inventory Logger',
            icon_url = 'https://i.imgur.com/4M34hi2.png'
        }
    }
    
    sendWebhook(Config.Webhooks.crafting, embed)
end

-- Bizonyítékraktár log
function Logger.logEvidence(source, action, item, count, evidenceId)
    if not Config.Webhooks.evidence or Config.Webhooks.evidence == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    local actionText = action == 'add' and 'Hozzáadás' or 'Eltávolítás'
    local actionEmoji = action == 'add' and '📥' or '📤'
    
    local embed = {
        title = actionEmoji .. ' Bizonyítékraktár - ' .. actionText,
        color = action == 'add' and Config.Colors.add or Config.Colors.remove,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        fields = {
            {
                name = '👮 Rendőr',
                value = string.format('**%s**\nID: %s\nIdentifier: %s', playerName, source, playerId),
                inline = true
            },
            {
                name = '🗃️ Bizonyítékraktár',
                value = string.format('**#%s**', evidenceId or 'N/A'),
                inline = true
            },
            {
                name = '📦 Item',
                value = string.format('**%s**\nMennyiség: %s\nSúly: %sg\nMetadata: %s', 
                    itemInfo.name, itemInfo.count, itemInfo.weight, itemInfo.metadata),
                inline = false
            }
        },
        footer = {
            text = 'OX Inventory Logger',
            icon_url = 'https://i.imgur.com/4M34hi2.png'
        }
    }
    
    sendWebhook(Config.Webhooks.evidence, embed)
end

-- Bolt log
function Logger.logShop(source, shopType, item, count, price, currency)
    if not Config.Webhooks.shop or Config.Webhooks.shop == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    local currencySymbol = currency == 'money' and '$' or currency
    
    local embed = {
        title = '🛒 Bolt Vásárlás',
        color = Config.Colors.shop,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        fields = {
            {
                name = '👤 Vásárló',
                value = string.format('**%s**\nID: %s\nIdentifier: %s', playerName, source, playerId),
                inline = true
            },
            {
                name = '🏪 Bolt',
                value = string.format('**%s**', tostring(shopType)),
                inline = true
            },
            {
                name = '📦 Vásárolt Item',
                value = string.format('**%s**\nMennyiség: %s\nSúly: %sg', 
                    itemInfo.name, itemInfo.count, itemInfo.weight),
                inline = false
            },
            {
                name = '💰 Ár',
                value = string.format('**%s%s**', price or 0, currencySymbol),
                inline = true
            }
        },
        footer = {
            text = 'OX Inventory Logger',
            icon_url = 'https://i.imgur.com/4M34hi2.png'
        }
    }
    
    sendWebhook(Config.Webhooks.shop, embed)
end

-- Jármű log (csomagtartó/kesztyűtartó)
function Logger.logVehicle(source, action, vehicleType, plate, item, count)
    if not Config.Webhooks.vehicle or Config.Webhooks.vehicle == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    local actionText = action == 'add' and 'Betett' or 'Kivett'
    local actionEmoji = action == 'add' and '📥' or '📤'
    local vehicleTypeText = vehicleType == 'trunk' and 'Csomagtartó' or 'Kesztyűtartó'
    
    local embed = {
        title = actionEmoji .. ' ' .. vehicleTypeText .. ' - ' .. actionText,
        color = action == 'add' and Config.Colors.add or Config.Colors.remove,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        fields = {
            {
                name = '👤 Játékos',
                value = string.format('**%s**\nID: %s\nIdentifier: %s', playerName, source, playerId),
                inline = true
            },
            {
                name = '🚗 Jármű',
                value = string.format('**%s**\nRendszám: %s', vehicleTypeText, plate or 'N/A'),
                inline = true
            },
            {
                name = '📦 Item',
                value = string.format('**%s**\nMennyiség: %s\nSúly: %sg\nMetadata: %s', 
                    itemInfo.name, itemInfo.count, itemInfo.weight, itemInfo.metadata),
                inline = false
            }
        },
        footer = {
            text = 'OX Inventory Logger',
            icon_url = 'https://i.imgur.com/4M34hi2.png'
        }
    }
    
    sendWebhook(Config.Webhooks.vehicle, embed)
end

-- Stash log
function Logger.logStash(source, action, stashName, stashLabel, item, count)
    local webhookUrl = Config.StashWebhooks[stashName] or Config.Webhooks.default_stash
    if not webhookUrl or webhookUrl == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    local actionText = action == 'add' and 'Betett' or 'Kivett'
    local actionEmoji = action == 'add' and '📥' or '📤'
    
    local embed = {
        title = actionEmoji .. ' Tároló - ' .. actionText,
        color = action == 'add' and Config.Colors.add or Config.Colors.remove,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        fields = {
            {
                name = '👤 Játékos',
                value = string.format('**%s**\nID: %s\nIdentifier: %s', playerName, source, playerId),
                inline = true
            },
            {
                name = '📦 Tároló',
                value = string.format('**%s**\nNév: %s', stashLabel or stashName, stashName),
                inline = true
            },
            {
                name = '📦 Item',
                value = string.format('**%s**\nMennyiség: %s\nSúly: %sg\nMetadata: %s', 
                    itemInfo.name, itemInfo.count, itemInfo.weight, itemInfo.metadata),
                inline = false
            }
        },
        footer = {
            text = 'OX Inventory Logger',
            icon_url = 'https://i.imgur.com/4M34hi2.png'
        }
    }
    
    sendWebhook(webhookUrl, embed)
end

-- Item használat log
function Logger.logItemUse(source, item, slot)
    if not Config.Settings.logItemUse or not Config.Webhooks.use or Config.Webhooks.use == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, 1)
    
    local embed = {
        title = '🎯 Item Használat',
        color = Config.Colors.use,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        fields = {
            {
                name = '👤 Játékos',
                value = string.format('**%s**\nID: %s\nIdentifier: %s', playerName, source, playerId),
                inline = true
            },
            {
                name = '📦 Használt Item',
                value = string.format('**%s**\nSlot: %s\nMetadata: %s', 
                    itemInfo.name, slot or 'N/A', itemInfo.metadata),
                inline = false
            }
        },
        footer = {
            text = 'OX Inventory Logger',
            icon_url = 'https://i.imgur.com/4M34hi2.png'
        }
    }
    
    sendWebhook(Config.Webhooks.use, embed)
end

-- Általános inventory mozgás log
function Logger.logInventoryMove(source, fromInventory, toInventory, item, count, action)
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    
    -- Meghatározzuk a webhook URL-t és log típust
    local webhookUrl = Config.Webhooks.default_stash
    local logTitle = '📦 Item Mozgatás'
    local logColor = Config.Colors.stash
    
    if toInventory.type == 'trunk' or toInventory.type == 'glovebox' or 
       fromInventory.type == 'trunk' or fromInventory.type == 'glovebox' then
        webhookUrl = Config.Webhooks.vehicle
        logTitle = '🚗 Jármű Tároló'
        logColor = Config.Colors.vehicle
    elseif toInventory.type == 'policeevidence' or fromInventory.type == 'policeevidence' then
        webhookUrl = Config.Webhooks.evidence
        logTitle = '🚔 Bizonyítékraktár'
        logColor = Config.Colors.evidence
    elseif toInventory.type == 'stash' or fromInventory.type == 'stash' then
        local stashName = toInventory.type == 'stash' and toInventory.id or fromInventory.id
        webhookUrl = Config.StashWebhooks[stashName] or Config.Webhooks.default_stash
        logTitle = '📦 Tároló'
        logColor = Config.Colors.stash
    end
    
    if not webhookUrl or webhookUrl == '' then return end
    
    local embed = {
        title = logTitle,
        color = logColor,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        fields = {
            {
                name = '👤 Játékos',
                value = string.format('**%s**\nID: %s\nIdentifier: %s', playerName, source, playerId),
                inline = true
            },
            {
                name = '📍 Mozgatás',
                value = string.format('**%s** → **%s**', 
                    fromInventory.label or fromInventory.type or 'Ismeretlen', 
                    toInventory.label or toInventory.type or 'Ismeretlen'),
                inline = true
            },
            {
                name = '📦 Item',
                value = string.format('**%s**\nMennyiség: %s\nSúly: %sg\nMetadata: %s', 
                    itemInfo.name, itemInfo.count, itemInfo.weight, itemInfo.metadata),
                inline = false
            }
        ],
        footer = {
            text = 'OX Inventory Logger',
            icon_url = 'https://i.imgur.com/4M34hi2.png'
        }
    }
    
    sendWebhook(webhookUrl, embed)
end

-- Stash webhookok betöltése
function Logger.loadStashWebhooks()
    Config.StashWebhooks = {}
    
    -- Próbáljuk betölteni a stash konfigurációt
    local success, stashes = pcall(function()
        return exports.ox_inventory and exports.ox_inventory:GetStashes() or {}
    end)
    
    if not success then
        if Config.Settings.debug then
            print('^3[OX_INVENTORY_LOGGER] Nem sikerült betölteni a stash konfigurációt^0')
        end
        return
    end
    
    for _, stash in pairs(stashes or {}) do
        if stash.webhook and stash.name then
            Config.StashWebhooks[stash.name] = stash.webhook
            if Config.Settings.debug then
                print(string.format('^2[OX_INVENTORY_LOGGER] Stash webhook betöltve: %s^0', stash.name))
            end
        end
    end
end

-- Inicializálás
CreateThread(function()
    Wait(2000) -- Várunk, hogy az ox_inventory betöltődjön
    Logger.loadStashWebhooks()
    print('^2[OX_INVENTORY_LOGGER] Logger modul betöltve!^0')
end)

-- Exportok
exports('logGive', Logger.logGive)
exports('logCrafting', Logger.logCrafting)
exports('logEvidence', Logger.logEvidence)
exports('logShop', Logger.logShop)
exports('logVehicle', Logger.logVehicle)
exports('logStash', Logger.logStash)
exports('logItemUse', Logger.logItemUse)
exports('logInventoryMove', Logger.logInventoryMove)
exports('loadStashWebhooks', Logger.loadStashWebhooks)

return Logger