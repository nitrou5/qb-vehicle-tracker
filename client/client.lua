local trackedVehicles = {}

lib.locale()

-- Function
local function uiNotify(description, nType)
    lib.notify({description = description, type = nType, position = 'center-right', iconAnimation = 'bounce', duration = 6500})
end

-- Events
RegisterNetEvent('qb_vehicle_tracker:client:manageTracker', function(vehPlate)
    lib.registerContext({
        id = 'vt_menu',
        title = locale('vt_menu_header'),
        options = {
            {title = locale('vt_menu_check_location'), event = 'qb_vehicle_tracker:client:locateTracker', icon = 'eye', args = vehPlate}
        }
    })

    if lib.progressBar({
        duration = 2000,
        label = locale('vt_pb_connecting'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'amb@code_human_in_bus_passenger_idles@female@tablet@base',
            clip = 'base'
        },
        prop = {
            model = `prop_cs_tablet`,
            pos = vec3(0.03, 0.002, -0.0),
            rot = vec3(10.0, 160.0, 0.0)
        },
    }) then lib.showContext('vt_menu') else uiNotify(locale('vt_pb_cancelled'), 'error') end
end)


RegisterNetEvent('qb_vehicle_tracker:client:scanTracker', function(slot)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, true)
    
    if vehicle == nil or not DoesEntityExist(vehicle) then return uiNotify(locale('vt_no_vehicle_nearby'), 'error') end

    if lib.progressBar({
        duration = 6000,
        label = locale('vt_pb_scanning'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'amb@code_human_in_bus_passenger_idles@female@tablet@base',
            clip = 'base'
        },
        prop = {
            model = `prop_cs_tablet`,
            pos = vec3(0.03, 0.002, -0.0),
            rot = vec3(10.0, 160.0, 0.0)
        },
    }) then
        lib.callback('qb_vehicle_tracker:server:getTrackedVehicle', false, function(veh)
            if veh == nil then return uiNotify(locale('vt_no_tracker'), 'info') end

            TriggerServerEvent('InteractSound_SV:PlayOnSource', 'panicbutton', 0.2)

            local alert = lib.alertDialog({
                header = locale('vt_alert_title'),
                content = locale('vt_alert_description'),
                centered = true,
                cancel = true
            })

            if alert == 'confirm' then
                TriggerEvent('qb_vehicle_tracker:client:removeTracker', slot)
            end
        end, lib.getVehicleProperties(vehicle).plate)
    else
        uiNotify(locale('vt_pb_cancelled'), 'error')
    end
end)

RegisterNetEvent('qb_vehicle_tracker:client:placeTracker', function(slot)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, true)
    
    if vehicle == nil or not DoesEntityExist(vehicle) then return uiNotify(locale('vt_no_vehicle_nearby'), 'error') end

    if lib.progressBar({
        duration = 6000,
        label = locale('vt_pb_placing'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'mp_car_bomb',
            clip = 'car_bomb_mechanic'
        }
    }) then
        TriggerServerEvent('qb_vehicle_tracker:server:placeTracker', NetworkGetNetworkIdFromEntity(vehicle), lib.getVehicleProperties(vehicle).plate, slot)
        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'Clothes1', 0.2)
        uiNotify(locale('vt_placed_success'), 'success')
    else
        uiNotify(locale('vt_pb_cancelled'), 'error')
    end
end)

RegisterNetEvent('qb_vehicle_tracker:client:removeTracker', function(slot)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, true)
    
    if vehicle == nil or not DoesEntityExist(vehicle) then return uiNotify(locale('vt_no_vehicle_nearby'), 'error') end

    local vehPlate = lib.getVehicleProperties(vehicle).plate

    lib.callback('qb_vehicle_tracker:server:getTrackedVehicle', false, function(veh)
        if veh == nil then return uiNotify(locale('vt_no_tracker'), 'info') end

        if lib.progressBar({
            duration = 6000,
            label = locale('vt_pb_removing'),
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true
            },
            anim = {
                dict = 'mp_car_bomb',
                clip = 'car_bomb_mechanic'
            }
        }) then
            if trackedVehicles[vehPlate] then
                RemoveBlip(trackedVehicles[vehPlate])

                trackedVehicles[vehPlate] = nil
            end

            TriggerServerEvent('qb_vehicle_tracker:server:removeTracker', vehPlate, slot)
            TriggerServerEvent('InteractSound_SV:PlayOnSource', 'metaldetector', 0.2)
            uiNotify(locale('vt_remove_success'), 'success')
        else
            uiNotify(locale('vt_pb_cancelled'), 'error')
        end
    end, vehPlate)

end)

RegisterNetEvent('qb_vehicle_tracker:client:locateTracker', function(vehPlate)
    if vehPlate == nil then return uiNotify(locale('vt_not_placed'), 'error') end

    lib.callback('qb_vehicle_tracker:server:getTrackedVehicle', false, function(veh, vehCoords)
        if veh == nil then return uiNotify(locale('vt_unable_connect'), 'error') end

        local blip = AddBlipForCoord(vehCoords.x , vehCoords.y, 0.0)

        SetBlipSprite(blip, 161)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 250)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, 2.5)
        PulseBlip(blip)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Tracker ' .. vehPlate)
        EndTextCommandSetBlipName(blip)

        trackedVehicles[vehPlate] = blip

        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'robberysound', 0.2)
        uiNotify(locale('vt_connection_success'), 'success')

    end, vehPlate)
end)

CreateThread(function()
    while true do
        Wait(3000)
        for vehPlate, blip in pairs(trackedVehicles) do
            if GetBlipAlpha(blip) > 0 then
                SetBlipAlpha(blip, GetBlipAlpha(blip) - 10)
            else
                trackedVehicles[vehPlate] = nil
                RemoveBlip(blip)
            end
        end
    end
end)