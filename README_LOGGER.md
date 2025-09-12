# OX Inventory Discord Logger

Ez a script egy átfogó logging rendszert biztosít az ox_inventory-hoz Discord webhookok segítségével.

## Telepítés

1. A script fájlok már hozzá vannak adva az ox_inventory-hoz
2. Konfiguráld a webhook URL-eket a `server.cfg`-ben vagy közvetlenül a stash konfigurációban

## Konfiguráció

### Server.cfg beállítások

```cfg
# Alapértelmezett webhook URL-ek
set inventory:webhook:give "https://discord.com/api/webhooks/YOUR_GIVE_WEBHOOK"
set inventory:webhook:crafting "https://discord.com/api/webhooks/YOUR_CRAFTING_WEBHOOK"
set inventory:webhook:evidence "https://discord.com/api/webhooks/YOUR_EVIDENCE_WEBHOOK"
set inventory:webhook:shop "https://discord.com/api/webhooks/YOUR_SHOP_WEBHOOK"
set inventory:webhook:vehicle "https://discord.com/api/webhooks/YOUR_VEHICLE_WEBHOOK"
set inventory:webhook:stash "https://discord.com/api/webhooks/YOUR_DEFAULT_STASH_WEBHOOK"

# Opcionális: Item használat logolása
set inventory:webhook:use "https://discord.com/api/webhooks/YOUR_USE_WEBHOOK"
```

### Stash-specifikus webhookok

A `data/stashes.lua` fájlban minden stash-hez külön webhook URL-t adhatsz meg:

```lua
{
    coords = vec3(301.3, -600.23, 43.28),
    target = {
        loc = vec3(301.82, -600.99, 43.29),
        length = 0.6,
        width = 1.8,
        heading = 340,
        minZ = 43.34,
        maxZ = 44.74,
        label = 'Open stash'
    },
    name = 'gangstash',
    label = 'Gang Stash',
    owner = false,
    slots = 70,
    weight = 70000,
    groups = {['gangsters'] = 0},
    webhook = 'https://discord.com/api/webhooks/YOUR_GANG_STASH_WEBHOOK'
},
```

## Funkciók

### Logolt események:

1. **📤 Item Átadás** - Játékosok közötti item átadások
2. **🔨 Kraftolás** - Minden kraftolt item részletes információkkal
3. **🚔 Bizonyítékraktár** - Rendőrségi bizonyítékraktár műveletek
4. **🛒 Bolt Vásárlás** - Minden bolt vásárlás ár információkkal
5. **🚗 Jármű Tároló** - Csomagtartó és kesztyűtartó műveletek
6. **📦 Tároló (Stash)** - Minden stash művelet, egyedi webhookokkal
7. **🎯 Item Használat** - Opcionális item használat logolás

### Minden log tartalmazza:

- Játékos neve és azonosítói
- Item részletes információi (név, mennyiség, súly, metadata)
- Időbélyeg
- Kontextus-specifikus információk (bolt név, stash név, stb.)
- Színkódolt embedek a könnyebb olvashatóságért

## Exportok

A script exportokat biztosít más scriptek számára:

```lua
-- Átadás logolása
exports.ox_inventory:logGive(source, target, item, count)

-- Kraftolás logolása  
exports.ox_inventory:logCrafting(source, benchId, recipe, item, count)

-- Bizonyítékraktár logolása
exports.ox_inventory:logEvidence(source, action, item, count, evidenceId)

-- Bolt logolása
exports.ox_inventory:logShop(source, shopType, item, count, price, currency)

-- Jármű logolása
exports.ox_inventory:logVehicle(source, action, vehicleType, plate, item, count)

-- Stash logolása
exports.ox_inventory:logStash(source, action, stashName, stashLabel, item, count)

-- Stash webhookok frissítése
exports.ox_inventory:updateStashWebhooks()
```

## Hibaelhárítás

Ha a webhookok nem működnek:

1. Ellenőrizd, hogy a webhook URL-ek helyesek-e
2. Győződj meg róla, hogy a Discord webhook aktív
3. Nézd meg a server konzolt hibaüzenetekért
4. Ellenőrizd a server.cfg beállításokat

## Testreszabás

A `modules/logger/config.lua` fájlban további beállításokat találsz a logolás testreszabásához.