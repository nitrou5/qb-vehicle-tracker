local trackedVehicles = {}

lib.locale()

-- Functions
local function uiNotify(description, nType)
    lib.notify({description = description, type = nType, position = 'center-right', iconAnimation = 'bounce', duration = 7000})
end

local function uiProgressBar(duration, label, anim, prop)
    return lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = true,
            disable = { car = true, move = true, combat = true },
            anim = anim,
            prop = prop
    })
end

local function playSound(audioName, audioDict)
    local soundId = GetSoundId()
    PlaySoundFrontend(soundId, audioName, audioDict, false)
    SetTimeout(3000, function()
        StopSound(soundId)
        ReleaseSoundId(soundId)
    end)
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

    if uiProgressBar(2000, locale('vt_pb_connecting'), {
        dict = 'amb@code_human_in_bus_passenger_idles@female@tablet@base',
        clip = 'base'
    }, {
        model = `prop_cs_tablet`,
        pos = vec3(0.03, 0.002, -0.0),
        rot = vec3(10.0, 160.0, 0.0)
    }) then lib.showContext('vt_menu') else uiNotify(locale('vt_pb_cancelled'), 'error') end
end)

RegisterNetEvent('qb_vehicle_tracker:client:scanTracker', function(slot)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, true)
    if vehicle == nil or not DoesEntityExist(vehicle) then uiNotify(locale('vt_no_vehicle_nearby'), 'error') return end

    if uiProgressBar(6000, locale('vt_pb_scanning'), {
        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        clip = 'machinic_loop_mechandplayer',
        flag = 1
    }, {
        model = `w_am_digiscanner`,
        pos = vec3(0.06, 0.03, -0.1),
        rot = vec3(10.0, 190.0, 0.0)
    }) then
        lib.callback('qb_vehicle_tracker:isVehicleTracked', false, function(veh)
            if veh == nil then uiNotify(locale('vt_no_tracker'), 'info') return end

            playSound('TIMER_STOP', 'HUD_MINI_GAME_SOUNDSET')

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
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 2.5, true)
    if vehicle == nil or not DoesEntityExist(vehicle) then uiNotify(locale('vt_no_vehicle_nearby'), 'error') return end

    if uiProgressBar(6000, locale('vt_pb_placing'), {
        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        clip = 'machinic_loop_mechandplayer',
        flag = 1
    }, {
        model = `prop_prototype_minibomb`,
        pos = vec3(0.1, 0.03, -0.0),
        rot = vec3(10.0, 160.0, 0.0)
    }) then
        lib.callback('qb_vehicle_tracker:placeTracker', false, function(success)
            if not success then return end
            playSound('Hack_Success', 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS')
            uiNotify(locale('vt_placed_success'), 'success')
        end, GetVehicleNumberPlateText(vehicle), slot, serialNumber)
    else
        uiNotify(locale('vt_pb_cancelled'), 'error')
    end
end)

RegisterNetEvent('qb_vehicle_tracker:client:removeTracker', function(slot)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, true)
    if vehicle == nil or not DoesEntityExist(vehicle) then uiNotify(locale('vt_no_vehicle_nearby'), 'error') return end

    local vehPlate = GetVehicleNumberPlateText(vehicle)

    lib.callback('qb_vehicle_tracker:isVehicleTracked', false, function(veh)
        if veh == nil then return uiNotify(locale('vt_no_tracker'), 'info') end
        if uiProgressBar(6000, locale('vt_pb_removing'), {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            clip = 'machinic_loop_mechandplayer',
            flag = 1
        }, {}) then
            lib.callback('qb_vehicle_tracker:removeTracker', false, function(success)
                if not success then return end

                if trackedVehicles[veh.serialNumber] then
                    RemoveBlip(trackedVehicles[veh.serialNumber])

                    trackedVehicles[veh.serialNumber] = nil
                end

                playSound('Hack_Success', 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS')
                uiNotify(locale('vt_remove_success'), 'success')
            end, vehPlate, slot)
        else
            uiNotify(locale('vt_pb_cancelled'), 'error')
        end
    end, vehPlate)

end)

RegisterNetEvent('qb_vehicle_tracker:client:locateTracker', function(serialNumber)
    if serialNumber == nil then uiNotify(locale('vt_not_placed'), 'error') return end

    lib.callback('qb_vehicle_tracker:getTrackedVehicleBySerial', false, function(veh, vehCoords)
        if veh == nil then uiNotify(locale('vt_unable_connect'), 'error') return end

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
        SetNewWaypoint(vehCoords.x , vehCoords.y)

        trackedVehicles[serialNumber] = blip

        playSound('10_SEC_WARNING', 'HUD_MINI_GAME_SOUNDSET')
        uiNotify(locale('vt_connection_success'), 'success')
    end, serialNumber)
end)

CreateThread(function()
    while true do
        Wait(3000)
        for serialNumber, blip in pairs(trackedVehicles) do
            local blipAlpha = GetBlipAlpha(blip)
            if blipAlpha > 0 then
                SetBlipAlpha(blip, blipAlpha - 10)
            else
                trackedVehicles[serialNumber] = nil
                RemoveBlip(blip)
            end
        end
    end
end)