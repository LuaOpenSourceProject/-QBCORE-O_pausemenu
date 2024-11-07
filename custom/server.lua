local QBCore = nil
local ESX = nil
local Police = 0
local playerCount = 0

if Config.Framework == "newqb" then
    QBCore = Init.NewQBGetSharedObject()
elseif Config.Framework == "oldqb" then
    QBCore = Init.OldQBGetSharedObject()
elseif Config.Framework == "esx" then
    ESX = Init.ESXGetSharedObject()
elseif Config.Framework == "newesx" then
    ESX = Init.NewESXGetSharedObject()
end

function getPolice()
    if Config.Framework == 'esx' or Config.Framework == 'newesx' then
        Police = ESX.GetExtendedPlayers("job", Config.PoliceJobs[1])
	if GetResourceState("origen_police") ~= "missing" then 
        	Police = exports["origen_police"]:GetPlayersInDuty(Config.PoliceJobs[1])
	end
    else
        Police = #(QBCore.Functions.GetPlayersOnDuty(Config.PoliceJobs[1]))
    end
    return Police
end

function getOnlinePlayers()
    if Config.Framework == 'esx' or Config.Framework == 'newesx' then
        playerCount = #(ESX.GetPlayers())
    else
        playerCount = #(QBCore.Functions.GetPlayers())
    end
    return playerCount
end

-- RegisterServerEvent("quitserver")
AddEventHandler("quitserver", function()
    local src = source
	DropPlayer(src, Config.ExitMessage)
end)
if Config.Framework == 'esx' or Config.Framework == 'newesx' then
    ESX.RegisterServerCallback('getBusinessIds', function(source, cb)
        local businesses = exports['origen_masterjob']:GetBusinesses()
        local businessIds = {}
        
        for key, business in pairs(businesses) do
            table.insert(businessIds, business.Data.id)
        end

        cb(businessIds)
    end)
elseif Config.Framework == 'oldqb' or Config.Framework == 'newqb' then
    QBCore.Functions.CreateCallback('getBusinessIds', function(source, cb)
        local businesses = exports['origen_masterjob']:GetBusinesses()
        local businessIds = {}
        
        for key, business in pairs(businesses) do
            table.insert(businessIds, business.Data.id)
        end
    
        cb(businessIds)
    end)
end