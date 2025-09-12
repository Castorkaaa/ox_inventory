# OX Inventory Discord Logger

Ez egy önálló FiveM script, ami részletes Discord webhook logolást biztosít az ox_inventory rendszerhez.

## 🚀 Telepítés

1. Töltsd le vagy másold a script fájlokat a `resources/ox_inventory_logger` mappába
2. Add hozzá a `server.cfg`-hez: `ensure ox_inventory_logger`
3. Konfiguráld a webhook URL-eket (lásd alább)
4. Indítsd újra a servert

## ⚙️ Konfiguráció

### Server.cfg beállítások

```cfg
# Alapértelmezett webhook URL-ek
set inventory_logger:webhook:give "https://discord.com/api/webhooks/YOUR_GIVE_WEBHOOK"
set inventory_logger:webhook:crafting "https://discord.com/api/webhooks/YOUR_CRAFTING_WEBHOOK"
set inventory_logger:webhook:evidence "https://discord.com/api/webhooks/YOUR_EVIDENCE_WEBHOOK"
set inventory_logger:webhook:shop "https://discord.com/api/webhooks/YOUR_SHOP_WEBHOOK"
set inventory_logger:webhook:vehicle "https://discord.com/api/webhooks/YOUR_VEHICLE_WEBHOOK"
set inventory_logger:webhook:stash "https://discord.com/api/webhooks/YOUR_DEFAULT_STASH_WEBHOOK"

# Opcionális beállítások
set inventory_logger:webhook:use "https://discord.com/api/webhooks/YOUR_USE_WEBHOOK"
set inventory_logger:log_item_use 0
set inventory_logger:debug 0
```

### Stash-specifikus webhookok

Az ox_inventory `data/stashes.lua` fájljában minden stash-hez külön webhook URL-t adhatsz meg:

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
    webhook = 'https://discord.com/api/webhooks/YOUR_GANG_SPECIFIC_WEBHOOK'
},
```

## 📋 Logolt Események

### 📤 Item Átadás
- Játékos neve és azonosítói (átadó és átvevő)
- Item részletek (név, mennyiség, súly, metadata)
- Időbélyeg

### 🔨 Kraftolás
- Játékos információk
- Munkaszék azonosító
- Elkészített item részletek
- Felhasznált alapanyagok listája

### 🚔 Bizonyítékraktár
- Rendőr információk
- Bizonyítékraktár azonosító
- Item részletek
- Művelet típusa (hozzáadás/eltávolítás)

### 🛒 Bolt Vásárlás
- Vásárló információk
- Bolt típusa
- Vásárolt item részletek
- Ár és valuta

### 🚗 Jármű Tároló
- Játékos információk
- Jármű rendszám
- Tároló típusa (csomagtartó/kesztyűtartó)
- Item részletek
- Művelet típusa

### 📦 Stash/Tároló
- Játékos információk
- Stash név és címke
- Item részletek
- Művelet típusa
- **Egyedi webhook URL minden stash-hez!**

### 🎯 Item Használat (Opcionális)
- Játékos információk
- Használt item részletek
- Slot információ

## 🛠️ Parancsok

### Console parancsok:
- `reloadstashwebhooks` - Stash webhookok újratöltése
- `testlogger [típus]` - Test webhook küldése (give/shop/stash)

## 🔧 Exportok

Más scriptek is használhatják a logger funkciókat:

```lua
-- Átadás logolása
exports.ox_inventory_logger:logGive(source, target, item, count)

-- Kraftolás logolása  
exports.ox_inventory_logger:logCrafting(source, benchId, recipe, item, count)

-- Bizonyítékraktár logolása
exports.ox_inventory_logger:logEvidence(source, action, item, count, evidenceId)

-- Bolt logolása
exports.ox_inventory_logger:logShop(source, shopType, item, count, price, currency)

-- Jármű logolása
exports.ox_inventory_logger:logVehicle(source, action, vehicleType, plate, item, count)

-- Stash logolása
exports.ox_inventory_logger:logStash(source, action, stashName, stashLabel, item, count)

-- Stash webhookok újratöltése
exports.ox_inventory_logger:loadStashWebhooks()
```

## 🎨 Testreszabás

A `config.lua` fájlban módosíthatod:
- Webhook URL-eket
- Színeket
- Logolási beállításokat
- Kizárt itemeket
- Debug módot

## 🐛 Hibaelhárítás

1. **Webhookok nem működnek:**
   - Ellenőrizd a webhook URL-eket
   - Kapcsold be a debug módot: `set inventory_logger:debug 1`
   - Nézd a server konzolt

2. **Hookök nem regisztrálódnak:**
   - Győződj meg róla, hogy az ox_inventory fut
   - Ellenőrizd az ox_inventory verzióját
   - Nézd a console üzeneteket

3. **Stash webhookok nem működnek:**
   - Futtasd a `reloadstashwebhooks` parancsot
   - Ellenőrizd a stash konfigurációt

## 📝 Changelog

### v1.0.0
- Kezdeti verzió
- Minden alapvető inventory művelet logolása
- Stash-specifikus webhookok támogatása
- Részletes Discord embedek
- Debug mód és hibaelhárítás

## 🤝 Támogatás

Ha problémád van a scripttel, ellenőrizd:
1. Az ox_inventory megfelelően fut-e
2. A webhook URL-ek helyesek-e
3. A debug mód mit ír ki
4. A server console hibaüzeneteit

## 📄 Licenc

Ez a script szabadon használható és módosítható.