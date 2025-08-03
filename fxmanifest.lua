fx_version 'cerulean'
game 'gta5'

author 'CoinShop Script'
description 'ESX Coin System with NPC Shop'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua',
    'client/npc.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'data/products.json'
}

dependencies {
    'es_extended',
    'oxmysql',
    'ox_inventory'
}
