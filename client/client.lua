-- Client oldali script (jelenleg nincs szükség rá, de a jövőben bővíthető)

if not lib then return end

-- Itt lehetne client oldali logolást is csinálni, ha szükséges
-- Például UI interakciók, stb.

CreateThread(function()
    Wait(1000)
    print('^2[OX_INVENTORY_LOGGER] Client oldal betöltve!^0')
end)