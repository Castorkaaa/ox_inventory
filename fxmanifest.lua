fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ox_inventory_logger'
author 'Custom Logger'
version '1.0.0'
description 'Discord webhook logger for ox_inventory'

dependencies {
    'ox_inventory',
    'ox_lib'
}

shared_script '@ox_lib/init.lua'

server_scripts {
    'config.lua',
    'server/logger.lua',
    'server/hooks.lua'
}

client_script 'client/client.lua'