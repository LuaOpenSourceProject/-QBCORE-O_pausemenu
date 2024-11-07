local statistics = {}
--[[ local MySQL = exports.oxmysql
 ]]
--[[ import { oxmysql as MySQL } from '@overextended/oxmysql';
QBCore = exports['qb-core']:GetCoreObject()
local statistics = {}
local driving = 0
local shooting = 0
local condition = 0
local strength = 0


function GetPlayerStatistics()
    local playerData = QBCore.Functions.GetPlayerData()
    local cid = playerData.citizenid
    
    local result = MySQL.query.await('SELECT driving, shooting, condition, strength FROM player_stats WHERE citizenid = ?', {cid})
    
    if result and #result > 0 then
        statistics.driving = result[1].driving or 0
        statistics.shooting = result[1].shooting or 0
        statistics.condition = result[1].condition or 0
        statistics.strength = result[1].strength or 0
    else
        statistics.driving = 0
        statistics.shooting = 0
        statistics.condition = 0
        statistics.strength = 0
    end
end ]]

--[[ function GetPlayerStatistics()
statistics.driving = MySQL.query.await('SELECT driving FROM player_stats WHERE citizenid = ?', {QBCore.Functions.GetPlayerData().citizenid})
statistics.shooting = MySQL.query.await('SELECT shooting FROM player_stats WHERE citizenid = ?', {QBCore.Functions.GetPlayerData().citizenid})
statistics.condition = MySQL.query.await('SELECT condition FROM player_stats WHERE citizenid = ?', {QBCore.Functions.GetPlayerData().citizenid})
statistics.strength = MySQL.query.await('SELECT strength FROM player_stats WHERE citizenid = ?', {QBCore.Functions.GetPlayerData().citizenid})
if statistics.driving == nil then
    statistics.driving = driving
end
if statistics.shooting == nil then
    statistics.shooting = shooting
end
if statistics.condition == nil then
    statistics.condition = condition
end
if statistics.strength == nil then
    statistics.strength = strength
end
end ]]

--[[ 
function GetPlayerStatistics()
    statistics.driving = exports['df_stats']:GetPlayerStat(playerId, 'driving') -- driving -> energy
    statistics.shooting = exports['df_stats']:GetPlayerStat(playerId, 'lung_capacity') --shoting -> swiming
    statistics.condition = exports['df_stats']:GetPlayerStat(playerId, 'stamina') 
    statistics.strenght = exports['df_stats']:GetPlayerStat(playerId, 'strength')
end ]]
local mugshot = ""
function GetPlayerMugShot()
    if Config.UseMugShot then
        mugshot = exports["MugShotBase64"]:GetMugShotBase64(PlayerPedId(), false)
    end
end
function SendNUIData()
    if GetGameTimer() - lastInfoUpdated > 10000 then
        GetPlayerMugShot()
        Wait(100)
--[[         GetPlayerStatistics()
       
        Wait(100)]] 
        updateInfo()
    end
    pInfo = pInfo or {}

    SendNUIMessage({
        action = "OpenMenu",
        mugshot = mugshot,
        Driving = statistics.driving,
        Shooting = statistics.shooting,
        Condition = statistics.condition,
        Strenght = statistics.strenght,
        usersOnline = pInfo.usersOnline or 0,
        maxPlayers = pInfo.maxPlayers or 32,
        name = pInfo.name or "Loading...",
        job = pInfo.job or "Loading...",
        cash = pInfo.cash or 0,
        bank = pInfo.money or 0,
        discord = Config.Discord or "https://discord.gg/origenrp",
        website = Config.Website or "https://www.dfnetwork.in/",
        twitter = Config.Twitter or "https://twitter.com/OrigenNetwork",
        instagram = Config.Instagram or "https://instagram.com/origenrp",
        youtube = Config.Youtube or "https://www.youtube.com/@OrigenNetworkStore",
        PoliceAvailable = pInfo.PoliceAvailable and true or false,
        other = Config.ExtraData
        
    })
end
function ShowNotification(message, type)
    if Config.UseOkokNotify then
        exports['okokNotify']:Alert("Acceso Denegado", message, 5000, type)
    else
        exports["origen_notify"]:ShowNotification(message, type)
    end
end

--[[ 
lib.registerContext({
    id = "menu_paga",
    title = "¿Qué quieres pagar?",
    options = {
        {
           title = "Facturas",
           description = "Pagar facturas de los negocios",
           icon = "barcode",
           iconColor = "f02a",
           onSelect = function()
            exports['origen_masterjob']:ShowBills()
           end
        },
        {
            title = "Multas",
            description = "Pagar multas de la policía",
            icon = "barcode",
            iconColor = "f02a",
            onSelect = function()
             exports['origen_police']:ShowBills()
            end
         },
    }
}) ]]

RegisterNUICallback('facturas', function(data, cb)
    lib.showContext("menu_paga")
end)

RegisterNUICallback('ilegal', function(data, cb)
    if exports["origen_ilegal"]:GetGangID() then
        TriggerEvent("origen_ilegal:OpenGangMenu")
    else 
        ShowNotification("No perteneces a ninguna organización", 'error')
    end
end)

RegisterNUICallback('openmartjobTablet', function(data, cb)
    if Config.Framework == 'esx' or Config.Framework == 'newesx' then
        ESX.TriggerServerCallback('getBusinessIds', function(businessIds)
            local playerData = ESX.GetPlayerData()
            local playerBusinessId = playerData.job and playerData.job.name or nil
            local hasBusiness = false

            for _, id in ipairs(businessIds) do
                if tostring(id) == tostring(playerBusinessId) then
                    hasBusiness = true
                    break
                end
            end

            if hasBusiness then
                TriggerEvent("origen_masterjob:OpenBusinessMenu")
            else
                ShowNotification("No perteneces a ningún negocio", 'error')
            end
            
            cb('ok')
        end)
    elseif Config.Framework == 'oldqb' or Config.Framework == 'newqb' then
        QBCore.Functions.TriggerCallback('getBusinessIds', function(businessIds)
            local PlayerData = QBCore.Functions.GetPlayerData()
            local playerBusinessId = PlayerData.job and PlayerData.job.name or nil
            local hasBusiness = false
            
            for _, id in ipairs(businessIds) do
                if tostring(id) == tostring(playerBusinessId) then
                    hasBusiness = true
                    break
                end
            end
    
            if hasBusiness then
                TriggerEvent("origen_masterjob:OpenBusinessMenu")
            else 
                ShowNotification("No perteneces a ningún negocio", 'error')
            end
            
            cb('ok')
        end)
    else
        cb('error')
    end
end)



function GetPlayerBusinessId()
    if Config.Framework == 'esx' or Config.Framework == 'newesx' then
        local playerData = ESX.GetPlayerData()
        return playerData.job and playerData.job.businessId or nil
    elseif Config.Framework == 'oldqb' or Config.Framework == 'newqb' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        return PlayerData.job and PlayerData.job.businessId or nil
    end
    return nil
end

RegisterNUICallback('openPoliceTablet', function(data, cb)
    if Config.Framework == 'esx' or Config.Framework == 'newesx' then
        local playerData = ESX.GetPlayerData()
        local isOnDutyPolice = false

        for _, jobName in ipairs(Config.serviciosdeemergecia) do
            if playerData.job.name == jobName and playerData.job.grade >= 0 then
                isOnDutyPolice = true
                break
            end
        end

        if isOnDutyPolice then
            TriggerEvent("origen_police:client:OpenPoliceCad")
        else 
            ShowNotification("No tienes el trabajo de policía ni EMS", 'error')
        end

        cb('ok')  
    elseif Config.Framework == 'oldqb' or Config.Framework == 'newqb' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        local isOnDutyPolice = false
    
        for _, jobName in ipairs(Config.serviciosdeemergecia) do
            if PlayerData.job.name == jobName and PlayerData.job.onduty then
                isOnDutyPolice = true
                break
            end
        end
    
        if isOnDutyPolice then
            TriggerEvent("origen_police:client:OpenPoliceCad")
        else 
            ShowNotification("No tienes el trabajo de policía ni EMS", 'error')
        end

        cb('ok') 
    else
        cb('error') 
    end
end)