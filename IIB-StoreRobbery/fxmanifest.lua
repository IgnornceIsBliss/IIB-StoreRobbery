fx_version 'cerulean'
game 'gta5'

description 'IIB-StoreRobbery'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}