local trackedVehicles = {}

lib.locale()

-- Function
local function uiNotify(description, nType)
    lib.notify({description = description, type = nType, position = 'center-right', iconAnimation = 'bounce', duration = 6500})
end

-- Events
RegisterNetEvent('qb_vehicle_tracker:client:manageTracker', function(serialNumber)
    lib.registerContext({
        id = 'vt_menu',
        title = locale('vt_menu_header'),
        options = {
            {
                title = locale('vt_menu_check_location'),
                event = 'qb_vehicle_tracker:client:locateTracker',
                icon = 'eye',
                args = serialNumber
            }
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
        lib.callback('qb_vehicle_tracker:server:isVehicleTracked', false, function(veh)
            if veh == nil then return uiNotify(locale('vt_no_tracker'), 'info') end

            TriggerEvent('InteractSound_CL:PlayOnOne', 'metaldetected', 0.3)

            local alert = lib.alertDialog({
                header = locale('vt_alert_title'),
                content = locale('vt_alert_description'),
                centered = true,
                cancel = true
            })

            if alert == 'confirm' then
                TriggerEvent('qb_vehicle_tracker:client:removeTracker', slot)
            end
        end, GetVehicleNumberPlateText(vehicle))
    else
        uiNotify(locale('vt_pb_cancelled'), 'error')
    end
end)

RegisterNetEvent('qb_vehicle_tracker:client:placeTracker', function(slot, serialNumber)
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
        TriggerServerEvent('qb_vehicle_tracker:server:placeTracker',
                            NetworkGetNetworkIdFromEntity(vehicle), GetVehicleNumberPlateText(vehicle),
                            slot, serialNumber)
        TriggerEvent('InteractSound_CL:PlayOnOne', 'Clothes1', 0.3)
        uiNotify(locale('vt_placed_success'), 'success')
    else
        uiNotify(locale('vt_pb_cancelled'), 'error')
    end
end)

RegisterNetEvent('qb_vehicle_tracker:client:removeTracker', function(slot)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, true)

    if vehicle == nil or not DoesEntityExist(vehicle) then return uiNotify(locale('vt_no_vehicle_nearby'), 'error') end

    local vehPlate = GetVehicleNumberPlateText(vehicle)

    lib.callback('qb_vehicle_tracker:server:isVehicleTracked', false, function(veh)
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
            if trackedVehicles[veh.serialNumber] then
                RemoveBlip(trackedVehicles[veh.serialNumber])

                trackedVehicles[veh.serialNumber] = nil
            end

            TriggerServerEvent('qb_vehicle_tracker:server:removeTracker', vehPlate, slot)
            TriggerEvent('InteractSound_CL:PlayOnOne', 'metaldetector', 0.3)
            uiNotify(locale('vt_remove_success'), 'success')
        else
            uiNotify(locale('vt_pb_cancelled'), 'error')
        end
    end, vehPlate)

end)

RegisterNetEvent('qb_vehicle_tracker:client:locateTracker', function(serialNumber)
    if serialNumber == nil then return uiNotify(locale('vt_not_placed'), 'error') end

    lib.callback('qb_vehicle_tracker:server:getTrackedVehicleBySerial', false, function(veh, vehCoords)
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
        AddTextComponentSubstringPlayerName('Tracker ' .. veh)
        EndTextCommandSetBlipName(blip)

        trackedVehicles[serialNumber] = blip

        TriggerEvent('InteractSound_CL:PlayOnOne', 'monkeyopening', 0.3)
        uiNotify(locale('vt_connection_success'), 'success')

    end, serialNumber)
end)

CreateThread(function()
    while true do
        Wait(3000)
        for serialNumber, blip in pairs(trackedVehicles) do
            if GetBlipAlpha(blip) > 0 then
                SetBlipAlpha(blip, GetBlipAlpha(blip) - 10)
            else
                trackedVehicles[serialNumber] = nil
                RemoveBlip(blip)
            end
        end
    end
end)