local QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent("pausemenu:server")
AddEventHandler("pausemenu:server", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src) -- QB
    local job = Player.PlayerData.job.name -- QB
    local money = Player.PlayerData.money["cash"] -- QB
    local bank = Player.PlayerData.money["bank"] -- QB
    local name = Player.PlayerData.charinfo.firstname.. " " ..Player.PlayerData.charinfo.lastname -- QB
    local players = #GetPlayers()
    local maxPlayers = GetConvarInt('sv_maxclients', 32)
    local police = Config.PoliceOnline
    local ems = Config.EMSOnline

    TriggerClientEvent("pausemenu:client", src, {name=name, job=job, cash=money, bank=bank, players=players, max=maxPlayers, police=police, ems=ems})
end)

RegisterServerEvent('salir')
AddEventHandler('salir', function()
    DropPlayer(source, "¡Te fuiste del servidor!")
end) 

if Config.Framework == 'oldqb' or Config.Framework == 'newqb' then
    QBCore.Functions.CreateCallback('getBusinessIds', function(source, cb)
        local businesses = exports['origen_masterjob']:GetBusinesses()
        local businessIds = {}
        
        for key, business in pairs(businesses) do
            table.insert(businessIds, business.Data.id)
        end
    
        cb(businessIds)
    end)
end