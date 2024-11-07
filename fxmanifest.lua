lua54 "yes"

fx_version 'cerulean'
games { 'gta5' }

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    --[[ '@oxmysql/lib/MySQL.lua',
    "@ox_lib/init.lua", ]]
    'client/*.lua',
    'custom/client.lua',
    'custom/server.lua'
}
server_scripts {
    'server/*.lua'
}

ui_page 'html/ui.html'

files {
    'html/css/*.css',
    'html/js/*.js',
    'html/**/*.png',
    'html/sounds/*.mp3',
    'html/sounds/*.wav',
    'html/sounds/*.ogg',
    'html/ui.html'
}
