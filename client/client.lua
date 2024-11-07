local QBCore = exports['qb-core']:GetCoreObject()
local PlayerProps = {}

function startAnim(lib, anim)
    RequestAnimDict(lib)
    while not HasAnimDictLoaded(lib) do
        Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), lib, anim, 2.0, 2.0, -1, 51, 0.0, false, false, false)
end

function AddPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3)
    local Player = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(Player))

    if not HasModelLoaded(prop1) then
        LoadPropDict(prop1)
    end

    local prop = CreateObject(GetHashKey(prop1), x, y, z + 0.2, true, true, true)
    AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
    table.insert(PlayerProps, prop)
    SetModelAsNoLongerNeeded(prop1)
end

function EmoteCancel()
    ClearPedTasks(GetPlayerPed(-1))
    DestroyAllProps()
end

function DestroyAllProps()
    for _, v in pairs(PlayerProps) do
        DeleteEntity(v)
    end
end

function LoadPropDict(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Wait(10)
    end
end

CreateThread(function()
    while true do
        Wait(0)
        SetPauseMenuActive(false)
        if IsControlJustPressed(0, 200) and not IsPauseMenuActive() and not IsNuiFocused() then
            TransitionToBlurred(1000)
            SetNuiFocus(true, true)
            TriggerServerEvent("pausemenu:server")
            startAnim('amb@code_human_in_bus_passenger_idles@female@tablet@idle_a', 'idle_a')
        end
    end
end)

function ClosePause()
    EmoteCancel()
    TransitionFromBlurred(1000)
    SetNuiFocus(false, false)
end

RegisterNUICallback('closeMenu', function(data)
    ClosePause()
end)

RegisterNUICallback('openSettings', function(data)
    ClosePause()
    ActivateFrontendMenu('FE_MENU_VERSION_LANDING_MENU', 0, 1)
end)

RegisterNUICallback('openMap', function(data)
    ClosePause()
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_MP_PAUSE'), 0, -1)
end)

RegisterNUICallback('exitGame', function(data)
    TriggerServerEvent('salir')
end)

RegisterNUICallback('paybill', function(data, cb)
    data.id = tonumber(data.id)
    data.price = tonumber(data.price)
    local billId = data.id
    local job = data.job
    local price = data.price

    if data.job == "notjobjobjobjob" then
        QBCore.Functions.TriggerCallback('qb-billing:payBill', function(cal)
            cb(cal)
        end, data.id)
    elseif data.job == "police" then
        exports['origen_police']:ShowBills()
        exports['okokBilling']:ToggleMyInvoices()
        cb(true)
    else
        exports['origen_masterjob']:ShowBills()
        exports['okokBilling']:ToggleMyInvoices()
        cb(true)
    end
end)

RegisterNUICallback('facturas', function(data, cb)
    local masterjob = GetResourceState("origen_masterjob")
    local police = GetResourceState("origen_police")
    local elements = {}

    QBCore.Functions.TriggerCallback('qb-billing:getBills', function(bills)
        if #bills > 0 then
            for _, v in ipairs(bills) do
                elements[#elements + 1] = {
                    title = v.label,
                    price = QBCore.Functions.Math.GroupDigits(v.amount),
                    billId = v.id,
                    job = "notjobjobjobjob"
                }
            end
        end
    end)

    if masterjob == "started" then
        local canopenmenu1 = false
        QBCore.Functions.TriggerCallback("origen_masterjob:server:GetBills", function(bills)
            for i = 1, #bills do
                elements[#elements + 1] = {
                    title = bills[i].title,
                    billId = bills[i].id,
                    price = bills[i].price,
                    job = bills[i].job
                }
            end
            canopenmenu1 = true
        end)
        while not canopenmenu1 do
            Wait(0)
        end
    end

    if police == "started" then
        local canopenmenu2 = false
        QBCore.Functions.TriggerCallback("origen_police:server:GetBills", function(bills)
            for i = 1, #bills do
                elements[#elements + 1] = {
                    title = bills[i].title,
                    billId = bills[i].id,
                    price = bills[i].price,
                    job = "police"
                }
            end
            canopenmenu2 = true
        end)
        while not canopenmenu2 do
            Wait(0)
        end
    end

    Wait(200)
    cb(elements)
end)

RegisterNUICallback('negocios', function(data, cb)
    local negocios = {}
    for k, v in pairs(Config.Negocios) do
        negocios[#negocios + 1] = {
            label = v.label,
            coords = v.coords,
            open = v.open
        }
    end
    cb(negocios)
end)

RegisterNUICallback("SetWaypointinCoords", function(data, cb)
    SetNewWaypoint(data.x, data.y)
    QBCore.Functions.Notify("Se asignó un nuevo marcador en el mapa", 'success')
end)

RegisterNetEvent("origen_notify:business", function(data)
    Config.Negocios[data.job]['open'] = data.value
end)
local mugshot = ""
function GetPlayerMugShot()
    if Config.UseMugShot then
        mugshot = exports["MugShotBase64"]:GetMugShotBase64(PlayerPedId(), false)
    end
    if GetGameTimer() - lastInfoUpdated > 10000 then
        GetPlayerMugShot()
        Wait(100)
        updateInfo()
    end
end

--[[ function SendNUIData()
    if GetGameTimer() - lastInfoUpdated > 10000 then
        GetPlayerMugShot()
        Wait(100)
        updateInfo()
    end ]]

RegisterNetEvent("pausemenu:client", function(data)
    SendNUIMessage({
        action = "OpenMenu",
        mugshot = exports["MugShotBase64"]:GetMugShotBase64(PlayerPedId(), false),
        name = data.name,
        job = data.job,
        cash = data.cash,
        bank = data.bank,
        discord = Config.Discord,
        instagram = Config.Instagram,
        twitter = Config.Twitter,
        youtube = Config.Youtube,
        website = Config.Website,
        usersOnline = data.players,
        maxPlayers = data.max,
        police = data.police,
        ems = data.ems,
    })
end)

RegisterNetEvent("pausemenu:updatejobs", function(data)
    SendNUIMessage({
        action = "updatejobs",
        police = data.police,
        ems = data.ems,
    })
end)

RegisterNUICallback('PlayerId', function(_, cb)
    local serverId = GetPlayerServerId(PlayerId())
    cb(serverId)
end)

function ShowNotification(message, type)
    if Config.UseOkokNotify then
        exports['okokNotify']:Alert("Acceso Denegado", message, 5000, type)
    else
        exports["origen_notify"]:ShowNotification(message, type)
    end
end

RegisterNUICallback('ilegal', function(data, cb)
    if exports["origen_ilegal"]:GetGangID() then
        TriggerEvent("origen_ilegal:OpenGangMenu")
    else 
        ShowNotification("No perteneces a ninguna organización", 'error')
    end
    cb('ok')
end)

RegisterNUICallback('OpenHouses', function(data)
    ClosePause()
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_KEYMAPPING_MENU'), 0, -1)
end)

RegisterNUICallback('openmartjobTablet', function(data, cb)
    if Config.Framework == 'qb' then
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
        ShowNotification("No perteneces a ningún negocio", 'error')
        cb('error')
    end
end)

RegisterNUICallback('openmartcrewTablet', function(data, cb)
    local gangID = exports["origen_ilegal"]:GetGangID() 
    if gangID then
        local crew = {}
        for k, v in pairs(Config.crewTable) do
            crew[#crew + 1] = {
                crewname = v.crew,
            }
        end
        cb(crew)
        local isInCrew = false
        for _, v in ipairs(crew) do
            if gangID == v.crewname then
                isInCrew = true
                break
            end
        end
        if isInCrew then
            exports['rahe-racing']:openTablet() 
        else 
            ShowNotification("No perteneces a ninguna crew", 'error')
        end
    else
        ShowNotification("No perteneces a ninguna crew", 'error')
    end
end)
function GetPlayerBusinessId()
    local PlayerData = QBCore.Functions.GetPlayerData()
    return PlayerData.job and PlayerData.job.businessId or nil
end

RegisterNUICallback('openPoliceTablet', function(data, cb)
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
        cb('ok')
    else
        ShowNotification("No tienes el trabajo de policía ni EMS", 'error')
        cb('error')
    end
end)


RegisterNUICallback('propiedades', function(data, cb)
    -- Intenta abrir el menú de propiedades
    exports['origen_housing']:OpenHouseMenu() 

    -- Muestra una notificación si el jugador no tiene casas
    if not exports['origen_housing']:getPlayerHouses(identifier) then
        ShowNotification("No tienes ninguna propiedad", 'error') 
    end

    cb('ok') -- Responde al frontend
end)