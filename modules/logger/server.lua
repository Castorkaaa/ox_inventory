if not lib then return end

local Logger = {}
local Utils = require 'modules.utils.server'

-- Webhook URLs konfigurálása
local webhooks = {
    give = GetConvar('inventory:webhook:give', ''),
    crafting = GetConvar('inventory:webhook:crafting', ''),
    evidence = GetConvar('inventory:webhook:evidence', ''),
    shop = GetConvar('inventory:webhook:shop', ''),
    vehicle = GetConvar('inventory:webhook:vehicle', ''),
    default_stash = GetConvar('inventory:webhook:stash', ''),
}

-- Stash-specifikus webhookok betöltése
local stashWebhooks = {}
local stashes = lib.load('data.stashes') or {}

for i, stash in ipairs(stashes) do
    if stash.webhook then
        stashWebhooks[stash.name] = stash.webhook
    end
end

-- Discord embed színek
local colors = {
    give = 3447003,      -- Kék
    crafting = 15844367, -- Arany
    evidence = 15158332, -- Piros
    shop = 3066993,      -- Zöld
    vehicle = 10181046,  -- Lila
    stash = 15105570,    -- Narancs
    remove = 15158332,   -- Piros
    add = 3066993,       -- Zöld
}

-- Játékos információk lekérése
local function getPlayerInfo(source)
    local player = server.GetPlayerFromId and server.GetPlayerFromId(source)
    if not player then return 'Ismeretlen játékos', 'N/A' end
    
    local name = player.name or player.getName and player.getName() or GetPlayerName(source)
    local identifier = player.identifier or player.getIdentifier and player.getIdentifier() or 'N/A'
    
    return name, identifier
end

-- Item információk formázása
local function formatItemInfo(item, count)
    local itemData = require('modules.items.server')(item.name or item)
    local itemName = itemData and itemData.label or (item.name or item)
    local metadata = item.metadata and next(item.metadata) and json.encode(item.metadata, {indent = false}) or 'Nincs'
    
    return {
        name = itemName,
        count = count or item.count or 1,
        metadata = metadata,
        weight = item.weight or (itemData and itemData.weight or 0)
    }
end

-- Discord webhook küldése
local function sendWebhook(webhookUrl, embed)
    if not webhookUrl or webhookUrl == '' then return end
    
    local data = {
        username = 'OX Inventory Logger',
        embeds = { embed }
    }
    
    PerformHttpRequest(webhookUrl, function(statusCode, response, headers)
        if statusCode ~= 200 and statusCode ~= 204 then
            print('^1[OX_INVENTORY_LOGGER] Webhook hiba: ' .. statusCode .. '^0')
        end
    end, 'POST', json.encode(data), {
        ['Content-Type'] = 'application/json'
    })
end

-- Átadás log
function Logger.logGive(source, target, item, count)
    if not webhooks.give or webhooks.give == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local targetName, targetId = getPlayerInfo(target)
    local itemInfo = formatItemInfo(item, count)
    
    local embed = {
        title = '📤 Item Átadás',
        color = colors.give,
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
    
    sendWebhook(webhooks.give, embed)
end

-- Kraftolás log
function Logger.logCrafting(source, benchId, recipe, item, count)
    if not webhooks.crafting or webhooks.crafting == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    
    local ingredientsText = ''
    if recipe.ingredients then
        for ingredient, amount in pairs(recipe.ingredients) do
            local ingredientData = require('modules.items.server')(ingredient)
            local ingredientName = ingredientData and ingredientData.label or ingredient
            ingredientsText = ingredientsText .. string.format('• %s: %s\n', ingredientName, amount)
        end
    end
    
    local embed = {
        title = '🔨 Kraftolás',
        color = colors.crafting,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        fields = {
            {
                name = '👤 Játékos',
                value = string.format('**%s**\nID: %s\nIdentifier: %s', playerName, source, playerId),
                inline = true
            },
            {
                name = '🏭 Munkaszék',
                value = string.format('**%s**', benchId),
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
    
    sendWebhook(webhooks.crafting, embed)
end

-- Bizonyítékraktár log
function Logger.logEvidence(source, action, item, count, evidenceId)
    if not webhooks.evidence or webhooks.evidence == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    local actionText = action == 'add' and 'Hozzáadás' or 'Eltávolítás'
    local actionEmoji = action == 'add' and '📥' or '📤'
    
    local embed = {
        title = actionEmoji .. ' Bizonyítékraktár - ' .. actionText,
        color = action == 'add' and colors.add or colors.remove,
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
    
    sendWebhook(webhooks.evidence, embed)
end

-- Bolt log
function Logger.logShop(source, shopType, item, count, price, currency)
    if not webhooks.shop or webhooks.shop == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    local currencySymbol = currency == 'money' and '$' or currency
    
    local embed = {
        title = '🛒 Bolt Vásárlás',
        color = colors.shop,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        fields = {
            {
                name = '👤 Vásárló',
                value = string.format('**%s**\nID: %s\nIdentifier: %s', playerName, source, playerId),
                inline = true
            },
            {
                name = '🏪 Bolt',
                value = string.format('**%s**', shopType),
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
                value = string.format('**%s%s**', price, currencySymbol),
                inline = true
            }
        },
        footer = {
            text = 'OX Inventory Logger',
            icon_url = 'https://i.imgur.com/4M34hi2.png'
        }
    }
    
    sendWebhook(webhooks.shop, embed)
end

-- Jármű log (csomagtartó/kesztyűtartó)
function Logger.logVehicle(source, action, vehicleType, plate, item, count)
    if not webhooks.vehicle or webhooks.vehicle == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    local actionText = action == 'add' and 'Betett' or 'Kivett'
    local actionEmoji = action == 'add' and '📥' or '📤'
    local vehicleTypeText = vehicleType == 'trunk' and 'Csomagtartó' or 'Kesztyűtartó'
    
    local embed = {
        title = actionEmoji .. ' ' .. vehicleTypeText .. ' - ' .. actionText,
        color = action == 'add' and colors.add or colors.remove,
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
    
    sendWebhook(webhooks.vehicle, embed)
end

-- Stash log
function Logger.logStash(source, action, stashName, stashLabel, item, count)
    local webhookUrl = stashWebhooks[stashName] or webhooks.default_stash
    if not webhookUrl or webhookUrl == '' then return end
    
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    local actionText = action == 'add' and 'Betett' or 'Kivett'
    local actionEmoji = action == 'add' and '📥' or '📤'
    
    local embed = {
        title = actionEmoji .. ' Tároló - ' .. actionText,
        color = action == 'add' and colors.add or colors.remove,
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
    -- Ez opcionális, ha szeretnéd logolni az item használatokat is
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, 1)
    
    -- Csak akkor logoljuk, ha van webhook beállítva
    local useWebhook = GetConvar('inventory:webhook:use', '')
    if not useWebhook or useWebhook == '' then return end
    
    local embed = {
        title = '🎯 Item Használat',
        color = 5793266, -- Szürke
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
                    itemInfo.name, slot, itemInfo.metadata),
                inline = false
            }
        },
        footer = {
            text = 'OX Inventory Logger',
            icon_url = 'https://i.imgur.com/4M34hi2.png'
        }
    }
    
    sendWebhook(useWebhook, embed)
end

-- Inventory mozgás log (általános)
function Logger.logInventoryMove(source, fromInventory, toInventory, item, count, action)
    local playerName, playerId = getPlayerInfo(source)
    local itemInfo = formatItemInfo(item, count)
    
    -- Meghatározzuk a webhook URL-t a célhely alapján
    local webhookUrl = webhooks.default_stash
    local logTitle = '📦 Item Mozgatás'
    local logColor = colors.stash
    
    if toInventory.type == 'trunk' or toInventory.type == 'glovebox' then
        webhookUrl = webhooks.vehicle
        logTitle = '🚗 Jármű Tároló'
        logColor = colors.vehicle
    elseif toInventory.type == 'policeevidence' then
        webhookUrl = webhooks.evidence
        logTitle = '🚔 Bizonyítékraktár'
        logColor = colors.evidence
    elseif toInventory.type == 'stash' then
        webhookUrl = stashWebhooks[toInventory.id] or webhooks.default_stash
        logTitle = '📦 Tároló'
        logColor = colors.stash
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
                value = string.format('**%s** → **%s**', fromInventory.label or fromInventory.type, toInventory.label or toInventory.type),
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

-- Webhook URL frissítése stash-ekhez
function Logger.updateStashWebhooks()
    local newStashes = lib.load('data.stashes') or {}
    stashWebhooks = {}
    
    for i, stash in ipairs(newStashes) do
        if stash.webhook then
            stashWebhooks[stash.name] = stash.webhook
        end
    end
end

-- Exportok
exports('logGive', Logger.logGive)
exports('logCrafting', Logger.logCrafting)
exports('logEvidence', Logger.logEvidence)
exports('logShop', Logger.logShop)
exports('logVehicle', Logger.logVehicle)
exports('logStash', Logger.logStash)
exports('logItemUse', Logger.logItemUse)
exports('logInventoryMove', Logger.logInventoryMove)
exports('updateStashWebhooks', Logger.updateStashWebhooks)

return Logger