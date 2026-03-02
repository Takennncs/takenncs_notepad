fx_version 'cerulean'
game 'gta5'

author 'Takenncs'
description 'Takenncs Notepad'
version '1.0.0'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'oxmysql'
}

lua54 'yes'