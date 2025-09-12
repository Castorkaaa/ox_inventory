Config = {}

-- Alapértelmezett webhook URL-ek
-- Ezeket felül lehet írni a server.cfg-ben convars segítségével
Config.Webhooks = {
    -- Átadás webhook
    give = GetConvar('inventory_logger:webhook:give', ''),
    
    -- Kraftolás webhook  
    crafting = GetConvar('inventory_logger:webhook:crafting', ''),
    
    -- Bizonyítékraktár webhook
    evidence = GetConvar('inventory_logger:webhook:evidence', ''),
    
    -- Bolt webhook
    shop = GetConvar('inventory_logger:webhook:shop', ''),
    
    -- Jármű (csomagtartó/kesztyűtartó) webhook
    vehicle = GetConvar('inventory_logger:webhook:vehicle', ''),
    
    -- Alapértelmezett stash webhook (ha nincs egyedi beállítva)
    default_stash = GetConvar('inventory_logger:webhook:stash', ''),
    
    -- Item használat webhook (opcionális)
    use = GetConvar('inventory_logger:webhook:use', ''),
}

-- Logolási beállítások
Config.Settings = {
    -- Logoljuk-e az item használatokat
    logItemUse = GetConvarInt('inventory_logger:log_item_use', 0) == 1,
    
    -- Logoljuk-e a player -> player mozgatásokat (átadásokon kívül)
    logPlayerToPlayer = GetConvarInt('inventory_logger:log_player_to_player', 0) == 1,
    
    -- Minimális item érték logoláshoz (0 = minden)
    minItemValue = GetConvarInt('inventory_logger:min_item_value', 0),
    
    -- Logoljuk-e a metadata változásokat
    logMetadataChanges = GetConvarInt('inventory_logger:log_metadata_changes', 1) == 1,
    
    -- Webhook timeout (ms)
    webhookTimeout = GetConvarInt('inventory_logger:webhook_timeout', 5000),
    
    -- Debug mód
    debug = GetConvarInt('inventory_logger:debug', 0) == 1,
}

-- Kizárt itemek listája (ezeket nem logoljuk)
Config.ExcludedItems = {
    -- 'water',
    -- 'bread',
}

-- Kizárt inventory típusok
Config.ExcludedInventoryTypes = {
    -- 'drop',
}

-- Discord embed színek
Config.Colors = {
    give = 3447003,      -- Kék
    crafting = 15844367, -- Arany
    evidence = 15158332, -- Piros
    shop = 3066993,      -- Zöld
    vehicle = 10181046,  -- Lila
    stash = 15105570,    -- Narancs
    remove = 15158332,   -- Piros
    add = 3066993,       -- Zöld
    use = 5793266,       -- Szürke
}

-- Stash-specifikus webhookok (dinamikusan töltődik be)
Config.StashWebhooks = {}