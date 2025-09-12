# Telepítési Útmutató - OX Inventory Logger

## 1. Script Telepítése

1. **Mappák létrehozása:**
   ```
   resources/
   └── ox_inventory_logger/
       ├── fxmanifest.lua
       ├── config.lua
       ├── README.md
       ├── server/
       │   ├── logger.lua
       │   └── hooks.lua
       └── client/
           └── client.lua
   ```

2. **Server.cfg módosítása:**
   ```cfg
   ensure ox_inventory_logger
   ```

## 2. Webhook Beállítások

### Discord Webhook létrehozása:

1. Menj a Discord szerveredre
2. Válaszd ki a csatornát ahol a logokat szeretnéd
3. Jobb klikk → "Integrations" → "Webhooks" → "New Webhook"
4. Másold ki a webhook URL-t

### Server.cfg webhook konfigurálása:

```cfg
# === OX INVENTORY LOGGER WEBHOOKS ===

# Átadás logok
set inventory_logger:webhook:give "https://discord.com/api/webhooks/1234567890/abcdefghijklmnop"

# Kraftolás logok
set inventory_logger:webhook:crafting "https://discord.com/api/webhooks/1234567890/abcdefghijklmnop"

# Bizonyítékraktár logok
set inventory_logger:webhook:evidence "https://discord.com/api/webhooks/1234567890/abcdefghijklmnop"

# Bolt vásárlás logok
set inventory_logger:webhook:shop "https://discord.com/api/webhooks/1234567890/abcdefghijklmnop"

# Jármű tároló logok
set inventory_logger:webhook:vehicle "https://discord.com/api/webhooks/1234567890/abcdefghijklmnop"

# Alapértelmezett stash logok
set inventory_logger:webhook:stash "https://discord.com/api/webhooks/1234567890/abcdefghijklmnop"

# === OPCIONÁLIS BEÁLLÍTÁSOK ===

# Item használat logolása (0 = ki, 1 = be)
set inventory_logger:log_item_use 0

# Debug mód (0 = ki, 1 = be)
set inventory_logger:debug 0

# Minimális item érték logoláshoz
set inventory_logger:min_item_value 0
```

## 3. Stash-specifikus Webhookok

Az ox_inventory `data/stashes.lua` fájljában add hozzá a `webhook` mezőt:

```lua
return {
    {
        coords = vec3(452.3, -991.4, 30.7),
        target = {
            loc = vec3(451.25, -994.28, 30.69),
            length = 1.2,
            width = 5.6,
            heading = 0,
            minZ = 29.49,
            maxZ = 32.09,
            label = 'Open personal locker'
        },
        name = 'policelocker',
        label = 'Personal locker',
        owner = true,
        slots = 70,
        weight = 70000,
        groups = {['police'] = 0},
        webhook = 'https://discord.com/api/webhooks/POLICE_WEBHOOK_URL'
    },
    
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
        webhook = 'https://discord.com/api/webhooks/GANG_WEBHOOK_URL'
    },
}
```

## 4. Tesztelés

1. **Indítsd újra a servert**
2. **Ellenőrizd a console üzeneteket:**
   ```
   [OX_INVENTORY_LOGGER] Logger modul betöltve!
   [OX_INVENTORY_LOGGER] 4/4 hook sikeresen regisztrálva!
   ```

3. **Tesztelés console parancsokkal:**
   ```
   testlogger give
   testlogger shop
   testlogger stash
   ```

4. **Játékban tesztelés:**
   - Adj át egy itemet másik játékosnak
   - Vásárolj valamit egy boltból
   - Tegyél be/vegyél ki valamit egy stash-ből

## 5. Hibaelhárítás

### Ha nem működnek a webhookok:

1. **Debug mód bekapcsolása:**
   ```cfg
   set inventory_logger:debug 1
   ```

2. **Console üzenetek ellenőrzése:**
   - Keress "OX_INVENTORY_LOGGER" üzeneteket
   - Ellenőrizd a hook regisztrációkat

3. **Webhook URL tesztelése:**
   - Próbáld ki a webhook URL-t külső eszközzel
   - Ellenőrizd, hogy a Discord webhook aktív-e

### Gyakori problémák:

- **"Hook regisztrálása sikertelen"** → ox_inventory verzió probléma
- **"Webhook URL nincs beállítva"** → server.cfg beállítások hiányoznak
- **"Webhook hiba: 404"** → Rossz webhook URL

## 6. Frissítések

A stash webhookok újratöltéséhez (ha módosítottad a stashes.lua-t):
```
reloadstashwebhooks
```

## 7. Támogatott Frameworkök

- ESX
- QBCore/QBX
- OX Core
- ND Framework

A script automatikusan felismeri a használt frameworköt.