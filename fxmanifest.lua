fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name 'qb-vehicle-tracker'
repository 'https://github.com/nitrou5/qb-vehicle-tracker'
description 'a Vehicle GPS Tracker resource for FiveM'
version '0.1.0'
author 'nitrou5'

shared_script '@ox_lib/init.lua'

client_script 'client/client.lua'

server_script 'server/server.lua'

files {
    'config.lua',
    'locales/*.json'
}