-- OX Inventory Logger Konfiguráció
-- Ez a fájl tartalmazza a logger beállításait

local Config = {}

-- Alapértelmezett webhook URL-ek
-- Ezeket felül lehet írni a server.cfg-ben convars segítségével
Config.Webhooks = {
    -- Átadás webhook
    give = '',
    
    -- Kraftolás webhook  
    crafting = '',
    
    -- Bizonyítékraktár webhook
    evidence = '',
    
    -- Bolt webhook
    shop = '',
    
    -- Jármű (csomagtartó/kesztyűtartó) webhook
    vehicle = '',
    
    -- Alapértelmezett stash webhook (ha nincs egyedi beállítva)
    default_stash = '',
    
    -- Item használat webhook (opcionális)
    use = '',
}

-- Logolási beállítások
Config.Settings = {
    -- Logoljuk-e az item használatokat
    logItemUse = false,
    
    -- Logoljuk-e a player -> player mozgatásokat (átadásokon kívül)
    logPlayerToPlayer = false,
    
    -- Minimális item érték logoláshoz (0 = minden)
    minItemValue = 0,
    
    -- Logoljuk-e a metadata változásokat
    logMetadataChanges = true,
    
    -- Webhook timeout (ms)
    webhookTimeout = 5000,
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

return Config